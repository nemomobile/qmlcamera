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

Rectangle {
    id : cameraUI
    color: "black"
    state: "Standby"

    // This defines "active" state. For example when state is
    // "PhotoCapture" active state is also "PhotoCapture" but
    // when state changes to "Standby" active state remains as
    // "PhotoCapture". When the app returns from "Standby"
    // state the active state will be activated.
    property string activeState: "PhotoCapture"

    // Lens cover status
    // true = lens cover open
    // false = lens cover closed
    property bool lensCoverStatus: true

    // Is the app active i.e. is it the top most
    // window with focus. If screen is shut down
    // or closed the app is not active
    // true = active
    // false = not active
    property bool active : false

    states: [
        State {
            name: "Standby"
            StateChangeScript {
                script: {
                    stillControls.visible = false
                    photoPreview.visible = false
                }
            }
        },
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    stillControls.visible = true
                    photoPreview.visible = false
                }
            }
        },
        State {
            name: "PhotoPreview"
            StateChangeScript {
                script: {
                    stillControls.visible = false
                    photoPreview.visible = true
                    photoPreview.focus = true
                }
            }
        }
    ]

    // Activates given state
    function changeState(newState)
    {
        if(newState == state)
            return

        if(newState == "Standby") {
            toggleStandby(true)
        } else {
            activeState = newState

            if(active)
                state = newState
        }
    }

    // Toggles "Standby" state on/off
    function toggleStandby(standbyStatus)
    {
        console.log("meego-handset-camera: toggleStandby = " + standbyStatus)
        console.log("meego-handset-camera: toggleStandby: state = " + state + "  active = " + active)
        if(standbyStatus && state != "Standby") {
            // Go to standby mode
            activeState = state
            state = "Standby"
            console.log("meego-handset-camera: go to standby")
        } else if(!standbyStatus && state == "Standby" && active) {
            // Wake up from standby mode
            console.log("meego-handset-camera: wake up from standby to state " + activeState)
            state = activeState
        }
    }

    Component.onCompleted: {
        // Initialize settings from ini file
        stillControls.flashMode = settings.flashMode
        stillControls.whiteBalance = settings.whiteBalanceMode
        stillControls.exposureCompensation = settings.exposureCompensation

        console.log("meego-handset-camera: Component.onCompleted: lens cover = " + lensCoverStatus )

        //toggleStandby(false)
    }

    onStateChanged: {
        console.log("meego-handset-camera: onStateChanged = " + state)
        if(state == "Standby") {
            console.log("meego-handset-camera: onStateChanged: Standby: stop camera")
            camera.stop()
        } else if(state == "PhotoCapture" && lensCoverStatus) {
            console.log("meego-handset-camera: onStateChanged: PhotoCapture")

            if(lensCoverStatus) {
                console.log("meego-handset-camera: onStateChanged: PhotoCapture: start camera")
                camera.cameraState = "ActiveState"
                camera.start()
                camera.focus = true
            } /*else {
                console.log("meego-handset-camera: onStateChanged: PhotoCapture: lens cover closed -> stop camera")
                camera.stop()
                camera.focus = false
            }*/
        }
    }

    onLensCoverStatusChanged: {
        console.log("meego-handset-camera: onLensCoverStatusChanged = " + lensCoverStatus)

        if(!lensCoverStatus) {
            console.log("meego-handset-camera: onLensCoverStatusChanged: stop camera")
            camera.stop()
        } else if(state == "PhotoCapture") {
            console.log("meego-handset-camera: onLensCoverStatusChanged: start camera")
            camera.cameraState = "ActiveState"
            camera.start()
            camera.focus = true
        }
    }

    onActiveChanged: {
        console.log("meego-handset-camera ACTIVE = " + active )

        toggleStandby(!active)
    }


    // Bind setting controls to settings object
    Binding { target: settings; property: "flashMode"; value: stillControls.flashMode; when: cameraUI.state != "Standby" }
    Binding { target: settings; property: "whiteBalanceMode"; value: stillControls.whiteBalance; when: cameraUI.state != "Standby" }
    Binding { target: settings; property: "exposureCompensation"; value: stillControls.exposureCompensation; when: cameraUI.state != "Standby" }

