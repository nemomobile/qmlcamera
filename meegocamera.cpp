#include "meegocamera.h"

#include <fcntl.h>
#include <syslog.h>
#include <errno.h>
//#include <iostream>

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

    connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()));

    cleanSocket();

    m_server->listen(SERVER_NAME);

    m_gpioFile = open(GPIO_KEYS, O_RDONLY | O_NONBLOCK);
    if (m_gpioFile != -1) {
        m_gpioNotifier = new QSocketNotifier(m_gpioFile, QSocketNotifier::Read);
        connect(m_gpioNotifier, SIGNAL(activated(int)), this, SLOT(didReceiveKeyEventFromFile(int)));
    } else {
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
}


void MeegoCamera::createCamera()
{
    if (!m_view) {
        //qDebug() << Q_FUNC_INFO << "new UI created";

        const QString mainQmlApp = QLatin1String("qrc:/declarative-camera.qml");

        m_view = new QDeclarativeView;
        m_view->setAttribute(Qt::WA_DeleteOnClose, true);
        m_view->setViewport(new QGLWidget);

        m_view->rootContext()->setContextProperty("settings", &m_settings);
        m_view->rootContext()->setContextProperty("mainWindow", m_view);

        m_view->setSource(QUrl(mainQmlApp));

        //m_view->rootObject()->setProperty("lensCoverStatus",m_coverState);

        m_view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
        // Qt.quit() called in embedded .qml by default only emits
        // quit() signal, so do this (optionally use Qt.exit()).
        QObject::connect(m_view->engine(), SIGNAL(quit()), this, SIGNAL(quit()));
        // QObject::connect(view.engine(), SIGNAL(()), qApp, SLOT(quit()));
        m_view->setGeometry(QRect(0, 0, 800, 480));
        m_view->installEventFilter(this);

        //qDebug() << Q_FUNC_INFO << "new UI ready";
    }
}



/* Called when we get an input event from a file descriptor. */
void MeegoCamera::didReceiveKeyEventFromFile(int fd)
{
    for (;;) {
        struct input_event ev;
        memset(&ev, 0, sizeof(ev));
        int ret = read(fd, &ev, sizeof(ev));

        if (ret <= 0)
            break;

        if (ret == sizeof(ev) )
            HandleGpioKeyEvent(ev);
    }
}

void MeegoCamera::HandleGpioKeyEvent(struct input_event &ev)
{
    if (ev.code == 528) { // Focus button state changed
        if ( m_uiVisible) {
            if ( ev.value == 1 ) { // Focus button down
                QApplication::postEvent(m_view,
                        new QKeyEvent(QEvent::KeyPress,
                        Qt::Key_CameraFocus,
                        Qt::NoModifier));
            }
            if ( ev.value == 0 ) { // Focus button up
                QApplication::postEvent(m_view,
                        new QKeyEvent(QEvent::KeyRelease,
                        Qt::Key_CameraFocus,
                        Qt::NoModifier));
            }
        }
    } else if (ev.code == 212 && ev.value == 1 ) { // Camera button pressed
        // Check if UI is running and show it if not
        showUI(true);
    } else if ((ev.code == 9 && ev.value == 0) ) { // Lens cover opened
        // Check if UI is running and show it if not
        m_coverState = true;
        showUI(true);
        //m_view->rootObject()->setProperty("lensCoverStatus",true);
    } else if (ev.code == 9 && ev.value == 1) { // Lens cover closed
        m_coverState = false;
        m_view->rootObject()->setProperty("lensCoverStatus",false);
        showUI(false);
    }
}

void MeegoCamera::showUI(bool show)
{
    if (show) {
        //qDebug() << Q_FUNC_INFO << "show ->";
        m_volumeKeyResource->acquire();
        createCamera();

        //qDebug() << Q_FUNC_INFO << "show: camera created";

        m_view->rootObject()->setProperty("lensCoverStatus",m_coverState);
        m_view->showFullScreen();

        //qDebug() << Q_FUNC_INFO << "show: UI shown";

        m_view->rootObject()->setVisible(true);
        m_view->rootObject()->setProperty("active",true);
        m_uiVisible = true;
        //qDebug() << Q_FUNC_INFO << "show <-";
    } else {
        //qDebug() << Q_FUNC_INFO << "hide ->";
        m_volumeKeyResource->release();
        if(m_view) {
            //qDebug() << Q_FUNC_INFO << "hide";
            m_view->close();
            //qDebug() << Q_FUNC_INFO << "hide: view closed";
            m_view = 0;
        }

        m_uiVisible = false;
        //qDebug() << Q_FUNC_INFO << "hide <-";
    }
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

bool MeegoCamera::eventFilter(QObject* watched, QEvent* event)
{
    if( watched == m_view && event->type() == QEvent::ActivationChange && m_view->rootObject()) {
        //qDebug() << Q_FUNC_INFO << "window active status changed as " << m_view->isActiveWindow();

        m_view->rootObject()->setProperty("active",m_view->isActiveWindow());

        // Acquire access to volume keys when the UI is active
        // and release the keys when the UI is deactive i.e.
        // minimized to task switcher.
        if(m_view->isActiveWindow())
            m_volumeKeyResource->acquire();
        else
            m_volumeKeyResource->release();
    }

    return false;
}

void MeegoCamera::cleanSocket()
{
    QFile serverSocket(SERVER_NAME);
    if (serverSocket.exists()) {
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
    return (keys[key/8] & (1 << (key % 8)));
}

