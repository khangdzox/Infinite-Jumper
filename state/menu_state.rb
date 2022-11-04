require_relative "../modules"
require_relative "../entity/button"
require_relative "./game_state"
require_relative "./play_state"

class MenuState < GameState
  def initialize
    super
    @font = Gosu::Font.new(40, name: "./img/DoodleJump.ttf")
    @background_color = 0xFF_82C4FF
    @title = Gosu::Image.new("./img/doodle-jump.png")
    play_img = Gosu::Image.new("./img/play.png")
    play_img_pressed = Gosu::Image.new("./img/play-on.png")
    @play_button = Button.new(50, 150, 111, 40, play_img, play_img_pressed)
    # @sfx_enter = Gosu::Sample.new('sound/sfx_enter.mp3')
    # @bgm_title = Gosu::Song.new('sound/title.mp3')
    @platform = StaticPlatform.new(80, 500)
    @player = Player.new(80, 630)
    @player.jump(-15)
  end

  def enter
    # @bgm_title.play
  end

  def leave
    # @bgm_title.stop
  end

  def draw
    intro if @intro
    outro if @outro
    @platform.draw
    @player.draw
    @title.draw(20, 70, ZOrder::UI)
    @play_button.draw
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, @background_color)
  end

  def update
    if @player.vy > 0 and @player.collide_with(@platform)
      @player.jump
      @player.play_sound(:jump)
    end
    @player.fall
    @player.move_y
    if @play_button.clicked?($window.mouse_x, $window.mouse_y)
      @outro = true
      # @sfx_enter.play(1.0, 1.0, false)
    end
    if @outro == false
      GameState.switch(PlayState.new)
    end
  end
end