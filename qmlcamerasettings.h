#ifndef QMLCAMERASETTINGS_H
#define QMLCAMERASETTINGS_H

#include <QSettings>

class QmlCameraSettings : public QSettings
{
    Q_OBJECT
    Q_PROPERTY(QVariant whiteBalanceMode READ whiteBalanceMode WRITE setWhiteBalanceMode NOTIFY whiteBalanceModeChanged)
    Q_PROPERTY(QVariant flashMode READ flashMode WRITE setFlashMode NOTIFY flashModeChanged)
    Q_PROPERTY(QVariant exposureCompensation READ exposureCompensation WRITE setExposureCompensation NOTIFY exposureCompensationChanged)
    Q_PROPERTY(QVariant captureResolution READ captureResolution WRITE setCaptureResolution NOTIFY captureResolutionChanged)
public:
    explicit QmlCameraSettings(QObject *parent = 0);

    QVariant whiteBalanceMode() const;
    QVariant flashMode() const;
    QVariant exposureCompensation() const;
    QVariant captureResolution() const;

signals:

    void whiteBalanceModeChanged(QVariant);
    void flashModeChanged(QVariant);
    void exposureCompensationChanged(QVariant);
    void captureResolutionChanged(QVariant);

public slots:

    void setWhiteBalanceMode(QVariant);
    void setFlashMode(QVariant);
    void setExposureCompensation(QVariant);
    void setCaptureResolution(QVariant);

};

#endif // QMLCAMERASETTINGS_H
