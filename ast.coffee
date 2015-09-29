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

class exports.BinExpr
  constructor: (@kind, @left, @right) ->
  toString: -> 'BinExpr(' + @kind + ', ' + @left + ', ' + @right + ')'

class exports.AssignExpr
  constructor: (@id, @expr) ->
  toString: -> 'AssignExpr(' + @id + ', ' + @expr + ')'

class exports.SeqExpr
  constructor: (@left, @right) ->
  toString: -> 'SeqExpr(' + @left + ', ' + @right + ')'

class exports.MatchExpr
  constructor: (@expr, @mrules) ->
  toString: -> 'MatchExpr(' + @expr + ', ' + @mrules + ')'

class exports.FnExpr
  constructor: (@id, @expr) ->
  toString: -> 'FnExpr(' + @id + ', ' + @expr + ')'

class exports.AppExpr
  constructor: (@id, @arg) ->
  toString: -> 'AppExpr(' + @id + ', ' + @arg + ')'

class exports.TypeExpr
  constructor: (@fields) ->
  toString: -> 'TypeExpr(' + (@fields.join ', ') + ')'

class exports.PrintExpr
  constructor: (@expr) ->
  toString: -> 'PrintExpr(' + @expr + ')'

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
  toString: -> 'TypePat(' + $id + ', [' + (@pats.join ', ') + '])'

class exports.TypePatField
  constructor: (@key, @pat) ->
  toString: -> @key + ': ' + @pat
