import Qt 4.7
import com.meego.MeegoHandsetCamera 1.0

Item {
    id: quickSettingsPane

    property QtObject camera
    property QtObject settings
    property QtObject propertyPopup

    Binding {
        target: settings
        property: "flashMode"
        value: flashModesButton.value
    }

    Binding {
        target: settings
        property: "whiteBalanceMode"
        value: wbModesButton.value
    }

    Binding {
        target: settings
        property: "exposureCompensation"
        value: exposureCompensationButton.value
    }


    Row {
        id: settingButtonsColumn
        spacing : 0
        anchors.fill: parent

        CameraPropertyButton {
            id : flashModesButton

            width: parent.height + parent.height * 2 / 3
            height: parent.height
            hMargin: parent.height / 3

            icon: flashModesButtonListModel.get(flashModesButtonModel.currentIndex()).icon

            visible: camera.cameraMode == MeegoCamera.CaptureStillImage

            model: CameraPropertyModel {
                id: flashModesButtonModel

                currentValue: settings.flashMode

                model: ListModel {
                    id: flashModesButtonListModel

                    ListElement {
                        icon: "image://theme/icon-m-camera-flash-auto-screen"
                        value: MeegoCamera.FlashAuto
                        text: "Auto"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-flash-off-screen"
                        value: MeegoCamera.FlashOff
                        text: "Off"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-flash-always-screen"
                        value: MeegoCamera.FlashOn
                        text: "On"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-flash-red-eye-screen"
                        value: MeegoCamera.FlashRedEyeReduction
                        text: "Red Eye Reduction"
                    }
                }

            }
            onClicked: propertyPopup.toggleOn(flashModesButton.model)

        }

        CameraPropertyButton {
            id : wbModesButton

            width: parent.height + parent.height * 2 / 3
            height: parent.height
            hMargin: parent.height / 3

            icon: wbModesButtonListModel.get(wbModesButtonModel.currentIndex()).icon

            model: CameraPropertyModel {
                id: wbModesButtonModel

                currentValue: settings.whiteBalanceMode

                model: ListModel {
                    id: wbModesButtonListModel

                    ListElement {
                        icon: "image://theme/icon-m-camera-whitebalance-auto-screen"
                        value: MeegoCamera.WhiteBalanceAuto
                        text: "Auto"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-whitebalance-sunny-screen"
                        value: MeegoCamera.WhiteBalanceSunlight
                        text: "Sunlight"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-whitebalance-cloudy-screen"
                        value: MeegoCamera.WhiteBalanceCloudy
                        text: "Cloudy"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-whitebalance-tungsten-screen"
                        value: MeegoCamera.WhiteBalanceIncandescent
                        text: "Incandescent"
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-whitebalance-fluorescent-screen"
                        value: MeegoCamera.WhiteBalanceFluorescent
                        text: "Fluorescent"
                    }
                }
            }

            onClicked: propertyPopup.toggleOn(wbModesButton.model)

        }

        CameraPropertyButton {
            id : exposureCompensationButton

            width: parent.height * 2 + parent.height * 3 / 4
            height: parent.height
            hMargin: parent.height / 3
            fontSize: 0.66
            imageMargins: 0

            icon: exposureCompensationButtonListModel.get(exposureCompensationButtonModel.currentIndex()).icon
            text: "Ev:"

            model: CameraPropertyModel {
                id: exposureCompensationButtonModel

                currentValue: settings.exposureCompensation

                model: ListModel {
                    id: exposureCompensationButtonListModel
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-minus2"
                        value: -2.0
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-minus17"
                        value: -1.7
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-minus1"
                        value: -1.0
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-minus07"
                        value: -0.7
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-minus03"
                        value: -0.3
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-0"
                        value: 0.0
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-plus03"
                        value: 0.3
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-plus07"
                        value: 0.7
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-plus1"
                        value: 1.0
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-plus13"
                        value: 1.3
                        text: ""
                    }
                    ListElement {
                        icon: "image://theme/icon-m-camera-exposure-plus2"
                        value: 2.0
                        text: ""
                    }
                }
            }

            onClicked: propertyPopup.toggleOn(exposureCompensationButton.model)
        }
    }

}
