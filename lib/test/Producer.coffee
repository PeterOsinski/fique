Producer = require '../Producer'
debug = require('debug')('fq:test')
async = require 'async'

config = 
	name: 'foo_bar'

producer = new Producer config

# async.timesSeries 500, (n, next) ->
# 	producer.push Math.random(), () ->
# 		next null, true
# , () ->
# 	process.exit()

setInterval () ->
	producer.push Math.random()
	producer.push Math.random()
	producer.push Math.random()
, 10