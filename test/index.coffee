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
      cache.init(null, null, {namespace: 'open-cache-test'})
      cache.get('name', (error, result) ->
        assert.equal null, error
        assert.equal undefined, result
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
        assert.equal null, error
        assert.equal 'hello world', data
        readFile('./index.coffee', (error, data) ->
          assert.equal 1, count
          assert.equal null, error
          assert.equal 'hello world', data
          setTimeout ->
            readFile('./index.coffee', (error, data) ->
              assert.equal 2, count
              assert.equal null, error
              assert.equal 'hello world', data
              done()
            )
          , 1000
        )
      )

    it "call cache, auto cached function, exec fail, no-cache", (done) ->
      count = 0
      asyncFn = (path, callback) ->
        count += 1
        process.nextTick ->
          callback(Error 'something is wrong')

      asyncFn = cache "asyncFn:{0}", asyncFn, 1

      asyncFn('./index.coffee', (error, data) ->
        assert.equal 1, count
        assert.equal 'something is wrong', error.message
        assert.equal undefined, data
        asyncFn('./index.coffee', (error, data) ->
          assert.equal 2, count
          assert.equal 'something is wrong', error.message
          assert.equal undefined, data
          setTimeout ->
            asyncFn('./index.coffee', (error, data) ->
              assert.equal 3, count
              assert.equal 'something is wrong', error.message
              assert.equal undefined, data
              done()
            )
          , 1000
        )
      )

    it "call cache, auto cached function, exec fail, restore cache", (done) ->
      count = 0
      asyncFn2 = (path, callback) ->
        count += 1
        process.nextTick ->
          return callback(null, 'hello world') if count > 1
          callback(Error 'something is wrong')

      asyncFn2 = cache "asyncFn2:{0}", asyncFn2, 1

      asyncFn2('./index.coffee', (error, data) ->
        assert.equal 1, count
        assert.equal 'something is wrong', error.message
        assert.equal undefined, data
        asyncFn2('./index.coffee', (error, data) ->
          assert.equal 2, count
          assert.equal null, error
          assert.equal 'hello world', data
          asyncFn2('./index.coffee', (error, data) ->
            assert.equal 2, count
            assert.equal null, error
            assert.equal 'hello world', data
            setTimeout ->
              asyncFn2('./index.coffee', (error, data) ->
                assert.equal 3, count
                assert.equal null, error
                assert.equal 'hello world', data
                done()
              )
            , 1000
          )
        )
      )

    key1 = "http://trackx.stonephp.com/api_v2/campaigns/26956/reports/basics?startDate=2015-04-08&endDate=2015-04-14&maxResults=300&dimensions=media&metrics=imp%2Cclk%2Cuimp%2Cuclk%2CctRate&sort=-imp&startIndex=0&access_token=32d2011d39618c842183713f7a80c6926ee2a0f2"
    key2 = "http://trackx.stonephp.com/api_v2/campaigns/26998/reports/basics?startDate=2015-04-08&endDate=2015-04-14&maxResults=300&dimensions=media&metrics=imp%2Cclk%2Cuimp%2Cuclk%2CctRate&sort=-imp&startIndex=0&access_token=32d2011d39618c842183713f7a80c6926ee2a0f2"
    it "set, get, key length test", (done) ->
      cache.set key1, 'key1', 1, (error) ->
        assert.equal null, error
        cache.get key2, (error, data) ->
          assert.equal null, error
          assert.equal undefined, data
          cache.get key1, (error, data) ->
            assert.equal null, error
            assert.equal 'key1', data
            done()

    it "set, get, key length test 2", (done) ->
      cache.set key2, 'key2', 1, (error) ->
        assert.equal null, error
        cache.get key2, (error, data) ->
          assert.equal null, error
          assert.equal 'key2', data
          cache.get key1, (error, data) ->
            assert.equal null, error
            assert.equal 'key1', data
            done()

    it "removeKey test", (done) ->
      count = 0
      fn = (key, callback) ->
        count += 1
        callback(null, "#{key}, Hello world")

      fn = cache('Key: {0}', fn, 1000)
      fn('nihao', (error, result) ->
        assert.ifError(error)
        assert.equal('nihao, Hello world', result)
        fn.removeKey('nihao', (error) ->
          cache.get('Key: nihao', (error, result) ->
            assert.ifError(error)
            assert.equal(null, result)
            fn('nihao', (error, result) ->
              assert.ifError(error)
              assert.equal('nihao, Hello world', result)
              assert.equal(2, count)
              fn.removeKey('nihao', (error) ->
                assert.ifError(error)
                done()
              )
            )
          )
        )
      )
