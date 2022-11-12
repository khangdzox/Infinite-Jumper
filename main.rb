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
    # @demo = Monster.new(200, 100, :flying, Hitbox.new_xywh(200, 100, 25, 25), Gosu::Image.load_tiles("img/flying_monster.png", 80, 63))
    # @demo = FlyingDownMonster.new(200, -30)
    @pause = false
    @button_pressed = false
    @time_offset = 0
    @time_now = Gosu.milliseconds
    # @star = Star.new(200, 100)
    # @health_bottle = HealthBottle.new(250, 100)
    # @propeller = Propeller.new(50, 100)
    # @springshoe = Springshoe.new(100, 100)
    # @spikeshoe = Spikeshoe.new(300, 100)
    # @shield = Shield.new(200, 100)
  end

  def draw
    # @demo.draw
    # @star.draw
    # @health_bottle.draw
    # @propeller.draw
    # @springshoe.draw
    # @spikeshoe.draw
    # @shield.draw
    @state.draw
  end

  def update
    # @star.animate
    # @star.animate
    # @propeller.animate
    # @springshoe.animate
    if not @pause
      # @demo.animatea
      @state.update
      @time_now = Gosu.milliseconds - @time_offset
    end
    if Gosu.button_down?(Gosu::KB_ESCAPE)
      if not @button_pressed
        @pause = !@pause
        @button_pressed = true
        if !@pause
          @time_offset = Gosu.milliseconds - @time_now
        end
      end
    else
      @button_pressed = false
    end
    # puts @time_now/1000
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
