_ = require 'underscore'

deep = (obj, path) ->
  return obj if path is '.'
  _.reduce path.split('.'), ((memo, part) -> memo[part]), obj


required = (arg, checkFun, errorFun) -> (fun) -> ->
  checkFun ?= (i) ->
    if ~arg.indexOf('.')
      return i?
    else
      return not _.isUndefined(i)

  errorFun ?= (arg) -> throw new Error("invalid parameter: #{arg}")

  params = fun.toString()
    .split('\n')[0]
    .replace(/[^\(]+\(([^{]+)\).*/, '$1')
    .replace(' ', '')
    .split(',')
  toMatch = arg.split('.')[0]

  index = params.indexOf(toMatch)
  if not ~index
    return errorFun arg

  val = arguments[index]
  val = deep(val, arg) if _.isObject(val)

  if not checkFun val
    return errorFun arg

  fun.apply @, arguments


bar = required('arg3', null, ((i) -> console.log 'aargh', i)) (arg1, arg2) ->
  console.log('arg1', arg1, 'arg2', arg2)

bar({arg1: foo: 42}, null)
console.log 'done'
