# mustache-file

[mustache]: http://mustache.github.io/
[issues]: https://github.com/CliffS/mustache-file/issues

## Read mustache files and partials from disk.

This is simple wrapper around the standard [mustache][mustache]
templating package.

This module is designed to read its template files from disk, as well as
any partials referred to therein.  It is fully async and is either
passed a callback or it returns a promise.

[Mustache][mustache] is a logic-less template syntax. It can be used for HTML,
config files, source code - anything. It works by expanding tags in a template
using values provided in a hash or object.

For a language-agnostic overview of mustache's template syntax, see the
`mustache(5)` [manpage][mustache].

## Install

    npm install mustache-file

## Usage

    Mustache = require('mustache-file');

This returns a Mustache class that can be instantiated with `new`.

    must = new Mustache(options);

Create a new Mustache object.  Options is an object containing:

    extension:

The extension to add to the template names passed to `render()`.  If extension
is null, nothing will be added to the filename.  There is no need for
the leading `.` on the extension.  The default is `"mustache"`.

    path:

This is the path to look for the template and any partials.  It can either
be a string or an array of strings.  If it is an array, the paths will be
searched in order, both for the original template and for each partial.
Relative paths are surched from the current working directory.

If it is not passed, templates will be loaded from the current working
directory.

### Example:

    must = new Mustache({
        extension: 'html',
        path: [ 'templates/special', 'templates' ]
    });

To render the template either pass a callback or
(if no callback is passed) `render()` will return
a promise.

#### With a callback

    must.render(template, context, function(err, html) {
        if (err) throw err;
        // Send html to the browser, for example
    });

#### As a promise

    must.render(template, context)
    .then(function(html) {
        // Send html to the browser, for example
    })
    .catch(function(err) {
        throw err;
    });

This module should currently be treated as beta.  Any issues
or comments would be appreciated at [Github][issues].
