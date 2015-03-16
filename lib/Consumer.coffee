fs = require 'fs'
debug = (require 'debug')('fq:Consumer')
readline = require 'readline'
stream = require 'stream'

class Consumer
	constructor: (config) ->
		@_file = null 		#current file handle
		@_filename = null 	#current file name
		@_messagesConsumed = 0
		@_consumeFn = null
		@_rl = null #readline interface
		@_scanInterval = null #interval that scans for new files

		@path = validateParam 'path', config #where queue files are stored
		@name = validateParam 'name', config #which queue this consumer should consume

	validateParam = (param, config) ->
		if not config[param]
			throw Error("Provide #{param} in config object")
		else
			config[param]

	onMessage: (cb) -> @_consumeFn = cb

	start: () ->

		if not @_consumeFn
			throw Error 'Define onMessage function!'

		processClosedFiles @, () =>
			processOpenedFiles @

	processClosedFiles = (self, cb) ->
		debug 'Processing closed files'
		getFile self, 'ready', (filename) ->
			if not filename
				debug 'No closed files to process'
				return cb()

			debug 'Opening closed file', filename

			self._filename = filename
			self._file = fs.createReadStream self.path + '/' + filename

			self._rl = readline.createInterface input: self._file, output: new stream

			self._rl.on 'line', (data) =>
				self._consumeFn data

			self._rl.on 'close', () =>
				markFileAsProcessed self, () =>
					self.start()

	processOpenedFiles = (self) ->
		debug 'Processing opened files'
		getFile self, 'opened', (filename) ->
			if not filename
				return

			debug 'Processing file', filename

			self._filename = filename
			

	markFileAsProcessed = (self, cb) ->
		path = self.path + '/' + self._filename
		fs.rename path, path + '_processed', cb

	getFile = (self, type, cb) ->
		fs.readdir self.path, (err, files) ->
			
			for file in files
				
				name = file.indexOf(self.name) == 0
				status = file.indexOf('_fq_' + type) == (file.length - (type.length  + 4))

				if name and status
					cb file
					break

			cb false
					

module.exports = Consumer