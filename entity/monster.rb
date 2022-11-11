require './modules'
  ##
  # Monster general class
class Monster
  attr_accessor :type, :hitbox
  def initialize(x, y, type, hitbox, animation, ani_duration = 100)
    @x = @base_x = x
    @y = @base_y = y
    @type = type
    @hitbox = hitbox
    @animation = animation
    @ani_index = 0
    @ani_time = Gosu.milliseconds
    @ani_duration = ani_duration
  end

  def move(y)
    @y -= y
    @base_y -= y
    @hitbox.top -= y
    @hitbox.bottom -= y
  end

  def action
  end

  def animate
    if Gosu.milliseconds - @ani_time >= @ani_duration
      @ani_index += 1
      @ani_index %= @animation.length
      @ani_time = Gosu.milliseconds
    end
    action
  end

  def draw
    @animation[@ani_index].draw_rot(@x, @y, ZOrder::MONSTERS)
    @hitbox.draw(@x, @y, ZOrder::MONSTERS, 0xff_ff0000)
  end
end

##
# Monster that stay static on two platforms
class StaticMonster < Monster
  def initialize(x, y)
    super(x, y, :monster, Hitbox.new_xywh(x, y, 82, 46), Gosu::Image.load_tiles("img/static_monster.png", 82, 52))
  end
end

##
# Monster that bounce on two platforms
class BouncingMonster < Monster
  def initialize(x, y)
    @w = 91
    @h = 31
    super(x, y, :monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/bouncing_monster.png", @w, @h))
    @bounce_delay = 800
    @bounce_start = Gosu.milliseconds
    @bounce_count = 0
    @vy = 0
  end

  def action
    if Gosu.milliseconds - @bounce_start >= 0
      @vy += Gravity
      @y += @vy
      if @y >= @base_y
        @y = @base_y
        if @bounce_count == 2
          @bounce_start = Gosu.milliseconds + @bounce_delay
          @bounce_count = 0
        else
          @vy = -5
          @bounce_count += 1
        end
      end
      @hitbox.top = @y - @h/2
      @hitbox.bottom = @y + @h/2
    end
  end
end

##
# Monster that hang in the mid-air and slightly move left and right
class MovingMonster < Monster
  def initialize(x, y)
    @w = 80
    @h = 45
    super(x, y, :monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/moving_monster.png", @w, @h))
    @start = Gosu.milliseconds
  end

  def action
    @x = @base_x + Math.cos((Gosu.milliseconds - @start) / 500.0 * Math::PI) * 20.0
    @hitbox.left = @x - @w/2
    @hitbox.right = @x + @w/2
  end
end

##
# Monster that fly from one edge of the screen to the another
class FlyingLRMonster < Monster
  def initialize(x, y)
    @w = 37
    @h = 49
    super(x, y, :monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/flying_monster.png", @w, @h))
    @start = Gosu.milliseconds
    @dir = 1
    @vx = 2
  end

  def action
    @y = @base_y + Math.sin((Gosu.milliseconds - @start) / 500.0 * Math::PI) * 15.0
    @hitbox.top = @y - @h/2
    @hitbox.bottom = @y + @h/2

    if @hitbox.right >= Window::WIDTH or @hitbox.left <= 0
      @dir = - @dir
    end
    @x += @dir * @vx
    @hitbox.left = @x - @w/2
    @hitbox.right = @x + @w/2
  end

  def draw
    @animation[@ani_index].draw_rot(@x, @y, ZOrder::MONSTERS, 0, 0.5, 0.5, @dir)
    @hitbox.draw(@x, @y, ZOrder::MONSTERS, 0xff_ff0000)
  end
end

##
# Monster that fly from the bottom to the top of the screen
# Spawn at y = 640
class FlyingUpMonster < Monster
  def initialize(x, y)
    @w = 70
    @h = 90
    super(x, y, :monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/flying_up_monster.png", @w, @h))
    @start = Gosu.milliseconds
  end

  def action
    dt = Gosu.milliseconds - @start
    if dt < 3000
      @y = @base_y - (1.0 - (1.0 - (dt-2000.0)/1000.0)**3.0) * 30.0
    elsif dt > 3500 and dt < 4500
      @y = @base_y - 30 - ((dt-3500.0)/1000.0)**3.0 * 100.0
    elsif dt >= 4500
      @y -= 7
    end
    @hitbox.top = @y - @h/2
    @hitbox.bottom = @y + @h/2
  end
end

##
# Monster that randomly fly from the top to the bottom of the screen
class FlyingDownMonster < Monster
  def initialize(x, y)
    @w = 46
    @h = 35
    super(x, y, :monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/virus_monster.png", @w, @h))
    @dir = 1
  end

  def action
    @y += 2
    if @x > Window::WIDTH - @w/2 or @x < @w/2 or rand(20) == 0
      @dir = - @dir
    end
    @x += 3 * @dir
    @hitbox.left = @x - @w/2
    @hitbox.right = @x + @w/2
    @hitbox.top = @y - @h/2
    @hitbox.bottom = @y + @h/2
  end
end
