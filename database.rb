require "cassandra"

def init_session()
  cluster = Cassandra.cluster(
    username: "NpbvnzkKWqbBazJFqClnFkSi",
    password: "FwY2Zb6BQlWgMq-IrCjOa6GRWO,KdOLD.,bCK0Wd_ZIPT3X42piH9I2LL6by5Kx3RZ7hjp+Zxi+9,ZZ+B+,KBBXHy+Sw_XB5sPt_BfBSjcMm6kk4o1htct_jwyFZTxDR",
    hosts: ["937149b8-f8b5-4495-8275-07c69cfd17e0-asia-south1.db.astra.datastax.com"],
    port: 29042,
    server_cert: "./etc/ssl/certs/astra-secure-connect/ca.crt",
    client_cert: "./etc/ssl/certs/astra-secure-connect/cert",
    private_key: "./etc/ssl/certs/astra-secure-connect/key"
  )
  return cluster.connect('infjump') # create session, optionally scoped to a keyspace, to execute queries
end

def query(query)
  result = $session.execute(query)
  rows = []
  result.each { |r| rows << r }
  return rows
end

def query_async(query)
  return $session.execute_async(query)
end

def generate_random_data(session, number_of_data)
  (number_of_data < 100 ? number_of_data : 100).times do |i|
    session.execute("INSERT INTO scores (id, time, name, score) VALUES (uuid(), totimestamp(now()), 'player#{i < 10 ? "0#{i}" : i}', #{rand(500)}")
  end
end