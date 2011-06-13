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


public:

    // Event filter is used to track activation/deactivation
    // of events of QDeclarativeView window
    bool eventFilter(QObject* watched, QEvent* event);

private slots:

    void hideUI();
    void didReceiveKeyEventFromFile(int);
    void newConnection();
    void disconnected();

private:
    void HandleGpioKeyEvent(struct input_event &ev);
    void openHandles();
    void cleanSocket();
    void createCamera();
    void showUI();

    // Returns state of given switch, for example lens cover
    // true = switch is on
    // false = switch is off
    bool getSwitchState(int fd, int key);

    bool m_uiVisible;
    bool m_coverState;
    bool m_background;
    int m_gpioFile;

    QSocketNotifier *m_gpioNotifier;
    QLocalServer *m_server;
    QVector<QLocalSocket*> m_connections;

    QDeclarativeView *m_view;
    QmlCameraSettings m_settings;

    ResourcePolicy::ResourceSet* m_volumeKeyResource;
};

#endif // GpioKeysListener_H
