TEMPLATE=app

CONFIG+=meego

DEFINES+=Q_WS_MEEGO

QT += declarative network opengl

HEADERS += \
    qmlcamerasettings.h

SOURCES += qmlcamera.cpp \
    qmlcamerasettings.cpp

TARGET = meego-de-camera
target.path=/usr/bin

RESOURCES += declarative-camera.qrc

app_icon.files = meegocamera.desktop
app_icon.path = /usr/share/applications

INSTALLS += target app_icon
