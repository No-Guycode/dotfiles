#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib
import datetime

class ClockWidget:
    def __init__(self):
        self.window = Gtk.Window()
        self.window.set_title("Clock Widget")
        self.window.set_decorated(False)
        self.window.set_skip_taskbar_hint(True)
        self.window.set_skip_pager_hint(True)
        self.window.set_keep_below(True)
        self.window.set_type_hint(Gdk.WindowTypeHint.DESKTOP)
        
        # Set window properties
        self.window.set_default_size(800, 400)
        self.window.set_position(Gtk.WindowPosition.CENTER)
        
        # Make transparent
        screen = self.window.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.window.set_visual(visual)
        self.window.set_app_paintable(True)
        
        # Create layout
        vbox = Gtk.VBox(spacing=20)
        vbox.set_halign(Gtk.Align.CENTER)
        vbox.set_valign(Gtk.Align.CENTER)
        
        # Day label
        self.day_label = Gtk.Label()
        self.day_label.set_markup('<span font="Orbitron Bold 72" foreground="white">LOADING...</span>')
        
        # Time label  
        self.time_label = Gtk.Label()
        self.time_label.set_markup('<span font="Space Mono Bold 36" foreground="#f0f0f0">00:00:00 AM</span>')
        
        # Date label
        self.date_label = Gtk.Label()
        self.date_label.set_markup('<span font="Space Mono 24" foreground="#b0b0b0">1/1/2024</span>')
        
        vbox.pack_start(self.day_label, False, False, 0)
        vbox.pack_start(self.time_label, False, False, 0)
        vbox.pack_start(self.date_label, False, False, 0)
        
        self.window.add(vbox)
        self.window.show_all()
        
        # Update clock every second
        self.update_clock()
        GLib.timeout_add(1000, self.update_clock)
        
        # Handle transparency
        self.window.connect('draw', self.on_draw)
        
    def on_draw(self, widget, cr):
        cr.set_source_rgba(0, 0, 0, 0)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        
    def update_clock(self):
        now = datetime.datetime.now()
        
        # Update day
        day = now.strftime('%A').upper()
        self.day_label.set_markup(f'<span font="Orbitron Bold 72" foreground="white">{day}</span>')
        
        # Update time
        time_str = now.strftime('%I:%M:%S %p')
        self.time_label.set_markup(f'<span font="Space Mono Bold 36" foreground="#f0f0f0">{time_str}</span>')
        
        # Update date
        date_str = now.strftime('%d/%m/%Y')
        self.date_label.set_markup(f'<span font="Space Mono 24" foreground="#b0b0b0">{date_str}</span>')
        
        return True

if __name__ == "__main__":
    import cairo
    widget = ClockWidget()
    Gtk.main()
