use std::{cell::RefCell, collections::HashMap};

use qmetaobject::{prelude::*, QMetaType, SimpleListItem, SimpleListModel, USER_ROLE};

#[derive(SimpleListItem, Default)]
struct Tab {
  // Properties
  pub title: String,
  pub icon: String,
  pub page_url: String,
}

#[derive(QObject, Default)]
pub struct BrowserTabList {
  base: qt_base_class!(trait QObject),

  // Properties
  tabs: qt_property!(RefCell<SimpleListModel<Tab>>; NOTIFY tabs_changed),
  current_tab_index: qt_property!(usize; NOTIFY current_tab_index_changed),

  // Signals
  current_tab_index_changed: qt_signal!(),
  tabs_changed: qt_signal!(),

  // Methods
  open_in_new_tab: qt_method!(fn(&mut self, url: String)),
  // get_tab: qt_method!(fn(&self, index: usize) -> QVariant),
  // get_current_tab: qt_method!(fn(&self) -> QVariant),
}

impl BrowserTabList {
  fn open_in_new_tab(&mut self, url: String) {
    println!(">>> opening {}", url);
    let mut tabs = self.tabs.borrow_mut();
    tabs.push(Tab {
      page_url: url,
      title: "Loading...".to_string(),
      icon: "".to_string(),
    })
  }

  // fn get_tab(&self, index: usize) -> QVariant {
  //   self.tabs[index].to_qvariant()
  // }
  // fn get_current_tab(&self) -> QVariant {
  //   self.get_tab(self.current_tab_index)
  // }
}
