pg = require 'pg'
# Postgres

# Configuration:
#   hostname
#   username
#   password
#   database
module.exports = (config) ->
  # This stores the close connection function to be used later.
  done = null

  promise = new Promise (resolve, reject) ->
    pg.connect config, (err, client, done) ->
      if err? then throw new Error 'Problem connecting to postgres.'



      client.query """
        SELECT definition, matviewname FROM pg_matviews
      """, (err, result) ->
        done()

  return {

  }
