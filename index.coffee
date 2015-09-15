fs = require 'fs'
parser = require './parser'
js = require './js'

input = fs.readFileSync process.argv[2], { encoding: 'utf-8' }
ast = parser.parse input
output = js.translate(ast)
console.log output
