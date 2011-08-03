import Qt 4.7

Item {

    property QtObject camera
    property QtObject settings
    property QtObject propertyPopup

    property alias quickSettingsVisible : quickSettings.visible

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

    QuickSettingsPane {
        id: quickSettings

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: homeButton.right
        anchors.right: quitButton.left

        anchors.leftMargin: 64
        anchors.rightMargin: 6

        camera: parent.camera
        settings: parent.settings
        propertyPopup: parent.propertyPopup
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
}
