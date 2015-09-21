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
    else if expr instanceof ast.BinExpr
      left = @translateExpr stmts, expr.left
      right = @translateExpr stmts, expr.right
      b.binaryExpression expr.kind, left, right
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
      @vars.push '$1'
      value = b.identifier '$1'
      label = b.identifier 'label'
      mstmts = []
      v = @translateExpr mstmts, expr.expr
      mstmts.push (b.expressionStatement (b.assignmentExpression '=', value, v))
      for mrule in expr.mrules
        bstmts = []
        e = @translateExpr bstmts, mrule.expr
        bstmts.push (b.expressionStatement (b.assignmentExpression '=', result, e))
        bstmts.push (b.breakStatement label)
        cond = @translatePat mstmts, value, mrule.pat
        if cond
          mstmts.push (b.ifStatement cond, b.blockStatement bstmts)
        else
          Array.prototype.push.apply mstmts, bstmts
          break
      stmts.push (b.labeledStatement label, b.blockStatement mstmts)
      result
    else if expr instanceof ast.FnExpr
      bstmts = []
      e = @translateExpr bstmts, expr.expr
      bstmts.push (b.returnStatement e)
      b.functionExpression null, [b.identifier expr.id], (b.blockStatement bstmts)
    else if expr instanceof ast.AppExpr
      id = b.identifier expr.id
      arg = @translateExpr stmts, expr.arg
      b.callExpression id, [arg]
    else if expr instanceof ast.PrintExpr
      e = @translateExpr stmts, expr.expr
      stmts.push (b.expressionStatement (b.callExpression (b.memberExpression (b.identifier 'console'), (b.identifier 'log')), [e]))
      e
    else
      throw 'Unknown expression: ' + expr

  translatePat: (stmts, id, pat) ->
    if pat instanceof ast.IdPat
      stmts.push (b.expressionStatement (b.assignmentExpression '=', (b.identifier pat.value), id))
      null
    else if pat instanceof ast.NumPat
      e = b.literal pat.value
      b.binaryExpression '===', id, e
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
