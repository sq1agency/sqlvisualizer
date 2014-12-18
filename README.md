Simple as pie! Will create an html document that will create a view structure
graph and a markdown-style set of query definitions for those views.

Current iteration requires Coffeescript.

Built using Mermaid and Strapdown.js.

**NOTE**: You'll need to change the config variable in index to use.

```
  npm install
  coffee index.coffee > FILE_OF_CHOICE.html
```

## Plans
  1. Make a pure command line nodejs module.
  2. Allow for throwing configuration settings using the package command.
  3. Add support for MSSQL and MySQL.
  4. Create a build process to release builds in Javascript.
