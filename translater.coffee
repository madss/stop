ast = require './ast'
recast = require 'recast'
b = recast.types.builders


class Block
  constructor: ->
    @vars = []
    @exprs = []


translateExpr = (block, expr) ->
  if expr instanceof ast.NumExpr
    return b.literal expr.value
  else if expr instanceof ast.AssignExpr
    block.vars.push expr.id
    id = b.identifier expr.id
    e = translateExpr block, expr.expr
    return b.assignmentExpression '=', id, e
  else if expr instanceof ast.SeqExpr
    block.exprs.push translateExpr block, expr.left
    translateExpr block, expr.right
  else
    throw 'Unknown expression: ' + expr


exports.translate = (ast) ->
  block = new Block
  expr = translateExpr block, ast
  stmts = []
  for id in block.vars
    declarator = b.variableDeclarator (b.identifier id), null
    stmts.push b.variableDeclaration 'var', [declarator]
  for e in block.exprs
    stmts.push (b.expressionStatement e)
  stmts.push (b.expressionStatement expr)
  result = b.program stmts
  recast.print(result).code
