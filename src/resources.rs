use qmetaobject::prelude::*;

qrc!(load_resources_inner,
  "qml" {
    "src/main.qml",
  },
);

pub fn load_resources() {
  load_resources_inner()
}
