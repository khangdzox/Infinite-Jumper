require 'gosu'

module Window
  WIDTH, HEIGHT = 400, 600
end

module ZOrder
  BACKGROUND, PLATFORMS, MONSTERS, COLLECTIBLES, PLAYER, UI, OVERLAY = *0..6
end

Gravity = 0.4
HeightLimit = 250
