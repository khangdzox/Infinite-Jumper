require_relative '../modules'
require_relative '../entity/player'
require_relative '../entity/platform'
require_relative '../entity/collectibles'
require_relative './game_state'
require_relative './replay_state'

class PlayState < GameState
  def initialize(window)
    super(window)

    @platforms = []
    19.downto(-10) do |i|
      @platforms << StaticPlatform.new(30 + rand(341), i * 30)
    end

    @collectible = nil
    
    @player = Player.new(@platforms[0].x, 600)
    @player.jump(-13, 0)

    @highest_standable_platform = @platforms.last

    @background_color = 0xFF_82C4FF

    @bgm = Gosu::Song.new('sound/Insert-Quarter.mp3')
    @bgm.volume = 0.4
  end

  def enter
    @bgm.play(true)
  end

  def leave
    @bgm.stop
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
    if not @collectible.nil?
      @collectible.draw
    end
  end

  def update
    @platforms.each do |platform|
      if platform.type == :move
        platform.move_around
      elsif platform.type == :break
        platform.drop if platform.broken != nil
      end

      if @player.vy > 0 and not @player.is_dead
        if platform.hitbox.bottom > HeightLimit + 60
          if @player.collide_with_platform(platform)
            case platform.type
            when :boost
              platform.active
              @player.jump(-22)
              @player.roll
            when :break
              platform.break
            when :spike
              if platform.spike
                @player.damage
              end
              @platforms.each do |p|
                if p.type == :spike
                  p.change_state
                end
              end
              @player.jump
            else
              @player.jump
            end
          end
        end
      end
    end

    if not @collectible.nil?
      if @player.collide_with(@collectible)
        # do something
      end
    end

    if not @player.is_dead
      if Gosu.button_down?(Gosu::KB_A) or Gosu.button_down?(Gosu::KB_LEFT)
        @player.move_left if not @player.is_hurt
      elsif Gosu.button_down?(Gosu::KB_D) or Gosu.button_down?(Gosu::KB_RIGHT)
        @player.move_right if not @player.is_hurt
      else
        @player.slow_down
      end
    end

    @player.fall
    if @player.vy < 0 and @player.hitbox.top <= HeightLimit
      @platforms.each { |platform| platform.move_y(@player.vy + @player.hitbox.top - HeightLimit)}
      @platforms.reject! { |platform| platform.hitbox.bottom >= Window::HEIGHT}
      @player.set_top(HeightLimit)
      @player.move_x
      @player.score += 1
    else
      @player.move_y
      @player.move_x
    end

    if @platforms.last.hitbox.top > 5
      if @highest_standable_platform.hitbox.top > 80
        @platforms += generate_random_standable_platform(@highest_standable_platform.x, 70)
        @highest_standable_platform = @platforms.last
      elsif @highest_standable_platform.hitbox.top > 50
        if rand(100) < 50
          @platforms += generate_random_standable_platform(@highest_standable_platform.x, 120)
          @highest_standable_platform = @platforms.last
        elsif rand(100) < 30
          @platforms += generate_random_breakable_platform
        end
      elsif @highest_standable_platform.hitbox.top > 30
        if rand(100) < 30
          @platforms += generate_random_standable_platform(@highest_standable_platform.x, 180)
          @highest_standable_platform = @platforms.last
        elsif rand(100) < 30
          @platforms += generate_random_breakable_platform
        end
      elsif @highest_standable_platform.hitbox.top > 10
        if rand(100) < 10
          @platforms += generate_random_standable_platform(@highest_standable_platform.x, 200)
          @highest_standable_platform = @platforms.last
        elsif rand(100) < 10
          @platforms += generate_random_breakable_platform
        end
      end
    end
    
    if @collectible.nil? and @highest_standable_platform.hitbox.bottom < 0 and rand(10) == 0
      @collectible = generate_collectible(@highest_standable_platform.x, @highest_standable_platform.hitbox.top + 20)
      #@platforms += generate_random_standable_platform(@highest_standable_platform.x, 70)
      #@highest_standable_platform = @platforms.last
      puts "Collectible generated: #{@collectible}"
    end
    # if @collectibles.last.hitbox.top > 5
    #   if @collectibles.hitbox.top > 80
    #     @collectibles += generate_collectibles(@collectibles.x, 70)
    #     @collectibles = @collectibles.last
    #   elsif @collectibles.hitbox.top > 50
    #     if rand(100) < 50
    #       @platforms += generate_collectibles(@collectibles.x, 120)
    #       @collectibles = @collectibles.last
    #     end
    #   elsif @collectibles.hitbox.top > 30
    #     if rand(100) < 30
    #       @collectibles += generate_collectibles(@collectibles.x, 180)
    #       @collectibles = @collectibles.last
    #     end
    #   elsif @collectibles.hitbox.top > 10
    #     if rand(100) < 10
    #       @collectibles += generate_collectibles(@collectibles.x, 200)
    #       @collectibles = @collectibles.last
    #     end
    #   end
    # end
 
    if @player.hitbox.top >= Window::HEIGHT
      @window.switch(ReplayState.new(@window, @player.score, @player.x, @player.dir))
    end

    if Gosu.button_down?(Gosu::KB_A) and Gosu.button_down?(Gosu::KB_B)
      @god_mode = true
    end
  end
end