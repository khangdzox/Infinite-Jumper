require 'gosu'

class Button
  def initialize(x, y, w, h, img_normal, img_pressed)
    @x = x
    @y = y
    @w = w
    @h = h
    @normal = img_normal
    @pressed = img_pressed
    @img = @normal
  end

  def mouse_in?(mouse_x, mouse_y)
    if (@x <= mouse_x and mouse_x <= @x + @w) and (@y <= mouse_y and mouse_y <= @y + @h)
      @img = @pressed
      return true
    else
      @img = @normal
      return false
    end
  end

  def clicked?(mouse_x, mouse_y)
    if mouse_in?(mouse_x, mouse_y) and Gosu.button_down?(Gosu::MS_LEFT)
      return true
    else
      return false
    end
  end

  def draw
    @img.draw(@x, @y, ZOrder::UI)
  end
end