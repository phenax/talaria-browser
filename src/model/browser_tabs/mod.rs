use std::{cell::RefCell, ops::IndexMut};

use qmetaobject::{prelude::*, QMetaType, SimpleListItem, SimpleListModel, USER_ROLE};

#[derive(SimpleListItem, QObject, Default)]
struct Tab {
  base: qt_base_class!(trait QObject),

  pub page_title: qt_property!(QString),
  pub page_icon: qt_property!(QString),
  pub page_url: qt_property!(QString),
}

#[derive(QObject, Default)]
pub struct BrowserTabList {
  base: qt_base_class!(trait QObject),

  // Properties
  tabs: qt_property!(RefCell<SimpleListModel<Tab>>; NOTIFY tabs_changed),
  active_tab: qt_property!(usize; NOTIFY active_tab_changed),

  // Signals
  active_tab_changed: qt_signal!(),
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

  fn clamp_index(&self, index: usize) -> usize {
    let len = self.length();
    if len <= 1 {
      0
    } else {
      index.clamp(0, len as usize - 1)
    }
  }

  fn set_active_tab(&mut self, index: usize) {
    self.active_tab = self.clamp_index(index);
    self.active_tab_changed();
  }

  fn open_in_new_tab(&mut self, url: String) {
    let index = if self.length() > 0 {
      self.clamp_index(self.active_tab) + 1
    } else {
      0
    };

    self.tabs.borrow_mut().insert(
      index,
      Tab {
        page_url: url.into(),
        page_title: "Loading...".into(),
        page_icon: "".into(),
        ..Tab::default()
      },
    );
    self.tabs_changed();

    self.set_active_tab(index);
  }

  fn delete_tab(&mut self, index: usize) {
    let i = self.clamp_index(index);
    self.tabs.borrow_mut().remove(i);
    self.tabs_changed();
  }

  fn delete_active_tab(&mut self) {
    self.delete_tab(self.active_tab);
  }

  // fn set_tab_title(&mut self, index: usize, title: String) {
  //   let mut tabs = self.tabs.borrow_mut();
  //   let mut tabs_vec = tabs.iter().collect::<Vec<_>>();
  //   let mut tab = tabs_vec.index_mut(index);
  //   tab.page_title = title;
  //   let qidx = tabs.row_index(index as i32);
  //   tabs.data_changed(qidx, qidx);
  // }
}
