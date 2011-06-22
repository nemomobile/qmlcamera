/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import Qt 4.7
import QtMultimediaKit 1.1
import com.meego.MeegoHandsetCamera 1.0

FocusScope {
    id : captureControls

    property QtObject camera
    property bool previewAvailable : false
    property bool videoModeEnabled : false
    property alias settingsPaneWidth : buttonsColumn.width

    property alias whiteBalance : wbModesButton.value
    property alias flashMode : flashModesButton.value
    property alias exposureCompensation : exposureCompensationButton.value

    signal previewSelected

    Column {
        id: buttonsColumn
        spacing : 8
        anchors.right : parent.right
        anchors.rightMargin: 8
        anchors.top : parent.top
        anchors.topMargin: 8

//        FocusButton {
//            camera: captureControls.camera
//        }

        CameraButton {
            text: "Capture"
            onClicked: camera.captureImage()
            visible: camera.cameraMode == MeegoCamera.CaptureStillImage && camera.cameraState == MeegoCamera.ActiveState
        }

        CameraButton {
            text: "Record"
            visible: camera.cameraMode == MeegoCamera.CaptureVideo && camera.recordingState == MeegoCamera.Stopped
            onClicked: camera.record()
        }

        CameraButton {
            text: "Resume"
            visible: camera.cameraMode == MeegoCamera.CaptureVideo && camera.recordingState == MeegoCamera.Paused
            onClicked: camera.record()
        }

        CameraButton {
            text: "Pause"
            visible: camera.cameraMode == MeegoCamera.CaptureVideo && camera.recordingState == MeegoCamera.Recording
            onClicked: camera.pauseRecording()
        }

        CameraButton {
            text: "Stop"
            visible: camera.cameraMode == MeegoCamera.CaptureVideo && camera.recordingState != MeegoCamera.Stopped
            onClicked: camera.stopRecording()
        }

        CameraPropertyButton {
            id : flashModesButton
            value: MeegoCamera.FlashOff
            visible: camera.cameraMode == MeegoCamera.CaptureStillImage
            model: ListModel {
                ListElement {
                    icon: "images/camera_flash_auto.png"
                    value: MeegoCamera.FlashAuto
                    text: "Auto"
                }
                ListElement {
                    icon: "images/camera_flash_off.png"
                    value: MeegoCamera.FlashOff
                    text: "Off"
                }
                ListElement {
                    icon: "images/camera_flash_fill.png"
                    value: MeegoCamera.FlashOn
                    text: "On"
                }
                ListElement {
                    icon: "images/camera_flash_redeye.png"
                    value: MeegoCamera.FlashRedEyeReduction
                    text: "Red Eye Reduction"
                }
            }

            onPopupVisibleChanged: {
                if( popupVisible )
                    wbModesButton.closePopup();
            }

        }

        CameraPropertyButton {
            id : wbModesButton
            value: MeegoCamera.WhiteBalanceAuto
            model: ListModel {
                ListElement {
                    icon: "images/camera_auto_mode.png"
                    value: MeegoCamera.WhiteBalanceAuto
                    text: "Auto"
                }
                ListElement {
                    icon: "images/camera_white_balance_sunny.png"
                    value: MeegoCamera.WhiteBalanceSunlight
                    text: "Sunlight"
                }
                ListElement {
                    icon: "images/camera_white_balance_cloudy.png"
                    value: MeegoCamera.WhiteBalanceCloudy
                    text: "Cloudy"
                }
                ListElement {
                    icon: "images/camera_white_balance_incandescent.png"
                    value: MeegoCamera.WhiteBalanceIncandescent
                    text: "Incandescent"
                }
                ListElement {
                    icon: "images/camera_white_balance_flourescent.png"
                    value: MeegoCamera.WhiteBalanceFluorescent
                    text: "Fluorescent"
                }
            }

            onPopupVisibleChanged: {
                if( popupVisible )
                    flashModesButton.closePopup();
            }

        }

        ExposureCompensationButton {
            id : exposureCompensationButton
        }

        CameraButton {
            text: "View"
            onClicked: captureControls.previewSelected()
            visible: camera.cameraMode == MeegoCamera.CaptureStillImage && captureControls.previewAvailable
        }
    }

    CameraButton {
        id: modeButton
        anchors.right : parent.right
        anchors.rightMargin: 8
        anchors.bottom : quitButton.top
        anchors.bottomMargin: 8
        visible: videoModeEnabled
        state: camera.cameraMode == MeegoCamera.CaptureStillImage ? "stillCapture" : "videoCapture"

        states: [
            State {
                name: "stillCapture"
                PropertyChanges { target: modeButton; text: "Still" }
            },
            State {
                name: "videoCapture"
                PropertyChanges { target: modeButton; text: "Video" }
            }
        ]

        onClicked: {
            if( camera.cameraMode == MeegoCamera.CaptureStillImage ) {
                camera.cameraMode = MeegoCamera.CaptureVideo;
            } else {
                camera.cameraMode = MeegoCamera.CaptureStillImage;
            }
        }
    }

    CameraButton {
        id: quitButton
        anchors.right : parent.right
        anchors.rightMargin: 8
        anchors.bottom : parent.bottom
        anchors.bottomMargin: 8
        text: "Quit"
        onClicked: Qt.quit()
    }

    Item {
        id: exposureDetails
        anchors.bottom : parent.bottom
        anchors.left : parent.left
        anchors.bottomMargin: 16
        anchors.leftMargin: 16
        height: childrenRect.height
        width: childrenRect.width

        visible : camera.lockStatus == MeegoCamera.Locked

        Rectangle {
            opacity: 0.4
            color: "black"
            anchors.fill: parent
        }

        Row {
            spacing : 16

            Text {
                text: "Av: "+camera.aperture.toFixed(1)
                font.pixelSize: 18
                color: "white"
                visible: camera.aperture > 0
            }

            Text {
                font.pixelSize: 18
                color: "white"
                visible: camera.shutterSpped > 0
                text: "Tv: "+printableExposureTime(camera.shutterSpeed)

                function printableExposureTime(t) {
                    if (t > 3.9)
                        return "Tv: "+t.toFixed() + "\"";

                    if (t > 0.24 )
                        return "Tv: "+t.toFixed(1) + "\"";

                    if (t > 0)
                        return "Tv: 1/"+(1/t).toFixed();

                    return "";
                }
            }

            Text {
                text: "ISO: "+camera.iso.toFixed()
                font.pixelSize: 18
                color: "white"
                visible: camera.iso > 0
            }
        }
    }

    ZoomControl {
        visible: camera.cameraState == MeegoCamera.ActiveState
        x : 0
        y : 0
        width : 100
        height: parent.height

        currentZoom: camera.digitalZoom
        maximumZoom: Math.min(4.0, camera.maximumDigitalZoom)
        onZoomTo: camera.setDigitalZoom(value)
    }
}
