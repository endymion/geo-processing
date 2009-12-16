# This was originally based on the Where On The Web example by JP:
# http://jphastings.tumblr.com/tagged/whereontheweb

require 'ruby-processing'
require "socket"
require "open-uri"
require "fileutils"

def coordinates_from_point(point)
  return nil if point.nil?
  lat = point[0]
  long = point[1]
  #Equirectangular
  return (long+180)/360.0 * @width, (90-lat)/180.0 * @height
end

class GeoProcessing < Processing::App
  load_ruby_library "control_panel"
  load_java_library "opengl"
  include_package "processing.opengl"
  
  def setup
    render_mode OPENGL
    hint(ENABLE_OPENGL_2X_SMOOTH)
    smooth

    # Defaults
    map_types = [
      'cloudless-color',
      'saturated-color',
      'glowing-edges'
      ]
    @map_type = map_types.first
    @map_brightness = 0.5
    @fade_rate = 0.1
    
    control_panel do |c|
      c.menu(:map_type, map_types, map_types.first) {|m| @map_type = m; load_map }
      c.slider(:map_brightness, 0.0..1.0, 0.5)
      c.slider(:fade_rate, 0.1..10.0, 1)
    end
    
    background 0, 0, 0
    
    @map_img = load_map

    @data = []
    $here = [25.7, -80.4]    
    @data << $here + [255]
    
  end
  
  def load_map
    file_name = "images/maps/#{@map_type}-#{@width}.jpg"
    @map_img = load_image(file_name)
  end
  
  def draw

    background 0

    # Draw map.
    tint = @map_brightness * 255
    tint 255, 255, 255, tint
    image @map_img,0,0,@width,@height
    
    @data.delete_if{|point| point[0] <= 0}

    @data.each do |point|
      no_stroke
      x,y = coordinates_from_point(point)
      ellipse x, y, 15, 15
    end

  end
  
end

GeoProcessing.new :title => "Geo Processing", :width => 1280, :height => 640 # , :y => 800