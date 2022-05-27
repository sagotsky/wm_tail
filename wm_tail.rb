#!/usr/bin/env ruby

# xprop cannot watch urgency events on all windows.
# i haven't figured out how to watch a proc in crystal
# therefore we need a spy proc per window
# trying ruby.  (py is next best choice)
# not sure if ruby is fast enough, but keeping it all in proc without bash pipes may help

# TODO: wmctrl's needs_attention works
# termite setting the urgency WM_HINT goes unnoticed.
# figure out what property triggers it.

# puts "%{F#333333}⚫ %{F-}"*10 # skeleton output for faster perceived output

require 'xlib-objects'
require 'pry'

class Event
  EVENT_MAP = %i[
    KeyPress KeyRelease ButtonPress ButtonRelease MotionNotify EnterNotify
    LeaveNotify FocusIn FocusOut KeymapNotify Expose GraphicsExpose NoExpose
    VisibilityNotify CreateNotify DestroyNotify UnmapNotify MapNotify MapRequest
    ReparentNotify ConfigureNotify ConfigureRequest GravityNotify ResizeRequest
    CirculateNotify CirculateRequest PropertyNotify SelectionClear
    SelectionRequest SelectionNotify ColormapNotify ClientMessage MappingNotify
    GenericEvent LASTEvent
  ].each_with_object({}) { |constant, hash| hash[Xlib.const_get(constant)] = constant }

  def initialize(xlib_event)
    @attributes = xlib_event.members.zip(xlib_event.values).to_h
  end

  def update?
    PropertyNotify? || ClientMessage?
  end

  private

  EVENT_MAP.each do |event_value, event_name|
    define_method("#{event_name}?") do
      @attributes[:type] == event_value
    end
  end
end

class ShellFormatter
  def workspaces(workspaces_hash)
    workspace_list = workspaces_hash.keys.join(' ')
    ws_list = "WS_LIST='#{workspace_list}'"

    ws_info = workspaces_hash.flat_map do |id, workspace|
      workspace(id, workspace)
    end

    [ws_list, *ws_info].join(' ')
  end

  private

  def workspace(id, workspace)
    state_var = "WS_#{id}_STATE"
    name_var  = "WS_#{id}_NAME"

    [
      "#{state_var}=#{workspace.state}",
      "#{name_var}=#{workspace.name}"
    ]
  end
end

class Cli
  EVENT_DELAY = 0.004 # give windows time to close before we query them.  yeah, it's like that :-\

  def initialize
    @display = XlibObj::Display.new(':0')
    @root = Root.new(@display)
    @formatter = ShellFormatter.new
  end

  def main
    update
    loop do
      e = Xlib::X.next_event(@display)
      if Event.new(e).update?
        sleep EVENT_DELAY
        update
      end
    end
  end

  def update
    # can detect multiple screens?
    all = Array(@root.all_windows).each_with_object(@root.workspaces) do |window, workspaces|
      ws = workspaces[window.workspace]
      next unless ws

      if    window.urgent?  then ws.urgent!
      elsif window.focused? then ws.focus!
      elsif window.visible? then ws.visible!
      else
        ws.occupied!
      end
    end

    # puts @formatter.root(@root)
    output = @formatter.workspaces(all)
    puts output unless output == @_last_output
    @_last_output = output
  end
end

class Workspace
  # attr_writer :urgent, :visible, :occupied
  attr_reader :name, :state

  URGENT = :urgent
  FOCUSED = :focused
  VISIBLE = :visible
  OCCUPIED = :occupied
  EMPTY = :empty

  def initialize(name, visible)
    @name = name
    @state = :empty
    visible! if visible
  end

  def urgent!
    @state = URGENT
  end

  def focus!
    @state = FOCUSED unless @state == URGENT
  end

  def visible!
    @state = VISIBLE unless @state == URGENT
  end

  def occupied!
    @state = OCCUPIED if @state == EMPTY
  end
end

class Root
  NET_CLIENT_LIST_STACKING = :_NET_CLIENT_LIST_STACKING
  NET_CLIENT_LIST = :_NET_CLIENT_LIST

  def initialize(display)
    @root = display.screens.first.root_window
    @display = display
    # binding.pry if ENV['DEBUG']
    init_events!
  end

  def all_windows
    client_list = @root.property(NET_CLIENT_LIST_STACKING) || @root.property(NET_CLIENT_LIST)
    Array(client_list).map do |xlibobj_window|
      Window.new @display, xlibobj_window
    end
  end

  def workspaces
    net_current_desktops = XlibObj::Window::Property.new(@root, :_NET_CURRENT_DESKTOP).get
    current_ws = net_current_desktops.respond_to?(:first) ? net_current_desktops.first : nil
    Array(desktop_names).each_with_object({}).with_index do |(name, workspaces), index|
      workspaces[index] = Workspace.new(name, current_ws == index)
    end
  end

  private

  def screen_names
    @_screen_names ||= @display.screens.first.crtcs.flat_map(&:outputs).map(&:name)
  end

  def desktop_names
    names = XlibObj::Window::Property.new(@root, :_NET_DESKTOP_NAMES).get # Names is preferred, but not all WMs provide it
    number_of_desktops_atom = XlibObj::Window::Property.new(@root, :_NET_NUMBER_OF_DESKTOPS).get
    number = number_of_desktops_atom.nil? ? nil : number_of_desktops_atom.first

    if names
      names
    elsif number
      (0...number).to_a.map(&:to_s)
    else
      []
    end
  end

  def init_events!
    @root.on(:property_change, :property_notify) { |event| puts event }
    @root.on(:substructure_notify, :client_message) { |event| puts event }
  end
end

class Window
  Position = Struct.new(:x, :y, :w, :h, keyword_init: true)

  NET_WM_NAME = :_NET_WM_NAME
  NET_WM_DESKTOP = :_NET_WM_DESKTOP
  NET_WM_STATE = :_NET_WM_STATE
  WM_HINTS = :WM_HINTS
  URGENCY_HINT = 1 # this is reverse engineered based on observed WM_HINTS.
  NET_WM_STATE_DEMANDS_ATTENTION = :_NET_WM_STATE_DEMANDS_ATTENTION

  def initialize(display, xlibobj_window)
    @display = display
    @window = xlibobj_window
  end

  def id
    @window.id
  end

  def name
    window.property(NET_WM_NAME)&.join
  end

  def workspace
    @workspace ||= property(NET_WM_DESKTOP)&.first
  end

  def focused?
    # binding.pry
    # @window.focused?
    false
  end

  def visible?
    false
    # true
  end

  def urgent?
    needs_attention? || urgency_hint?
  end

  def position
    Position.new(
      x: @window.attribute(:x),
      y: @window.attribute(:y),
      w: @window.attribute(:width),
      h: @window.attribute(:height)
    )
  end

  private

  def needs_attention?
    states = property(NET_WM_STATE)
    states&.any? { |state| state.name == NET_WM_STATE_DEMANDS_ATTENTION }
  end

  def urgency_hint?
    Array(property(WM_HINTS))[URGENCY_HINT]&.bytes == [1]
  end

  def property(name)
    @window.property(name) if window_exists?
  end

  def window_exists?
    root = @display.screens.first.root_window
    all_windows = root.property(:_NET_CLIENT_LIST_STACKING) || root.property(:_NET_CLIENT_LIST)
    Array(all_windows).map(&:id).include?(@window.id)
  end
end

Cli.new.main
