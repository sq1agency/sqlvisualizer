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
  
  Promise.props(
    views: db.grabAllViews()
    materializedViews: db.grabAllMaterializedViews()
    tables: db.grabAllTables()
  ).then
