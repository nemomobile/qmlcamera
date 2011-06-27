import Qt 4.7

Item {

    signal homePressed
    signal quitPressed

    ImageButton {
        id: homeButton

        width: homeButton.height

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        source: "images/icon-m-framework-home.svg"

        onClicked: homePressed()
    }

    ImageButton {
        id: quitButton

        width: height

        anchors.top : parent.top
        anchors.bottom: parent.bottom
        anchors.right : parent.right

        source: "images/icon-m-framework-close.svg"

        onClicked: quitPressed()
    }

    // TODO: Add quick settings pane
}
