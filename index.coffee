redis     = require 'redis'


client = null
namespace = ''

getKey = (key) ->
  "#{namespace}::#{key}"

get = (key, callback) ->
  key = getKey(key)
  client.get(key, (error, result) ->
    return callback(error) if error
    callback null, JSON.parse(result)
  )

set = (key, value, life, callback) ->
  key = getKey(key)
  client.set(key, JSON.stringify(value), (error) ->
    callback?(error)
    return unless life
    client.expire([key, +life or 1], (error) ->
      console.error error if error
    )
  )

del = (key, callback = console.error) ->
  key = getKey(key)
  client.del key, callback

cache =

  init: (port = 6379, ip = '127.0.0.1', opts) ->
    return if client
    namespace = opts and opts.namespace or ''
    client = redis.createClient(port, ip, opts and opts.redis)
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
