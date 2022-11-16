require "./modules"
require "./entity/hitbox"
require "./entity/platform"
require "./entity/player"
require "./entity/monster"

def generate_collectible(last_x, last_y)
  x = 60 + (last_x + rand(150) - 50) %280
  y = last_y - 80
  case rand(2)
  when 0
    collectible = Star.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(x, y),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 1
    collectible = HealthBottle.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(x, y),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 2
    collectible = Propeller.new(x + rand(41) - 15, y - 25)
    associated_platforms = [
      StaticPlatform.new(x-30, y+5),
      StaticPlatform.new(x+30, y+5),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 3
    collectible = Springshoe.new(x + rand(51) - 20, y - 25)
    associated_platforms = [
      StaticPlatform.new(x-30, y+5),
      StaticPlatform.new(x+30, y+5),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 4
    collectible = Spikeshoe.new(x + rand(71) - 15, y - 10)
    associated_platforms = [
      StaticPlatform.new(x-30, y+5),
      StaticPlatform.new(x+30, y+5),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 5
    collectible = Shield.new(x + rand(81) - 20, y - 20)
    associated_platforms = [
      StaticPlatform.new(x-30, y+5),
      StaticPlatform.new(x+30, y+5),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  end 
  return *[collectible, associated_platforms]
end   


class Collectible 
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

  def move(y)
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
    @animation[@ani_index].draw_rot(@x, @y, ZOrder::COLLECTIBLES)
    @hitbox.draw(@x, @y, ZOrder::COLLECTIBLES, 0xFF_FFBF00)
  end
end 

class Star < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :star, Hitbox.new_xywh(x, y, 25, 40), Gosu::Image.load_tiles("img/star.png", 25, 40))
  end 

  def action
    # if collide_with?
    #   @score += 50 
    # end 
  end 
end 

class HealthBottle < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :health_bottle, Hitbox.new_xywh(x, y, 20, 28), Gosu::Image.load_tiles("img/health_bottle.png", 20, 28))
  end 

  def action
    # if collide_with?
    #   @heart += 1
    # end 
  end 
end 

class Propeller < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :propeller, Hitbox.new_xywh(x, y, 32, 32), Gosu::Image.load_tiles("img/propeller.png", 32, 32)[1..3])  
    @fly_start = Gosu.milliseconds
    @vy = 0
  end

  def remove 

  end 

  def action
    if collide_with?
      @vy += Gravity
      @y += @vy
      fly_duration = Gosu.milliseconds - @fly_start
    end

    if fly_duration > 6000
      Propeller.remove
    end  
  end 

end 

class Springshoe < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :springshoe, Hitbox.new_xywh(x, y, 28, 21), Gosu::Image.load_tiles('img/springshoes_icon.png', 28, 21))
    @spring_icon = Gosu::Image.load_tiles('img/springshoes_icon.png', 28, 21)
    @spring_left = Gosu::Image.load_tiles('img/springshoes-side_left.png', 30, 24)
    @spring_right = Gosu::Image.load_tiles('img/springshoes-side_right.png', 30, 24)
    @type = :springshoe 
    @dir = 'right'
    @springshoe_start = Gosu.milliseconds
    @vy = 0
  end 

  def remove

  end 

  def action
    if collide_with?
      @vy += Gravity
      @y += @vy
      springshoe_duration = Gosu.milliseconds - @springshoe_start
    end 

    if springshoe_duration > 10000
      Springshoe.remove
    end 
  end 

  def draw 
    case @dir 
    when 'left'
      spring = @spring_left
    when 'right'
      spring = @spring_right
    end 
  end 
end 

class Spikeshoe < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :spikeshoe, Hitbox.new_xywh(x, y, 30, 30), Gosu::Image.load_tiles('img/spikeshoes_left.png', 30, 30))
    @spike_left = Gosu::Image.load_tiles('img/spikeshoes_left.png', 30, 30)
    @spike_right = Gosu::Image.load_tiles('img/spikeshoes_right.png', 30, 30)
    @type = :spikeshoe 
    @dir = 'right'
    @spikeshoe_start = Gosu.milliseconds
  end 

  def remove 

  end 

  def action
    if collide_with?
      spikeshoe_duration = Gosu.milliseconds - @spikeshoe_start
    end 

    if spikeshoe_duration > 15000
      Spikeshoe.remove
    end 
  end 
end 

class Shield < Collectible
  def initialize(x, y)
    super(x, y, :shield, Hitbox.new_xywh(x, y, 25, 25), Gosu::Image.load_tiles("img/shield_icon.png", 25, 25))
    #@shield = Gosu::Image.load_tiles("shield.png", 96, 96)
    #@shield_hitbox = Hitbox.new_xywh(100, 200, 96, 96)
    @shield_start = Gosu.milliseconds
  end 

  def remove 

  end 

  def action
    if collide_with?
      @shield.draw
      shield_duration = Gosu.milliseconds - @shield_start
    end 

    if shield_duration > 15000 || Player.collide_with(monster)
      Shield.remove
    end 
  end 
end 