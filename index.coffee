redis     = require 'redis'


client = null

get = (key, callback) ->
  client.get(key, (error, result) ->
    return callback(error) if error
    callback null, JSON.parse(result)
  )

set = (key, value, life, callback) ->
  throw Error 'cache must be init, at use before'
  client.set(key, JSON.stringify(value), (error) ->
    callback?(error)
    client.expire([key, life], (error) ->
      console.error error if error
    )
  )

del = (key, callback = console.error) ->
  client.del key, callback

cache =

  init: (port, ip, opts) ->
    return if client
    client = redis.createClient(port, ip, opts)
    cache.get = get
    cache.set = set
    cache.del = del

  get: (key, callback) ->
    throw Error 'cache must be init, at use before'

  set: (key, value, life, callback) ->
    throw Error 'cache must be init, at use before'

  del: (key, callback = console.error) ->
    throw Error 'cache must be init, at use before'

module.exports = cache
