import Qt 4.7
import QtQuick 1.0
import com.nokia.meego 1.0

//PageStackWindow {
Window {
    id: mainview

    property alias lensCoverStatus : camera.lensCoverStatus
    property alias videoModeEnabled : camera.videoModeEnabled
    property alias imagePath : camera.imagePath

    signal deleteImage

//    anchors.centerIn: parent
    anchors.fill: parent

//    Screen {
//        id: screen
//        allowedOrientations: Screen.Landscape
//    }

    Component.onCompleted: {
        screen.allowedOrientations = Screen.Landscape
    }

//    initialPage: Camera {
//        anchors.fill: parent
//        active: screen.windowState.active
//    }

    Camera {
        id: camera
        anchors.fill: parent
        active: screen.windowState.active
        onDeleteImage: {
            console.log("main.qml: Delete image")
            parent.deleteImage()
        }
    }

}
