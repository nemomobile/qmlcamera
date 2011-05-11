#ifndef QMLCAMERASETTINGS_H
#define QMLCAMERASETTINGS_H

#include <QSettings>

class QmlCameraSettings : public QSettings
{
    Q_OBJECT
    Q_PROPERTY(QVariant whiteBalanceMode READ whiteBalanceMode WRITE setWhiteBalanceMode NOTIFY whiteBalanceModeChanged)
    Q_PROPERTY(QVariant flashMode READ flashMode WRITE setFlashMode NOTIFY flashModeChanged)
    Q_PROPERTY(QVariant exposureCompensation READ exposureCompensation WRITE setExposureCompensation NOTIFY exposureCompensationChanged)
public:
    explicit QmlCameraSettings(QObject *parent = 0);

    QVariant whiteBalanceMode() const;
    QVariant flashMode() const;
    QVariant exposureCompensation() const;

signals:

    void whiteBalanceModeChanged(QVariant);
    void flashModeChanged(QVariant);
    void exposureCompensationChanged(QVariant);

public slots:

    void setWhiteBalanceMode(QVariant);
    void setFlashMode(QVariant);
    void setExposureCompensation(QVariant);

};

#endif // QMLCAMERASETTINGS_H
