Consumer = require '../Consumer'
debug = require('debug')('fq:test')
async = require 'async'

config = 
	name: 'test1'
	path: '/tmp',
	offset: 5000

consumer = new Consumer config

consumer.onMessage (data, offset) ->
	debug offset

consumer.start()