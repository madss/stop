fs = require 'fs'
parser = require './parser'
translater = require './translater'

input = fs.readFileSync process.argv[2], { encoding: 'utf-8' }
ast = parser.parse input
js = translater.translate(ast)
console.log js
