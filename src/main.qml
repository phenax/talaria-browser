import QtQuick 2.9;
import QtQuick.Window 2.0;
// import QtQuick.Controls 1.2;
import QtQuick.Controls 2.15;
import QtWebEngine 1.8;
import QtQuick.Layouts 1.15;

import Talaria 1.0;
import "widgets" as TalariaWidgets;

QtObject {
  id: root

  // Spawn first window
  Component.onCompleted: windowComponent.createObject(root)

  property Component windowComponent: Window {
    property string loadUrl: _DEFAULT_URL

    id: currentWindow
    title: "Talaria Browser"
    visible: true
    width: 800
    height: 600

    Component.onCompleted: currentWindow.newTab(loadUrl)

    function newWindow(url) {
      windowComponent.createObject(root, { loadUrl: url || _DEFAULT_URL })
    }

    function closeWindow(url) {
      currentWindow.close()
    }

    function newTab(url) {
      tabListModel.open_in_new_tab(url || _DEFAULT_URL)
    }

    function closeTab(index) {
      tabListModel.delete_tab(index)
    }

    BrowserTabListModel {
      id: tabListModel

      onTabsChanged: {
        if (length() <= 0) {
          currentWindow.closeWindow()
        }
      }
    }

    TalariaWidgets.CommandMenu {
      id: commandMenu

      onSelected: id => {
        var splits = id.split(/\s+/)
        var type = splits[0]
        var url = id

        switch (type) {
          case 'go': url = 'https://google.com/search?q=' + splits.slice(1).join(' '); break;
          case 'd': url = 'https://duckduckgo.com/?q=' + splits.slice(1).join(' '); break;
          default: url = id;
        }

        if (!url.match(/^https?/)) {
          url = 'https://' + url
        }

        currentWindow.newTab(url)
      }
    }

    Column {
      anchors.fill: parent

      TalariaWidgets.Topbar {
        id: topbar
        activeTab: tabListModel.active_tab
        tabs: tabListModel.tabs

        onOpenNewTab: currentWindow.newTab()
        onTabClosed: index => currentWindow.closeTab(index)
        onCurrentIndexChanged: activeTab => {
          if (activeTab < 0) return;
          if (tabListModel.active_tab !== activeTab) {
            tabListModel.active_tab = activeTab
          }
        }
      }

      StackLayout {
        id: tabStack
        currentIndex: topbar.activeTab
        width: parent.width
        height: parent.height - topbar.height

        Repeater {
          model: tabListModel.tabs

          Item {
            id: tabItem

            TalariaWidgets.WebView {
              id: webview
              url: model.page_url

              onOpenInNewWindow: url => currentWindow.newWindow(url)
              onOpenInNewTab: url => currentWindow.newTab(url)
              onCloseTab: currentWindow.closeTab(model.index)
              onLoadingProgress: (loading, progress) => {
                // console.log('>>>>', loading, progress)
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
      id: commandMenuBtn
      text: " CommandMenu "
      onClicked: commandMenu.open()
      x: parent.width - width - 5
      y: 100
    }

    Button {
      id: closeWindowButton
      text: " Close Window "
      onClicked: currentWindow.closeWindow()
      x: parent.width - width - 5
      // y: 100
      anchors.top: commandMenuBtn.bottom
    }
  }
}
