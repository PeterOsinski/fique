Broker = require '../Broker'
debug = (require 'debug')('fq:testBroker')

config = 
	name: 'test1'
	path: '/tmp'
	maxFileMessages: 500
	maxFileSize: 1024 * 1024 * 1
	maxBufferSize: 1024 * 50
	maxBufferMessages: 50
	# port: 5678

broker = new Broker config