import QtQuick 2.6;
import QtQuick.Window 2.0;
import QtQuick.Controls 1.2;
import QtWebEngine 1.8;

QtObject {
  id: rootNode
  // Spawn first window
  Component.onCompleted: windowComponent.createObject(rootNode);

  property Component windowComponent: Window {
    property string loadUrl: "https://google.com"

    title: "Talaria"
    visible: true
    width: 800
    height: 600

    Component.onCompleted: tabListModel.insert(0, { pageUrl: loadUrl })

    ListModel {
      id: tabListModel

      ListElement {
        pageUrl: "https://html5test.com"
      }

      ListElement {
        pageUrl: "https://google.com"
      }
    }

    TabView {
      id: tabView
      anchors.fill: parent

      Repeater {
        model: tabListModel

        Tab {
          id: tabItem
          title: "Loading..."

          WebEngineView {
            id: webview
            anchors.fill: parent
            anchors.bottomMargin: 20
            url: pageUrl

            onNewViewRequested: function(request) {
              switch (request.destination) {
                case WebEngineView.NewViewInWindow:
                case WebEngineView.NewViewInDialog:
                  tabView.newWindow(request.requestedUrl.toString());
                  break;
                case WebEngineView.NewViewInBackgroundTab:
                case WebEngineView.NewViewInTab:
                  tabView.newTab(request.requestedUrl.toString())
                  break;
                default: break;
              }
            }

            onWindowCloseRequested: {
              tabListModel.remove(tabView.currentIndex, 1)
              webview.destroy()
            }

            onLoadingChanged: {
              tabItem.title = (webview.title || 'Loading...').slice(0, 20) + '...'
            }
          }
        }
      }

      function newWindow(url) {
        windowComponent.createObject(rootNode, { loadUrl: url || 'https://google.com' });
      }

      function newTab(url) {
        tabListModel.insert(tabView.currentIndex, { pageUrl: url || 'https://google.com' })
      }

      function getCurrentWebView() {
        var tab = tabView.getTab(tabView.currentIndex)
        return tab && tab.item
      }

      function webViewLoadProgress() {
        var webview = tabView.getCurrentWebView()
        if (webview && webview.loading) {
          return webview.loadProgress
        }
        return 0
      }
    }

    Rectangle {
      color: "black"
      height: 18
      width: parent.width
      y: parent.height - height

      Text {
        text: tabView.getCurrentWebView().url
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        color: "white"
      }

      Text {
        text: tabView.webViewLoadProgress() + "%"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        height: parent.height
        color: "white"
      }
    }

    Button {
      id: newTabButton
      text: "Open new tab"
      onClicked: tabView.newTab()
      x: parent.width - newTabButton.width - 5
      y: 5
    }
  }
}
