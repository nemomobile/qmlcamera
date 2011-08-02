import Qt 4.7

Item {
    id: button

    property alias source : image.source

    property int imageMargins: 0
    property real imageCrop : 0.0
    property int hMargin : 0
    property int vMargin : 0

    property alias text: text.text
    property alias textColor: text.color
    property alias fontSize: text.font.pixelSize

    signal clicked

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Item {

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
            font.pixelSize: parent.height - imageMargins * 2

            visible: text != ""
        }

        Image {
            id: image

            property int origWidth : text.visible ? parent.width - text.width - imageMargins * 2 : parent.width - imageMargins * 2
            property int origHeight : parent.height - imageMargins * 2

            property int xCrop : imageCrop * origWidth / 2
            property int yCrop : imageCrop * origHeight / 2

            x: text.visible ? text.x + text.width - xCrop : parent.x + xCrop

            width: origWidth + 2 * xCrop
            height: origHeight + 2 * yCrop

            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }


}
