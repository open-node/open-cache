redis     = require 'redis'
_         = require 'underscore'


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

###
# 只为cache 函数使用，用来根据用户执行函数的参数中获取到cache的key
# 有别于getKey
###
cacheKey = (tpl, args) ->
  regxp = /\{(\d+)\}/g
  return tpl unless regxp.test(tpl)
  tpl.replace(regxp, (m, i) -> args[i])

cache = (keyTpl, func, life, bind) ->
  throw Error 'cache must be init, at use before' unless client
  (args..., callback) ->
    throw "Callback function non-exists" unless _.isFunction(callback)
    key = cacheKey(keyTpl, args)
    get(key, (error, result) ->
      # 获取cache有错误的时候需要输出，但是不需要通知调用方，对调用方透明
      # 因为调用方可能压根没有处理这种异常的逻辑
      # 另外这种并不会影响程序功能
      # 所以返回给用户将毫无意义，而且会打乱调用方原有的代码
      console.error error if error
      # 如果有错误或者结果不存在，则需要执行func
      return callback(null, result) if not error and result

      # 这里要把用户原有的callback给封装起来，这样我们才能将他的结果cache起来
      # 这里要注意的是我们只cache成功的结果。失败的，错误的都不cache
      # 以免影响用户既有功能
      args.push((error, result) ->
        return callback(error, result) if error
        set(key, result, life)
        callback(error, result)
      )
      # 执行函数
      # 因为callback已经是被替换后的函数了。
      # 所以尽管只是简单的调用的用户的函数，但其实会把他的结果cache起来
      func.apply(bind, args)
    )

cache.init = (port = 6379, ip = '127.0.0.1', opts) ->
  return if client
  namespace = opts and opts.namespace or ''
  client = redis.createClient(port, ip, opts and opts.redis)
  client.on 'error', (error) ->
    console.error error
  cache.get = get
  cache.set = set
  cache.del = del

cache.get = cache.set = cache.del =  ->
  throw Error 'cache must be init, at use before'

module.exports = cache
