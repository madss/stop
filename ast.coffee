# Expressions
class exports.IdExpr
  constructor: (@value) ->
  toString: -> 'IdExpr(' + @value + ')'

class exports.NumExpr
  constructor: (@value) ->
  toString: -> 'NumExpr(' + @value + ')'

class exports.AssignExpr
  constructor: (@id, @expr) ->
  toString: -> 'AssignExpr(' + @id + ', ' + @expr + ')'

class exports.SeqExpr
  constructor: (@left, @right) ->
  toString: -> 'SeqExpr(' + @left + ', ' + @right + ')'

class exports.MatchExpr
  constructor: (@expr, @mrules) ->
  toString: -> 'MatchExpr(' + @expr + ', ' + @mrules + ')'

# Matches
class exports.MRule
  constructor: (@pat, @expr) ->
  toString: -> 'MRule(' + @pat + ', ' + @expr + ')'

# Patterns
class exports.NumPat
  constructor: (@value) ->
  toString: -> 'NumPat(' + @value + ')'
