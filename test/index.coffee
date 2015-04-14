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
        return done(error) if error
        assert.equal  undefined, result
        done()
      )
