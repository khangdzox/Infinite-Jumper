puts "i> Loading cassandra..."
require "cassandra" # COMMENT THIS FOR QUICK TESTING
require "./state/menu_state"
require "./entity/monster"
require "./entity/hitbox"
require "./entity/collectibles"

# COMMENT THIS FOR QUICK TESTING

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

# END OF COMMENT

$systime = 0

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
