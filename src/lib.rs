use qmetaobject::prelude::*;
#[cfg(not(no_qt))]
use qmetaobject::webengine;

mod resources;

pub fn run_webengine() {
  std::env::set_var("QTWEBENGINE_REMOTE_DEBUGGING", "9000");

  #[cfg(not(no_qt))]
  webengine::initialize();

  resources::load_resources();

  let mut engine = QmlEngine::new();
  engine.load_file("qrc:/qml/src/main.qml".into());

  #[cfg(not(no_qt))]
  engine.exec();
}
