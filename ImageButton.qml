import Qt 4.7
import QtQuick 1.0
import QtQuick 1.0
import com.nokia.meego 1.0

Item {
    id: button

    property alias source : image.source

    property int imageMargins: 0
    property real imageHorizontalAlignment : 0.0
    property int hMargin : 0
    property int vMargin : 0

    property Style platformStyle: ButtonStyle {}

    property alias text: text.text
    property alias textColor: text.color
    property real fontSize: 1.0

    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: button.clicked()
    }

    BorderImage {
        id: background
        anchors.fill: parent
        smooth: true
        visible: source != ""
        border {
            left: platformStyle.backgroundMarginLeft;
            top: platformStyle.backgroundMarginTop;
            right: platformStyle.backgroundMarginRight;
            bottom: button.platformStyle.backgroundMarginBottom
        }

        source: mouseArea.pressed ? button.platformStyle.pressedBackground : "";
    }

    Item {
        id: buttonItem

        anchors.fill: parent
        anchors.leftMargin: hMargin
        anchors.rightMargin: hMargin
        anchors.topMargin: vMargin
        anchors.bottomMargin: vMargin

        Text {
            id: text

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            color: "white"
            font.pixelSize: (parent.height - imageMargins * 2) * fontSize

            visible: text != ""
        }

        Image {
            id: image

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: text.visible ? text.right : parent.left
            anchors.right: parent.right

            anchors.margins: imageMargins

            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }


}
