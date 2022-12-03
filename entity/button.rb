require "gosu"

class Button
  def initialize(x, y, w, h, img_normal, img_pressed)
    @x = x
    @y = y
    @w = w
    @h = h
    @normal = img_normal
    @pressed = img_pressed
    @img = @normal
    @clicked = false
    @availability = true
  end

  def mouse_in?(mouse_x, mouse_y)
    if (@x - @w/2 <= mouse_x and mouse_x <= @x + @w/2) and (@y - @h/2 <= mouse_y and mouse_y <= @y + @h/2)
      @img = @pressed
      return true
    else
      @img = @normal
      return false
    end
  end

  def clicked?(mouse_x, mouse_y)
    if @availability and mouse_in?(mouse_x, mouse_y) and Gosu.button_down?(Gosu::MS_LEFT)
      if not @clicked
        @clicked = true
        return true
      else
        return false
      end
    else
      @clicked = false
      return false
    end
  end

  def set_xy(x, y)
    @x = x
    @y = y
  end

  def hide
    @availability = false
  end

  def show
    @availability = true
  end

  def draw(z = ZOrder::UI)
    @img.draw_rot(@x, @y, z) if @availability
  end
end

##
# This class is for leaderboard
class Panel
  def initialize(x, y, w, h, img_normal, img_hover, img_active, offset)
    @x = x
    @y = y
    @w = w
    @h = h
    @img = @normal = img_normal
    @hover = img_hover
    @active = img_active
    @clicked = false
    @offset = offset
  end

  def mouse_in?(mouse_x, mouse_y)
    if (@x <= mouse_x and mouse_x <= @x + @w) and (@y + (@img != @active ? @offset : 0) <= mouse_y and mouse_y <= @y + @h)
      @img = @hover if @img != @active
      return true
    else
      @img = @normal if @img != @active
      return false
    end
  end

  def clicked?(mouse_x, mouse_y)
    if mouse_in?(mouse_x, mouse_y) and Gosu.button_down?(Gosu::MS_LEFT)
      if not @clicked
        @clicked = true
        @img = @active
        return true
      else
        return false
      end
    else
      @clicked = false
      return false
    end
  end

  def activate
    @img = @active
  end

  def deactivate
    @img = @normal
  end

  def draw
    @img.draw(@x, @y, ZOrder::UI)
  end
end