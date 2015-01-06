mssql   = require 'mssql'
Promise = require 'bluebird'

# MSSql

# Configuration:
#   hostname
#   username
#   password
#   database
module.exports = (config) ->
  returnObj = {
    # Relationship regular expressions.
    relationshipRegex:
      from: /FROM[\s]{0,32}([a-zA-Z0-9_\-\.\[\]]+)/gi
      join: /JOIN ([a-zA-Z0-9_\-]+)/gi
      union: /UNION/gi

    client: null

    releaseConnection: () ->

    fetchAllTables: () ->
      new Promise (resolve, reject) ->
        request = new returnObj.client.Request()
        request.query """
          SELECT * FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_TYPE = 'BASE TABLE'
        """, (err, recordset) ->
          console.log err
          rows = []
          for record in recordset
            rows.push "dbo.#{record.TABLE_NAME}".toLowerCase()

          resolve rows

    fetchAllViews: () ->
      new Promise (resolve, reject) ->
        request = new returnObj.client.Request()
        request.query 'SELECT * FROM INFORMATION_SCHEMA.VIEWS',
          (err, recordset) ->
            rows = []
            for record in recordset
              row = {}
              row.name = "dbo.#{record.TABLE_NAME}".toLowerCase()
              row.definition = record.VIEW_DEFINITION

              rows.push row

            resolve rows

    fetchAllMaterializedViews: () ->
      new Promise (resolve, reject) ->
        resolve []
  }

  # Returns a promise that contains the interactive DB object.
  new Promise (resolve, reject) ->
    config = {
      user: config.user
      password: config.password
      server: config.host
      database: config.database
    }

    connection = mssql.connect config, (err) ->
      returnObj.client = mssql
      resolve returnObj
