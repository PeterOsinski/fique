Producer = require '../Producer'
debug = require('debug')('fq:test')
async = require 'async'

config = 
	name: 'test1'

producer = new Producer config

# async.timesSeries 500, (n, next) ->
# 	producer.push Math.random(), () ->
# 		next null, true
# , () ->
# 	process.exit()

setInterval () ->
	producer.push JSON.stringify
		a: Math.random()
		b: Math.random()
		c: Math.random()
		d: Math.random()
		aa: Math.random()
		bb: Math.random()
		cc: Math.random()
		dd: Math.random()
, 100