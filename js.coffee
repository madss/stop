ast = require './ast'
recast = require 'recast'
b = recast.types.builders


class Scope

  constructor: ->
    @vars = []

  translateExpr: (stmts, expr) ->
    if expr instanceof ast.IdExpr
      b.identifier expr.value
    else if expr instanceof ast.NumExpr
      b.literal expr.value
    else if expr instanceof ast.AssignExpr
      # FIXME: Only push var if it is undeclared
      @vars.push expr.id
      id = b.identifier expr.id
      e = @translateExpr stmts, expr.expr
      b.assignmentExpression '=', id, e
    else if expr instanceof ast.SeqExpr
      e = @translateExpr stmts, expr.left
      stmts.push b.expressionStatement e
      @translateExpr stmts, expr.right
    else if expr instanceof ast.MatchExpr
      @vars.push '$$'
      result = b.identifier '$$'
      label = b.identifier 'label'
      mstmts = []
      for mrule in expr.mrules
        left = @translateExpr mstmts, expr.expr
        right = @translatePat mstmts, mrule.pat
        cond = b.binaryExpression '===', left, right
        bstmts = []
        e = @translateExpr bstmts, mrule.expr
        bstmts.push (b.expressionStatement (b.assignmentExpression '=', result, e))
        bstmts.push (b.breakStatement label)
        mstmts.push (b.ifStatement cond, b.blockStatement bstmts)
      stmts.push (b.labeledStatement label, b.blockStatement mstmts)
      result
    else
      throw 'Unknown expression: ' + expr

  translatePat: (stmts, pat) ->
    if pat instanceof ast.NumPat
      b.literal pat.value
    else
      throw 'Unknown pattern: ' + pat


exports.translate = (ast) ->
  scope = new Scope
  stmts = []
  expr = scope.translateExpr stmts, ast
  for id in scope.vars
    declarator = b.variableDeclarator (b.identifier id), null
    stmts.unshift b.variableDeclaration 'var', [declarator]
  stmts.push (b.expressionStatement expr)
  result = b.program stmts
  recast.print(result).code
