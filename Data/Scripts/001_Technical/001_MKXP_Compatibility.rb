# Using mkxp-z v2.4.0 - https://gitlab.com/mkxp-z/mkxp-z/-/releases/v2.4.0
#$VERBOSE = nil
$MOBILE = true
begin; require 'zlib'; rescue; nil; end
#===============================================================================
# MKXP-Z UNIFIED MULTI-PLATFORM BOOTSTRAP
# Desktop (Windows / Linux / macOS)
# Android (JoiPlay)
# Nintendo Switch / PS Vita / PS3 Linux / PS4-PS5 Linux / Wii U / Xbox
# Steam Deck
# FONT-SAFE VERSION
#===============================================================================

# Original mkxp-z header
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 60
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

def pbSetWindowText(string)
System.set_window_title(string || System.game_title)
end

module Graphics
  def self.delta_s
    return self.delta.to_f / 1_000_000
  end
end

class Bitmap
attr_accessor :text_offset_y

alias mkxp_draw_text draw_text unless method_defined?(:mkxp_draw_text)

def draw_text(x, y, width, height = nil, text = "", align = 0)
if x.is_a?(Rect)
x.y -= (@text_offset_y || 0)
# rect, string & alignment
mkxp_draw_text(x, y, width)
else
y -= (@text_offset_y || 0)
height = text_size(text).height
mkxp_draw_text(x, y, width, height, text, align)
end
end
end

#===============================================================================
# Platform Detection
#===============================================================================
module Platform
def self.os
RUBY_PLATFORM.to_s.downcase rescue ""
end

def self.env(k)
ENV[k] || ENV[k.upcase] rescue nil
end

def self.joiplay?
os.include?("android") || env("joiplay")
end

def self.switch?
os.include?("nintendo") || os.include?("nx") || os.include?("switch")
end

# Steam Deck detection (optional but handy)
def self.deck?
env("SteamDeck") || os.include?("steam")
end

# Generic console detection (PS3/4/5, Vita, Wii U, Xbox, etc.)
def self.console?
plat = os.dup
sys = ""
if defined?(System) && System.respond_to?(:platform)
sys = System.platform.to_s.downcase rescue ""
end
combo = "#{plat} #{sys}"
return true if combo =~ /(ps3|ps4|ps5|vita|wiiu|xbox)/
return false
end

# Desktop = Windows / Linux / macOS / BSD / Steam Deck
def self.desktop?
!(joiplay? || switch? || console?)
end

# Platforms where we should avoid resizing / aggressive rendering tricks
def self.constrained?
joiplay? || switch? || console?
end
end

#===============================================================================
# Resize Factor Handler (Disabled on constrained platforms)
#===============================================================================
$ResizeInitialized = false if !defined?($ResizeInitialized)

def pbSetResizeFactor(factor)
if !$ResizeInitialized
begin
Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
rescue
# Some platforms (JoiPlay / consoles) may not support this
end
$ResizeInitialized = true
end

# No resize/fullscreen scaling on:
# - JoiPlay (Android)
# - Nintendo Switch
# - Consoles (PS3/4/5, Vita, Wii U, Xbox, etc.)
return if Platform.constrained?

if factor < 0 || factor == 4
if Graphics.respond_to?(:fullscreen) && !Graphics.fullscreen
Graphics.fullscreen = true
end
else
Graphics.fullscreen = false if Graphics.respond_to?(:fullscreen)
if Graphics.respond_to?(:scale)
Graphics.scale = (factor + 1) * 0.5
end
Graphics.center if Graphics.respond_to?(:center)
end
end

#===============================================================================
# mkxp-z Version Mismatch Warning (Desktop Only)
#===============================================================================
if Platform.desktop? &&
defined?(System::VERSION) &&
defined?(Essentials::MKXPZ_VERSION) &&
System::VERSION != Essentials::MKXPZ_VERSION

printf("\e[1;33mWARNING: mkxp-z version mismatch.\e[0m\r\n")
end
#===============================================================================
# Renderer Stabilizer (Constrained platforms: Switch / Consoles / JoiPlay)
#===============================================================================
begin
class Spriteset_Map
alias __init_preload initialize
def initialize(map = nil)
if Platform.constrained?
begin
renderer = $scene.map_renderer rescue nil
if renderer
renderer.reset if renderer.respond_to?(:reset)
m = map || $game_map
begin; renderer.add_tileset(m.tileset_name); rescue; end
m.autotile_names.each { |a| begin; renderer.add_autotile(a); rescue; end }
begin; renderer.add_extra_autotiles(m.tileset_id); rescue; end
end
rescue
end
end
__init_preload(map)
end
end
rescue
end

#===============================================================================
# SafeWrite (Fixes button config not saving on constrained systems)
#===============================================================================
module SafeWrite
def self.overwrite(path, data)
if Platform.constrained?
begin
File.open(path, "wb") do |f|
f.write(data)
f.flush
begin; f.fsync; rescue; end
end
return true
rescue
return false
end
else
File.open(path, "wb") { |f| f.write(data) }
return true
end
end
end

begin
if defined?(Input) && Input.singleton_class.method_defined?(:write_save_settings)
module Input
class << self
alias __orig_write write_save_settings
def write_save_settings
path = RTP.getSaveFileName("controls.rxdata")
data = Marshal.dump(@settings)
unless SafeWrite.overwrite(path, data)
__orig_write
end
end
end
end
end
rescue
end

#===============================================================================
# END OF MULTI-PLATFORM MKXP-Z PATCH
#===============================================================================

=======
module Essentials
  GEN_8_VERSION = "1.1.0"
end
