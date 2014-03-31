_ = require 'underscore'

# Returns deep property of `obj` specified by `path`.
# Example:
#     > deep a: b: 'c', 'a.b'
#     > 'b'
# We expect that `obj` fields do not contain dots.
# Pass '.' as the path to get the whole object.
#     > deep a: b: 'c', '.'
#     > {a: {b: 'c'}}
deep = (obj, path) ->
  return obj if path is '.'
  _.reduce path.split('.'), ((memo, part) -> memo[part]), obj


required = (args, checkFun, errorFun) -> (fun) -> ->
  if not _.isArray(args)
    args = [args]

  _.each args, (arg) ->
    checkFun ?= (i) ->
      if ~arg.indexOf('.')
        # We're searching in an object => use '?' (`null`s are invalid too).
        return i?
      else
        # A non-object, `null`s are valid, only check for `undefined`s.
        return not _.isUndefined(i)

    errorFun ?= (arg) -> throw new Error("invalid parameter: #{arg}")

    # Parse the function signature to get params.
    params = fun.toString()
      .split('\n')[0]
      .replace(/[^\(]+\(([^{]+)\).*/, '$1')
      .replace(' ', '')
      .split(',')
    toMatch = arg.split('.')[0]

    # Is `arg` in the params?
    index = params.indexOf(toMatch)
    if not ~index
      return errorFun arg

    val = arguments[index]
    # Treat `foo.bar.baz`-ish args specially (search for the value recursively).
    val = deep(val, arg) if _.isObject(val)

    if not checkFun val
      return errorFun arg

  # Call the original fun.
  fun.apply @, arguments


exports.required = required

# example
# =======
# bar = required('arg3', null, ((i) -> console.log 'aargh', i)) (arg1, arg2) ->
#   console.log('arg1', arg1, 'arg2', arg2)
#
# bar({arg1: foo: 42}, null)
