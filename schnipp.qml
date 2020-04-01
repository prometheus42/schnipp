import QtQuick 2.4
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Controls.Universal 2.4
import QtMultimedia 5.6
import QtQuick.Dialogs 1.3
import QtQml 2.4

// ApplicationWindow???
Pane {
    Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
    Keys.onLeftPressed: video.seek(video.position - 5000)
    Keys.onRightPressed: video.seek(video.position + 5000)
    
    Timer {
        /**
         * Refreshes elapsed time label and progress bar to show video position.
         **/
        interval: 100; running: true; repeat: true
        onTriggered: {
            elapsedTimeLabel.text = new Date(video.position).toLocaleTimeString(Qt.locale(), "mm.ss") +
                                  ' / ' + + new Date(video.duration).toLocaleTimeString(Qt.locale(), "mm.ss") 
            videoProgressBar.value = video.position / video.duration
        }
    }

    width : 1000
    height : 700
    
    Video {
        id: video
        width: parent.width
        height: 500
        //anchors.top: parent.top
        //Layout.fillWidth: true
        //anchors.centerIn: parent
        focus: true
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            border.color: 'black'
            color: '#000000ff'
        }

        source: 'video.mkv'
        muted: true

        MouseArea {
            /**
             * Highlights a area marked by mouse.
             *
             * Source: https://stackoverflow.com/a/25865131
             **/
            id: selectArea;
            anchors.fill: parent;
            onPressed: {
                if (highlightItem !== null) {
                    // if there is already a selection, delete it
                    highlightItem.destroy (); 
                }
                // create a new rectangle at the wanted position
                highlightItem = highlightComponent.createObject (selectArea, {
                    'x' : mouse.x,
                    'y' : mouse.y
                });
                // here you can add you zooming stuff if you want
            }
            onPositionChanged: {
                // on move, update the width of rectangle
                highlightItem.width = (Math.abs (mouse.x - highlightItem.x));
                highlightItem.height = (Math.abs (mouse.y - highlightItem.y));
            }
            onReleased: {
                // here you can add you zooming stuff if you want
                var xs1 = highlightItem.x
                var xs2 = highlightItem.x + highlightItem.width
                var ys1 = highlightItem.y
                var ys2 = highlightItem.y + highlightItem.height
                var xv1 = video.metaData.resolution.width / parent.width * xs1
                var xv2 = video.metaData.resolution.width / parent.width * xs2
                var yv1 = video.metaData.resolution.height / parent.height * ys1
                var yv2 = video.metaData.resolution.height / parent.height * ys2
                
                console.log('Choosen clipping on screen: (' + xs1 + ', ' + ys1 + ') to (' + xs2 + ', ' + ys2 + ').')
                console.log('Choosen clipping on video: (' + xv1 + ', ' + yv1 + ') to (' + xv2 + ', ' + yv2 + ').')
            }

            property Rectangle highlightItem : null;

            Component {
                id: highlightComponent;

                Rectangle {
                    color: 'yellow';
                    opacity: 0.30;
                    /*anchors {
                        top: parent.top;
                        bottom: parent.bottom;
                    }*/
                }
            }
        }
    }

    Pane{
        anchors.bottom: parent.bottom
        anchors.margins: 10

        Row {
            spacing: 10

            Button {
                text: 'Choose video file...'
                background.anchors.fill: this
                spacing: 40

                FileDialog {
                    id: fileDialog
                    title: 'Choose a video file...'
                    //folder: shortcuts.home
                    nameFilters: [ 'Video Files (*.mp4 *.flv *.ts *.mts *.avi *.mkv)', 'All files (*)' ]
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
                text: 'Play'
                onClicked: {
                    if (video.playbackState == MediaPlayer.PlayingState) {
                        text: 'Play'
                        video.pause()
                    }
                    else if (video.playbackState == MediaPlayer.PausedState) {
                        text = 'Pause'
                        video.play()
                    }
                    else if (video.playbackState == MediaPlayer.StoppedState) {
                        text = 'Pause'
                        video.play()
                    }
                }
            }
            Button {
                text: 'Stop'
                onClicked: {
                    video.stop()
                    playButton.text = 'Play'
                }
            }
            Button {
                text: 'Rewind'
                onClicked: {
                    video.seek(video.position - 5000)
                }
            }
            Button {
                text: 'Forward'
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
}
