ast = require './ast'
recast = require 'recast'
b = recast.types.builders


class Context
  constructor: ->
    @vars = []


translateExpr = (context, expr) ->
  if expr instanceof ast.NumExpr
    return b.literal expr.value
  else if expr instanceof ast.AssignExpr
    context.vars.push expr.id
    id = b.identifier expr.id
    e = translateExpr context, expr.expr
    return b.assignmentExpression '=', id, e
  else
    throw 'Unknown expression: ' + expr


exports.translate = (ast) ->
  context = new Context
  expr = translateExpr context, ast
  stmts = []
  for id in context.vars
    declarator = b.variableDeclarator (b.identifier id), null
    stmts.push b.variableDeclaration 'var', [declarator]
  stmts.push (b.expressionStatement expr)
  result = b.program stmts
  recast.print(result).code
