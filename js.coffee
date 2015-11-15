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

  translateBlock: (expr) ->
    vars = []
    stmts = []
    expr = @translateExpr vars, stmts, expr
    for id in vars
      declarator = b.variableDeclarator (b.identifier id), null
      stmts.unshift b.variableDeclaration 'var', [declarator]
    stmts.push (b.expressionStatement expr)
    stmts

  translateExpr: (vars, stmts, expr) ->
    if expr instanceof ast.IdExpr
      b.identifier expr.value
    else if expr instanceof ast.NumExpr
      b.literal expr.value
    else if expr instanceof ast.StrExpr
      b.literal expr.value
    else if expr instanceof ast.ListExpr
      b.arrayExpression ((@translateExpr vars, stmts, e) for e in expr.values)
    else if expr instanceof ast.BinExpr
      left = @translateExpr vars, stmts, expr.left
      right = @translateExpr vars, stmts, expr.right
      b.binaryExpression expr.kind, left, right
    else if expr instanceof ast.MemberExpr
      e = @translateExpr vars, stmts, expr.expr
      b.memberExpression e, (idExpr expr.id)
    else if expr instanceof ast.AssignExpr
      # FIXME: Only push var if it is undeclared
      if expr.lval instanceof ast.IdExpr
        vars.push expr.lval.value
      lval = @translateExpr vars, stmts, expr.lval
      e = @translateExpr vars, stmts, expr.expr
      b.assignmentExpression '=', lval, e
    else if expr instanceof ast.SeqExpr
      e = @translateExpr vars, stmts, expr.left
      stmts.push b.expressionStatement e
      @translateExpr vars, stmts, expr.right
    else if expr instanceof ast.MatchExpr
      resultName = @createVar()
      vars.push resultName
      result = b.identifier resultName
      valueName = @createVar()
      vars.push valueName
      value = b.identifier valueName
      label = b.identifier @createLabel()
      mstmts = []
      v = @translateExpr vars, mstmts, expr.expr
      mstmts.push (b.expressionStatement (b.assignmentExpression '=', value, v))
      for mrule in expr.mrules
        bstmts = @translatePat vars, mstmts, value, mrule.pat
        e = @translateExpr vars, bstmts, mrule.expr
        bstmts.push (b.expressionStatement (b.assignmentExpression '=', result, e))
        bstmts.push (b.breakStatement label)
      stmts.push (b.labeledStatement label, b.blockStatement mstmts)
      result
    else if expr instanceof ast.FnExpr
      bstmts = @translateBlock expr.expr
      stmt = bstmts.pop()
      bstmts.push (b.returnStatement stmt.expression)
      b.functionExpression null, ((b.identifier id) for id in expr.ids), (b.blockStatement bstmts)
    else if expr instanceof ast.AppExpr
      f = @translateExpr vars, stmts, expr.expr
      args = ((@translateExpr vars, stmts, arg) for arg in expr.args)
      b.callExpression f, args
    else if expr instanceof ast.TypeExpr
      ids = (b.identifier id for id in expr.fields)
      assignments = (b.expressionStatement (b.assignmentExpression '=', \
        (b.memberExpression b.thisExpression(), id), id) \
        for id in ids)
      cond = b.binaryExpression 'instanceof', b.thisExpression(), (b.identifier 'type')
      b.functionExpression (b.identifier 'type'), ids, (b.blockStatement [
        b.ifStatement cond, \
        (b.blockStatement assignments), \
        (b.blockStatement [b.returnStatement (b.newExpression (b.identifier 'type'), ids)])])
    else
      throw 'Unknown expression: ' + expr

  translatePat: (vars, stmts, expr, pat) ->
    if pat instanceof ast.IdPat
      vars.push pat.value
      stmts.push (assignStmt (idExpr pat.value), expr)
      stmts
    else if pat instanceof ast.NumPat
      bstmts = []
      cond = eqExpr expr, (litExpr pat.value)
      stmts.push (b.ifStatement cond, (b.blockStatement bstmts))
      bstmts
    else if pat instanceof ast.StrPat
      m bstmts = []
      cond = eqExpr expr, (litExpr pat.value)
      stmts.push (b.ifStatement cond, (b.blockStatement bstmts))
      bstmts
    else if pat instanceof ast.TypePat
      bstmts = []
      cond = b.binaryExpression 'instanceof', expr, (idExpr pat.id)
      stmts.push (b.ifStatement cond, b.blockStatement bstmts)
      for field in pat.fields
        bstmts = @translatePat vars, bstmts, (b.memberExpression expr, (idExpr field.key)), field.pat
      bstmts
    else
      throw 'Unknown pattern: ' + pat


exports.translate = (ast) ->
  scope = new Scope
  result = b.program (scope.translateBlock ast)
  recast.print(result).code
