require './modules'

def generate_random_standable_platform
  case rand(20)
  when 0
    Platform.new(:boost , 30 + rand(341), -20)
  when 1..3
    MoveablePlatform.new( 30 + rand(341), -20)
  else
    Platform.new(:static, 30 + rand(341), -20)
  end
end

def generate_random_breakable_platform
  BreakablePlatform.new(30 + rand(341), -20)
end

class Platform
  attr_reader :type, :top, :bottom, :left, :right, :x

  def initialize(type, x, y)
    @type = type
    @img_static, @img_move, @img_boost, @img_white = *Gosu::Image.load_tiles("./img/platforms.png", 57, 15)
    @x = x
    @y = y
    @w = 57
    @h = 15

    @top = @y
    @bottom = @y + @h
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def move_y(y)
    @y -= y
    @top = @y
    @bottom = @y + @h
  end

  def draw
    case @type
    when :static
      @img_static.draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    when :boost
      @img_boost.draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    when :white
      @img_white.draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    end
  end
end

class MoveablePlatform
  attr_reader :type, :top, :bottom, :left, :right, :x

  def initialize(x, y)
    @type = :move
    @img_move = Gosu::Image.load_tiles("./img/platforms.png", 57, 15)[1]
    @x = x
    @y = y
    @w = 57
    @h = 15
    @dir = 1
    @vx = 1

    @top = @y
    @bottom = @y + @h
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def move_y(y)
    @y -= y
    @top = @y
    @bottom = @y + @h
  end

  def move_around
    if @x < @w/2 or @x > Window::WIDTH - @w/2
      @dir = - @dir
    end
    @x += @vx * @dir
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def draw
    @img_move.draw(@x - @w/2, @y, ZOrder::PLATFORMS)
  end
end

class BreakablePlatform
  attr_reader :type, :top, :bottom, :left, :right, :broken

  def initialize(x, y)
    @type = :break
    @img_break = Gosu::Image.load_tiles("./img/breakable_platform.png", 60, 33)
    @x = x
    @y = y
    @w = 60
    @h = 15
    @broken = nil
    @vy = 2

    @top = @y
    @bottom = @y + @h
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def break
    @broken = Gosu.milliseconds if @broken == nil
  end

  def drop
    @vy += Gravity
    @y += @vy
  end

  def move_y(y)
    @y -= y
    @top = @y
    @bottom = @y + @h
  end

  def draw
    if @broken == nil
      @img_break[0].draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    elsif Gosu.milliseconds - @broken < 50
      @img_break[1].draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    elsif Gosu.milliseconds - @broken < 100
      @img_break[2].draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    else
      @img_break[3].draw(@x - @w/2, @y, ZOrder::PLATFORMS)
    end
  end
end
