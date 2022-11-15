require_relative "../modules"
require_relative "../entity/button"
require_relative "./game_state"
require_relative "./play_state"

class PauseState < GameState
  def initialize(window)
    super(window)
    
    @font = Gosu::Font.new(35, bold: true, name: "img/DoodleJump.ttf")
    pause_img = Gosu::Image.new('pause_button.png')
    pause_img_pressed = Gosu::Image.new('pause_button.png')
    @pause_button = Button.new(380, 580, 30, 30, pause_img, pause_img_pressed)
    
    @play_state = nil 
  end 
  
  def enter
  end 
  
  def leave
  end 
  
  def draw
    @font.draw_text("Game paused...", 110, 210, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @pause_button.draw
  end 
  
  def update 
    if @pause_button.clicked?(@window.mouse_x, @window.mouse_y)
      @play_state = PlayState.new(@window)
    end 
  end 
end 