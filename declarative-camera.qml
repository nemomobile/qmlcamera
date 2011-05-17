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
    state: "Initialization"
    property QtObject settings

    states: [
        State {
            name: "Initialization"
            StateChangeScript {
                script: {
                    camera.visible = true
                    camera.focus = false
                    stillControls.visible = false
                    photoPreview.visible = false
                }
            }
        },
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    camera.visible = true
                    camera.focus = true
                    stillControls.visible = true
                    photoPreview.visible = false
                }
            }
        },
        State {
            name: "PhotoPreview"
            StateChangeScript {
                script: {
                    camera.visible = false                    
                    stillControls.visible = false
                    photoPreview.visible = true
                    photoPreview.focus = true
                }
            }
        }
    ]

    // Bind setting controls to settings object
    Binding { target: settings; property: "flashMode"; value: stillControls.flashMode; when: cameraUI.state != "Initialization" }
    Binding { target: settings; property: "whiteBalanceMode"; value: stillControls.whiteBalance; when: cameraUI.state != "Initialization" }
    Binding { target: settings; property: "exposureCompensation"; value: stillControls.exposureCompensation; when: cameraUI.state != "Initialization" }

    PhotoPreview {
        id : photoPreview
        anchors.fill : parent
        onClosed: cameraUI.state = "PhotoCapture"
        focus: visible

        Keys.onPressed : {
            //return to capture mode if the shutter button is touched
            if (event.key == Qt.Key_CameraFocus || event.key == Qt.Key_WebCam ) {
                cameraUI.state = "PhotoCapture"
                event.accepted = true;
            }
        }
    }

    Camera {
        id: camera
        objectName: "camera"
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        focus: visible //to receive focus and capture key events
        
        previewResolution : camera.width + "x" + camera.height
        viewfinderResolution : camera.width + "x" + camera.height


        flashMode: stillControls.flashMode
        whiteBalanceMode: stillControls.whiteBalance
        exposureCompensation: stillControls.exposureCompensation

        onImageCaptured : {
            photoPreview.source = preview
            stillControls.previewAvailable = true
            cameraUI.state = "PhotoPreview"
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
                zoomOutAnimation.stop();
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

    CaptureControls {
        id: stillControls
        anchors.fill: parent
        camera: camera
        onPreviewSelected: cameraUI.state = "PhotoPreview"
    }

    onSettingsChanged : {
        // Initialize settings from ini file
        stillControls.flashMode = settings.flashMode
        stillControls.whiteBalance = settings.whiteBalanceMode
        stillControls.exposureCompensation = settings.exposureCompensation
    }
}
