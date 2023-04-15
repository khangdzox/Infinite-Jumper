# Infinite Jumper
This is a clone of the famous game 'Doodle Jump', written on Ruby using Gosu.

# Database Structure
This project uses AstraDB, a free Cassandra serverless database service. We use Ruby legacy driver to connect to the database. See [AstraDB documentation](https://docs.datastax.com/en/astra-serverless/docs/connect/drivers/legacy-drivers.html#_ruby_legacy_drivers).
- Keyspace: `infjump`
- Tables:
```
CREATE TABLE scores (  
    id UUID PRIMARY KEY,  
    time TIMESTAMP,  
    score INT  
);  
```
```
CREATE TABLE names (
    id UUID PRIMARY KEY,  
    name TEXT  
);  
```