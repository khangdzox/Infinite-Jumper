require "./modules"
require "./entity/button"
require "./state/game_state"
require "./state/play_state"
require "./state/leaderboard_state"
require "./state/instruction_state"

class MenuState < GameState
  def initialize(window)
    super(window)
    @font = Gosu::Font.new(40, name: "img/DoodleJump.ttf")
    @background = Gosu::Image.new("img/background.png")
    @title = Gosu::Image.new("img/doodle-jump.png")
    play_img, play_img_pressed = Gosu::Image.load_tiles("img/play_button.png", 111, 40)
    leaderboard_img, leaderboard_img_pressed = Gosu::Image.load_tiles("img/leaderboard_button.png", 134, 41)
    ins_img, ins_img_pressed = Gosu::Image.load_tiles("img/instruction_button.png", 114, 41)
    @play_button = Button.new(170, 220, 111, 40, play_img, play_img_pressed)
    @leaderboard_button = Button.new(300, 400, 134, 41, leaderboard_img, leaderboard_img_pressed)
    @instruction_button = Button.new(300, 500, 114, 41, ins_img, ins_img_pressed)
    @bgm = Gosu::Song.new('sound/Analog-Nostalgia.mp3')
    @bgm.volume = 0.7
    @platform = StaticPlatform.new(80, 500)
    @player = Player.new(80, 630)
    @player.jump(-15, 0)
    @next_state = nil
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
    @title.draw_rot(150, 150, ZOrder::UI)
    @play_button.draw
    @leaderboard_button.draw
    @instruction_button.draw
    @background.draw(0, 0, ZOrder::BACKGROUND)
  end

  def update
    if @player.vy > 0 and @player.collide_with(@platform)
      @player.jump
    end
    @player.fall
    @player.move_y
    if @leaderboard_button.clicked?(@window.mouse_x, @window.mouse_y)
      @outro = true
      @next_state = LeaderboardState.new(@window)
    end
    if @instruction_button.clicked?(@window.mouse_x, @window.mouse_y)
      @outro = true
      @next_state = InstructionState.new(@window)
    end 
    if @play_button.clicked?(@window.mouse_x, @window.mouse_y) or Gosu.button_down?(Gosu::KB_SPACE)
      @outro = true
      @next_state = PlayState.new(@window)
    end
    if @outro == false
      @window.switch(@next_state)
    end
  end
end