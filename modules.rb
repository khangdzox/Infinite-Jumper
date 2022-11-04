require 'gosu'

module Window
  WIDTH, HEIGHT = 400, 600
end

module ZOrder
  BACKGROUND, PLATFORMS, PLAYER, UI, OVERLAY = *0..4
end

module States
  FALL, JUMP = 5, 6
end

module Types
  STATIC, MOVE, BREAK, BOOST = *7..10
end

Gravity = 0.4
HeightLimit = 250
