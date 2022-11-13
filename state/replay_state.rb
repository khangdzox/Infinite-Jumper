require "./modules"
require "./entity/button"
require "./state/game_state"
require "./state/play_state"

class ReplayState < GameState
  def initialize(window, score, last_x, last_dir)
    super(window)
    @score = score
    @player = Player.new(last_x, -60)
    @player.dir = last_dir
    @background_color = 0xFF_82C4FF
    @font = Gosu::Font.new(35, bold: true, name: "img/DoodleJump.ttf")
    @game_over = Gosu::Image.new("img/game_over_title.png")
    @sfx_fall = Gosu::Sample.new('sound/fall.mp3') 

    menu_img, play_again_img, menu_img_pressed, play_again_img_pressed = *Gosu::Image.load_tiles("img/buttons.png", 114, 41)
    @replay_button = Button.new(120, 330, 114, 41, play_again_img, play_again_img_pressed)
    @menu_button = Button.new(280, 330, 114, 41, menu_img, menu_img_pressed)

    @next_state = nil

    high_score_file = File.new("highscore.txt", "r")
    @highscore = high_score_file.read.to_i
    high_score_file.close
    if @highscore < @score
      high_score_file = File.new("highscore.txt", "w")
      high_score_file.write(@score)
      high_score_file.close
      @highscore = @score
    end
  end

  def enter
    @sfx_fall.play
  end

  def leave
  end

  def draw
    outro if @outro
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, @background_color)
    @game_over.draw(80, 112, ZOrder::UI)
    @font.draw_text("your score: #{@score}", 110, 210, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @font.draw_text("your high score: #{@highscore}", 62, 240, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    # @font.draw_text("your name: #{"no info"}", 117, 270, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @menu_button.draw
    @replay_button.draw
    if @player != nil
      @player.draw
    end
  end

  def update
    if @menu_button.clicked?(@window.mouse_x, @window.mouse_y) and @outro.nil?
      @outro = true
      @next_state = MenuState.new(@window)
    end
    if @replay_button.clicked?(@window.mouse_x, @window.mouse_y) or Gosu.button_down?(Gosu::KB_SPACE) and @outro.nil?
      @outro = true
      @next_state = PlayState.new(@window)
    end
    if @outro == false
      @window.switch(@next_state)
    end
    if @player != nil
      @player.fall
      @player.move_y
      if @player.hitbox.top > Window::HEIGHT
        @player = nil
      end
    end
  end
end