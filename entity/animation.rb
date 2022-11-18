require "gosu"

class Animation
  def initialize(animation, ani_duration = 100)
    @animation = animation
    @ani_index = 0
    @ani_time = $systime
    @ani_duration = ani_duration
  end

  def animate
    if $systime - @ani_time >= @ani_duration and @animation != []
      @ani_index += 1
      @ani_index %= @animation.length
      @ani_time = $systime
    end
  end

  def draw(x, y, z, dir = 1, angle = 0, cen_x = 0.5, cen_y = 0.5, scale_x = 1, scale_y = 1)
    @animation[@ani_index].draw_rot(x, y, z, angle, cen_x, cen_y, dir * scale_x, scale_y) if @animation != []
  end
end