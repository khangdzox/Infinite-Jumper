require './modules'

def generate_random_standable_platform
  case rand(20)
  when 0
    [
      SpikePlatform.new(30 + rand(341), -20, false),
      SpikePlatform.new(30 + rand(341), -60, rand(2)%2==0),
      SpikePlatform.new(30 + rand(341), -100, rand(2)%2==0)
    ]
  when 1..2
    [BoostPlatform.new(30 + rand(341), -20)]
  when 3..5
    [MoveablePlatform.new(30 + rand(341), -20)]
  else
    [StaticPlatform.new(30 + rand(341), -20)]
  end
end

def generate_random_breakable_platform
  [BreakablePlatform.new(30 + rand(341), -20)]
end

class StaticPlatform
  attr_reader :type, :top, :bottom, :left, :right, :x

  def initialize(x, y)
    @type = :static
    @img = Gosu::Image.new("./img/static_platform.png")
    @x = x
    @y = y
    @w = 57
    @h = 15

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def info
    puts("Static: #{@x}, #{@y}, top: #{@top}")
  end

  def move_y(y)
    @y -= y
    @top = @y - @h/2
    @bottom = @y + @h/2
  end

  def draw
    @img.draw_rot(@x, @y, ZOrder::PLATFORMS)
  end
end

class SpikePlatform
  attr_reader :type, :top, :bottom, :left, :right, :x, :spike

  def initialize(x, y, spike)
    @type = :spike
    @img_normal, @img_active = *Gosu::Image.load_tiles("./img/spike_platform.png", 57, 35)
    @img = @img_normal
    @x = x
    @y = y
    @w = 57
    @h = 15
    @spike = spike
    @start_delay = 0
    @delay_time = 200

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def info
    puts("Spike : #{@x}, #{@y}, top: #{@top}")
  end

  def change_state
    @spike = !@spike
    @start_delay = Gosu.milliseconds
  end

  def move_y(y)
    @y -= y
    @top = @y - @h/2
    @bottom = @y + @h/2
  end

  def draw
    if @spike and (Gosu.milliseconds - @start_delay > @delay_time)
      @img = @img_active
    elsif not @spike and (Gosu.milliseconds - @start_delay > @delay_time)
      @img = @img_normal
    end
    @img.draw_rot(@x, @y, ZOrder::PLATFORMS)
  end
end

class BoostPlatform
  attr_reader :type, :top, :bottom, :left, :right, :x

  def initialize(x, y)
    @type = :boost
    @img, @img_active = *Gosu::Image.load_tiles("./img/boost_platform.png", 57, 45)
    @sfx_boing = Gosu::Sample.new('sound/boost.mp3')
    @x = x
    @y = y
    @w = 57
    @h = 15

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def info
    puts("Boost : #{@x}, #{@y}, top: #{@top}")
  end

  def move_y(y)
    @y -= y
    @top = @y - @h/2
    @bottom = @y + @h/2
  end

  def active
    @img = @img_active
    @sfx_boing.play
  end

  def draw
    @img.draw_rot(@x, @y, ZOrder::PLATFORMS)
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

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def info
    puts("Move  : #{@x}, #{@y}, top: #{@top}")
  end

  def move_y(y)
    @y -= y
    @top = @y - @h/2
    @bottom = @y + @h/2
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
    @img_move.draw_rot(@x, @y, ZOrder::PLATFORMS)
  end
end

class BreakablePlatform
  attr_reader :type, :top, :bottom, :left, :right, :broken

  def initialize(x, y)
    @type = :break
    @img_break = Gosu::Image.load_tiles("./img/breakable_platform.png", 60, 33)
    @sfx_break = Gosu::Sample.new('sound/break.mp3')
    @x = x
    @y = y
    @w = 60
    @h = 15
    @broken = nil
    @vy = 2

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end

  def info
    puts("Break : #{@x}, #{@y}, top: #{@top}")
  end

  def break
    @broken = Gosu.milliseconds and @sfx_break.play if @broken == nil
  end

  def drop
    @vy += Gravity
    @y += @vy
    @top = @y - @h/2
    @bottom = @y + @h/2
  end

  def move_y(y)
    @y -= y
    @top = @y - @h/2
    @bottom = @y + @h/2
  end

  def draw
    if @broken == nil
      @img_break[0].draw_rot(@x, @y, ZOrder::PLATFORMS)
    elsif Gosu.milliseconds - @broken < 50
      @img_break[1].draw_rot(@x, @y, ZOrder::PLATFORMS)
    elsif Gosu.milliseconds - @broken < 100
      @img_break[2].draw_rot(@x, @y, ZOrder::PLATFORMS)
    else
      @img_break[3].draw_rot(@x, @y, ZOrder::PLATFORMS)
    end
  end
end
