require "./state/game_state"

class InstructionState < GameState
  def initialize(window)
    super(window)
    @background = Gosu::Image.new("img/instruction_background.png")
    menu_img, menu_img_pressed = *Gosu::Image.load_tiles("img/menu_button.png", 114, 41)
    @menu_button = Button.new(303, 568, 114, 41, menu_img, menu_img_pressed)
  end

  def enter

  end

  def leave
    
  end

  def draw
    intro if @intro
    outro if @outro
    @background.draw(0, 0, ZOrder::BACKGROUND)
    @menu_button.draw
  end

  def update
    if @menu_button.clicked?(@window.mouse_x, @window.mouse_y)
      @outro = true
    end 
    if @outro == false
      @window.switch(MenuState.new(@window))
    end 
  end
end