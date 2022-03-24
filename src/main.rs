use gtk::prelude::*;
use gtk::Button;
use wry::{
  application::{
    event::{Event, StartCause, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::{Window, WindowBuilder},
  },
  webview::{WebView, WebViewBuilder},
};
// use webkit2gtk;

#[cfg(target_os = "linux")]
use wry::application::platform::unix::WindowExtUnix;

#[cfg(target_os = "linux")]
fn add_stuff(window: &Window) -> wry::Result<()> {
  let gtk_window = &window.gtk_window();

  if let Some(widget) = gtk_window.child() {
    let webview_box = widget.downcast::<gtk::Box>().unwrap();
    gtk_window.remove(&webview_box);

    let vbox = gtk::Box::new(gtk::Orientation::Vertical, 20);

    let children = webview_box.children();

    if let Some(menu_bar) = children.first() {
      webview_box.remove(menu_bar);
      vbox.add(menu_bar);
    }

    let button = Button::with_label("Click me!");
    button.connect_clicked(|_| {
      eprintln!("Clicked 1!");
    });
    vbox.add(&button);

    let button = Button::with_label("Click me!");
    button.connect_clicked(|_| {
      eprintln!("Clicked 2!");
    });
    vbox.add(&button);

    if let Some(webview) = children.last() {
      webview_box.remove(webview);
      vbox.pack_end(webview, true, true, 0);
      webview.grab_focus();
    }

    gtk_window.add(&vbox);
  }

  gtk_window.show_all();

  Ok(())
}

fn make_webview(window: Window) -> wry::Result<WebView> {
  WebViewBuilder::new(window)?
    .with_url("https://html5test.com")?
    .with_dev_tool(true)
    .build()
}

fn main() -> wry::Result<()> {
  let event_loop = EventLoop::new();
  let window = WindowBuilder::new()
    .with_title("Testing app")
    .build(&event_loop)?;

  let webview = make_webview(window)?;
  let window = webview.window();

  add_stuff(window)?;

  event_loop.run(move |event, _, control_flow| {
    *control_flow = ControlFlow::Wait;

    match event {
      Event::NewEvents(StartCause::Init) => {
        println!("Wry has started!");
      }
      Event::WindowEvent {
        event: WindowEvent::CloseRequested,
        ..
      } => *control_flow = ControlFlow::Exit,
      _ => (),
    }
  });
}
