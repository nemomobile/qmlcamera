TEMPLATE=app

CONFIG+=meego

DEFINES+=Q_WS_MEEGO

QT += declarative network opengl

HEADERS += \
    qmlcamerasettings.h \
    gpiokeyslistener.h

SOURCES += qmlcamera.cpp \
    qmlcamerasettings.cpp \
    gpiokeyslistener.cpp

TARGET = meego-de-camera
target.path=/usr/bin

RESOURCES += declarative-camera.qrc

INSTALLS += target
