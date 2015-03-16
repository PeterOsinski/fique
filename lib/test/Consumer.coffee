Consumer = require '../Consumer'
debug = require('debug')('fq:test')
async = require 'async'

config = 
	name: 'foo_bar'
	path: '/tmp',
	offset: 2210

consumer = new Consumer config

consumer.onMessage (data, offset) ->
	debug data, offset

consumer.start()