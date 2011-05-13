import QtQuick 1.0


Item {
    anchors.fill: parent
    visible:  false
    //focus:  true
    Loader { id: pageLoader
             anchors.fill: parent
             source : ""
             focus:  true
    }

    onVisibleChanged: {
    if ( visible )
        {
        pageLoader.source = "declarative-camera.qml"
        pageLoader.focus = true
        }
    else
        {
        pageLoader.source = ""
        }
    }
}
