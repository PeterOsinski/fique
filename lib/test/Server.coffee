Server = require '../Server'
debug = (require 'debug')('fq:testServer')

config = 
	name: 'test1'
	path: '/tmp'
	maxMessagesPerFile: 10000
	maxFileSize: 1024 * 1024

server = new Server config