aarghs
=====

Coffee-script decorator to checks whether your params are defined (or whatever you heart desires).


### Example

```coffeescript
aarghs = require './index'

required = (args) ->
  aarghs.required(args, null,
    ((arg) -> throw new Error("argument #{arg} undefined!") ))

# passing example
# ===============

foo = required(['arg1.foo', 'arg2']) (arg1, arg2) ->
  console.log "Hello world!"
  
bar({arg1: foo: 42}, null)


# throwing example
# ================

bar = required(['arg1.foo', 'borg']) (arg1, arg2) ->
  console.log("I won't get here - `borg!` is undefined.")

bar({arg1: foo: 42}, null) # Raises an exception.
```
