fs = require 'fs'
debug = require('debug')('fq:Producer')
net = require 'net'

class Producer
	constructor: (config) ->

		@name = validateParam 'name', config #name of the queue
		@maxBufferMessages = parseInt config.maxBufferMessages or 10
		@maxBufferSize = parseInt config.maxBufferSize or 1024 * 10
		@brokerHost = config.brokerHost
		@brokerPort = config.brokerPort

		@_buffer = ''
		@_messagesInBuffer = 0
		@_bufferSize = 0
		@_connection = null

		connectToBroker @

	validateParam = (param, config) ->
		if not config[param]
			throw Error("Provide #{param} in config object")
		else
			config[param]

	connectToBroker = (self) ->
		debug 'Connecting to broker'

		if not self.brokerHost and not self.brokerPort
			
			self._connection = net.connect path: '/tmp/' + self.name + '.sock'
			debug 'Connected with sock!'

		else

			self._connection = net.connect port: self.brokerPort, host: self.brokerHost, () ->
				debug 'Connected with TCP!'

	push: (msg) ->
		if typeof msg isnt 'string'
			msg = msg.toString()
		
		msg += "\n"
		@_buffer += msg

		@_messagesInBuffer++
		@_bufferSize += new Buffer(msg, 'utf8').length

		if @_connection
			if @_messagesInBuffer >= @maxBufferMessages or @_bufferSize >= @maxBufferSize
				send @

	send = (self) ->

		debug 'Sending payload to broker, messages: %s, size: %s', self._messagesInBuffer, self._bufferSize

		msg = self._buffer

		self._buffer = ''
		self._bufferSize = 0
		self._messagesInBuffer = 0

		self._connection.write msg, () ->


module.exports = Producer