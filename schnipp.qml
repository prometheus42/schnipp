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

Window {
    /*Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
    Keys.onLeftPressed: video.seek(video.position - 5000)
    Keys.onRightPressed: video.seek(video.position + 5000)*/
    
    Timer {
        /**
         * Refreshes elapsed time label and progress bar to show video position.
         **/
        interval: 100; running: true; repeat: true
        onTriggered: {
            elapsedTimeLabel.text = new Date(video.position).toLocaleTimeString(Qt.locale(), "mm.ss") +
                                  ' / ' + new Date(video.duration).toLocaleTimeString(Qt.locale(), "mm.ss")
            videoProgressBar.value = video.position / video.duration
        }
    }

    visible: true
    width: 1000
    height: 700
    title: qsTr('Schnipp!')
    
    ColumnLayout {
        anchors.fill: parent
        
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

                property int stage: 1

                // properties to be set in the GUI (in pixel of given video!)
                property int topLetterboxBar: 0
                property int bottomLetterboxBar: 0
                property int xv1: 0
                property int xv2: 0 
                property int yv1: 0 
                property int yv2: 0

                onPressed: {
                    if (highlightLogo !== null) {
                        highlightLogo.destroy()
                    }
                    if (stage == 1) {
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
                    else if (stage == 2) {
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
                        highlightLetterbox1.height = Math.abs(selectArea.y - mouse.y)
                        highlightLetterbox2.y = selectArea.height - Math.abs(selectArea.y - mouse.y)
                        highlightLetterbox2.height = Math.abs(selectArea.y - mouse.y)
                        topLetterboxBar = video.metaData.resolution.height / parent.height * Math.abs(selectArea.y - mouse.y)
                        bottomLetterboxBar = topLetterboxBar
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
                        opacity: 0.30;
                        /*anchors {
                            left: parent.left;
                            right: parent.right;
                        }*/
                    }
                }
            }
        }

        Pane {
            //anchors.bottom: parent.bottom
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

        Pane {
            Row {
                RadioButton {
                    checked: true
                    text: qsTr('Set Letterbox bars...')
                    onClicked: {
                        selectArea.stage = 1
                    }
                }
                RadioButton {
                    text: qsTr('Set logo...')
                    onClicked: {
                        selectArea.stage = 2
                    }
                }
                RadioButton {
                    text: qsTr('Export...')
                    onClicked: {
                        console.log('Top letterbox bar: ' + selectArea.topLetterboxBar)
                        console.log('Bottom letterbox bar: ' + selectArea.bottomLetterboxBar)
                        console.log('Logo: (' + selectArea.xv1 + ', ' + selectArea.yv1 + ') to (' + selectArea.xv2 + ', ' + selectArea.yv2 + ').')
                    }
                }
            }
        }
    }
}
