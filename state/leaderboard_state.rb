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

    @player_index = nil
    @rank_offset = 0
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
        @line_splitter.draw(0, 0, ZOrder::BACKGROUND)
        if @scores.length >= 5
          maxfirstfive = 5
          if @rank_offset != 0
            @splitter.draw(0, 0)
            5.upto(7) do |i|
              index_img = Gosu::Image.from_markup("<c=E1DCC6>#{i + @rank_offset + 1}</c>", 28, font: "Arial Black")
              name = Gosu::Image.from_text(@names[i], 30, bold: true, font: "img/DoodleJump.ttf")
              score = Gosu::Image.from_text(@scores[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
              index_img.draw_rot(66, 198 + i*45, ZOrder::UI)
              name.draw_rot(115, 198 + i*45, ZOrder::UI, 0, 0)
              score.draw_rot(350, 198 + i*45, ZOrder::UI, 0, 1)
            end
          else
            5.upto(@scores.length - 1) do |i|
              index_img = Gosu::Image.from_markup("<c=E1DCC6>#{i + 1}</c>", 28, font: "Arial Black")
              name = Gosu::Image.from_text(@names[i], 30, bold: true, font: "img/DoodleJump.ttf")
              score = Gosu::Image.from_text(@scores[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
              index_img.draw_rot(66, 153 + i*45, ZOrder::UI)
              name.draw_rot(115, 153 + i*45, ZOrder::UI, 0, 0)
              score.draw_rot(350, 153 + i*45, ZOrder::UI, 0, 1)
            end
          end
        else
          maxfirstfive = @scores.length
        end
        maxfirstfive.times do |i|
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
          name = Gosu::Image.from_text(@names[i], 30, bold: true, font: "img/DoodleJump.ttf")
          score = Gosu::Image.from_text(@scores[i]["score"], 30, bold: true, font: "img/DoodleJump.ttf")
          index_img.draw_rot(66, 153 + i * 45, ZOrder::UI)
          name.draw_rot(115, 153 + i * 45, ZOrder::UI, 0, 0)
          score.draw_rot(350, 153 + i * 45, ZOrder::UI, 0, 1)
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
      puts "i> Query leaderboard scores..."
      case @state
      when :today
        future = $session.execute_async("SELECT * FROM scores WHERE time > '#{(Time.now - 86400).strftime('%Y-%m-%d')}' ALLOW FILTERING")
      when :thisweek
        future = $session.execute_async("SELECT * FROM scores WHERE time > '#{(Time.now - 604800).strftime('%Y-%m-%d')}' ALLOW FILTERING")
      when :alltime
        future = $session.execute_async("SELECT * FROM scores")
      end
      @query_executed = true
      future.on_success do |result|
        puts "i> Success!"
        puts "i> Sorting scores..."
        @scores = []
        result.each { |row| @scores << row }
        i = 0
        while i < @scores.length - 1
          if @scores[i]["id"] == @scores[i + 1]["id"]
            if @scores[i]["score"] >= @scores[i + 1]["score"]
              @scores.delete_at(i + 1)
            else
              @scores.delete_at(i)
            end
          else
            i += 1
          end
        end
        @scores.sort_by! { |row| [-row["score"], row["time"]] }
        @player_index = @scores.find_index { |row| row["id"].to_s == File.open("info", "r") { |f| f.read } }
        if @player_index.nil? or (not @player_index.nil? and @player_index < 8)
          @scores = @scores[0..8]
          @rank_offset = 0
        else
          if @player_index == @scores.length - 1
            @scores = @scores[0..4] + @scores[(@player_index - 2)..(@player_index)]
            @rank_offset = @player_index - 7
          else
            @scores = @scores[0..4] + @scores[(@player_index - 1)..(@player_index + 1)]
            @rank_offset = @player_index - 6
          end
        end
        puts "i> Done!"
        puts "i> Scores' count: " + @scores.length.to_s
        puts "i> Query leaderboard names..."
        @names = []
        name_array = []
        result = $session.execute("SELECT * FROM names WHERE id IN (#{@scores.map{ |r| r["id"] }.join(", ")})")
        result.each { |row| name_array << [row["id"].to_s, row["name"]] }
        name_hash = name_array.to_h
        name_hash[File.open("info", "r") { |f| f.read }] += " (you)" 
        @scores.each do |row|
          @names << name_hash[row["id"].to_s]
        end
        puts "i> Done!"
        puts "i> Names' count: " + @names.length.to_s
        if @scores.length == @names.length
          puts "i> Success!"
          @loading = false
          @query_executed = false
        else
          puts "e> An error has occurred!"
          @query_executed = false
        end
      end
      future.on_failure do |e|
        puts "e> #{e}"
        @query_executed = false
      end
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