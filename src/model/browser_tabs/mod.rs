use std::{cell::RefCell, ops::IndexMut};

use qmetaobject::{prelude::*, SimpleListItem, SimpleListModel};

#[derive(SimpleListItem, Clone, Default)]
struct Tab {
  pub page_title: String,
  pub page_icon: String,
  pub page_url: String,
}

#[derive(QObject, Default)]
pub struct BrowserTabList {
  base: qt_base_class!(trait QObject),

  // Properties
  tabs: qt_property!(RefCell<SimpleListModel<Tab>>; NOTIFY tabs_changed),
  active_tab: qt_property!(usize; NOTIFY current_tab_index_changed),

  // Signals
  current_tab_index_changed: qt_signal!(),
  tabs_changed: qt_signal!(),

  // Methods
  open_in_new_tab: qt_method!(fn(&mut self, url: String)),
  delete_tab: qt_method!(fn(&mut self, index: usize)),
  length: qt_method!(fn(&self) -> i32),
  set_active_tab: qt_method!(fn(&mut self, index: usize)),
  delete_active_tab: qt_method!(fn(&mut self)),
  // set_tab_title: qt_method!(fn(&mut self, index: usize, title: String)),
}

impl BrowserTabList {
  fn length(&self) -> i32 {
    self.tabs.borrow().row_count()
  }

  fn index(&self, index: usize) -> usize {
    let len = self.length();
    index.clamp(0, len as usize - 1)
  }

  fn set_active_tab(&mut self, index: usize) {
    self.active_tab = self.index(index);
    self.current_tab_index_changed();
  }

  fn open_in_new_tab(&mut self, url: String) {
    self.tabs.borrow_mut().push(Tab {
      page_url: url,
      page_title: "Loading...".to_string(),
      page_icon: "".to_string(),
    });
    self.tabs_changed();

    let tab_len = self.length();
    self.set_active_tab(tab_len as usize - 1);
  }

  fn delete_tab(&mut self, index: usize) {
    let i = self.index(index);
    self.tabs.borrow_mut().remove(i);
    self.tabs_changed();
  }

  fn delete_active_tab(&mut self) {
    self.delete_tab(self.active_tab);
  }

  //fn set_tab_title(&mut self, index: usize, title: String) {
  //let tabs = self.tabs.borrow_mut();
  //let mut tabs_vec = tabs.iter().collect::<Vec<_>>();
  //let i = self.index(index);
  //let tab = *tabs_vec.index_mut(i);
  //tab.to_owned().page_title = title;
  //self.tabs_changed();
  //}
}
