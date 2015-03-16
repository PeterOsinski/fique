Consumer = require '../Consumer'
debug = require('debug')('fq:test')
async = require 'async'

config = 
	name: 'foo_bar'
	path: '/tmp'

consumer = new Consumer config

consumer.onMessage (data) ->
	debug data

consumer.start()