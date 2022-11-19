require "./modules"
require "./entity/hitbox"
require "./entity/platform"
require "./entity/player"
require "./entity/monster"
require "./entity/animation"

def generate_collectible(last_x, last_y)
  x = 60 + (last_x + rand(150) - 50) %280
  y = last_y - 80
  case rand(6)
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
    collectible = Propeller.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(x, y),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 3
    collectible = Springshoe.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(x, y),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 4
    collectible = Spikeshoe.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(x, y),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  when 5
    collectible = Shield.new(x, y - 25)
    associated_platforms = [
      StaticPlatform.new(x, y),
      StaticPlatform.new(30 + (x + rand(201) - 100) %340, y - 80)
    ]
  end 
  return *[collectible, associated_platforms]
end   


class Collectible 
  attr_accessor :type, :hitbox, :duration, :collected_time
  def initialize(x, y, type, hitbox, duration, animation_collectible, animation_activated, ani_duration = 100)
    @x = x
    @y = y
    @type = type
    @hitbox = hitbox
    @duration = duration
    @sfx_deactivate = Gosu::Sample.new('sound/deactivate.mp3')
    @animation = @ani_collectible = Animation.new(animation_collectible, ani_duration)
    @ani_activated = Animation.new(animation_activated, ani_duration)
    @activated = false
    @collected_time = nil
  end 

  def move(y)
    @y -= y
    @hitbox.top -= y
    @hitbox.bottom -= y
  end

  def custom_activate(player)
  end

  def activate(player)
    @activated = true
    @collected_time = $systime
    @animation = @ani_activated
    custom_activate(player)
  end
 
  def action(player)
  end

  def animate
    @animation.animate
  end

  def remove
    move(-500)
  end
  
  def draw(dir = 1)
    @animation.draw(@x, @y, ZOrder::COLLECTIBLES, dir)
    @hitbox.draw(@x, @y, ZOrder::COLLECTIBLES, 0xFF_FFBF00)
  end
end 

class Star < Collectible
  def initialize(x, y)
    @sfx_star = Gosu::Sample.new('sound/star.mp3')
    super(
      x,
      y,
      :star,
      Hitbox.new_xywh(x, y, 25, 40),
      0,
      Gosu::Image.load_tiles("img/star.png", 25, 40),
      []
    )
  end 

  def custom_activate(player)
    player.score += 100
    @sfx_star.play
  end
end 

class HealthBottle < Collectible
  def initialize(x, y)
    @sfx_health = Gosu::Sample.new('sound/health_regained.mp3')
    super(
      x,
      y,
      :health_bottle,
      Hitbox.new_xywh(x, y, 20, 28),
      0,
      Gosu::Image.load_tiles("img/health_bottle.png", 20, 28),
      []
    )
  end 

  def custom_activate(player)
    player.heart += 1 if player.heart < 3
    @sfx_health.play
  end 
end 

class Propeller < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    @sfx_propeller = Gosu::Sample.new('sound/propeller.mp3')
    super(x,
      y,
      :propeller,
      Hitbox.new_xywh(x, y, 32, 32),
      4000,
      [Gosu::Image.load_tiles("img/propeller.png", 32, 32)[0]],
      Gosu::Image.load_tiles("img/propeller.png", 32, 32)[1..3]
    )
    @vx = 2.5 * (rand(2) == 0 ? 1 : -1)
    @vy = -5
  end

  def custom_activate(player)
    player.state = :propeller
    @sfx_propeller.play
  end

  def action(player)
    dt = ($systime - @collected_time).to_f / @duration.to_f
    player.vy = -13.0 * (1.0 - (1.0 - dt)**4.0)
    @x = player.x
    @y = player.hitbox.top - 6
    @hitbox = Hitbox.new_xywh(@x, @y, 32, 32)
  end

  def remove
    @vy += Gravity
    @x += @vx
    @y += @vy
    @hitbox = Hitbox.new_xywh(@x, @y, 32, 32)
    @sfx_deactivate.play
  end
end 

