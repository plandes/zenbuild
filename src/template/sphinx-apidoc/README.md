# Modified Sphinx Template Files

These files are copied from the Sphinx [source] template files with
`package.rst_t` modified to include inheritance graphs using:

```rst
.. inheritance-diagram:: {{submodule}}
   :parts: 1
```

which is inserted right after:

```rst
*{{- [submodule, "module"] | join(" ") | e | heading(2) }}*
```

[source]: ~/opt/lib/python/lib/python3.9/site-packages/sphinx/templates/apidoc
