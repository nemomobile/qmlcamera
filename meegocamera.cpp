#include "meegocamera.h"

#include <fcntl.h>
#include <syslog.h>
#include <errno.h>
#include <iostream>

#include <sys/socket.h>
#include <sys/stat.h>
#include <QFile>



#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeEngine>
#include <QGraphicsObject>
#include <QDeclarativeContext>
#include <QtOpenGL/QGLWidget>
#include <QKeyEvent>


#define GPIO_KEYS "/dev/input/gpio-keys"


MeegoCamera::MeegoCamera(bool visible): QObject(),
    m_uiVisible(visible),
    m_gpioFile(-1),
    m_gpioNotifier(0),
    m_server(0),
    m_connections(0),
    m_view(0)
{
    m_server = new QLocalServer(this);
    if (!connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()))) {
        //std::cout << "Failed to connect the newConnection signal  ()" << std::endl;
    }
    cleanSocket();

    if (!m_server->listen(SERVER_NAME)) {
         //std::cout << "Failed to listen incoming connections on()" << std::endl;
    }


    m_gpioFile = open(GPIO_KEYS, O_RDONLY | O_NONBLOCK);
    if (m_gpioFile != -1) {
        m_gpioNotifier = new QSocketNotifier(m_gpioFile, QSocketNotifier::Read);
        connect(m_gpioNotifier, SIGNAL(activated(int)), this, SLOT(didReceiveKeyEventFromFile(int)));
    } else {
        //std::cout << "could not open m_gpioFile " << std::endl;
        m_gpioNotifier = 0;
    }

    m_volumeKeyResource = new ResourcePolicy::ResourceSet("camera", this);
    m_volumeKeyResource->setAlwaysReply();
    // No need to connect resourcesGranted() or lostResources() signals for now.
    // Camera UI will be started even if ScaleButtonResource resource is not granted.

    ResourcePolicy::ScaleButtonResource *volumeKeys = new ResourcePolicy::ScaleButtonResource;
    m_volumeKeyResource->addResourceObject(volumeKeys);

    m_coverState = !getSwitchState(m_gpioFile, 9);

    if (m_uiVisible)
        showUI(true);
}

MeegoCamera::~MeegoCamera()
{
    //std::cout << ">~GpioKeysListener()" <<   std::endl;
    m_volumeKeyResource->release();

    if (m_view)
        delete m_view;

    m_view = 0;

    m_server->close();
    delete m_server;
    m_server = 0;
    closelog();


    if (m_gpioFile != -1) {
        close(m_gpioFile);
        m_gpioFile = -1;
        delete m_gpioNotifier;
        m_gpioNotifier = 0;
    }
    //std::cout << "<~GpioKeysListener()" <<   std::endl;
}


bool MeegoCamera::createCamera()
{
    if (!m_view) {
        const QString mainQmlApp = QLatin1String("qrc:/declarative-camera.qml");

        m_view = new QDeclarativeView;
        m_view->setAttribute(Qt::WA_DeleteOnClose, true);
        m_view->setViewport(new QGLWidget);
        m_view->rootContext()->setContextProperty("settings", &m_settings);
        m_view->rootContext()->setProperty("lensCoverStatus", m_coverState);
        m_view->setSource(QUrl(mainQmlApp));
        m_view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
        // Qt.quit() called in embedded .qml by default only emits
        // quit() signal, so do this (optionally use Qt.exit()).
        QObject::connect(m_view->engine(), SIGNAL(quit()), this, SIGNAL(quit()));
        // QObject::connect(view.engine(), SIGNAL(()), qApp, SLOT(quit()));
        m_view->setGeometry(QRect(0, 0, 800, 480));

    }

    return true;
}



/* Called when we get an input event from a file descriptor. */
void MeegoCamera::didReceiveKeyEventFromFile(int fd)
{
    //std::cout << ">didReceiveKeyEventFromFile" <<   std::endl;
    for (;;) {
        struct input_event ev;
        memset(&ev, 0, sizeof(ev));
        int ret = read(fd, &ev, sizeof(ev));

        if (ret <= 0)
            break;

        if (ret == sizeof(ev) )
            HandleGpioKeyEvent(ev);
    }
    //std::cout << "<didReceiveKeyEventFromFile" <<   std::endl;
}

