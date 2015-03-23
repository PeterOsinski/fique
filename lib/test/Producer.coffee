Producer = require '../Producer'
async = require 'async'
cluster = require 'cluster'

if cluster.isMaster

	cluster.fork()
	cluster.fork()
	cluster.fork()
	cluster.fork()
	cluster.fork()

else

	debug = require('debug')('fq:test:worker' + cluster.worker.id)
	debug 'New worker!'
	config = 
		# brokerHost: '127.0.0.1'
		# brokerPort: 5678
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
			aaa: Math.random()
			bbb: Math.random()
			ccc: Math.random()
			ddd: Math.random()
			aaaa: Math.random()
			bbbb: Math.random()
			cccc: Math.random()
			dddd: Math.random()
	, 100