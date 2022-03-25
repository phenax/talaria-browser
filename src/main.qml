import QtQuick 2.6;
import QtQuick.Window 2.0;
import QtQuick.Controls 1.2;
import QtWebEngine 1.8;

Window {
  title: "Talaria"
  visible: true
  width: 800
  height: 600

  ListModel {
    id: tabListModel

    ListElement {
      pageUrl: "https://www.bennish.net/web-notifications.html"
    }

    ListElement {
      pageUrl: "https://html5test.com"
    }

    ListElement {
      pageUrl: "https://google.com"
    }
  }

  TabView {
    id: tabView
    anchors.rightMargin: 0
    anchors.bottomMargin: 0
    anchors.leftMargin: 0
    anchors.topMargin: 0
    anchors.fill: parent

    // MouseArea {
    //   anchors.fill:parent
    //   onClicked: tabView.newTab()
    // }

    Repeater {
      model: tabListModel

      Tab {
        id: tabItem
        title: "Loading..."

        WebEngineView {
          id: webview
          anchors.fill: parent
          url: pageUrl

          // devToolsView: WebEngineView {
          //   visible: false
          //   anchors.fill: parent
          //   url: "http://localhost:9000"
          // }

          onLoadingChanged: {
            tabItem.title = (webview.title || 'Loading...').slice(0, 20) + '...'
          }
        }

        // Rectangle {
        //   color: "steelblue"
        //   height: 18
        //   width: parent.width
        //   x: 0
        //   y: parent.height - height
        //   Text {
        //     text: tabItem.title + "%"
        //     color: "white"
        //   }
        // }
      }
    }

    function newTab() {
      tabListModel.push({ pageUrl: 'https://google.com' })
    }

    function loadingProgress() {
      var tab = tabView.getTab(tabView.currentIndex)
      if (tab && tab.item && tab.item.loading) {
        return tab.item.loadProgress
      }
      return 0
    }
  }

}
