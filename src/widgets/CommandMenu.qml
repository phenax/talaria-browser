import QtQuick 2.9;
import QtQuick.Controls 2.15;

Popup {
  signal selected(string id)

  property bool closeOnSelect: true;
  property int yOffset: 20;

  id: root
  width: Math.min(parent.width * 0.8, 1000)
  height: 400
  modal: true
  focus: true
  closePolicy: Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
  padding: 0

  x: Math.round((parent.width - width) / 2)
  y: yOffset

  property var _easing: Easing.InOutQuart

  property int _animTranslate: 100

  enter: Transition {
    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: _easing }
    NumberAnimation { property: "y"; from: yOffset + _animTranslate; to: yOffset; easing.type: _easing }
  }
  exit: Transition {
    NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: _easing }
    NumberAnimation { property: "y"; from: yOffset; to: yOffset + _animTranslate; easing.type: _easing }
  }

  Overlay.modal: Rectangle {
    color: "#aa000000"
  }

  ListModel {
    id: dummyAutoCompleteModel
    ListElement { url: "https://google.com"; title: "Google" }
    ListElement { url: "https://duckduckgo.com"; title: "DuckDuckGo" }
    ListElement { url: "https://youtube.com"; title: "Youtube" }
  }

  contentItem: Column {
    id: content
    anchors.fill: parent

    function selectItem(id) {
      if (root.closeOnSelect) {
        root.close()
      }
      root.selected(id)
    }

    Row {
      TextField {
        id: searchInput
        width: content.width
        focus: true

        onAccepted: content.selectItem(searchInput.text)
      }
    }

    Repeater {
      model: dummyAutoCompleteModel
      delegate: Button {
        onClicked: content.selectItem(model.url)
        width: parent.width
        flat: true
        height: 30
        contentItem: Text {
          text: model.title + " (" + model.url + ")"
        }
      }
    }
  }
}

