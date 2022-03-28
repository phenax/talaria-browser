import QtQuick 2.9;
import QtQuick.Window 2.0;
// import QtQuick.Controls 1.2;
import QtQuick.Controls 2.15;
import QtWebEngine 1.8;
import QtQuick.Layouts 1.15;

import Talaria 1.0;
import "widgets" as Talaria

QtObject {
  id: rootNode

  // Spawn first window
  Component.onCompleted: windowComponent.createObject(rootNode);

  property Component windowComponent: Window {
    property string loadUrl: defaultUrl

    id: currentWindow
    title: "Talaria Browser"
    visible: true
    width: 800
    height: 600

    Component.onCompleted: newTab(loadUrl)

    function newWindow(url) {
      windowComponent.createObject(rootNode, { loadUrl: url || defaultUrl })
    }

    function closeWindow(url) {
      currentWindow.close()
    }

    function newTab(url) {
      tabListModel.open_in_new_tab(url || defaultUrl)
    }

    function closeTab(index) {
      tabListModel.delete_tab(index)
    }

    BrowserTabListModel {
      id: tabListModel

      Component.onCompleted: {
        newTab("https://google.com")
        newTab("https://html5test.com")
      }

      onTabsChanged: {
        if (length() <= 0) {
          closeWindow()
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
          if (tabBar.currentIndex < 0) return;
          if (tabListModel.active_tab !== tabBar.currentIndex) {
            tabListModel.active_tab = tabBar.currentIndex
          }
        }

        Repeater {
          model: tabListModel.tabs

          Talaria.Tab {
            page_title: model.page_title
            page_url: model.page_url
            page_icon: model.page_icon
            onTabClosed: closeTab(model.index)
          }
        }

        Button {
          id: newTabBtn
          width: 80
          text: "+"
        }
      }

      StackLayout {
        id: tabStack
        currentIndex: tabBar.currentIndex
        width: parent.width
        height: parent.height - tabBar.height

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
                // tabListModel.set_tab_title(index, title)
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
                  + webview.loadProgress + "%"
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
      text: " New tab "
      onClicked: newTab()
      x: parent.width - width - 5
      y: 0
    }

    Button {
      id: closeTabButton
      text: " Close Tab "
      onClicked: tabListModel.delete_active_tab()
      x: parent.width - width - 5
      y: 40
    }

    Button {
      id: closeWindowButton
      text: " Close Window "
      onClicked: closeWindow()
      x: parent.width - width - 5
      y: 80
    }
  }
}
