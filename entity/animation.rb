require "gosu"

class Animation
  def initialize(animation, ani_duration = 100)
    @animation = animation
    @ani_index = 0
    @ani_time = Gosu.milliseconds
    @ani_duration = ani_duration
  end

  def animate
    if Gosu.milliseconds - @ani_time >= @ani_duration
      @ani_index += 1
      @ani_index %= @animation.length
      @ani_time = Gosu.milliseconds
    end
  end

  def draw(x, y, z, dir = 1)
    @animation[@ani_index].draw_rot(x, y, z, 0, 0.5, 0.5, dir)
  end
end