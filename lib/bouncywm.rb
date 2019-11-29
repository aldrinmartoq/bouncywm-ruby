require 'xlib-objects'
require_relative 'console'

class BouncyWM
  include Bouncy::Console
  attr_accessor :display, :root_window, :bouncing_windows

  def initialize(display_name = nil)
    puts "Hello X11 #{display_name}"
    setup_x11 display_name
  end

  def setup_x11(display_name)
    self.display = XlibObj::Display.new(display_name)
    self.root_window = display.screens.first.root_window
    self.bouncing_windows = {}

    # Grab ALT + BUTTON1 click
    Xlib.XGrabButton display.to_native,
      1, Xlib::Mod1Mask, root_window.id, true,
      Xlib::ButtonPressMask, Xlib::GrabModeAsync, Xlib::GrabModeAsync, Xlib::None, Xlib::None
  end

  def process
    loop do
      process_events
      bounce_windows
      sleep 0.01
    end
  end

  def process_events
    while Xlib::X.pending(display) > 0
      event = Xlib::X.next_event display
      subwindow_id = event[:xbutton][:subwindow]

      if event[:type] == Xlib::ButtonPress && subwindow_id != Xlib::None
        if bouncing_windows[subwindow_id]
          puts "Removing window #{subwindow_id}"
          bouncing_windows.delete subwindow_id
        else
          puts "Adding window #{subwindow_id}"
          bouncing_windows[subwindow_id] = OpenStruct.new dx: 1, dy: 1, window: XlibObj::Window.new(display, subwindow_id)
        end
      end
    end
  end

  def dx(curr, pos, plus, max)
    if pos <= 0 && plus != max
      1
    elsif pos + plus >= max && plus != max
      -1
    elsif plus == max
      0
    else
      curr
    end
  end

  def bounce_windows
    bouncing_windows.each do |id, item|
      item.dx = dx item.dx, item.window.x, item.window.width, root_window.width
      item.dy = dx item.dy, item.window.y, item.window.height, root_window.height

      x = item.window.x + item.dx
      y = item.window.y + item.dy

      Xlib::XMoveResizeWindow(display.to_native, id, x, y, item.window.width, item.window.height)
    end
  end
end
