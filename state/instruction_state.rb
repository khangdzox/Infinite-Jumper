require "./state/game_state"

class InstructionState < GameState
  def initialize(window)
    super(window)
  end

  def enter

  end

  def leave
    
  end

  def draw
    intro if @intro
    outro if @outro
  end

  def update

  end
end