net = require 'net'
fs = require 'fs'
debug = (require 'debug')('fq:Server')
readline = require 'readline'
stream = require 'stream'

class Broker
	constructor: (config) ->
		@_file = null 		#current file handle
		@_filename = null 	#current file name
		
		@_messagesInFile = 0
		@_fileSize = 0

		@_buffer = '' #buffer that keeps the messages
		@_messagesInBuffer = 0
		@_bufferSize = 0

		@_rl = null

		@path = validateParam 'path', config #where to store queue files
		@name = validateParam 'name', config #name of the queue

		# following values should be passed as bytes
		@maxFileMessages = parseInt config.maxFileMessages or 1000
		@maxFileSize = parseInt config.maxFileSize or 1024 * 100 
		@maxBufferMessages = parseInt config.maxBufferMessages or 10000
		@maxBufferSize = parseInt config.maxBufferSize or 1024 * 1000

		startServer @
		pickupLastFile @
		onCloseHandler @

	onCloseHandler = (self) ->
		process.on 'SIGINT', () ->
			flushBuffer self, () ->
				setCurrentFileCount self
				process.exit()

	getSockPath = (self) ->
		return '/tmp/' + self.name + '.sock'

	startServer = (self) ->

		if fs.existsSync getSockPath(self)
			fs.unlinkSync getSockPath(self)

		messagesReceived = 0
		setInterval () ->
			debug 'Messages received: %s', messagesReceived
			messagesReceived = 0
		, 10000

		@_server = net.createServer (sock) =>
			
			debug 'Client connected to broker'

			streamPass = new stream.PassThrough();
			self._rl = readline.createInterface input: streamPass, output: new stream

			self._rl.on 'line', (line) =>
				messagesReceived++
				addToBuffer self, line.toString()
				
			sock.on 'data', (data) ->
				streamPass.write data

			sock.on 'end', () ->
				debug 'Client disconnected'

		@_server.listen getSockPath(self), () ->
			debug 'Broker listening'


	validateParam = (param, config) ->
		if not config[param]
			throw Error("Provide #{param} in config object")
		else
			config[param]

	pickupLastFile = (self) ->
		lastFile = self.path + '/.' + self.name + '_current_file'
		fileMessagesCount = self.path + '/.' + self.name + '_current_file_count'

		if fs.existsSync lastFile

			lastFile = fs.readFileSync lastFile, encoding: 'utf8'
			fileMessagesCount = fs.readFileSync fileMessagesCount, encoding: 'utf8'
			
			self._fileSize = fs.statSync(self.path + '/' + lastFile)['size']
			self._messagesInFile = fileMessagesCount
			self._filename = lastFile
			
			debug 'Picking last file: %s, message count: %s, size: %s', lastFile, fileMessagesCount, self._fileSize
			
			openFile self
			
			setCurrentFile self

	addToBuffer = (self, msg) ->
		if msg.length == 0 or not msg
			return

		if not self._file
			newFile self

		msg = JSON.stringify(msg.toString().trim()) + "\n"

		if msg == 'null' or not msg
			return

		self._buffer += msg

		self._fileSize += msg.length
		self._bufferSize += msg.length
		self._messagesInFile++
		self._messagesInBuffer++

		if self._messagesInFile >= self.maxFileMessages or self._fileSize >= self.maxFileSize
			flushBuffer self
			newFile self

		if self._messagesInBuffer >= self.maxBufferMessages or self._bufferSize >= self.maxBufferSize
			flushBuffer self

	flushBuffer = (self, cb) ->

		if self._buffer.length == 0
			return

		debug 'Flushing buffer'

		self._messagesInBuffer = 0
		self._bufferSize = 0

		msg = new Buffer self._buffer, 'utf8'

		self._buffer = ''

		self._file.write msg, (err) =>
			if err
				debug err
			cb && cb()

	getMessagesCount: () -> @_messagesInFile
	getFileSize: () -> @_fileSize
	getFilePath: () -> @_filepath

	generateFileName = (self) ->
		self.name + '_' + (new Date().getTime()) + '_' + getOffset self

	getCurrentFilePath = (self) ->
		self.path + '/' + self._filename

	closeFile: (cb) ->
		if not @_file
			return

		@_file.end()
		debug 'Closing file %s, current message count: %s, size: %s', @_filename, @_messagesInFile, @_fileSize

		if @_messagesInFile == 0
			debug 'File is empty, deleting file %s', @path
			fs.unlinkSync @path
			return

		cp = getCurrentFilePath @
		offset = getOffset(@) + @_messagesInFile
		setOffset @, offset

	getOffset = (self) -> 
		offsetFile = self.path + '/.' + self.name + '_offset'
		if fs.existsSync offsetFile
			offset = parseInt(fs.readFileSync(offsetFile, encoding: 'utf8')) || 0
			return offset
		else
			return 0

	setOffset = (self, offset) -> 
		fs.writeFileSync self.path + '/.' + self.name + '_offset', offset

	setCurrentFileCount = (self) ->
		fs.writeFileSync self.path + '/.' + self.name + '_current_file_count', self._messagesInFile
		
	setCurrentFile = (self) ->
		fs.writeFileSync self.path + '/.' + self.name + '_current_file', self._filename

	openFile = (self) ->
		fp = getCurrentFilePath self
		self._file = fs.createWriteStream(fp, flags: 'a')

	newFile = (self) ->
		self.closeFile()

		self._messagesInFile = 0
		self._fileSize = 0

		self._filename = generateFileName self
		openFile self

		setCurrentFile self

		debug 'New file', self._filename

module.exports = Broker