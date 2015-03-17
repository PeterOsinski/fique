# fique
Node.js implementation of **FI**le **QUE**ue with multiple producer-consumer pattern

# API
## Server
### Server(config)
* `path`: the path where to store the queue files
* `name`: the name of the queue, used to distinct different queues in one process
* `maxMessagesPerFile`: maximum message count per file
* `maxFileSize`: maximum file size with messages

``` js
Server = require '../Server'

config = 
	name: 'foo_bar'
	path: '/tmp'
	maxMessagesPerFile: 10
	maxFileSize: 1024 * 1024

server = new Server config
```

## Producer
### Producer(config)
* `name`: the name of the queue, used to distinct different queues in one process
You can set up as many producers as you want

``` js
Producer = require '../Producer'
config = 
	name: 'foo_bar'

producer = new Producer config

setInterval () ->
	producer.push Math.random()
, 500
```


## Consumer
### Consumer(config)
* `path`: the path where the queue files are stored
* `name`: the name of the queue, used to distinct different queues in one process
* `offset`: from what offset you want to start processing messages

``` js
Consumer = require '../Consumer'

config = 
	name: 'foo_bar'
	path: '/tmp',
	offset: 15

consumer = new Consumer config

consumer.onMessage (data, offset) ->
	debug data, offset

consumer.start()
```
