# wm_tail

Window Manager agnostic tool for reading X11 windows and workspaces

# About

This app aims to abstract away some of the pain when switching window managers.
It serves as glue between a Window Manager and its status bar.  This is WM
agnostic because it talks to xlib directly to get its window information.  This
is bar agnostic because it doesn't assume anything about which bar you're using
- it simply pipes out env vars for other scripts to consume.

# Installation

1. Install ruby.  If you're looking for a version manager, I recommend asdf.
2. Clone this repo and cd into it.
3. Run `bundle` to install required dependencies.
4. `./workspaces.rb`

# Usage

`workspaces.rb` reads your x11 windows and emits shell vars describing what's
going on in each workspace.  This is pretty useless on its own, so you'll have
to pipe it into another executable to format it for your bar of choice.

A few sample scripts are included to demonstrate how to format output.  E.g.
`workspaces.rb | scripts/wm-formatter-polybar.sh`

Foreground colors can be overridden via the EMPTY_COLOR, VISIBLE_COLOR,
OCCUPIED_COLOR, URGENT_COLOR, FOCUSED_COLOR env vars.

For anything more complex, write your own script.

# Roadmap (using the term extremely loosely)

## Phase 0

- [x] Write readme
- [ ] Import workspaces.rb

## Phase 1
- [ ] Clean up ruby
- [ ] Multi monitor support
- [ ] Cut formatting, define output forma- [ ]  (Spoiler: env var all the things)
- [ ] Build out example scripts for reading output [ ]
- [ ] Harden interface

## Phase 2
- [ ] Leave ruby

# FAQ

## Why build this?

I like WM hopping.

## Why Ruby?

I write Ruby professionally.  I've never worked with xlib before.  If I try to
pick up a new language while also figuring out the xlib pieces, I'll never
finish.  Once the xlib parts are sorted out, I'll consider porting elswhere.

## Is Ruby fast enough?

Yes-ish.

Once running, this will respond to window events in a spritely enough manner.  E.g. if I hit a key to change workspace, the change in my bar looks instantaneous.

Startup time hurts though.
