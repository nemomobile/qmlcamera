#ifndef GpioKeysListener_H
#define GpioKeysListener_H


#include <QObject>
#include <QLocalServer>
#include <QSocketNotifier>
#include <QLocalSocket>
#include <QProcess>
#include <linux/input.h>
#include <stdint.h>
#include <QtDeclarative/QDeclarativeView>
#include <policy/resource-set.h>

#include "qmlcamerasettings.h"

#define SERVER_NAME "/tmp/meegocamera"

class MeegoCamera : public QObject
{
    Q_OBJECT

public:
    MeegoCamera(bool visible);
    ~MeegoCamera();


signals:

    void quit();

private slots:
    void didReceiveKeyEventFromFile(int);
    void hideUI();
    void newConnection();
    void disconnected();
private:
    void HandleGpioKeyEvent(struct input_event &ev);
    void openHandles();
    void cleanSocket();
    bool createCamera();
    void showUI(bool show);


    bool uiVisible;
    int gpioFile;
    QSocketNotifier *gpioNotifier;
    QLocalServer *server;
    QVector<QLocalSocket*> connections;

    QDeclarativeView *m_view;
    QmlCameraSettings m_settings;

    ResourcePolicy::ResourceSet* m_volumeKeyResource;
};

#endif // GpioKeysListener_H
