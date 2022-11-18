require "gosu"

module Window
  WIDTH, HEIGHT = 400, 600
end

module ZOrder
  BACKGROUND, PLATFORMS, MONSTERS, PLAYER, COLLECTIBLES, UI, OVERLAY = *0..6
end

Gravity = 0.35
HeightLimit = 250
