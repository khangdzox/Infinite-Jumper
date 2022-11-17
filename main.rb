puts "i> Loading cassandra..."
require "cassandra"
require "./state/menu_state"
require "./entity/monster"
require "./entity/hitbox"
require "./entity/collectibles"

puts "i> Connect to database..."
cluster = Cassandra.cluster(
  username: "NpbvnzkKWqbBazJFqClnFkSi",
  password: "FwY2Zb6BQlWgMq-IrCjOa6GRWO,KdOLD.,bCK0Wd_ZIPT3X42piH9I2LL6by5Kx3RZ7hjp+Zxi+9,ZZ+B+,KBBXHy+Sw_XB5sPt_BfBSjcMm6kk4o1htct_jwyFZTxDR",
  hosts: ["937149b8-f8b5-4495-8275-07c69cfd17e0-asia-south1.db.astra.datastax.com"],
  port: 29042,
  server_cert: "./etc/ssl/certs/astra-secure-connect/ca.crt",
  client_cert: "./etc/ssl/certs/astra-secure-connect/cert",
  private_key: "./etc/ssl/certs/astra-secure-connect/key",
  consistency: :local_quorum
)
$session = cluster.connect("infjump")

puts "i> Finding information file..."
if not File.exist?("info")
  puts "e> Information file doesn't exist. Create new file..."
  uuid = Cassandra::Uuid::Generator.new.uuid
  File.write("info", uuid)
  puts ("c> INSERT INTO names (id, names) VALUES (#{uuid}, 'player')")
  future = $session.execute_async("INSERT INTO names (id, names) VALUES (#{uuid}, 'player')")
  future.on_success { puts ("i> Success!") }
  future.on_failure { |e| puts ("e> #{e}") }
else
  puts "i> Information file found! Verifying information..."
  uuid = File.open("info", "r") { |f| f.read}
  future = $session.execute_async("SELECT id FROM names WHERE id = #{uuid}")
  future.on_success do |rows|
    if not rows.empty?
      puts "i> ID verified!"
    else
      puts "e> ID is invalid! Update information..."
      puts ("c> INSERT INTO names (id, names) VALUES (#{uuid}, 'player')")
      future = $session.execute_async("INSERT INTO names (id, names) VALUES (#{uuid}, 'player')")
      future.on_success { puts ("i> Success!") }
      future.on_failure { |e| puts ("e> #{e}") }
    end
  end
  future.on_failure { |e| puts ("e> #{e}") }
end

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
    @pause = false
    @button_pressed = false
    @time_offset = 0
    @time_now = Gosu.milliseconds
    # @star = Star.new(200, 100)
    # @health_bottle = HealthBottle.new(250, 100)
    # @propeller = Propeller.new(50, 100)
    # @springshoe = Springshoe.new(100, 100)
    # @spikeshoe = Spikeshoe.new(300, 100)
    # @shield = Shield.new(200, 100)
  end

  def draw
    # @demo.draw
    # @star.draw
    # @health_bottle.draw
    # @propeller.draw
    # @springshoe.draw
    # @spikeshoe.draw
    # @shield.draw
    @state.draw
  end

  def update
    # @star.animate
    # @star.animate
    # @propeller.animate
    # @springshoe.animate
    if not @pause
      # @demo.animatea
      @state.update
      @time_now = Gosu.milliseconds - @time_offset
    end
    # if Gosu.button_down?(Gosu::KB_ESCAPE)
    #   if not @button_pressed
    #     @pause = !@pause
    #     @button_pressed = true
    #     if !@pause
    #       @time_offset = Gosu.milliseconds - @time_now
    #     end
    #   end
    # else
    #   @button_pressed = false
    # end
    # puts @time_now/1000
  end

  def switch(new_state)
    @state && @state.leave
    @state = new_state
    new_state.enter
  end
end
 
window = MainWindow.new
window.switch(MenuState.new(window))
window.show
