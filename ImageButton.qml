import Qt 4.7

Item {
    id: button

    property alias source : image.source
//    property alias imageWidth : image.width
//    property alias imageHeight: image.height
//    property alias imageMargins: image.anchors.margins
    property int imageMargins: 0

    property alias text: text.text
    property alias textColor: text.color
    property alias fontSize: text.font.pixelSize

    signal clicked

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Text {
        id: text

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        color: "white"
        font.pixelSize: parent.height * 2 / 3

        visible: text != ""
    }

    Image {
        id: image

        width: text.visible ? parent.width - text.width : parent.width
        height: text.visible ? parent.height - text.height : parent.height

        anchors.left: text.visible ? text.right : parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: imageMargins

        //anchors.verticalCenter: parent.verticalCenter
        //anchors.horizontalCenterOffset: text.visible ? parent.width / 2 + text.width / 2 : parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

}
