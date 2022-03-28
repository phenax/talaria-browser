import QtQuick 2.9;
import QtQuick.Controls 2.15;

import "." as TalariaWidgets;

Row {
  signal openNewTab()
  signal currentIndexChanged(int activeTab)
  signal tabClosed(int index)

  property int activeTab
  property var tabs

  id: root
  width: parent.width

  TabBar {
    id: tabBar
    width: parent.width - newTabBtn.width
    currentIndex: root.activeTab

    onCurrentIndexChanged: root.currentIndexChanged(tabBar.currentIndex)

    Repeater {
      model: root.tabs

      TalariaWidgets.Tab {
        page_title: model.page_title
        page_url: model.page_url
        page_icon: model.page_icon
        onTabClosed: root.tabClosed(model.index)
      }
    }
  }

  Button {
    id: newTabBtn
    width: 50
    height: tabBar.height
    onClicked: root.openNewTab()
    text: "+"
  }
}
