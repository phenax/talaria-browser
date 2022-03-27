import QtQuick 2.9;
import QtQuick.Window 2.0;
// import QtQuick.Controls 1.2;
import QtQuick.Controls 2.15;
import QtWebEngine 1.8;
import QtQuick.Layouts 1.15;

import Talaria 1.0;

QtObject {
  id: rootNode

  // Spawn first window
  Component.onCompleted: windowComponent.createObject(rootNode);

  property Component windowComponent: Window {
    property string loadUrl: defaultUrl

    title: "Talaria Browser"
    visible: true
    width: 800
    height: 600

    Component.onCompleted: newTab(loadUrl)

    function newWindow(url) {
      windowComponent.createObject(rootNode, { loadUrl: url || defaultUrl });
    }

    function getWebView(index) {
      return null
      // TODO: Fix
      // var tab = tabStack.getTab(index)
      // return tab && tab.item
    }

    function getCurrentWebView() {
      return getWebView(tabStack.currentIndex)
    }

    function webViewLoadProgress() {
      var webview = getCurrentWebView()
      return webview ? webview.loadProgress : 0
    }

    function newTab(url) {
      tabListModel.open_in_new_tab(url || defaultUrl)
    }

    BrowserTabListModel {
      id: tabListModel

      Component.onCompleted: {
        newTab("https://google.com")
        newTab("https://html5test.com")
      }

      onTabsChanged: {
        if (length() <= 0) {
          tabStack.cleanup()
          windowComponent.close()
        }
      }
    }

    Column {
      anchors.fill: parent

      TabBar {
        id: tabBar
        width: parent.width
        currentIndex: tabListModel.active_tab

        onCurrentIndexChanged: {
          if (tabListModel.active_tab !== tabBar.currentIndex) {
            tabListModel.active_tab = tabBar.currentIndex
          }
        }

        Repeater {
          model: tabListModel.tabs

          TabButton {
            text: page_title + ' | ' + page_url
            verticalPadding: 0
            topInset: 0
          }
        }
      }

      StackLayout {
        id: tabStack
        currentIndex: tabBar.currentIndex
        width: parent.width
        height: parent.height - tabBar.height

        function cleanup() {
          Array(count).fill(null).forEach((_, i) => {
            var webview = getWebView(i)
            webview && webview.destroy()
          })
        }

        Repeater {
          model: tabListModel.tabs

          Item {
            id: tabItem

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
                tabListModel.delete_tab(tabListModel.active_tab)
                webview.deleteLater()
                // webview.destroy()
              }

              onLoadingChanged: {
                var prefix = webview.loading ? webview.loadProgress + '% | ' : ''
                var title = prefix + (webview.title || 'Loading...').slice(0, 20) + '...'
                model.page_title = title
                console.log('>>>>>>>>', model.page_title, title)
              }
            }

            Rectangle {
              id: statusBar
              color: "black"
              height: 18
              width: parent.width
              y: parent.height - height

              Text {
                text: page_url
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                color: "white"
              }

              Text {
                text:
                  (tabListModel.active_tab + 1) + "/" + tabListModel.tabs.rowCount()
                  + " | "
                  + webViewLoadProgress() + "%"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: parent.height
                color: "white"
              }
            }
          }
        }
      }
    }

    Button {
      id: newTabButton
      text: " + "
      onClicked: newTab()
      x: parent.width - width - 5
      y: 5
    }

    Button {
      id: closeTabButton
      text: " CLOSE "
      onClicked: tabListModel.delete_active_tab()
      x: parent.width - width - 5
      y: 40
    }
  }
}
