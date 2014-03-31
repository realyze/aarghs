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

  checkFun ?= (arg, i) ->
    if ~arg.indexOf('.')
      # We're searching in an object => use '?' (`null`s are invalid too).
      return i?
    else
      # A non-object, `null`s are valid, only check for `undefined`s.
      return not _.isUndefined(i)

  errorFun ?= (arg) ->
    throw new Error("invalid parameter: #{arg}")

  checkArg = (arg, origParams) ->
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

    val = origParams[index]
    # Treat `foo.bar.baz`-ish args specially (search for the value recursively).
    val = deep(val, arg) if _.isObject(val)

    if not checkFun arg, val
      return errorFun arg
  
  params = arguments
  _.each args, (arg) -> checkArg(arg, params)

  # Call the original fun.
  fun.apply @, arguments


exports.required = required
