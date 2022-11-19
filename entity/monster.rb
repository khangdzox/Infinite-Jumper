require "./modules"
require "./entity/platform"
require "./entity/animation"

##
# Generate a monster that scroll with platforms
def generate_scrolling_monster(last_x, last_y)
  x = 60 + (last_x + rand(101) - 50) %280
  y = last_y - 50
  case rand(4)
  when 3
    monster = StaticMonster.new(x + rand(31) - 15, y - 25)
    associated_platforms = [
      StaticPlatform.new(x-30, y+5),
      StaticPlatform.new(x+30, y+5),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 2
    monster = BouncingMonster.new(x + rand(21) - 10, y - 15)
    associated_platforms = [
      StaticPlatform.new(x-30, y+7),
      StaticPlatform.new(x+30, y+7),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 1
    monster = MovingMonster.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(30+(x-170)%340, y+7),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 0
    monster = FlyingLRMonster.new(x, y)
    associated_platforms = [
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 70)
    ]
  end
  return *[monster, associated_platforms]
end

##
# Generate a monster that floating on the screen
def generate_floating_monster
  case rand(2)
  when 1
    FlyingUpMonster.new(35 + rand(331), 640)
  when 0
    FlyingDownMonster.new(35 + rand(331), -17)
  end
end

##
# Monster general class
class Monster
  attr_reader :type, :hitbox, :x
  def initialize(x, y, type, hitbox, animation, ani_duration = 100)
    @x = @base_x = x
    @y = @base_y = y
    @type = type
    @hitbox = hitbox
    @animation = Animation.new(animation, ani_duration)
    @is_killed = false
    @sfx_kill = Gosu::Sample.new('sound/kill.mp3')
  end

  def move(y)
    @y -= y
    @base_y -= y
    @hitbox.top -= y
    @hitbox.bottom -= y
  end

  def action
  end

  def kill
    @sfx_kill.play
    @is_killed = true
  end

  def animate
    if not @is_killed
      @animation.animate
      action
    else
      move(-9)
    end
  end

  def draw
    @animation.draw(@x, @y, ZOrder::MONSTERS)
    @hitbox.draw(@x, @y, ZOrder::MONSTERS, 0xff_ff0000)
  end
end

##
# Monster that stay static on two platforms
class StaticMonster < Monster
  def initialize(x, y)
    super(x, y, :scrolling_monster, Hitbox.new_xywh(x, y, 82, 46), Gosu::Image.load_tiles("img/static_monster.png", 82, 52))
  end
end

##
# Monster that bounce on two platforms
class BouncingMonster < Monster
  def initialize(x, y)
    @w = 91
    @h = 31
    super(x, y, :scrolling_monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/bouncing_monster.png", @w, @h))
    @bounce_delay = 800
    @bounce_start = $systime
    @bounce_count = 0
    @vy = 0
  end

  def action
    if $systime - @bounce_start >= 0
      @vy += Gravity
      @y += @vy
      if @y >= @base_y
        @y = @base_y
        if @bounce_count == 2
          @bounce_start = $systime + @bounce_delay
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
    super(x, y, :scrolling_monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/moving_monster.png", @w, @h))
    @start = $systime
  end

  def action
    @x = @base_x + Math.cos(($systime - @start) / 500.0 * Math::PI) * 20.0
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
    super(x, y, :scrolling_monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/flying_monster.png", @w, @h))
    @start = $systime
    @dir = 1
    @vx = 2
  end

  def action
    @y = @base_y + Math.sin(($systime - @start) / 500.0 * Math::PI) * 15.0
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
    @animation.draw(@x, @y, ZOrder::MONSTERS, @dir)
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
    super(x, y, :floating_monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/flying_up_monster.png", @w, @h))
    @start = $systime
  end

  def action
    dt = $systime - @start
    if dt < 1000
      @y = @base_y - (1.0 - (1.0 - dt/1000.0)**3.0) * 35.0
    elsif dt > 1400 and dt < 2400
      @y = @base_y - 35 - ((dt-1400.0)/1000.0)**3.0 * 100.0
    elsif dt >= 2400
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
    super(x, y, :floating_monster, Hitbox.new_xywh(x, y, @w, @h), Gosu::Image.load_tiles("img/virus_monster.png", @w, @h))
    @dir = 1
  end

  def action
    @y += 3
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
