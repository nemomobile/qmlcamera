#include "gpiokeyslistener.h"

#include <fcntl.h>
#include <syslog.h>
#include <errno.h>
#include <iostream>

#include <sys/inotify.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <QFile>



#include <QtGui/QApplication>
#include <QtGui/QDesktopWidget>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeEngine>
#include <QGraphicsObject>
#include <QDeclarativeContext>


#if !defined(QT_NO_OPENGL)
#include <QtOpenGL/QGLWidget>
#endif

#include <QKeyEvent>


#define GPIO_KEYS "/dev/input/gpio-keys"

#ifndef KEY_CAMERA_FOCUS
#define KEY_CAMERA_FOCUS 0x210
#endif
#ifndef SW_KEYPAD_SLIDE
#define SW_KEYPAD_SLIDE 0x0a
#endif


GpioKeysListener::GpioKeysListener(bool visible): QObject(),
    uiVisible(visible),
    gpioFile(-1),
    gpioNotifier(0),
    server(0),
    connections(0)
{
    server = new QLocalServer(this);
    if (!connect(server, SIGNAL(newConnection()), this, SLOT(newConnection()))) {
        std::cout << "Failed to connect the newConnection signal  ()" << std::endl;
    }
    cleanSocket();

    if (!server->listen(SERVER_NAME)) {
         std::cout << "Failed to listen incoming connections on()" << std::endl;
    }


    gpioFile = open(GPIO_KEYS, O_RDONLY | O_NONBLOCK);
    if (gpioFile != -1) {
        gpioNotifier = new QSocketNotifier(gpioFile, QSocketNotifier::Read);
        connect(gpioNotifier, SIGNAL(activated(int)), this, SLOT(didReceiveKeyEventFromFile(int)));
    } else {
        //std::cout << "could not open gpioFile " << std::endl;
        gpioNotifier = 0;
    }

    m_volumeKeyResource = new ResourcePolicy::ResourceSet("camera", this);
    m_volumeKeyResource->setAlwaysReply();
    // No need to connect resourcesGranted() or lostResources() signals for now.
    // Camera UI will be started even if ScaleButtonResource resource is not granted.

    ResourcePolicy::ScaleButtonResource *volumeKeys = new ResourcePolicy::ScaleButtonResource;
    m_volumeKeyResource->addResourceObject(volumeKeys);

    if(uiVisible)
    {
        createCamera();
        // forced UI visible or hide set
        showUI(uiVisible,true);
    }
}

GpioKeysListener::~GpioKeysListener()
{
    std::cout << ">~GpioKeysListener()" <<   std::endl;
    m_volumeKeyResource->release();
    server->close();
    delete server, server = 0;
    closelog();


    if (gpioFile != -1) {
        close(gpioFile), gpioFile = -1;
        delete gpioNotifier, gpioNotifier = 0;
    }
     std::cout << "<~GpioKeysListener()" <<   std::endl;
}


bool GpioKeysListener::createCamera()
{
    const QString mainQmlApp = QLatin1String("qrc:/declarative-camera.qml");
    //const QString mainQmlApp = QLatin1String("qrc:/cameraloader.qml");

    view = new QDeclarativeView;
#if !defined(QT_NO_OPENGL) && !defined(Q_WS_MAEMO_5) && !defined(Q_WS_S60)
    view->setViewport(new QGLWidget);
#endif
    view->rootContext()->setContextProperty("settings", &m_settings);
    view->setSource(QUrl(mainQmlApp));
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    // Qt.quit() called in embedded .qml by default only emits
    // quit() signal, so do this (optionally use Qt.exit()).
    QObject::connect(view->engine(), SIGNAL(quit()), this, SLOT(hideUI()));
    // QObject::connect(view.engine(), SIGNAL(()), qApp, SLOT(quit()));
#if defined(Q_OS_SYMBIAN) || defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6) || defined(Q_WS_MEEGO)
    view->setGeometry(QRect(0, 0, 800, 480));
#else
    view->setGeometry(QRect(100, 100, 800, 480));
#endif

    return true;
}



