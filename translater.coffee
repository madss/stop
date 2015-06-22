ast = require './ast'
recast = require 'recast'
b = recast.types.builders


translateExpr = (expr) ->
  if expr instanceof ast.NumExpr
    return b.literal expr.value
  else
    throw 'Unknown expression: ' + expr


exports.translate = (ast) ->
  expr = translateExpr ast
  stmt = b.expressionStatement expr
  result = b.program [stmt]
  recast.print(result).code
