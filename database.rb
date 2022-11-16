require "cassandra"

cluster = Cassandra.cluster(
  username: "NpbvnzkKWqbBazJFqClnFkSi",
  password: "FwY2Zb6BQlWgMq-IrCjOa6GRWO,KdOLD.,bCK0Wd_ZIPT3X42piH9I2LL6by5Kx3RZ7hjp+Zxi+9,ZZ+B+,KBBXHy+Sw_XB5sPt_BfBSjcMm6kk4o1htct_jwyFZTxDR",
  hosts: ["937149b8-f8b5-4495-8275-07c69cfd17e0-asia-south1.db.astra.datastax.com"],
  port: 29042,
  server_cert: "./etc/ssl/certs/astra-secure-connect/ca.crt",
  client_cert: "./etc/ssl/certs/astra-secure-connect/cert",
  private_key: "./etc/ssl/certs/astra-secure-connect/key"
)

$session  = cluster.connect('infjump') # create session, optionally scoped to a keyspace, to execute queries

future = $session.execute_async('SELECT id, name, score FROM scores WHERE id = c84b47e9-3bbb-490b-a19f-6b51d74da4b2') # fully asynchronous api
future.on_success do |rows|
  rows.each do |row|
    puts "ID: #{row["id"]}\nName: #{row["name"]}\nScore: #{row["score"]}"
  end
end
future.join