/* Called when we get an input event from a file descriptor. */
void GpioKeysListener::didReceiveKeyEventFromFile(int fd)
{
    std::cout << ">didReceiveKeyEventFromFile" <<   std::endl;
    for (;;) {
        struct input_event ev;
        memset(&ev, 0, sizeof(ev));
        int ret = read(fd, &ev, sizeof(ev));

        if (ret <= 0) {
            break;
        }

        if (ret == sizeof(ev) ) {
            HandleGpioKeyEvent(ev);
        }
    }
    std::cout << "<didReceiveKeyEventFromFile" <<   std::endl;
}

void GpioKeysListener::HandleGpioKeyEvent(struct input_event &ev)
{
     std::cout << ">HandleGpioKeyEvent()" <<   std::endl;
    if (ev.code == 528) {
        if ( uiVisible) {
            if ( ev.value == 1 )
                {
                //std::cout << "Half Press Pressed" <<  ev.code  << " ev.value" <<  ev.value << std::endl;
                QApplication::postEvent(view,
                        new QKeyEvent(QEvent::KeyPress,
                        Qt::Key_CameraFocus,
                        Qt::NoModifier));
                }
            if ( ev.value == 0 )
                {
                //std::cout << "Half Press released" <<  ev.code  << " ev.value" <<  ev.value << std::endl;
                QApplication::postEvent(view,
                        new QKeyEvent(QEvent::KeyRelease,
                        Qt::Key_CameraFocus,
                        Qt::NoModifier));
                }
        }

    }
    else if ((ev.code == 212 && ev.value == 1) || (ev.code == 9 && ev.value == 0) )
    {
        // Check if UI is running and show it if not
        showUI(true);
        //std::cout << "Full Press or cover opened" << ev.code  << " ev.value" <<  ev.value<< std::endl;
    }
    else if (ev.code == 9 && ev.value == 1)
    {
        showUI(false);
        //std::cout << "Cover close " << ev.code  << " ev.value" <<  ev.value << std::endl;
    }


    std::cout << "<HandleGpioKeyEvent" <<   std::endl;
}


void GpioKeysListener::hideUI()
{
    showUI(false, true);
}

void GpioKeysListener::showUI(bool show, bool forced)
{
    std::cout << ">showUI " << show  << std::endl;
    if ((show && !uiVisible) || (show && forced )  )
        {
        m_volumeKeyResource->acquire();
        if(!uiVisible || (show && forced ))
        {
            std::cout << "show 2" << std::endl;
            createCamera();
        }
        std::cout << "show" << std::endl;
        QGraphicsObject *viewobject2 = view->rootObject();
        view->showFullScreen();
        viewobject2->setVisible(true);
        uiVisible = true;
        }
    else if ((!show && uiVisible )|| (!show && forced ) )
        {
        m_volumeKeyResource->release();
        if(uiVisible)
        {
            std::cout << "hide" << std::endl;
            view->close();
            view->deleteLater();
            view = 0;
        }

        std::cout << "hide" << std::endl;
        uiVisible = false;
        }
    std::cout << "<showUI " << std::endl;
}

void GpioKeysListener::newConnection()
{
    while (server->hasPendingConnections()) {
        showUI(true);
        QLocalSocket *socket = server->nextPendingConnection();
        connect(socket, SIGNAL(disconnected()), this, SLOT(disconnected()));
        connections.push_back(socket);
    }
}

void GpioKeysListener::disconnected()
{
    QLocalSocket *socket = qobject_cast<QLocalSocket*>(sender());
    for (QVector<QLocalSocket*>::iterator it = connections.begin(); it != connections.end(); it++) {
        if (*it == socket) {
            connections.erase(it);
            break;
        }
    }
    socket->deleteLater();
}

void GpioKeysListener::cleanSocket()
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
