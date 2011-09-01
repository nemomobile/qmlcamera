import Qt 4.7
import QtMultimediaKit 1.1
import com.meego.MeegoHandsetCamera 1.0

Item {

    property QtObject camera
    property QtObject settings
    property bool videoModeEnabled: false
    property bool previewAvailable : false

    signal previewSelected

    ImageButton {
        id: viewButton

        source: "image://theme/icon-m-toolbar-gallery"

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        hMargin: 6
        vMargin: 6

        width: viewButton.height

        onClicked: previewSelected()

        visible: camera.cameraMode == MeegoCamera.CaptureStillImage && previewAvailable
    }

    ImageButton {
        id: modeButton

        source: camera.cameraMode == MeegoCamera.CaptureVideo ? "image://theme/icon-m-toolbar-camera" : "image://theme/icon-m-camera-video"

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        hMargin: 6
        vMargin: 6

        width: modeButton.height

        onClicked: {
            if( camera.cameraMode != MeegoCamera.CaptureStillImage )
                settings.cameraMode = MeegoCamera.CaptureStillImage
            else
                settings.cameraMode = MeegoCamera.CaptureVideo
        }

        visible: videoModeEnabled
    }
}
