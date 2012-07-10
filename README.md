cf-prefix-checker
=================

Checks Coldfusion templates for unused and undeclared cfimport prefixes

Setup
-----

cf-prefix-checker runs in a web browser. You'll need to point your Coldfusion web server environment at cf-prefix-checker's
folder.

E.g. in your Apache host configuration file:

```
Alias /prefixchecker /path/to/cf-prefix-checker
```

Usage
-----

In your browser, enter the address of the host & path that you've configured cf-prefix-checker into.

e.g. http://localhost/prefixchecker/

Options are specified in url parameters.

* Format: one of 'dump' (uses cfdump), 'json', 'xml'
* FilePath: can be the path to a single file, or a folder. If it's a folder, the checker operates recursively. If FilePath is not specified, the test-template.cfm in this project is used

License
-------
cf-prefix-checker is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.html).