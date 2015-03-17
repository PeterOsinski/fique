Server = require '../Server'
debug = (require 'debug')('fq:testServer')

config = 
	name: 'foo_bar'
	path: '/tmp'
	maxMessagesPerFile: 10
	maxFileSize: 1024 * 1024

server = new Server config