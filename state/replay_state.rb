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
    @background = Gosu::Image.new("img/background.png")
    @font = Gosu::Font.new(35, bold: true, name: "img/DoodleJump.ttf")
    @game_over = Gosu::Image.new("img/game_over_title.png")
    @sfx_fall = Gosu::Sample.new('sound/fall.mp3') 

    @uuid = File.open("info", "r") { |f| f.read}
    result = $session.execute("SELECT name FROM names WHERE id = #{@uuid}")
    result.each { |r| @name = r["name"] }
    @name_text = Gosu::Image.from_text(@name, 35, bold: true, font: "img/DoodleJump.ttf")

    menu_img, menu_img_pressed = *Gosu::Image.load_tiles("img/menu_button.png", 114, 41)
    play_again_img, play_again_img_pressed  = *Gosu::Image.load_tiles("img/play_again_button.png", 114, 41)
    edit_img, edit_img_pressed = *Gosu::Image.load_tiles("img/edit_button.png", 30, 30)
    @replay_button = Button.new(120, 350, 114, 41, play_again_img, play_again_img_pressed)
    @menu_button = Button.new(280, 350, 114, 41, menu_img, menu_img_pressed)
    @edit_button = Button.new(235 + @name_text.width, 270 + @name_text.height/2, 30, 30, edit_img, edit_img_pressed)

    @next_state = nil

    @edit_state = false

    @highscore = nil
    puts ("i> Query scores...")
    puts ("c> SELECT score FROM scores WHERE id = #{@uuid}")
    future = $session.execute_async("SELECT score FROM scores WHERE id = #{@uuid}")
    future.on_success do |result|
      if not result.empty?
        scores = []
        result.each { |r| scores << r["score"] }
        @highscore = scores.max
        @highscore = @score if @highscore < @score
      else
        @highscore = @score
      end
    end

    puts ("i> Insert new score...")
    puts ("c> INSERT INTO scores (id, time, score) VALUES (#{@uuid}, totimestamp(now()), #{@score})")
    future = $session.execute_async("INSERT INTO scores (id, time, score) VALUES (#{@uuid}, totimestamp(now()), #{@score})")
    future.on_success { puts ("i> Success!") }
  end

  def enter
    @sfx_fall.play
  end

  def leave
  end

  def draw
    outro if @outro
    @background.draw(0, 0, ZOrder::BACKGROUND)
    @game_over.draw(80, 112, ZOrder::UI)
    @font.draw_text("your score: #{@score}", 90, 210, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @font.draw_text("your high score: #{@highscore}", 42, 240, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @font.draw_text("your name:", 97, 270, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @name_text.draw(220, 270, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @edit_button.draw
    @menu_button.draw
    @replay_button.draw
    if @player != nil
      @player.draw
    end
  end

  def update
    if @edit_button.clicked?(@window.mouse_x, @window.mouse_y)
      @edit_state = true
      @window.text_input = Gosu::TextInput.new
      @window.text_input.text = @name
      @edit_button.hide
    end
    if @edit_state
      @name = @window.text_input.text.gsub(/[\W]/, '')
      @name_text = Gosu::Image.from_text(@name, 35, bold: true, font: "img/DoodleJump.ttf")
      if Gosu.button_down?(Gosu::KB_RETURN) or Gosu.button_down?(Gosu::KB_ESCAPE) or Gosu.button_down?(Gosu::KB_ENTER) or (Gosu.button_down?(Gosu::MS_LEFT) and not @edit_button.mouse_in?(@window.mouse_x, @window.mouse_y))
        @edit_state = false
        if @window.text_input.text == ""
          puts "e> Empty name! Revert to old name..."
          result = $session.execute("SELECT name FROM names WHERE id = #{@uuid}")
          result.each { |r| @name = r["name"] }
          @name_text = Gosu::Image.from_text(@name, 35, bold: true, font: "img/DoodleJump.ttf")
        else
          if @window.text_input.text.length > 12
            puts "e> Too long name! Limit name length to 12 characters..."
            @name = @name[0..11]
            @name_text = Gosu::Image.from_text(@name, 35, bold: true, font: "img/DoodleJump.ttf")
          end
          puts ("i> Update name...")
          puts ("c> UPDATE names SET name = '#{@name}' WHERE id = #{@uuid}")
          future = $session.execute_async("UPDATE names SET name = '#{@name}' WHERE id = #{@uuid}")
          future.on_success { puts ("i> Success!") }
        end
        @window.text_input = nil
        @edit_button.set_xy(235 + @name_text.width, 270 + @name_text.height/2)
        @edit_button.show
      end
    end
    if @menu_button.clicked?(@window.mouse_x, @window.mouse_y) and @outro.nil?
      @outro = true
      @next_state = MenuState.new(@window)
    end
    if @replay_button.clicked?(@window.mouse_x, @window.mouse_y) or (Gosu.button_down?(Gosu::KB_SPACE) and @outro.nil? and not @edit_state)
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