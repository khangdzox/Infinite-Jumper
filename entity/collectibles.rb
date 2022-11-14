require './modules'
require_relative './hitbox'
require_relative './player'

def generate_collectible(x, y)
  case rand(6)
  when 0
    Star.new(x, y)
  when 1
    HealthBottle.new(x, y)
  when 2
    Propeller.new(x, y)
  when 3
    Springshoe.new(x, y)
  when 4
    Spikeshoe.new(x, y)
  when 5
    Shield.new(x, y)
  end 
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
  end
end 

class Star < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :star, Hitbox.new_xywh(100, 200, 25, 25), Gosu::Image.load_tiles("img/star.png", 25, 40)[1..8])
  end 
end 

class HealthBottle < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :healthbottle, Hitbox.new_xywh(100, 200, 20, 28), Gosu::Image.load_tiles("img/health_bottle.png", 20, 28))
  end 
end 

class Propeller < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :propeller, Hitbox.new_xywh(100, 200, 32, 32), Gosu::Image.load_tiles("img/propeller.png", 32, 32)[1..3])   
  end
end 

class Springshoe < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :springshoe, Hitbox.new_xywh(100, 200, 30, 24), Gosu::Image.load_tiles("img/springshoes-side.png", 30, 24)[1..5])
    @use_duration = Gosu.milliseconds
    if Gosu.milliseconds - @use_duration > 5000
      @use_duration = nil
    end 
  end 
  
end 

class Spikeshoe < Collectible
  attr_accessor :type, :hitbox
  def initialize(x, y)
    super(x, y, :spikeshoe, Hitbox.new_xywh(100, 200, 30, 30), Gosu::Image.load_tiles("img/spikeshoes.png", 30, 30))
    
  end 
end 

class Shield < Collectible
  def initialize(x, y)
    super(x, y, :shield, Hitbox.new_xywh(100, 200, 25, 25), Gosu::Image.load_tiles("img/shield_icon.png", 25, 25))
  end 
end 