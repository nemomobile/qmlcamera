import Qt 4.7

Item {
    id: button
    property alias source : image.source
    property alias imageWidth : image.width
    property alias imageHeight: image.height

    signal clicked

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Image {
        id: image

        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

}
