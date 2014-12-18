pg = require 'pg'

config =
  user: 'USER'
  password: 'PASSWORD'
  database: 'DATABASE'
  host: 'HOST'

# This is just a few regular expressions I use.
regex =
  from: /FROM \(?\(?([a-zA-Z0-9_\-]+)/gi
  join: /JOIN \(?\(?([a-zA-Z0-9_\-]+)/gi
  union: /UNION/gi

html = """
<!DOCTYPE html>
  <html>
    <head>
      <title>#{config.database} Views</title>
      <style>
      .mermaid {
        width: 1170px;
        overflow:hidden;
        overflow-x:scroll;
        margin-left:auto;
        margin-right: auto;
        border: 2px solid gray;
      }

      .mermaid .label {
        color: #000;
        text-shadow: none;
      }
      </style>
    </head>
"""

# Connects to postgres. I just use pg.
pg.connect config, (err, client, done) ->
  if err? then return console.error 'Problem connecting to postgres.', err

  client.query "SELECT definition, matviewname FROM pg_matviews", (err, result) ->
    done()

    if err then return console.error 'Error running query.', err

    res = ""

    views = {}

    graph = "graph LR;"

    for row in result.rows
      view       = row.matviewname
      definition = row.definition

      views[view] = {}
      views[view].pullsFrom = []
      views[view].joins     = []
      views[view].union     = false

      while (m = regex.from.exec definition) isnt null
        if m.index is regex.from.lastIndex
          regex.from.lastIndex += 1

        views[view].pullsFrom.push m[1]

      while (m = regex.join.exec definition) isnt null
        if m.index is regex.from.lastIndex
          regex.from.lastIndex += 1

        views[view].joins.push m[1]

      if definition.match(regex.union)? then views[view].union = true

      for other in views[view].pullsFrom
        graph += "\n#{other}-->#{view};"

      for other in views[view].joins
        graph += "\n#{other}-->#{view};"

      res += """

      ## #{view}

      ```
      #{definition}
      ```

      """

    html += """
      <div class="container">
        <h1>View Structure</h1>
      </div>
      <div class="mermaid">
        #{graph}
      </div>

      <div class="container">
      <h1>View Query Definitions</h1>
      </div>

      <xmp theme="united" style="display:none;">
        #{res}
      </xmp>

      <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/0.2.16/mermaid.full.min.js"></script>
      <script src="http://strapdownjs.com/v/0.2/strapdown.js"></script>
    </html>
    """

    console.log html
