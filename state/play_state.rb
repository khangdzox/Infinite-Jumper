require_relative '../modules'
require_relative '../entity/player'
require_relative '../entity/platform'
require_relative './game_state'
require_relative './replay_state'

class PlayState < GameState
  def initialize
    super
    @platforms = []
    23.downto(-30) do |i|
      @platforms << Platform.new(:static, 30 + rand(341), i * 25)
    end

    @player = Player.new(@platforms[0].x, 600)
    @player.jump(-15)

    @highest_standable_platform = @platforms.last

    @background_color = 0xFF_82C4FF

    @god_mode = false
  end

  def enter
  end

  def leave
  end

  def draw
    intro if @intro
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, @background_color)
    @player.draw
    @player.draw_score
    @player.draw_heart
    @platforms.each do |platform|
      platform.draw
    end
  end

  def update
    @platforms.each do |platform|
      if platform.type == :move
        platform.move_around
      elsif platform.type == :break
        platform.drop if platform.broken != nil
      end

      if @player.vy > 0
        if platform.bottom > HeightLimit + 60
          if @player.collide_with(platform)
            case platform.type
            when :boost
              @player.jump(-22)
              @player.roll
            when :break
              platform.break
            else
              @player.jump
            end
          end
        end
      end
    end

    if not @god_mode
      if Gosu.button_down?(Gosu::KB_A) or Gosu.button_down?(Gosu::KB_LEFT)
        @player.move_left
      elsif Gosu.button_down?(Gosu::KB_D) or Gosu.button_down?(Gosu::KB_RIGHT)
        @player.move_right
      else
        @player.slow_down
      end
    else
      @player.set_x($window.mouse_x)
    end

    @player.fall
    if @player.vy < 0 and @player.top <= HeightLimit
      @platforms.each { |platform| platform.move_y(@player.vy + @player.top - HeightLimit)}
      @platforms.reject! { |platform| platform.bottom >= Window::HEIGHT}
      @player.set_top(HeightLimit)
      @player.move_x
      @player.score += 1
    else
      @player.move_y
      @player.move_x
    end

    if @platforms.last.top > 5
      if @highest_standable_platform.top > 90
        @platforms << @highest_standable_platform = generate_random_standable_platform
      elsif @highest_standable_platform.top > 70
        if rand(100) < 50
          @platforms << @highest_standable_platform = generate_random_standable_platform
        elsif rand(100) < 30
          @platforms << generate_random_breakable_platform
        end
      elsif @highest_standable_platform.top > 50
        if rand(100) < 30
          @platforms << @highest_standable_platform = generate_random_standable_platform
        elsif rand(100) < 30
          @platforms << generate_random_breakable_platform
        end
      elsif @highest_standable_platform.top > 10
        if rand(100) < 10
          @platforms << @highest_standable_platform = generate_random_standable_platform
        elsif rand(100) < 10
          @platforms << generate_random_breakable_platform
        end
      end
    end

    if @player.top >= Window::HEIGHT
      GameState.switch(ReplayState.new(@player.score, @player.x))
    end

    if Gosu.button_down?(Gosu::KB_A) and Gosu.button_down?(Gosu::KB_B)
      @god_mode = true
    end
  end
end