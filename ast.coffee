# Expressions

class exports.IdExpr
  constructor: (@value) ->
  toString: -> 'IdExpr(' + @value + ')'

class exports.NumExpr
  constructor: (@value) ->
  toString: -> 'NumExpr(' + @value + ')'

class exports.StrExpr
  constructor: (@value) ->
  toString: -> 'StrExpr(' + @value + ')'

class exports.ListExpr
  constructor: (@values) ->
  toString: -> 'ListExpr(' + @values + ')'

class exports.BinExpr
  constructor: (@kind, @left, @right) ->
  toString: -> 'BinExpr(' + @kind + ', ' + @left + ', ' + @right + ')'

class exports.MemberExpr
  constructor: (@expr, @id) ->
  toString: -> 'MemberExpr(' + @expr + ', ' + @id + ')'

class exports.AssignExpr
  constructor: (@lval, @expr) ->
  toString: -> 'AssignExpr(' + @lval + ', ' + @expr + ')'

class exports.SeqExpr
  constructor: (@left, @right) ->
  toString: -> 'SeqExpr(' + @left + ', ' + @right + ')'

class exports.MatchExpr
  constructor: (@expr, @mrules) ->
  toString: -> 'MatchExpr(' + @expr + ', ' + @mrules + ')'

class exports.FnExpr
  constructor: (@ids, @expr) ->
  toString: -> 'FnExpr(' + @ids + ', ' + @expr + ')'

class exports.AppExpr
  constructor: (@expr, @args) ->
  toString: -> 'AppExpr(' + @expr + ', ' + @args + ')'

class exports.TypeExpr
  constructor: (@fields) ->
  toString: -> 'TypeExpr(' + (@fields.join ', ') + ')'

# Matches

class exports.MRule
  constructor: (@pat, @expr) ->
  toString: -> 'MRule(' + @pat + ', ' + @expr + ')'

# Patterns
class exports.IdPat
  constructor: (@value) ->
  toString: -> 'IdPat(' + @value + ')'

class exports.NumPat
  constructor: (@value) ->
  toString: -> 'NumPat(' + @value + ')'

class exports.StrPat
  constructor: (@value) ->
  toString: -> 'StrPat(' + @value + ')'

class exports.TypePat
  constructor: (@id, @fields) ->
  toString: -> 'TypePat(' + @id + ', [' + (@fields.join ', ') + '])'

class exports.TypePatField
  constructor: (@key, @pat) ->
  toString: -> @key + ': ' + @pat
