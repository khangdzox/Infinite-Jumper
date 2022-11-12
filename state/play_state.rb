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

    @player = Player.new(@platforms[0].x, 600)
    @player.jump(-13, 0)

    @highest_standable_platform = @platforms.last

    @collectible = nil

    @monster = nil

    # @pause = false
    # @button_pressed = false

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
    if not @monster.nil?
      @monster.draw
    end
  end

  def update

    # Animation and Collision

    if not @pause
      @platforms.each do |platform|
        if platform.type == :move
          platform.move_around
        elsif platform.type == :break
          platform.drop if platform.broken != nil
        end

        if @player.vy > 0 and not @player.is_dead
          if platform.hitbox.top > HeightLimit
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

      if not @monster.nil?
        @monster.animate
        if not @player.is_dead and not @player.is_hurt and @player.collide_with(@monster) # and @player.powerup.type != :propeller
          @player.damage
          @player.bounce_off(@player.x > @monster.x ? 1 : -1)
        end
        if @monster.hitbox.top > Window::HEIGHT+50 or (@monster.type == :floating_monster ? @monster.hitbox.bottom < -50 : false)
          @monster = nil
        end
      end

      # Player movement

      if not @player.is_dead
        if Gosu.button_down?(Gosu::KB_A) or Gosu.button_down?(Gosu::KB_LEFT)
          @player.move_left if not @player.is_hurt
        elsif Gosu.button_down?(Gosu::KB_D) or Gosu.button_down?(Gosu::KB_RIGHT)
          @player.move_right if not @player.is_hurt
        else
          @player.slow_down
        end
      end

      # Scroll

      @player.fall
      if @player.vy < 0 and @player.hitbox.top <= HeightLimit
        @platforms.each { |platform| platform.move_y(@player.vy + @player.hitbox.top - HeightLimit)}
        @platforms.reject! { |platform| platform.hitbox.bottom >= Window::HEIGHT+15}
        @monster.move(@player.vy + @player.hitbox.top - HeightLimit) if not @monster.nil? and @monster.type == :scrolling_monster
        @player.set_top(HeightLimit)
        @player.move_x
        @player.score -= (@player.vy + @player.hitbox.top - HeightLimit)/10
      else
        @player.move_y
        @player.move_x
      end

      ##
      # @TODO: Warm-up don't spawn spike, boost, collectibles and monsters

      # Generate

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
        @collectible = generate_collectible(@highest_standable_platform.x, @highest_standable_platform.hitbox.top - 20)
        @platforms << StaticPlatform.new(30 + (@highest_standable_platform.x + rand(100*2+1) - 100) %340, @highest_standable_platform.hitbox.top - 70)
        @highest_standable_platform = @platforms.last
        puts "Collectible generated: #{@collectible}"
      end

      if @monster.nil? and rand(500) == 0
        case rand(2)
        when 0
          @monster, associated_platforms = generate_scrolling_monster(@highest_standable_platform.x, @highest_standable_platform.hitbox.top)
          @platforms += associated_platforms
          @highest_standable_platform = @platforms.last
        when 1
          @monster = generate_floating_monster()
        end
        puts "Monster generated: #{@monster}"
      end

      if @player.hitbox.top >= Window::HEIGHT
        @window.switch(ReplayState.new(@window, @player.score.to_i, @player.x, @player.dir))
      end
    end

    # if Gosu.button_down?(Gosu::KB_ESCAPE)
    #   if not @button_pressed
    #     @pause = !@pause
    #     @button_pressed = true
    #   end
    # else
    #   @button_pressed = false
    # end
  end
end