class Spikeshoe < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    @sfx_spikeshoe = Gosu::Sample.new('sound/spikeshoes.mp3')
    @vx = 2.5 * (rand(2) == 0 ? 1 : -1)
    @vy = -5
    @scale = 1.5
    super(
      x,
      y,
      :spikeshoe,
      Hitbox.new_xywh(x, y+6, 28*@scale, 12*@scale),
      6000,
      [Gosu::Image.new('img/spikeshoes.png')],
      [Gosu::Image.new('img/spikeshoes.png')]
    )
  end 

  def custom_activate(player)
    player.state = :spike
    @scale = 1
    @sfx_spikeshoe.play
  end

  def action(player)
    @x = player.x
    @y = player.hitbox.bottom - 5 + Gravity
    @hitbox = Hitbox.new_xywh(@x, @y+6, 28*@scale, 12*@scale)
  end

  def remove
    @scale = 1.5
    @vy += Gravity
    @x += @vx
    @y += @vy
    @hitbox = Hitbox.new_xywh(@x, @y+6, 28*@scale, 12*@scale)
    @sfx_deactivate.play
  end 

  def draw(dir = 1)
    @animation.draw(@x, @y, ZOrder::COLLECTIBLES, dir, 0, 0.5, 0, @scale, @scale)
    @hitbox.draw(@x, @y, ZOrder::COLLECTIBLES, 0xFF_FFBF00)
  end
end 

class Shield < Collectible
  def initialize(x, y)
    @sfx_shield = Gosu::Sample.new('sound/shield.mp3')
    super(
      x,
      y,
      :shield,
      Hitbox.new_xywh(x, y, 25, 25),
      10000,
      [Gosu::Image.new("img/shield_icon.png")],
      [Gosu::Image.new("img/shield.png")]
    )
    @vx = 2.5 * (rand(2) == 0 ? 1 : -1)
    @vy = -5
  end 

  def custom_activate(player)
    player.state = :shield
    @sfx_shield.play 
  end

  def action(player)
    @x = player.x
    @y = player.y + Gravity
    @hitbox = Hitbox.new_xywh(@x, @y, 96, 96)
  end

  def remove
    @vy += Gravity
    @x += @vx
    @y += @vy
    @hitbox = Hitbox.new_xywh(@x, @y, 96, 96)
    @sfx_deactivate.play
  end
end

##
# Springshoe class is complex so it will be separately implemented
class Springshoe
  attr_accessor :type, :hitbox, :duration, :collected_time
  def initialize(x, y)
    @x = x
    @y = y
    @type = :springshoe
    @scale = 1.2
    @hitbox = Hitbox.new_xywh(x, y+10.5, 28*@scale, 21*@scale)
    @duration = 6000
    @sfx_springshoe = Gosu::Sample.new('sound/springshoes.mp3')
    @animation = @ani_collectible = Gosu::Image.load_tiles('img/springshoes_icon.png', 28, 21)
    @ani_activated = Gosu::Image.load_tiles("img/springshoes.png", 28, 21)
    @ani_index = 0
    @ani_time = $systime
    @ani_duration = 50
    @ani_play = false
    @activated = false
    @collected_time = nil
    @vx = 2.5 * (rand(2) == 0 ? 1 : -1)
    @vy = -5
  end

  def move(y)
    @y -= y
    @hitbox.top -= y
    @hitbox.bottom -= y
  end

  def custom_activate(player)
    player.state = :spring
    @sfx_springshoe.play
  end

  def activate(player)
    @scale = 1
    @activated = true
    @collected_time = $systime
    @animation = @ani_activated
    custom_activate(player)
  end
 
  def action(player)
    @x = player.x
    @y = player.hitbox.bottom - 5 + Gravity
    @hitbox = Hitbox.new_xywh(@x, @y+10.5, 28, 21)
  end

  def animate_once
    @ani_play = true
    @ani_index = 0
  end

  def animate
    if @ani_play and $systime - @ani_time >= @ani_duration and @animation != []
      @ani_index += 1
      if @ani_index == @animation.length
        @ani_play = false
        @ani_index = 0
      end
      @ani_time = $systime
    end
  end

  def remove
    @scale = 1.2
    @vy += Gravity
    @x += @vx
    @y += @vy
    @hitbox = Hitbox.new_xywh(@x, @y+10.5, 28, 21)
    @sfx_deactivate.play
  end

  def draw(dir = 1)
    @animation[@ani_index].draw_rot(@x, @y, ZOrder::COLLECTIBLES, 0, 0.5, 0, dir * @scale, @scale) if @animation != []
    @hitbox.draw(@x, @y, ZOrder::COLLECTIBLES, 0xFF_FFBF00)
  end
end 