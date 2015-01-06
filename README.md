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

## To Do
- [x] Make a pure command line nodejs module.
- [x] Allow for throwing configuration settings using the package command.
- [x] Add support for MSSQL.
- [ ] Add support for MySQL.
- [ ] Create a build process to release builds in Javascript.
