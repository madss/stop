# Expressions
class exports.NumExpr
  constructor: (@value) ->

class exports.AssignExpr
  constructor: (@id, @expr) ->

class exports.SeqExpr
  constructor: (@left, @right) ->
