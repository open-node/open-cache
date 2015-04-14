redis     = require 'redis'


client = null

get = (key, callback) ->
  client.get(key, (error, result) ->
    return callback(error) if error
    callback null, JSON.parse(result)
  )

set = (key, value, life, callback) ->
  client.set(key, JSON.stringify(value), (error) ->
    callback?(error)
    client.expire([key, life], (error) ->
      console.error error if error
    )
  )

del = (key, callback = console.error) ->
  client.del key, callback

cache =

  init: (port = 6379, ip = '127.0.0.1', opts) ->
    return if client
    client = redis.createClient(port, ip, opts)
    cache.get = get
    cache.set = set
    cache.del = del

  get: ->
    throw Error 'cache must be init, at use before'

  set: ->
    throw Error 'cache must be init, at use before'

  del: ->
    throw Error 'cache must be init, at use before'

module.exports = cache
