Broker = require '../Broker'
debug = (require 'debug')('fq:testBroker')

config = 
	name: 'test1'
	path: '/tmp'
	maxMessagesPerFile: 10000
	maxFileSize: 1024 * 1024

broker = new Broker config