Broker = require '../Broker'
debug = (require 'debug')('fq:testBroker')

config = 
	name: 'test1'
	path: '/tmp'
	maxFileMessages: 500000
	maxFileSize: 1024 * 1024 * 25
	maxBufferSize: 1024 * 500
	maxBufferMessages: 5000
	# port: 5678

broker = new Broker config