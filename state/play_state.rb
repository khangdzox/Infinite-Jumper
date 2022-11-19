require "./modules"
require "./entity/player"
require "./entity/platform"
require "./entity/monster"
require "./entity/collectibles"
require "./state/game_state"
require "./state/replay_state"

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
    @collectible_time = nil

    @monster = nil

    # @pause = false
    # @button_pressed = false

    @background = Gosu::Image.new("img/background.png")
    @pause_background = Gosu::Image.new("img/pause_background.png")

    @bgm = Gosu::Song.new('sound/Insert-Quarter.mp3')
    @bgm.volume = 0.4

    @pause_pressed = false

    @sfx_star = Gosu::Sample.new('sound/star.mp3')
    @sfx_health = Gosu::Sample.new('sound/health_regained.mp3')
    puts "i> Game start"
  end

  def enter
    $time_offset = Gosu.milliseconds
    $systime = 0

    @bgm.play(true)
  end

  def leave
    @bgm.stop
  end

  def draw
    intro if @intro
    @pause_background.draw(0, 0, ZOrder::OVERLAY) if $pause
    @background.draw(0, 0)
    @player.draw
    @player.draw_score
    @player.draw_heart
    @platforms.each do |platform|
      platform.draw
    end
    if not @collectible.nil?
      if [:springshoe, :spikeshoe].include?(@collectible.type) and not @collectible.collected_time.nil?
        @collectible.draw(@player.dir == "left" ? 1 : -1)
      else
        @collectible.draw
      end
    end
    if not @monster.nil?
      @monster.draw
    end
  end

  def update

    if not $pause

      # Scroll

      if @player.vy < 0 and @player.hitbox.top <= HeightLimit
        @platforms.each { |platform| platform.move_y(@player.vy + @player.hitbox.top - HeightLimit)}
        @platforms.reject! { |platform| platform.hitbox.bottom >= Window::HEIGHT+10}
        @monster.move(@player.vy + @player.hitbox.top - HeightLimit) if not @monster.nil? and @monster.type == :scrolling_monster
        @collectible.move(@player.vy + @player.hitbox.top - HeightLimit) if not @collectible.nil? and @collectible.collected_time.nil?
        @player.set_top(HeightLimit)
        @player.move_x
        @player.score -= (@player.vy + @player.hitbox.top - HeightLimit)/10
      else
        @player.move_y
        @player.move_x
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

      # Fall

      @player.fall if @player.state != :propeller

      # Animation and Collision

      @platforms.each do |platform|
        if platform.type == :move
          platform.move_around
        elsif platform.type == :break
          platform.drop if platform.broken != nil
        end

        if @player.vy > 0 and not @player.is_dead
          @player.state = :normal if @player.state == :boost
          if platform.hitbox.top > HeightLimit
            if @player.collide_with_platform(platform)
              case platform.type
              when :boost
                platform.active
                @player.state = :boost if @player.state == :normal
                @player.jump(-25)
                @player.roll if @player.state == :normal
              when :break
                platform.break
              when :spike
                if platform.spike and not [:spike, :shield].include?(@player.state)
                  @player.damage
                end
                @platforms.each do |p|
                  if p.type == :spike
                    p.change_state
                  end
                end
                if @player.state == :spring
                  @player.jump(-18)
                  @collectible.animate_once
                else
                  @player.jump
                end
              else
                if @player.state == :spring
                  @player.jump(-18)
                  @collectible.animate_once
                else
                  @player.jump
                end
              end
            end
          end
        end
      end

      if not @collectible.nil?
        @collectible.animate
        if @collectible.hitbox.top > Window::HEIGHT
          @collectible = nil
        elsif @player.collide_with(@collectible) and @collectible.collected_time == nil
          case @collectible.type
          when :star
            puts ("i> Collect star")
          when :health_bottle
            puts ("i> Collect health bottle")
          when :propeller
            puts ("i> Collect propeller")
          when :springshoe
            puts ("i> Collect springshoe")
          when :spikeshoe
            puts ("i> Collect spikeshoe")
          when :shield
            puts ("i> Collect shield")
          end
          @collectible.activate(@player)
        end
        if not @collectible.nil? and not @collectible.collected_time.nil?
          if $systime - @collectible.collected_time < @collectible.duration
            @collectible.action(@player)
          else
            @collectible.remove
            @player.state = :normal
          end
        end
      end

      if not @monster.nil?
        @monster.animate
        if not @player.is_dead and not @player.is_hurt and @player.collide_with(@monster) # and @player.powerup.type != :propeller
          if @player.state == :normal or @player.state == :spring
            @player.damage
            @player.bounce_off(@player.x > @monster.x ? 1 : -1)
          elsif @player.hitbox.bottom <= @monster.hitbox.bottom and @player.vy > 0 and @player.state == :spike
            @monster.kill
            @player.jump(-13)
            @player.score += 50
          end
        end
        if @monster.hitbox.top > Window::HEIGHT+50 or (@monster.type == :floating_monster ? @monster.hitbox.bottom < -50 : false)
          @monster = nil
        end
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

      if @player.state != :propeller and @player.score > 300
        if @collectible.nil? and @highest_standable_platform.hitbox.bottom < 0 and rand(50) == 0
          @collectible, associated_platforms = generate_collectible(@highest_standable_platform.x, @highest_standable_platform.hitbox.top)
          @platforms += associated_platforms
          @highest_standable_platform = @platforms.last
          puts "i> Collectible generated: #{@collectible}"
        end

        if @monster.nil? and @highest_standable_platform.hitbox.bottom < 0 and rand(50) == 0
          case rand(5)
          when 0..3
            @monster, associated_platforms = generate_scrolling_monster(@highest_standable_platform.x, @highest_standable_platform.hitbox.top)
            @platforms += associated_platforms
            @highest_standable_platform = @platforms.last
          when 4
            @monster = generate_floating_monster()
          end
          puts "i> Monster generated: #{@monster}"
        end
      end

      if @player.hitbox.top >= Window::HEIGHT
        puts "i> Game ended"
        @window.switch(ReplayState.new(@window, @player.score.to_i, @player.x, @player.dir))
      end
    end

    if Gosu.button_down?(Gosu::KB_ESCAPE)
      if not @pause_pressed
        $pause = !$pause
        @pause_pressed = true
        if !$pause
          $time_offset = Gosu.milliseconds - $systime
        end
      end
    else
      @pause_pressed = false
    end
  end
end