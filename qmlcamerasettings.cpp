#include "qmlcamerasettings.h"


#define WB_MODE_KEY "wb-mode"
#define FLASH_MODE_KEY "flash-mode"
#define EXPOSURE_COMPENSATION_KEY "exposure-compensation"


QmlCameraSettings::QmlCameraSettings(QObject *parent) :
    QSettings(parent)
{
}

QVariant QmlCameraSettings::whiteBalanceMode() const
{
    return value(WB_MODE_KEY, QVariant(0));
}

QVariant QmlCameraSettings::flashMode() const
{
    return value(FLASH_MODE_KEY, QVariant(0));
}

QVariant QmlCameraSettings::exposureCompensation() const
{
    return value(EXPOSURE_COMPENSATION_KEY, QVariant(0));
}

void QmlCameraSettings::setWhiteBalanceMode(QVariant wb)
{
    setValue(WB_MODE_KEY, wb);
    emit whiteBalanceModeChanged(wb);
}

void QmlCameraSettings::setFlashMode(QVariant flash)
{
    setValue(FLASH_MODE_KEY, flash);
    emit flashModeChanged(flash);
}

void QmlCameraSettings::setExposureCompensation(QVariant exposure)
{
    setValue(EXPOSURE_COMPENSATION_KEY, exposure);
    emit exposureCompensationChanged(exposure);
}
