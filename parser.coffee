parser = require './_parser.js'
p = parser.parser
p.yy = require './ast'

exports.parse = (code) -> p.parse code
