require './state/menu_state'
require './entity/monster'
require './entity/hitbox'

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
    # @demo = Monster.new(200, 100, :flying, Hitbox.new_xywh(200, 100, 25, 25), Gosu::Image.load_tiles("img/flying_monster.png", 80, 63))
    @demo = FlyingDownMonster.new(200, -30)
    @pause = false
    @button_pressed = false
    @time_offset = 0
    @time_now = Gosu.milliseconds
  end

  def draw
    @demo.draw
    @state.draw
  end

  def update
    if not @pause
      @demo.animate
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
