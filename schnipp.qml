import QtQuick 2.9
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Controls.Universal 2.4
import QtMultimedia 5.6
import QtQuick.Dialogs 1.3
import QtQml 2.4
import QtQuick.Window 2.2
import QtQuick.Extras 1.4
import Qt.labs.settings 1.1

Window {
    //visibility: "FullScreen"
    visibility: "Maximized"

    Settings {
       
    }

    Timer {
        /**
         * Refreshes elapsed time label and progress bar to show video position.
         **/
        interval: 100; running: true; repeat: true
        onTriggered: {
            elapsedTimeLabel.text = new Date(video.position).toLocaleTimeString(Qt.locale(), "mm:ss") +
                                  ' / ' + new Date(video.duration).toLocaleTimeString(Qt.locale(), "mm:ss")
            videoProgressBar.value = video.position / video.duration
        }
    }

    visible: true
    width: 1000
    height: 700
    title: qsTr('Schnipp!')
    
    Pane {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 10

        ColumnLayout {
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            spacing: 10

            Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
            Keys.onLeftPressed: video.seek(video.position - 5000)
            Keys.onRightPressed: video.seek(video.position + 5000)
            
            Video {
                id: video
                width: parent.width
                height: 500
                Layout.fillHeight: true
                Layout.fillWidth: true

                focus: true
                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    border.color: 'black'
                    color: '#000000ff'
                }

                source: 'concat.mp4'
                //muted: true

                MouseArea {
                    /**
                    * Highlights a area marked by mouse.
                    *
                    * Source: https://stackoverflow.com/a/25865131
                    **/
                    id: selectArea;
                    anchors.fill: parent;

                    property int stage: 1

                    // properties to be set in the GUI (in pixel of given video!)
                    property int topLetterboxBar: 0
                    property int bottomLetterboxBar: 0
                    property int xv1: 0
                    property int xv2: 0 
                    property int yv1: 0 
                    property int yv2: 0

                    onPressed: {
                        if (stage == 1) {
                            if (highlightLetterbox1 !== null && highlightLetterbox2 !== null) {
                                console.log('Letterbox rectangles already instantiated.')
                            }
                            else {
                                // create two editable rectangles from the top down and the bottom up
                                highlightLetterbox1 = highlightComponent.createObject(selectArea, {
                                    'y': selectArea.y,
                                    'height': Math.abs(selectArea.y - mouse.y),
                                    'color': 'green',
                                    'anchors.left': selectArea.left,
                                    'anchors.right': selectArea.right
                                });
                                highlightLetterbox2 = highlightComponent.createObject(selectArea, {
                                    'y': selectArea.height - Math.abs(selectArea.y - mouse.y),
                                    'height': Math.abs(selectArea.y - mouse.y),
                                    'color': 'green',
                                    'anchors.left': selectArea.left,
                                    'anchors.right': selectArea.right
                                });
                            }
                        }
                        else if (stage == 2) {
                            if (highlightLogo !== null) {
                                highlightLogo.destroy()
                            }
                            // create a new rectangle for the broadcaster logo
                            highlightLogo = highlightComponent.createObject(selectArea, {
                                'x' : mouse.x,
                                'y' : mouse.y,
                                'color': 'yellow'
                            });
                        }
                    }
                    onPositionChanged: {
                        // on move, update the width of rectangle
                        if (stage == 1) {
                            if (mouse.y < parent.height/2) {
                                highlightLetterbox1.height = Math.abs(selectArea.y - mouse.y)
                                highlightLetterbox2.y = selectArea.height - Math.abs(selectArea.y - mouse.y)
                                highlightLetterbox2.height = Math.abs(selectArea.y - mouse.y)
                                topLetterboxBar = video.metaData.resolution.height / parent.height * Math.abs(selectArea.y - mouse.y)
                                bottomLetterboxBar = topLetterboxBar
                            }
                            else {
                                highlightLetterbox2.y = mouse.y
                                highlightLetterbox2.height = Math.abs(selectArea.height - mouse.y)
                                bottomLetterboxBar = video.metaData.resolution.height / parent.height * Math.abs(selectArea.height - mouse.y)
                            }
                        }
                        else if (stage == 2) {
                            // TODO: Check if mouse.{x,y} is outside video widget.
                            highlightLogo.width = (Math.abs(mouse.x - highlightLogo.x));
                            highlightLogo.height = (Math.abs(mouse.y - highlightLogo.y));
                        }
                    }
                    onReleased: {
                        if (stage == 1) {
                            console.log('Changed letterbox bars to: ' + topLetterboxBar + ', ' + bottomLetterboxBar)
                        }
                        else if (stage == 2) {
                            var xs1 = highlightLogo.x
                            var xs2 = highlightLogo.x + highlightLogo.width
                            var ys1 = highlightLogo.y
                            var ys2 = highlightLogo.y + highlightLogo.height
                            xv1 = video.metaData.resolution.width / parent.width * xs1
                            xv2 = video.metaData.resolution.width / parent.width * xs2
                            yv1 = video.metaData.resolution.height / parent.height * ys1
                            yv2 = video.metaData.resolution.height / parent.height * ys2   
                            console.log('Choosen clipping on screen: (' + xs1 + ', ' + ys1 + ') to (' + xs2 + ', ' + ys2 + ').')
                            console.log('Choosen clipping on video: (' + xv1 + ', ' + yv1 + ') to (' + xv2 + ', ' + yv2 + ').')
                        }
                    }

                    property Rectangle highlightLogo : null;
                    property Rectangle highlightLetterbox1 : null;
                    property Rectangle highlightLetterbox2 : null;

                    Component {
                        id: highlightComponent;

                        Rectangle {
                            opacity: 0.35;
                        }
                    }
                }
            }

            Pane {
                anchors.margins: 10

                Row {
                    spacing: 10

                    Button {
                        text:  qsTr('Choose video file...')
                        background.anchors.fill: this
                        spacing: 40

                        FileDialog {
                            id: fileDialog
                            title: qsTr('Choose a video file...')
                            //folder: shortcuts.home
                            nameFilters: [ qsTr('Video Files (*.mp4 *.flv *.ts *.mts *.avi *.mkv)'), qsTr('All files (*)') ]
                            selectMultiple: false
                            visible: false
                            onAccepted: {
                                console.log('You chose: ' + fileDialog.fileUrls)
                                video.source = fileDialog.fileUrls[0]
                                video.height = video.width / video.metaData.resolution.width * video.metaData.resolution.height
                                console.log('Loaded title: ' + video.metaData.title)
                                console.log('Loaded resolution: ' + video.metaData.resolution)
                                console.log('Loaded pixelAspectRatio: ' + video.metaData.pixelAspectRatio)
                                console.log('Loaded videoFrameRate: ' + video.metaData.videoFrameRate)
                            }
                            onRejected: {
                                console.log("Canceled")
                            }
                        }
                        
                        onClicked: {
                            fileDialog.visible = true
                        }
                    }
                    Button {
                        id: playButton
                        text: qsTr('Play')
                        onClicked: {
                            if (video.playbackState == MediaPlayer.PlayingState) {
                                text = qsTr('Play')
                                video.pause()
                            }
                            else if (video.playbackState == MediaPlayer.PausedState) {
                                text = qsTr('Pause')
                                video.play()
                            }
                            else if (video.playbackState == MediaPlayer.StoppedState) {
                                text = qsTr('Pause')
                                video.play()
                            }
                        }
                    }
                    Button {
                        text: qsTr('Stop')
                        onClicked: {
                            video.stop()
                            playButton.text = qsTr('Play')
                            selectArea.highlightLogo.destroy()
                            selectArea.highlightLetterbox1.destroy()
                            selectArea.highlightLetterbox2.destroy()
                        }
                    }
                    Button {
                        text: qsTr('Rewind')
                        onClicked: {
                            video.seek(video.position - 5000)
                        }
                    }
                    Button {
                        text: qsTr('Forward')
                        onClicked: {
                            video.seek(video.position + 5000)
                        }
                    }

                    Label {
                        id: elapsedTimeLabel
                        text: ''
                        elide: Label.ElideRight
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignCenter
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    ProgressBar {
                        id: videoProgressBar
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        value: 0.5
                    }   
                }
            }

            Pane {
                Row {
                    RadioButton {
                        checked: true
                        text: qsTr('Set Letterbox bars...')
                        onClicked: {
                            selectArea.stage = 1
                            cutListPane.visible = false
                        }
                    }
                    RadioButton {
                        text: qsTr('Set logo...')
                        onClicked: {
                            selectArea.stage = 2
                            cutListPane.visible = false
                        }
                    }
                    RadioButton {
                        text: qsTr('Set commercial breaks...')
                        onClicked: {
                            selectArea.stage = 3
                            cutListPane.visible = true
                        }
                    }
                    RadioButton {
                        text: qsTr('Export...')
                        onClicked: {
                            selectArea.stage = 4
                            console.log(`drm_dvr --preview . --delogo x=${selectArea.xv1}:y=${selectArea.yv1}:w=${selectArea.xv2-selectArea.xv1}:h=${selectArea.yv2-selectArea.yv1} --crop in_w:in_h-${selectArea.yv2-selectArea.yv1}:0:${selectArea.yv1}`)
                            video.grabToImage(function(result) {
                                result.saveToFile('screengrab.png');
                            });
                            var jsonOutput = {
                                crop: [0, selectArea.topLetterboxBar],
                                delogo: [selectArea.xv1, selectArea.yv1, selectArea.xv2-selectArea.xv1, selectArea.yv2-selectArea.yv1],
                                cutlist: []
                            };
                            var i;
                            for (i=0; i < cutListModel.count; i++) {
                                var tmp = cutListModel.get(i)
                                var startTime = new Date(tmp.startTime).toLocaleTimeString(Qt.locale(), "mm:ss")
                                var endTime = new Date(tmp.endTime).toLocaleTimeString(Qt.locale(), "mm:ss")
                                jsonOutput['cutlist'].push([startTime, endTime])
                            }
                            var jsonString = JSON.stringify(jsonOutput, null, 4)
                            console.log(jsonString)
                            //jsonOutput.writeFile('drm_dvr.cfg', jsonOutput)
                        }
                    }
                }
            }
        }

        Pane {
            id: cutListPane
            visible: false
            Layout.minimumWidth: 250
            Layout.maximumWidth: 250
            Layout.fillHeight: true
            Layout.fillWidth: true  
            Layout.alignment: Qt.AlignRight
            ScrollView {
                anchors.fill: parent
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                Component {
                    id: highlight
                    Rectangle { 
                        width: parent.width
                        height: 25
                        color: "lightsteelblue"
                        radius: 5 
                        y: cutListView.currentItem.y
                        Behavior on y {
                            SpringAnimation {
                                spring: 3
                                damping: 0.2
                            }
                        }
                    }
                }

                ListView {
                    id: cutListView
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height

                    keyNavigationWraps: true
                    highlightMoveDuration: 500
                    highlightMoveVelocity: -1
                    highlight: highlight
                    highlightFollowsCurrentItem: true
                    add: Transition {
                        NumberAnimation { properties: "x,y"; from: 100; duration: 500 }
                    }
                    populate: Transition {
                        NumberAnimation { properties: "x,y"; duration: 500 }
                    }
                    remove: Transition {
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; to: 0; duration: 500 }
                            NumberAnimation { properties: "x,y"; to: 100; duration: 500 }
                        }
                    }
                    
                    spacing: 15
                    displayMarginBeginning: 40
                    displayMarginEnd: 40
                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }

                    ListModel {
                        id: cutListModel
                    }
                    model: cutListModel
                   
                    delegate: Rectangle {
                        objectName: "delegate"
                        width: parent.width
                        height: 25
                        //color: index % 2 ? 'gray' : 'white'
                        //color: index % 2 ? 'gray' : 'white'
                        color: '#000000ff'
                        Text {
                            anchors.left: parent.left
                            text: `Cut from ${new Date(startTime).toLocaleTimeString(Qt.locale(), "mm.ss")} to ${new Date(endTime).toLocaleTimeString(Qt.locale(), "mm.ss")}`
                            //font.pixelSize: 14
                            MouseArea {
                                anchors.fill: parent
                                onClicked: cutListView.currentIndex = index
                            }
                        }
                        Button {
                            anchors.right: parent.right
                            text: 'x'
                            onClicked: {
                                cutListModel.remove(index)
                            }
                        }
                        ListView.onAdd: {
                            cutListView.currentIndex = index
                        }
                    }

                    header: Rectangle { 
                        width: parent.width; height: 40
                        anchors.bottomMargin: 40
                        color: '#000000ff'
                        Text {
                            anchors.centerIn: parent
                            text: 'Cut list'
                            font.pixelSize: 16
                        }
                    }

                    footer: Rectangle { 
                        width: parent.width; height: 40
                        radius: 5 
                        anchors.topMargin: 40
                        Row {
                            anchors.fill: parent
                            Button {
                                anchors.left: parent.left
                                width: parent.width / 2
                                height: parent.height
                                text: 'Set start time'
                                onClicked: {
                                    cutListModel.append({'startTime': video.position, 'endTime': 42})
                                }
                            }
                            Button {
                                anchors.right: parent.right
                                width: parent.width / 2
                                height: parent.height
                                text: 'Set end time'
                                onClicked: {
                                    cutListModel.get(cutListModel.count-1).endTime = video.position
                                }
                            }
                        }
                    } 
                }
            }
        }
        }
    }
}
