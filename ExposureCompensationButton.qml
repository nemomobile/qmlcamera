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

Item {
    id: exposureCompensation
    property alias value : flickableList.value
    signal clicked

//    width : 100
//    height: 70


    Text {

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        text: "Ev:"
        font.pixelSize: parent.height / 3
        color: "white"
    }

    FlickableList {
        anchors.fill: parent
        id: flickableList
        property real value: 0.0
        items: ["-2", "-1.5", "-1", "-0.5", "0", "+0.5", "+1", "+1.5", "+2"]
        index: 4

        onIndexChanged: {
            value = items[index]
            console.log("onIndexChanged: index = " +  index + "  value = " + value)
        }

        onValueChanged: {
            console.log("value = " + value)
            var newIndex = indexForValue(value)
            console.log("new index = " + newIndex + "  old index = " + index)
            if( newIndex != index)
                scrollTo(newIndex)
        }

        function indexForValue(value) {
            // Find index for given value from item list
            for(var i=0; i < items.length; i++) {
                if(items[i] == value)
                    return i
            }

            // If no index for the value found the centermost
            // index is returned
            return Math.floor(items.length / 2)
        }

        onClicked: exposureCompensation.clicked()

        delegate: Text {
            font.pixelSize: exposureCompensation.height / 3 + 4
            color: "white"
            styleColor: "black"
            width: flickableList.width
            height: flickableList.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: flickableList.items[index]
        }

    }
}

