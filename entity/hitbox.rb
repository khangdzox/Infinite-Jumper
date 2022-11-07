require 'gosu'

class Hitbox
  attr_accessor :top, :bottom, :left, :right
  def initialize(top, bottom, left, right)
    @top = top
    @bottom = bottom
    @left = left
    @right = right
  end

  def self.new_xywh(x, y, w, h)
    top = y - h / 2
    bottom = y + h / 2
    left = x - w / 2
    right = x + w / 2
    return self.new(top, bottom, left, right)
  end

  def draw(x, y, z, c)
    Gosu.draw_line(@left, @top, c, @right, @top, c, z)
    Gosu.draw_line(@left, @bottom, c, @right, @bottom, c, z)
    Gosu.draw_line(@left, @top, c, @left, @bottom, c, z)
    Gosu.draw_line(@right, @top, c, @right, @bottom, c, z)
  end

  def info
    puts("top: #{@top}; bottom: #{@bottom}; left: #{@left}; right: #{@right}")
  end
end