void MeegoCamera::HandleGpioKeyEvent(struct input_event &ev)
{
    //std::cout << ">HandleGpioKeyEvent()" <<   std::endl;
    if (ev.code == 528) {
        if ( m_uiVisible) {
            if ( ev.value == 1 ) {
                //std::cout << "Half Press Pressed" <<  ev.code  << " ev.value" <<  ev.value << std::endl;
                QApplication::postEvent(m_view,
                        new QKeyEvent(QEvent::KeyPress,
                        Qt::Key_CameraFocus,
                        Qt::NoModifier));
            }
            if ( ev.value == 0 ) {
                //std::cout << "Half Press released" <<  ev.code  << " ev.value" <<  ev.value << std::endl;
                QApplication::postEvent(m_view,
                        new QKeyEvent(QEvent::KeyRelease,
                        Qt::Key_CameraFocus,
                        Qt::NoModifier));
            }
        }
    } else if (ev.code == 212 && ev.value == 1 ) {
        // Check if UI is running and show it if not
        showUI(true);
        //std::cout << "Full Press" << ev.code  << " ev.value" <<  ev.value<< std::endl;
    } else if ((ev.code == 9 && ev.value == 0) ) {
        m_coverState = true;
        // Check if UI is running and show it if not
        showUI(true);
        //std::cout << "Cover opened" << ev.code  << " ev.value" <<  ev.value<< std::endl;
    } else if (ev.code == 9 && ev.value == 1) {
        m_coverState = false;
        showUI(false);
        //std::cout << "Cover close " << ev.code  << " ev.value" <<  ev.value << std::endl;
    }

    //std::cout << "<HandleGpioKeyEvent" <<   std::endl;
}


void MeegoCamera::hideUI()
{
    showUI(false);
}

void MeegoCamera::showUI(bool show)
{
    //std::cout << ">showUI " << show  << std::endl;
    if (show) {
        m_volumeKeyResource->acquire();
        createCamera();

        m_view->showFullScreen();
        m_view->rootObject()->setVisible(true);
        m_uiVisible = true;
    } else {
        m_volumeKeyResource->release();
        if(m_view) {
            //std::cout << "hide" << std::endl;
            m_view->close();
            m_view = 0;
        }

        m_uiVisible = false;
        //std::cout << "hide" << std::endl;
    }
    //std::cout << "<showUI " << std::endl;
}

void MeegoCamera::newConnection()
{
    while (m_server->hasPendingConnections()) {
        showUI(true);
        QLocalSocket *socket = m_server->nextPendingConnection();
        connect(socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
        m_connections.push_back(socket);
    }
}

void MeegoCamera::disconnected()
{
    QLocalSocket *socket = qobject_cast<QLocalSocket*>(sender());
    for (QVector<QLocalSocket*>::iterator it = m_connections.begin(); it != m_connections.end(); it++) {
        if (*it == socket) {
            m_connections.erase(it);
            break;
        }
    }
    socket->deleteLater();
}

void MeegoCamera::cleanSocket()
{
    std::cout << "cleanSocket()" << std::endl;
    QFile serverSocket(SERVER_NAME);
    if (serverSocket.exists()) {
        std::cout << "serverSocket.exists()" << std::endl;
        /* If a socket exists but we fail to delete it, it can be a sign of a potential
         * race condition. Therefore, exit the process as it is a critical failure.
         */
        if (!serverSocket.remove()) {
            syslog(LOG_CRIT, "Could not clean the existing socket %s, exit\n", SERVER_NAME);
            QCoreApplication::exit(1);
        }
    }
}

bool MeegoCamera::getSwitchState(int fd, int key)
{
    uint8_t keys[SW_MAX/8 + 1];
    memset(keys, 0, sizeof *keys);
    ioctl(fd, EVIOCGSW(sizeof(keys)), keys);
    return !!(keys[key/8] & (1 << (key % 8)));
}

