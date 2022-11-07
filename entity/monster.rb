require './modules'

class Monster
  attr_accessor :type, :hitbox
  def initialize(x, y, type, hitbox, animation, ani_duration = 100)
    @x = x
    @y = y
    @type = type
    @hitbox = hitbox
    @animation = animation
    @ani_index = 0
    @ani_time = Gosu.milliseconds
    @ani_duration = ani_duration
  end

  def move_y(y)
    @y -= y
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
  end

  def draw
    @animation[@ani_index].draw_rot(@x, @y, ZOrder::MONSTERS)
  end
end

class StaticMonster < Monster
  def initialize
    
  end
end

class MovingMonster < Monster
  def initialize
    
  end
end

class FlyingMonster < Monster
  def initialize
    
  end
end
