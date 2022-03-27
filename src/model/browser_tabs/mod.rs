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
  delete_tab: qt_method!(fn(&mut self, index: usize)),
  length: qt_method!(fn(&self) -> i32),
  set_active_tab: qt_method!(fn(&mut self, index: usize)),
  delete_active_tab: qt_method!(fn(&mut self)),
}

impl BrowserTabList {
  fn length(&self) -> i32 {
    self.tabs.borrow().row_count()
  }

  fn set_active_tab(&mut self, index: usize) {
    let len = self.length();
    let i = index.clamp(0, len as usize - 1);

    self.current_tab_index = i;
    self.current_tab_index_changed();
  }

  fn open_in_new_tab(&mut self, url: String) {
    self.tabs.borrow_mut().push(Tab {
      page_url: url,
      title: "Loading...".to_string(),
      icon: "".to_string(),
    });
    self.tabs_changed();

    let tab_len = self.tabs.borrow().row_count();
    self.set_active_tab(tab_len as usize - 1);
  }

  fn delete_tab(&mut self, index: usize) {
    self.tabs.borrow_mut().remove(index);
    self.tabs_changed();
    self.set_active_tab(self.current_tab_index);
  }

  fn delete_active_tab(&mut self) {
    println!(":: {}", self.current_tab_index);
    self.delete_tab(self.current_tab_index);
  }
}
