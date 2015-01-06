pg = require 'pg'
Promise = require 'bluebird'
# Postgres

# Configuration:
#   hostname
#   username
#   password
#   database
module.exports = (config) ->
  returnObj = {
    # Relationship regex.
    relationshipRegex:
      from: /FROM \(?\(?([a-zA-Z0-9_\-]+)/gi
      join: /JOIN \(?\(?([a-zA-Z0-9_\-]+)/gi
      union: /UNION/gi

    # The closing function passed back by pgConnect.
    close: null
    client: null

    # This is required with every DB object type. This should release the
    # connection if such a step is needed.
    releaseConnection: () ->
      returnObj.close()

    # Fetches the names of all tables and returns them in an array.
    fetchAllTables: () ->
      new Promise (resolve, reject) ->
        returnObj.client.query """
          SELECT table_name
          FROM information_schema.tables
          WHERE table_type = 'BASE TABLE' AND table_schema = 'public'
        """, (err, results) ->
          if err? then reject err
          else
            rows = []

            for row in results.rows
              rows.push row.table_name

            resolve rows

    # Fetches all the views from the database, if there are any to fetch. If not
    # this function should return an empty array.
    #
    # If there are any views, we expect to see them listed as an array of
    # objects with the following properties:
    # - name
    # - definition
    fetchAllViews: () ->
      new Promise (resolve, reject) ->
        returnObj.client.query """
          SELECT table_name, view_definition
          FROM INFORMATION_SCHEMA.views
          WHERE table_schema = ANY (current_schemas(false))
        """, (err, result) ->
          if err? then reject err
          else
            rows = result.rows
            newRows = []

            for row in rows
              r = {}
              r.name       = row.table_name
              r.definition = row.view_definition

              newRows.push r

            resolve newRows

    # Fetches all the materialized views from the database, if there are any to
    # fetch. If not, this function should return an empty array.
    #
    # If there are any views, we expect to see them listed as an array of
    # objects with the following properties:
    # - name
    # - definition
    fetchAllMaterializedViews: () ->
      new Promise (resolve, reject) ->
        returnObj.client.query """
          SELECT definition, matviewname FROM pg_matviews
        """, (err, result) ->
          if err? then reject err
          else
            rows = result.rows
            newRows = []

            for row in rows
              r = {}
              r.name       = row.matviewname
              r.definition = row.definition

              newRows.push r

            resolve newRows
  }

  new Promise (resolve, reject) ->
    pg.connect config, (err, client, done) ->
      if err? then throw new Error 'Problem connecting to postgres.'

      returnObj.close  = done
      returnObj.client = client
      resolve returnObj
