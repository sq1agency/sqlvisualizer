Simple as pie! Will create an html document that will create a view structure
graph and a markdown-style set of query definitions for those views.

Built using Mermaid and Strapdown.js.

```
  npm install -g
```

## Usage
```
  sqlvisualizer -f file.html -h host.local -u user -p password -d database
```

## Command Line Options
**-f, --file <file>** - The location of the file in which the HTML is stored.

**-h, --host <host>** - Database host location

**-d, --database <database>** - Database name

**-u, --user <user>** - Database user name

**-p, --password <password>** - Database password

## Plans
  [X] Make a pure command line nodejs module.
  [X] Allow for throwing configuration settings using the package command.
  [] Add support for MSSQL and MySQL.
  [] Create a build process to release builds in Javascript.
