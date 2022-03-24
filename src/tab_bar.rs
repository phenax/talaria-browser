use gtk::prelude::*;
use gtk::Button;

pub fn make_tab_bar() -> gtk::Box {
  let tab_bar = gtk::Box::new(gtk::Orientation::Horizontal, 0);

  let button = Button::with_label("Click me!");
  button.connect_clicked(|_| {
    eprintln!("Clicked 1!");
  });
  tab_bar.add(&button);

  let button = Button::with_label("Click me!");
  button.connect_clicked(|_| {
    eprintln!("Clicked 2!");
  });
  tab_bar.add(&button);

  tab_bar
}
