main = require './src/main'
path = require 'path'
fs   = require 'fs'

pkg = require path.join(__dirname, 'package.json')
# Setting up the command line argument functionality.
program = require 'commander'
program
  .version pkg.version
  .usage '[options]'
  .option '-f, --file <file>', 'Path to store the html document'
  .option '-h, --host <host>', 'Database host location'
  .option '-d, --database <database>', 'Database name'
  .option '-u, --user <user>', 'Database user name'
  .option '-p, --password <password>', 'Database password'
  .option '-s, --sql [value]', 'The database\'s SQL type.'
  .parse process.argv

config =
  user: program.user
  password: program.password
  database: program.database
  host: program.host

main(program.sql, config).then(
  (html) ->
    fs.writeFile program.file, html, (err) ->
      if err? then console.log err
      else console.log "SQL DB visualized!"
)
