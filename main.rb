puts "i> Loading cassandra..."
require "cassandra" # COMMENT THIS FOR QUICK TESTING
require "./state/menu_state"
require "./entity/monster"
require "./entity/hitbox"
require "./entity/collectibles"

# COMMENT THIS FOR QUICK TESTING

puts "i> Connect to database..."
cluster = Cassandra.cluster(
  username: "OQDTNndCGEjhTHDZpvXgnIkF",
  password: "Avh0MZwOJYppJ.yB4MhS-,Nt+y8,AcLvNz+nB609TXn.Z9X_Z8LazxZDkptZiZxGwcvpQQ-Yma9-OQo0ocm3Qp8UhgMQZ_PLsteiXccuL8ZD9uQoFG5HDNfWOZnJQ-ei",
  hosts: ["7da26e1a-51b6-4e58-9bd7-69224ad06723-asia-south1.db.astra.datastax.com"],
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
  puts ("c> INSERT INTO names (id, name) VALUES (#{uuid}, 'player')")
  future = $session.execute_async("INSERT INTO names (id, name) VALUES (#{uuid}, 'player')")
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
      puts ("c> INSERT INTO names (id, name) VALUES (#{uuid}, 'player')")
      future = $session.execute_async("INSERT INTO names (id, name) VALUES (#{uuid}, 'player')")
      future.on_success { puts ("i> Success!") }
      future.on_failure { |e| puts ("e> #{e}") }
    end
  end
  future.on_failure { |e| puts ("e> #{e}") }
end

# END OF COMMENT

$systime = 0
$time_offset = Gosu.milliseconds
$pause = false

class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
  end

  def draw
    @state.draw
  end

  def update
    @state.update
    $systime = Gosu.milliseconds - $time_offset if not $pause
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
