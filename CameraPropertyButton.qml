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
//import QtMultimediaKit 1.1

Item {
    id: propertyButton
    property CameraPropertyModel model
//    property alias value : model.currentValue
    property variant value : model.currentValue
    property alias icon : button.source
    //property alias model : popup.model
//    property bool popupVisible : popup.state == "visible"

    signal clicked

//    function closePopup() {
//        popup.state = "invisible"
//    }

    ImageButton {
        id: button

        anchors.fill: parent

//        source: popup.currentItem.icon
//        source: model
        imageWidth: parent.height * 2 / 3
        imageHeight: parent.height * 2 / 3

        onClicked: propertyButton.clicked()

//    CameraPropertyPopup {
//        id: popup
//        anchors.left: parent.left
//        anchors.top: parent.bottom
//        anchors.topMargin: 6
//        state: "invisible"
//        visible: opacity > 0


//        states: [
//            State {
//                name: "invisible"
//                PropertyChanges { target: popup; opacity: 0 }
//            },

//            State {
//                name: "visible"
//                PropertyChanges { target: popup; opacity: 1.0 }
//            }
//        ]

//        transitions: Transition {
//            NumberAnimation { properties: "opacity"; duration: 100 }
//        }

//        function toggle() {
//            if (state == "visible")
//                state = "invisible";
//            else
//                state = "visible";
//        }

//        onSelected: {
//            popup.state = "invisible"
//        }
    }
}

