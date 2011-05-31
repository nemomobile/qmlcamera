import Qt 4.7

Item {
    id: button
    property alias source : image.source

    signal clicked

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Image {
        id: image
        anchors.fill: parent
        opacity: parent
        //source: "images/icon-m-framework-home.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

}
