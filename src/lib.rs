#[cfg(not(no_qt))]
use qmetaobject::webengine;
use qmetaobject::{prelude::*, QMetaType};

mod model;
mod resources;

pub fn create_application() -> QQuickView {
  // std::env::set_var("QTWEBENGINE_REMOTE_DEBUGGING", "9000");

  #[cfg(not(no_qt))]
  webengine::initialize();

  resources::load_resources();
  model::register_all();

  let mut view = QQuickView::new();

  let engine = view.engine();
  engine.set_property(
    "_DEFAULT_URL".into(),
    "https://duckduckgo.com".to_string().to_qvariant(),
  );
  engine.load_file("qrc:/qml/src/main.qml".into());

  view
}

pub fn run_application() {
  let mut view = create_application();
  let engine = view.engine();

  #[cfg(not(no_qt))]
  engine.exec();
}
