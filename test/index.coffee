assert      = require 'assert'
cache       = require '../'


describe 'cache', ->

  describe 'init function unexec', ->
    it "call cache.get throw", (done) ->
      assert.throws ->
        cache.get('name')
      , Error
      done()


    it "call cache.set throw", (done) ->
      assert.throws ->
        cache.set('name', new Date, 10)
      , Error
      done()

    it "call cache.del throw", (done) ->
      assert.throws ->
        cache.del('name')
      , Error
      done()

    it "call cache.get name non-exists", (done) ->
      cache.init()
      cache.get('name', (error, result) ->
        assert.equal null, error
        assert.equal  undefined, result
        done()
      )

    it "call cache.set name", (done) ->
      cache.set('name', 'open-node', 1, (error) ->
        assert.equal error, null
        done()
      )

    it "call cache.get name exists", (done) ->
      cache.get('name', (error, value) ->
        assert.equal null, error
        assert.equal  'open-node', value
        done()
      )

    it "call cache.get cache expired, return null", (done) ->
      setTimeout ->
        cache.get('name', (error, value) ->
          assert.equal null, error
          assert.equal null, value
          done()
        )
      , 2000

    it "call cache.del cache, again cache.get return null", (done) ->
      cache.set('name', 'open-node', 0, (error) ->
        assert.equal null, error
        cache.del('name', (error) ->
          assert.equal null, error
          cache.get('name', (error, value) ->
            assert.equal null, error
            assert.equal null, value
            done()
          )
        )
      )

    it "call cache, auto cached function", (done) ->
      count = 0
      readFile = (path, callback) ->
        count += 1
        process.nextTick ->
          callback(null, 'hello world')

      readFile = cache "fs.readFile:{0}", readFile, 1

      readFile('./index.coffee', (error, data) ->
        assert.equal 1, count
        assert.equal 'hello world', data
        readFile('./index.coffee', (error, data) ->
          assert.equal 1, count
          assert.equal 'hello world', data
          setTimeout ->
            readFile('./index.coffee', (error, data) ->
              assert.equal 2, count
              assert.equal 'hello world', data
              done()
            )
          , 1000
        )
      )
