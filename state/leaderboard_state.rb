require "./state/game_state"
require "./state/menu_state"

class LeaderboardState < GameState
  def initialize(window)
    super(window)
    @background = Gosu::Image.new("img/achievement_background.png")
    @line_splitter = Gosu::Image.new("img/achievement_background_line_splitter.png")
    @splitter = Gosu::Image.new("img/achievement_background_splitter.png")
    @gold_medal, @silver_medal, @copper_medal = *Gosu::Image.load_tiles("img/medal.png", 44, 33)
    @loading_animation = Animation.new(Gosu::Image.load_tiles("img/loading.png", 30, 30), 50)
    @loading_title = Gosu::Image.from_markup("<b><c=ffffff>loading...</c></b>", 50, font: "img/DoodleJump.ttf")
    today_img, thisweek_img, alltime_img, today_img_hover, thisweek_img_hover, alltime_img_hover, today_img_active, thisweek_img_active, alltime_img_active = *Gosu::Image.load_tiles("img/achievement_panel.png", 96, 30)
    menu_img, menu_img_pressed = *Gosu::Image.load_tiles("img/menu_button.png", 114, 41)
    @today_panel = Panel.new(48, 101, 96, 29, today_img, today_img_hover, today_img_active, 6)
    @thisweek_panel = Panel.new(152, 101, 96, 29, thisweek_img, thisweek_img_hover, thisweek_img_active, 6)
    @alltime_panel = Panel.new(256, 101, 96, 29, alltime_img, alltime_img_hover, alltime_img_active, 6)
    @today_panel.activate
    @menu_button = Button.new(303, 568, 114, 41, menu_img, menu_img_pressed)

    @loading = true
    @state = :today
    @query_executed = false
    @query_success = false

    @show_3dot = false
    @player_index = -1
  end

  def enter

  end

  def leave
    
  end

  def draw
    intro if @intro
    outro if @outro
    @background.draw(0, 0, ZOrder::BACKGROUND)
    @today_panel.draw
    @thisweek_panel.draw
    @alltime_panel.draw
    @menu_button.draw
    if @intro or @outro == nil
      if @loading
        @loading_animation.draw(115, 320, ZOrder::UI)
        @loading_title.draw(150, 300, ZOrder::UI)
      else
        (@table.length >= 5 ? 5 : @table.length).times do |i|
          case i
          when 0
            index_img = @gold_medal
          when 1
            index_img = @silver_medal
          when 2
            index_img = @copper_medal
          else
            index_img = Gosu::Image.from_markup("<c=E1DCC6>#{i+1}</c>", 28, font: "Arial Black")
          end
          name = Gosu::Image.from_text(@table[i]["name"], 30, bold: true, font: "img/DoodleJump.ttf")
          score = Gosu::Image.from_text(@table[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
          index_img.draw_rot(66, 153 + i * 45, ZOrder::UI)
          name.draw_rot(115, 153 + i * 45, ZOrder::UI, 0, 0)
          score.draw_rot(350, 153 + i * 45, ZOrder::UI, 0, 1)
        end
        @line_splitter.draw(0, 0, ZOrder::BACKGROUND)
        if @show_3dot
          @splitter.draw(0, 0)
          if @player_index == @table.length-1
            (@player_index - 2).upto(@player_index) do |i|
              index_img = Gosu::Image.from_markup("<c=E1DCC6>#{i+1}</c>", 28, font: "Arial Black")
              name = Gosu::Image.from_text(@table[i]["name"], 30, bold: true, font: "img/DoodleJump.ttf")
              score = Gosu::Image.from_text(@table[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
              index_img.draw_rot(66, 153 + (i - @player_index + 8) * 45, ZOrder::UI)
              name.draw_rot(115, 153 + (i - @player_index + 8) * 45, ZOrder::UI, 0, 0)
              score.draw_rot(350, 153 + (i - @player_index + 8) * 45, ZOrder::UI, 0, 1)
            end
          else
            (@player_index - 1).upto(@player_index + 1) do |i|
              index_img = Gosu::Image.from_text.from_markup("<c=E1DCC6>#{i+1}</c>", 28, font: "Arial Black")
              name = Gosu::Image.from_text(@table[i]["name"], 30, bold: true, font: "img/DoodleJump.ttf")
              score = Gosu::Image.from_text(@table[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
              index_img.draw_rot(66, 153 + (i - @player_index + 7) * 45, ZOrder::UI)
              name.draw_rot(115, 153 + (i - @player_index + 7) * 45, ZOrder::UI, 0, 0)
              score.draw_rot(350, 153 + (i - @player_index + 7) * 45, ZOrder::UI, 0, 1)
            end
          end
        else
          5.upto(@table.length >= 9 ? 8 : @table.length-1) do |i|
            index_img = Gosu::Image.from_markup("<c=E1DCC6>#{i+1}</c>", 28, font: "Arial Black")
            name = Gosu::Image.from_text(@table[i]["name"], 30, bold: true, font: "img/DoodleJump.ttf")
            score = Gosu::Image.from_text(@table[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
            index_img.draw_rot(66, 153 + i*45, ZOrder::UI)
            name.draw_rot(115, 153 + i*45, ZOrder::UI, 0, 0)
            score.draw_rot(350, 153 + i*45, ZOrder::UI, 0, 1)
          end
        end
      end
    end
  end

  def update
    @loading_animation.animate
    if @menu_button.clicked?(@window.mouse_x, @window.mouse_y)
      @outro = true
    end
    if @outro == false
      @window.switch(MenuState.new(@window))
    end
    if @loading and not @query_executed
      puts "i> Query leaderboard information..."
      case @state
      when :today
        @future = $session.execute_async("SELECT * FROM scores WHERE time > '#{(Time.now - 86400).strftime('%Y-%m-%d')}' ALLOW FILTERING")
      when :thisweek
        @future = $session.execute_async("SELECT * FROM scores WHERE time > '#{(Time.now - 604800).strftime('%Y-%m-%d')}' ALLOW FILTERING")
      when :alltime
        @future = $session.execute_async("SELECT * FROM scores")
      end
      @query_executed = true
      @future.on_success do |result|
        puts "i> Success!"
        @table = []
        result.each do |row|
          @table << row
        end
        @table.sort_by! { |row| [-row["score"], row["time"]] }
        @loading = false
        @query_executed = false
        @query_success = true
      end
      @future.on_failure do |e|
        puts "e> #{e}"
        @query_executed = false
      end
    end
    if @query_success
      @player_index = @table.find_index { |row| row["id"].to_s == JSON.load_file("info")["id"] }
      if @player_index < 8
        @show_3dot = false
      else
        @show_3dot = true
      end
      @query_success = false
    end
    if @today_panel.clicked?(@window.mouse_x, @window.mouse_y)
      case @state
      when :thisweek
        @thisweek_panel.deactivate
      when :alltime
        @alltime_panel.deactivate
      end
      @loading = true
      @state = :today
    end
    if @thisweek_panel.clicked?(@window.mouse_x, @window.mouse_y)
      case @state
      when :today
        @today_panel.deactivate
      when :alltime
        @alltime_panel.deactivate
      end
      @loading = true
      @state = :thisweek
    end
    if @alltime_panel.clicked?(@window.mouse_x, @window.mouse_y)
      case @state
      when :today
        @today_panel.deactivate
      when :thisweek
        @thisweek_panel.deactivate
      end
      @loading = true
      @state = :alltime
    end
  end
end