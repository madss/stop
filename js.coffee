ast = require './ast'
recast = require 'recast'
b = recast.types.builders


idExpr = (name) -> b.identifier name
litExpr = (value) -> b.literal value
eqExpr = (left, right) -> b.binaryExpression '===', left, right
assignExpr = (lval, expr) -> b.assignmentExpression '=', lval, expr
assignStmt = (lval, expr) -> b.expressionStatement (assignExpr lval, expr)


class Scope

  constructor: ->
    @vars = []
    @nextVar = 0;
    @nextLabel = 0;

  createVar: ->
    name = '$' + @nextVar
    @nextVar++
    name

  createLabel: ->
    name = 'label' + @nextLabel
    @nextLabel++
    name

  translateExpr: (stmts, expr) ->
    if expr instanceof ast.IdExpr
      b.identifier expr.value
    else if expr instanceof ast.NumExpr
      b.literal expr.value
    else if expr instanceof ast.StrExpr
      b.literal expr.value
    else if expr instanceof ast.BinExpr
      left = @translateExpr stmts, expr.left
      right = @translateExpr stmts, expr.right
      b.binaryExpression expr.kind, left, right
    else if expr instanceof ast.MemberExpr
      e = @translateExpr stmts, expr.expr
      b.memberExpression e, (idExpr expr.id)
    else if expr instanceof ast.AssignExpr
      # FIXME: Only push var if it is undeclared
      if expr.lval instanceof ast.IdExpr
        @vars.push expr.lval.value
      lval = @translateExpr stmts, expr.lval
      e = @translateExpr stmts, expr.expr
      b.assignmentExpression '=', lval, e
    else if expr instanceof ast.SeqExpr
      e = @translateExpr stmts, expr.left
      stmts.push b.expressionStatement e
      @translateExpr stmts, expr.right
    else if expr instanceof ast.MatchExpr
      resultName = @createVar()
      @vars.push resultName
      result = b.identifier resultName
      valueName = @createVar()
      @vars.push valueName
      value = b.identifier valueName
      label = b.identifier @createLabel()
      mstmts = []
      v = @translateExpr mstmts, expr.expr
      mstmts.push (b.expressionStatement (b.assignmentExpression '=', value, v))
      for mrule in expr.mrules
        bstmts = @translatePat mstmts, value, mrule.pat
        e = @translateExpr bstmts, mrule.expr
        bstmts.push (b.expressionStatement (b.assignmentExpression '=', result, e))
        bstmts.push (b.breakStatement label)
      stmts.push (b.labeledStatement label, b.blockStatement mstmts)
      result
    else if expr instanceof ast.FnExpr
      bstmts = []
      e = @translateExpr bstmts, expr.expr
      bstmts.push (b.returnStatement e)
      b.functionExpression null, [b.identifier expr.id], (b.blockStatement bstmts)
    else if expr instanceof ast.AppExpr
      f = @translateExpr stmts, expr.expr
      args = ((@translateExpr stmts, arg) for arg in expr.args)
      b.callExpression f, args
    else if expr instanceof ast.TypeExpr
      ids = (b.identifier id for id in expr.fields)
      assignments = (b.expressionStatement (b.assignmentExpression '=', \
        (b.memberExpression b.thisExpression(), id), id) \
        for id in ids)
      b.functionExpression null, ids, (b.blockStatement assignments)
    else
      throw 'Unknown expression: ' + expr

  translatePat: (stmts, expr, pat) ->
    if pat instanceof ast.IdPat
      stmts.push (assignStmt (idExpr pat.value), expr)
      stmts
    else if pat instanceof ast.NumPat
      bstmts = []
      cond = eqExpr expr, (litExpr pat.value)
      stmts.push (b.ifStatement cond, (b.blockStatement bstmts))
      bstmts
    else if pat instanceof ast.StrPat
      bstmts = []
      cond = eqExpr expr, (litExpr pat.value)
      stmts.push (b.ifStatement cond, (b.blockStatement bstmts))
      bstmts
    else if pat instanceof ast.TypePat
      bstmts = []
      cond = b.binaryExpression 'instanceof', expr, (idExpr pat.id)
      stmts.push (b.ifStatement cond, b.blockStatement bstmts)
      for field in pat.fields
        bstmts = @translatePat bstmts, (b.memberExpression expr, (idExpr field.key)), field.pat
      bstmts
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
