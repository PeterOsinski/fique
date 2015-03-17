fs = require 'fs'
debug = (require 'debug')('fq:Consumer')
readline = require 'readline'
stream = require 'stream'
tailFile = (require 'tail').Tail

class Consumer
	constructor: (config) ->
		@_file = null 		#current file handle
		@_filename = null 	#current file name
		@_messagesConsumed = 0
		@_consumeFn = null
		@_rl = null #readline interface
		@_scanInterval = null #interval that scans for new files
		@_tailFile = null #here goes the currently tailed filename

		@path = validateParam 'path', config #where queue files are stored
		@name = validateParam 'name', config #which queue this consumer should consume
		@_offset = config.offset || 0 #keep the current offset

	validateParam = (param, config) ->
		if not config[param]
			throw Error("Provide #{param} in config object")
		else
			config[param]

	onMessage: (cb) -> @_consumeFn = cb

	start: () ->

		if not @_consumeFn
			throw Error 'Define onMessage function!'

		processFiles @

	processFiles = (self) ->

		_data = getFileForOffset self

		if _data
			self._filename = _data.file

		if not self._filename
			self._consumeFn error: 'Offset out of range!'
			return

		debug 'Opening file', self._filename

		self._file = fs.createReadStream self.path + '/' + self._filename

		self._rl = readline.createInterface input: self._file, output: new stream

		skipped = 0
		self._rl.on 'line', (data) =>
			if _data and _data.skip > skipped
				skipped++
				return
			self._offset++
			self._consumeFn data, self._offset

		self._rl.on 'close', () =>
				if getCurrentProducedFile(self) == self._filename
					debug 'File ended, but is currently produced, following the tail %s', self._filename
					openCurrentFile self
					fileWatcher self
				else
					debug 'Closed file looking for next file, offset %s', self._offset
					processFiles self

	openCurrentFile = (self) ->
		currentFile = getCurrentProducedFile self

		if not currentFile
			return debug 'Did not find current file...'

		if currentFile == self._tailFile
			return debug 'File %s is already tailed, skipping tailing', currentFile

		debug 'Found current file, opening %s', currentFile

		self._tailFile = currentFile

		tail = new tailFile self.path + '/' + self._tailFile
		tail.on 'error', (err) =>
			debug err

		tail.on 'line', (line) =>
			self._offset++
			self._consumeFn line, self._offset

	fileWatcher = (self) -> 
		fs.watch self.path + '/.' + self.name + '_current_file', () =>
			openCurrentFile self

	getCurrentProducedFile = (self) ->
		fs.readFileSync self.path + '/.' + self.name + '_current_file', encoding: 'utf8'

	getFileForOffset = (self) ->
		files = fs.readdirSync self.path
		.filter (file) =>
			file.indexOf(self.name + '_') == 0
		.sort()

		for file, k in files
			getOffsetFromFilename = (fn) => 
				fn && parseInt fn.substr(self.name.length + 15).substr(0, 13) || 0
			
			fileOffset = getOffsetFromFilename file
			nextFileOffset = getOffsetFromFilename files[k + 1]
			if fileOffset <= self._offset and (nextFileOffset > self._offset or not nextFileOffset)
				debug 'Found file %s for offset %s, skip %s', file, self._offset, self._offset - fileOffset
				return {
					file: file,
					skip: (self._offset - fileOffset) || 0
				}					

module.exports = Consumer