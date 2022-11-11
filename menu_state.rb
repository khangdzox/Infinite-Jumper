require_relative "../modules"
require_relative "../entity/button"
require_relative "./game_state"
require_relative "./play_state"
require_relative "./pause_state"

class MenuState < GameState
  def initialize(window)
    super(window)
    @font = Gosu::Font.new(40, name: "./img/DoodleJump.ttf")
    @background_color = 0xFF_82C4FF
    @title = Gosu::Image.new("./img/doodle-jump.png")
    play_img = Gosu::Image.new("./img/play.png")
    play_img_pressed = Gosu::Image.new("./img/play-on.png")
    @play_button = Button.new(270, 270, 111, 40, play_img, play_img_pressed)
    @bgm = Gosu::Song.new('sound/Analog-Nostalgia.mp3')
    @bgm.volume = 0.7
    @platform = StaticPlatform.new(80, 500)
    @player = Player.new(80, 630)
    @player.jump(-15, 0)
  end

  def enter
    @bgm.play(true)
  end

  def leave
    @bgm.stop
  end

  def draw
    intro if @intro
    outro if @outro
    @platform.draw
    @player.draw
    @title.draw_rot(150, 200, ZOrder::UI)
    @play_button.draw
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, @background_color)
  end

  def update
    if @player.vy > 0 and @player.collide_with(@platform)
      @player.jump
    end
    @player.fall
    @player.move_y
    if @play_button.clicked?(@window.mouse_x, @window.mouse_y)
      @outro = true
    end
    if @outro == false
      @window.switch(PlayState.new(@window))
    end
  end
end