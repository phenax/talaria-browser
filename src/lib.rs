#[cfg(not(no_qt))]
use qmetaobject::webengine;
use qmetaobject::{prelude::*, QMetaType};

mod model;
mod resources;

pub fn run_webengine() {
  // std::env::set_var("QTWEBENGINE_REMOTE_DEBUGGING", "9000");

  #[cfg(not(no_qt))]
  webengine::initialize();

  resources::load_resources();
  model::register_all();

  let mut engine = QmlEngine::new();
  engine.set_property(
    "defaultUrl".into(),
    "https://duckduckgo.com".to_string().to_qvariant(),
  );
  engine.load_file("qrc:/qml/src/main.qml".into());

  #[cfg(not(no_qt))]
  engine.exec();
}
