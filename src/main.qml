import QtQuick 2.6;
import QtQuick.Window 2.0;
import QtWebEngine 1.4

Window {
  title: "Talaria"
  visible: true
  width: 800
  height: 600

  WebEngineView {
    anchors.fill: parent
    url: "https://html5test.com"
  }
}
