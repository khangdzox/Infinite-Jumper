require './modules'

class Player
  attr_accessor :score, :left, :right, :bottom, :top, :vx, :vy, :y, :x, :dir

  def initialize(x, y)
    @state = States::FALL
    @img_left = Gosu::Image.new("img/lik-left.png")
    @img_right = Gosu::Image.new("img/lik-right.png")
    @img_stars = Gosu::Image.new("img/stars.png")
    @img_heart = Gosu::Image.new("img/heart.png")
    @sfx_jump = Gosu::Sample.new("sound/jump.wav")
    @x = x
    @y = y
    @w = 62
    @h = 60
    @vx = @vy = @ax = 0
    @ay = Gravity
    @heart = 3
    @score = 0
    @font_score = Gosu::Font.new(40, bold: true, name: "Consolas")
    @dir = 'right'
    @roll = nil
    @dead = false
    @time_start_hurt = nil

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - 15
    @right = @x + 15
  end

  def play_sound(sound)
    case sound
    when :jump
      @sfx_jump.play
    end
  end

  def roll
    @roll = Gosu.milliseconds
  end

  def degree_since_roll
    time_passed = Gosu.milliseconds - @roll
    if time_passed > 740
      @roll = nil
      return 0
    else
      return -360 * (1.0 - (1.0 - time_passed.to_f / 740.0) ** 2.0)
    end
  end

  def damage
    @heart -= 1
    @time_start_hurt = Gosu.milliseconds
  end

  def insta_death
    @heart = 0
  end

  def is_dead
    return true if @heart <= 0
    return false
  end

  def is_hurt
    return false if @time_start_hurt.nil?
    if Gosu.milliseconds - @time_start_hurt > 750
      @time_start_hurt = nil
      return false
    else
      return true
    end
  end

  def fall
    @vy += @ay
  end

  def jump(vy = -11, vol = 1)
    @vy = vy
    @sfx_jump.play(vol)
  end

  def move_left
    @dir = 'left'
    if @vx > -6
      @ax = -0.4
      @vx += @ax
    end
  end

  def move_right
    @dir = 'right'
    if @vx < 6
      @ax = 0.4
      @vx += @ax
    end
  end

  def slow_down
    if @vx > 0
      @ax = -0.1
      @vx += @ax
      if @vx < 0
        @ax = 0
        @vx = 0
      end
    elsif @vx < 0
      @ax = 0.1
      @vx += @ax
      if @vx > 0
        @ax = 0
        @vx = 0
      end
    end
  end

  def move_y
    @y += @vy

    @top = @y - @h/2
    @bottom = @y + @h/2
  end

  def move_x
    @x += @vx

    @x = @x % Window::WIDTH

    @left = @x - 15
    @right = @x + 15
  end

  def set_top(top)
    @y = top + @h/2
    @top = top
    @bottom = top + @h
  end

  def set_x(x)
    @x = x

    @x = @x % Window::WIDTH

    @left = @x - 15
    @right = @x + 15
  end

  def collide_with(platform)
    if (platform.left <= @left and @left <= platform.right) or (platform.left <= @right and @right <= platform.right)
      if platform.bottom >= @bottom and @bottom >= platform.top
        return true
      end
    end
    return false
  end

  def update
    fall
    move
  end

  def draw
    case @dir
    when 'left'
      img = @img_left
    when 'right'
      img = @img_right
    end
    if is_hurt and ((Gosu.milliseconds - @time_start_hurt)/50).to_i.even?
      opacity = 0x66_ffffff
    else
      opacity = 0xff_ffffff
    end
    if @roll == nil
      img.draw_rot(@x, @y, ZOrder::PLAYER, 0, 0.5, 0.5, 1, 1, opacity)
    else
      img.draw_rot(@x, @y, ZOrder::PLAYER, degree_since_roll, 0.5, 0.5, 1, 1, opacity)
    end
    @img_stars.draw_rot(@x, @top, ZOrder::PLAYER, 0, 0.5, 0.5, 1, 1, opacity) if is_hurt or is_dead
  end

  def draw_score
    @font_score.draw_text(@score.to_s, 200 - @score.to_s.length*10, 10, ZOrder::UI, 1, 1, Gosu::Color::YELLOW)
  end

  def draw_heart
    @heart.times do |i|
      @img_heart.draw(10 + i*35, 10, ZOrder::UI)
    end
  end
end
