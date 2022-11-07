require './state/menu_state'
require './entity/monster'
require './entity/hitbox'

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
    # @star = Monster.new(200, 100, :star, Hitbox.new_xywh(100, 200, 25, 25), Gosu::Image.load_tiles("img/star.png", 25, 40))
  end

  def draw
    # @star.draw
    @state.draw
  end

  def update
    # @star.animate
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
