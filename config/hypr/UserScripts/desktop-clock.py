#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf
import datetime
import cairo

class ClockOverlay:
    def __init__(self):
        self.window = Gtk.Window()
        self.window.set_title("Desktop Clock")
        self.window.set_decorated(False)
        self.window.set_skip_taskbar_hint(True)
        self.window.set_skip_pager_hint(True)
        
        # Key changes: Set as dock type and keep below
        self.window.set_type_hint(Gdk.WindowTypeHint.DOCK)
        self.window.set_keep_below(True)
        
        # Position and size the window
        screen = self.window.get_screen()
        screen_width = screen.get_width()
        screen_height = screen.get_height()
        
        # Set window size to cover screen but not interfere
        self.window.set_default_size(screen_width, screen_height)
        self.window.move(0, 0)
        
        # Make window transparent and non-focusable
        visual = screen.get_rgba_visual()
        if visual:
            self.window.set_visual(visual)
        self.window.set_app_paintable(True)
        self.window.set_accept_focus(False)
        
        # Create main container
        self.overlay = Gtk.Overlay()
        
        # Create layout box
        vbox = Gtk.VBox(spacing=10)
        vbox.set_halign(Gtk.Align.CENTER)
        vbox.set_valign(Gtk.Align.CENTER)
        vbox.set_margin_top(50)
        
        # Day label - Very large
        self.day_label = Gtk.Label()
        self.day_label.set_markup('<span font="Orbitron Bold 120" foreground="white" alpha="90%">LOADING...</span>')
        self.day_label.set_halign(Gtk.Align.CENTER)
        
        # Time label - Medium size
        self.time_label = Gtk.Label()
        self.time_label.set_markup('<span font="Space Mono Bold 48" foreground="#f0f0f0" alpha="85%">00:00:00 AM</span>')
        self.time_label.set_halign(Gtk.Align.CENTER)
        self.time_label.set_margin_top(20)
        
        # Date label - Smaller
        self.date_label = Gtk.Label()
        self.date_label.set_markup('<span font="Space Mono 32" foreground="#b0b0b0" alpha="80%">1/1/2024</span>')
        self.date_label.set_halign(Gtk.Align.CENTER)
        self.date_label.set_margin_top(15)
        
        # Pack labels into vbox
        vbox.pack_start(self.day_label, False, False, 0)
        vbox.pack_start(self.time_label, False, False, 0)
        vbox.pack_start(self.date_label, False, False, 0)
        
        # Add vbox to overlay
        self.overlay.add(vbox)
        
        # Add overlay to window
        self.window.add(self.overlay)
        
        # Connect signals
        self.window.connect('draw', self.on_draw)
        self.window.connect('destroy', Gtk.main_quit)
        self.window.connect('realize', self.on_realize)
        
        # Show all widgets
        self.window.show_all()
        
        # Update clock immediately and then every second
        self.update_clock()
        GLib.timeout_add(1000, self.update_clock)
        
    def on_realize(self, widget):
        # Make window click-through after it's realized
        self.make_click_through()
        
    def on_draw(self, widget, cr):
        # Make background completely transparent
        cr.set_source_rgba(0, 0, 0, 0)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        
    def make_click_through(self):
        try:
            gdk_window = self.window.get_window()
            if gdk_window:
                # Create empty region for click-through
                region = cairo.Region()
                gdk_window.input_shape_combine_region(region, 0, 0)
        except Exception as e:
            print(f"Could not make window click-through: {e}")
        
    def update_clock(self):
        now = datetime.datetime.now()
        
        # Update day
        day = now.strftime('%A').upper()
        self.day_label.set_markup(
            f'<span font="Orbitron Bold 120" foreground="white" alpha="90%">{day}</span>'
        )
        
        # Update time with pulse effect
        time_str = now.strftime('%I:%M:%S %p')
        alpha = "85%" if now.second % 2 == 0 else "75%"
        self.time_label.set_markup(
            f'<span font="Space Mono Bold 48" foreground="#f0f0f0" alpha="{alpha}">{time_str}</span>'
        )
        
        # Update date
        date_str = now.strftime('%d/%m/%Y')
        self.date_label.set_markup(
            f'<span font="Space Mono 32" foreground="#b0b0b0" alpha="80%">{date_str}</span>'
        )
        
        return True

def main():
    overlay = ClockOverlay()
    
    try:
        Gtk.main()
    except KeyboardInterrupt:
        print("\nClock overlay stopped.")
        Gtk.main_quit()

if __name__ == "__main__":
    main()
