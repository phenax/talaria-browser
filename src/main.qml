import QtQuick 2.9;
import QtQuick.Window 2.0;
import QtQuick.Controls 1.2;
import QtWebEngine 1.8;

import Talaria 1.0;

QtObject {
  id: rootNode
  // Spawn first window
  Component.onCompleted: windowComponent.createObject(rootNode);

  property Component windowComponent: Window {
    property string loadUrl: "https://google.com"

    title: "Talaria Browser"
    visible: true
    width: 800
    height: 600

    Component.onCompleted: newTab(loadUrl)

    function newWindow(url) {
      windowComponent.createObject(rootNode, { loadUrl: url || 'https://google.com' });
    }

    function getWebView(index) {
      var tab = tabView.getTab(index)
      return tab && tab.item
    }

    function getCurrentWebView() {
      return getWebView(tabView.currentIndex)
    }

    function webViewLoadProgress() {
      var webview = getCurrentWebView()
      return webview ? webview.loadProgress : 0
    }

    function newTab(url) {
      browserTabList.open_in_new_tab(url || "https://google.com")
    }

    BrowserTabList {
      id: browserTabList

      Component.onCompleted: {
        newTab("https://google.com")
        newTab("https://html5test.com")
      }
    }

    TabView {
      id: tabView
      anchors.fill: parent
      currentIndex: browserTabList.current_tab_index
      frameVisible: false
      tabsVisible: true

      Repeater {
        model: browserTabList.tabs

        Tab {
          id: tabItem
          title: "Loading..."

          WebEngineView {
            id: webview
            anchors.fill: parent
            anchors.bottomMargin: statusBar.height
            url: page_url.toString()

            onNewViewRequested: function(request) {
              switch (request.destination) {
                case WebEngineView.NewViewInWindow:
                case WebEngineView.NewViewInDialog:
                  newWindow(request.requestedUrl.toString());
                  break;
                case WebEngineView.NewViewInBackgroundTab:
                case WebEngineView.NewViewInTab:
                  newTab(request.requestedUrl.toString())
                  break;
                default: break;
              }
            }

            onWindowCloseRequested: {
              // tabListModel.remove(tabView.currentIndex, 1)
              // webview.destroy()
            }

            onLoadingChanged: {
              var prefix = webview.loading ? webview.loadProgress + '% | ' : ''
              tabItem.title = prefix + (webview.title || 'Loading...').slice(0, 20) + '...'
            }
          }
        }
      }
    }

    Rectangle {
      id: statusBar
      color: "black"
      height: 18
      width: parent.width
      y: parent.height - height

      Text {
        text: getCurrentWebView().url
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        color: "white"
      }

      Text {
        text: webViewLoadProgress() + "%"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        height: parent.height
        color: "white"
      }
    }

    Button {
      id: newTabButton
      text: " + "
      onClicked: newTab()
      x: parent.width - newTabButton.width - 5
      y: 5
    }
  }
}
