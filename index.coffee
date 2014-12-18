pg = require 'pg'

config =
  user: 'USER'
  password: 'PASSWORD'
  database: 'DATABASE'
  host: 'HOST'

pg.connect config, (err, client, done) ->
  if err? then return console.error 'Problem connecting to postgres.', err

  client.query "SELECT definition, matviewname FROM pg_matviews", (err, result) ->
    done()

    if err then return console.error 'Error running query.', err

    res = ""

    for row in result.rows
      res += """

      ## #{row.matviewname}

      ```
      #{row.definition}
      ```

      """

    console.log res
