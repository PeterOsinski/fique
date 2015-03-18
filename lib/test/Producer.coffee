Producer = require '../Producer'
async = require 'async'
cluster = require 'cluster'

if cluster.isMaster

	cluster.fork()
	cluster.fork()

else

	debug = require('debug')('fq:test:worker' + cluster.worker.id)
	debug 'New worker!'
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
	, 10