Producer = require '../Producer'
debug = require('debug')('fq:test')
async = require 'async'

config = 
	name: 'test1'

producer = new Producer config

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