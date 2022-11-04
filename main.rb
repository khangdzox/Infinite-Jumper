require './state/game_state'
require './state/menu_state'
require './state/play_state'

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
  end

  def draw
    @state.draw
  end

  def update
    @state.update
  end
end

$window = MainWindow.new
GameState.switch(MenuState.new)
$window.show
