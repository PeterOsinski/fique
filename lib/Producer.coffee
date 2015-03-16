fs = require 'fs'
debug = require('debug')('fq:Producer')
net = require 'net'

class Producer
	constructor: (config) ->
		@name = validateParam 'name', config #name of the queue
		@_sock = null

		@_sock = net.connect path: '/tmp/' + @name + '.sock'
		debug 'Connected!'

	validateParam = (param, config) ->
		if not config[param]
			throw Error("Provide #{param} in config object")
		else
			config[param]

	push: (msg, cb) ->
		if typeof msg isnt 'string'
			msg = msg.toString()

		msg += "\n"
		@_sock.write msg, cb


module.exports = Producer