//    Text {
//        id: standbyText
//        visible: parent.state == "Standby"
//        color: "white"
//        font.pixelSize: 36
//        anchors.fill: parent
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        text: "Standby"
//    }

    Camera {
        id: camera
        objectName: "camera"
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        visible: parent.state == "PhotoCapture" && lensCoverStatus
        cameraState: "LoadedState"

        captureResolution : settings.captureResolution
        
        previewResolution : camera.width + "x" + camera.height
        viewfinderResolution : camera.width + "x" + camera.height


        flashMode: stillControls.flashMode
        whiteBalanceMode: stillControls.whiteBalance
        exposureCompensation: stillControls.exposureCompensation

        onImageCaptured : {
            photoPreview.source = preview
            stillControls.previewAvailable = true
            changeState("PhotoPreview")
        }
        
        Keys.onPressed : {
            if (event.key == Qt.Key_Camera || event.key == Qt.Key_WebCam ) {
                // Capture button fully pressed
                event.accepted = true;
                // Take still image
                camera.captureImage();
            } else if (event.key == Qt.Key_ZoomIn || event.key == Qt.Key_F7  ) {
                // Zoom in
                event.accepted = true;
                zoomOutAnimation.stop();
                zoomInAnimation.duration = 4000 - camera.digitalZoom / Math.min(4.0, camera.maximumDigitalZoom) * 4000;
                zoomInAnimation.start();
            } else if (event.key == Qt.Key_ZoomOut || event.key == Qt.Key_F8 ) {
                // Zoom out
                event.accepted = true;
                zoomInAnimation.stop();
                zoomOutAnimation.duration = 4000 * camera.digitalZoom / Math.min(4.0, camera.maximumDigitalZoom);
                zoomOutAnimation.start();
            }
        }
        
        Keys.onReleased : {
            if (event.key == Qt.Key_ZoomIn || event.key == Qt.Key_F7  ) {
                // Zoom in
                event.accepted = true;
                zoomInAnimation.stop();
            } else if (event.key == Qt.Key_ZoomOut || event.key == Qt.Key_F8) {
			    // Zoom out
			    event.accepted = true;
			    zoomOutAnimation.stop();
			}
        }
        
        PropertyAnimation {
            id: zoomInAnimation;
            target: camera;
            property: "digitalZoom";
            to: Math.min(4.0, camera.maximumDigitalZoom);
            duration: 4000;
        }
        
        PropertyAnimation {
            id: zoomOutAnimation;
            target: camera;
            property: "digitalZoom";
            to: 0.0;
            duration: 4000;
        }
    }

    Text {
        id: infoText
        visible: parent.state == "Standby" || (parent.state == "PhotoCapture" && !lensCoverStatus)
        color: "white"
        font.pixelSize: 36
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: stillControls.visible ? parent.width : parent.width - stillControls.settingsPaneWidth
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: parent.state == "Standby" ? "Standby" : "Lens cover closed"
    }

    CaptureControls {
        id: stillControls
        anchors.fill: parent
        camera: camera
        onPreviewSelected: changeState("PhotoPreview")
    }

    PhotoPreview {
        id : photoPreview
        anchors.fill : parent
        onClosed: changeState("PhotoCapture")
        focus: visible

        Keys.onPressed : {
            //return to capture mode if the shutter button is touched
            if (event.key == Qt.Key_CameraFocus || event.key == Qt.Key_WebCam ) {
                changeState("PhotoCapture")
                event.accepted = true;
            }
        }
    }

    Text {
        id: log
        color: "red"
        font.pixelSize: 20
        text: camera.cameraState
    }

}
