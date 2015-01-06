# This is what handles the actual databases and allows for the database types to
# be abstracted. So long as everything lines up alright, the program should work
# for any data type.

# Promise library of choice is bluebird. ALL DAY.
Promise = require 'bluebird'

# Database types.
postgres = require './postgres'

# Requires a SQL definition (postgres, mysql, mssql, etc) and a configuration
# object that can contain:
#   hostname
#   username
#   password
#   database
module.exports = (sql, config) ->
  # Default is postgres.
  sql = 'postgres' or sql

  # We need configurations!
  if !config? then throw new Error 'No configuration settings sent.'

  db = null

  if sql is 'postgres'   then db = postgres config
  else if sql is 'mysql' then db = mysql config
  else if sql is 'mssql' then db = mssql config
  else throw new Error 'That database is not supported.'

  db.then (d) ->
    db = d

    Promise.props(
      views: db.fetchAllViews()
      materializedViews: db.fetchAllMaterializedViews()
      tables: db.fetchAllTables()
    )
  .then(
    (data) ->
      db.releaseConnection()

      views    = data.views
      matViews = data.materializedViews
      tables   = data.tables

      viewObj    = {}
      matViewObj = {}

      graph = "graph LR;"
      res   = ""

      # For tables, we add their names to the graph as simple nodes. Some will
      # find themselves connected, some won't.
      if tables.length > 0
        for table in tables
          graph += " \n#{table};"

      # For views and materialized views, we need to parse and build the
      # needed relationships.
      if views.length > 0
        for view in views
          viewObj[view.name] = {}
          viewObj[view.name].pullsFrom = []
          viewObj[view.name].joins     = []
          viewObj[view.name].union     = false

          while (m = db.relationshipRegex.from.exec view.definition) isnt null
            if m.index is db.relationshipRegex.from.lastIndex
              db.relationshipRegex.from.lastIndex += 1

            viewObj[view.name].pullsFrom.push m[1]

            while (m = db.relationshipRegex.join.exec view.definition) isnt null
              if m.index is db.relationshipRegex.from.lastIndex
                db.relationshipRegex.from.lastIndex += 1

              viewObj[view.name].joins.push m[1]

            if view.definition.match(db.relationshipRegex.union)?
              viewObj[view.name].union = true

            for other in viewObj[view.name].pullsFrom
              graph += " \n#{other}-->#{view.name};"

            for other in viewObj[view.name].joins
              graph += " \n#{other}-->#{view.name};"

          res += """

          ## #{view.name}

          ```
          #{view.definition}
          ```

          """

      # Materialized views.
      if matViews.length > 0
        for view in matViews
          matViewObj[view.name] = {}
          matViewObj[view.name].pullsFrom = []
          matViewObj[view.name].joins     = []
          matViewObj[view.name].union     = false

          while (m = db.relationshipRegex.from.exec view.definition) isnt null
            if m.index is db.relationshipRegex.from.lastIndex
              db.relationshipRegex.from.lastIndex += 1

            matViewObj[view.name].pullsFrom.push m[1]

            while (m = db.relationshipRegex.join.exec view.definition) isnt null
              if m.index is db.relationshipRegex.from.lastIndex
                db.relationshipRegex.from.lastIndex += 1

              matViewObj[view.name].joins.push m[1]

            if view.definition.match(db.relationshipRegex.union)?
              matViewObj[view.name].union = true

            for other in matViewObj[view.name].pullsFrom
              graph += " \n#{other}-->#{view.name};"

            for other in matViewObj[view.name].joins
              graph += " \n#{other}-->#{view.name};"

          res += """

          ## #{view.name}

          ```
          #{view.definition}
          ```

          """

      new Promise (resolve, reject) ->
        resolve createHtml config, res, graph
  )

createHtml = (config, markdown, graph) ->
  html = """
  <!DOCTYPE html>
    <html>
      <head>
        <title>#{config.database} Structure</title>
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
        #{markdown}
      </xmp>

      <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/0.2.16/mermaid.full.min.js"></script>
      <script src="http://strapdownjs.com/v/0.2/strapdown.js"></script>
    </html>
  """
