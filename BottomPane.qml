import Qt 4.7
import com.meego.MeegoHandsetCamera 1.0

Item {

    property QtObject camera
    property bool videoModeEnabled: false
    property bool previewAvailable : false

    signal previewSelected

    CameraButton {
        id: viewButton

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        text: "View"

        onClicked: previewSelected()

        visible: camera.cameraMode == MeegoCamera.CaptureStillImage && previewAvailable
    }


    CameraButton {
        id: modeButton

        anchors.top : parent.top
        anchors.bottom: parent.bottom
        anchors.right : parent.right

        visible: videoModeEnabled

        state: camera.cameraMode == MeegoCamera.CaptureStillImage ? "stillCapture" : "videoCapture"

        states: [
            State {
                name: "stillCapture"
                PropertyChanges { target: modeButton; text: "Still" }
            },
            State {
                name: "videoCapture"
                PropertyChanges { target: modeButton; text: "Video" }
            }
        ]

        onClicked: {
            if( camera.cameraMode == MeegoCamera.CaptureStillImage ) {
                camera.cameraMode = MeegoCamera.CaptureVideo;
            } else {
                camera.cameraMode = MeegoCamera.CaptureStillImage;
            }
        }
    }



}
