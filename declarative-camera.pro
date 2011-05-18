TEMPLATE=app

CONFIG+=link_pkgconfig

PKGCONFIG += libresourceqt1


DEFINES+=Q_WS_MEEGO

QT += core declarative opengl

HEADERS += \
    qmlcamerasettings.h

SOURCES += qmlcamera.cpp \
    qmlcamerasettings.cpp

TARGET = meego-handset-camera
target.path=/usr/bin

RESOURCES += declarative-camera.qrc

app_icon.files = meegocamera.desktop
app_icon.path = /usr/share/applications

INSTALLS += target app_icon
