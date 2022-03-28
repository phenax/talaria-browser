import QtQuick 2.9;
import QtQuick.Controls 2.15;

TabButton {
  id: tabButton

  signal tabClosed()

  property string page_title
  property string page_url
  property string page_icon

  text: page_title + ' | ' + page_url
  implicitHeight: 32
  icon {
    source: "https://github.com/favicon.ico" // page_icon
  }

  contentItem: Rectangle {
    anchors.fill: parent
    color: tabButton.checked ? tabButton.palette.window : tabButton.palette.dark

    Image {
      id: favicon
      width: 12
      height: width
      anchors.verticalCenter: parent.verticalCenter
      x: 8
      source: tabButton.icon.source
      cache: true
      fillMode: Image.PreserveAspectFit
      smooth: true
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: favicon.right
      anchors.leftMargin: 8
      clip: true
      width: parent.width - favicon.width - closeButton.width - 20
      text: tabButton.text
      font: tabButton.font
      color: tabButton.checked ? tabButton.palette.windowText : tabButton.palette.brightText
    }

    Button {
      id: closeButton
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      width: 20
      // anchors.rightMargin: 8
      text: 'X'
      palette.buttonText: "red"
      onClicked: tabButton.tabClosed()
      // display: AbstractButton.IconOnly
      background.opacity: 0
    }
  }
}
