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
  info = {"id"=>uuid, "name"=>"player", "score"=>0}
  File.write("info", JSON.generate(info))
  future = $session.execute_async("INSERT INTO scores (id, name, score) VALUES (#{info["id"]}, 'player', 0)")
  puts ("c> INSERT INTO scores (id, name, score) VALUES (#{info["id"]}, 'player', 0)")
  future.on_success do
    puts ("i> Success!")
  end
  future.on_failure do |e|
    puts ("e> #{e}")
  end
else
  puts "i> Information file found! Verifying information..."
  info = JSON.load_file("info")
  future = $session.execute_async("SELECT * FROM scores WHERE id = #{info["id"]}")
  future.on_success do |rows|
    if not rows.empty?
      puts "i> ID found in database!"
      rows.each do |row|
        if not (row["name"] == info["name"] and row["score"] == info["score"])
          puts "e> Name and Score is invalid! Update information..."
          future = $session.execute_async("UPDATE scores SET name = '#{info["name"]}', score = #{info["score"]} WHERE id = #{info["id"]}")
          puts ("c> UPDATE scores SET name = '#{info["name"]}', score = #{info["score"]} WHERE id = #{info["id"]}")
          future.on_success do
            puts ("i> Success!")
          end
          future.on_failure do |e|
            puts ("e> #{e}")
          end
        else
          puts "i> Name and Score verified!"
        end
      end
    else
      puts "e> ID not found! Update information..."
      future = $session.execute_async("INSERT INTO scores (id, name, score) VALUES (#{info["id"]}, '#{info["name"]}', #{info["score"]})")
      puts ("c> INSERT INTO scores (id, name, score) VALUES (#{info["id"]}, '#{info["name"]}', #{info["score"]})")
      future.on_success do
        puts ("i> Success!")
      end
      future.on_failure do |e|
        puts ("e> #{e}")
      end
    end
  end
end

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
    # @demo = Monster.new(200, 100, :flying, Hitbox.new_xywh(200, 100, 25, 25), Gosu::Image.load_tiles("img/flying_monster.png", 80, 63))
    # @demo = FlyingDownMonster.new(200, -30)
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
