import QtQuick 2.9;
import QtQuick.Controls 2.15;
import QtWebEngine 1.8;

WebEngineView {
  signal openInNewWindow(string url)
  signal openInNewTab(string url)
  signal closeTab()
  signal loadingProgress(bool loading, int progress)

  // property String url

  id: root
  anchors.fill: parent
  // anchors.bottomMargin: statusBar.height

  onNewViewRequested: function(request) {
    switch (request.destination) {
      case WebEngineView.NewViewInWindow:
      case WebEngineView.NewViewInDialog:
        root.openInNewWindow(request.requestedUrl.toString())
        break;
      case WebEngineView.NewViewInBackgroundTab:
      case WebEngineView.NewViewInTab:
        root.openInNewTab(request.requestedUrl.toString())
        break;
      default: break;
    }
  }

  onWindowCloseRequested: {
    root.closeTab()
    root.deleteLater()
  }

  onLoadingChanged: {
    root.loadingProgress(root.loading, root.loadProgress)
    // var prefix = root.loading ? root.loadProgress + '% | ' : ''
    // var title = prefix + (root.title || 'Loading...').slice(0, 20) + '...'
    // model.page_title = title
    // tabListModel.set_tab_title(index, title)
  }
}
