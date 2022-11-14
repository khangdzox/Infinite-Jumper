require './state/menu_state'
require './entity/monster'
require './entity/hitbox'
require './entity/collectibles'

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
    # @star = Monster.new(200, 100, :star, Hitbox.new_xywh(100, 200, 25, 25), Gosu::Image.load_tiles("img/star.png", 25, 40))
    #@star = Star.new(200, 100)
    #@health_bottle = HealthBottle.new(250, 100)
    #@propeller = Propeller.new(50, 100)
    #@springshoe = Springshoe.new(100, 100)
    #@spikeshoe = Spikeshoe.new(300, 100)
    @shield = Shield.new(200, 100)
  end

  def draw
    # @star.draw
    #@star.draw
    #@health_bottle.draw
    #@propeller.draw
    #@springshoe.draw
    #@spikeshoe.draw
    @shield.draw
    @state.draw
  end

  def update
    #@star.animate
    #@star.animate
    #@propeller.animate
    #@springshoe.animate
    @state.update
  end

  def switch(new_state)
    @state && @state.leave
    @state = new_state
    new_state.enter
  end
end
 
window = MainWindow.new
window.switch(MenuState.new(window))
window.show
