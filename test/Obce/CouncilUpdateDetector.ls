require! {
  expect: 'expect.js'
  redis
  async
  '../config.ls'
  '../../src/Obce/CouncilUpdateDetector.ls'
  '../data/computeCouncilResults.json'
}

describe 'CouncilUpdateDetector' (_) ->
  redisClient = null
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    done!
  describe 'First insert' (_) ->
    it 'should detect all councils in first insert' (done) ->
      (err, updated) <~ CouncilUpdateDetector.filterUpdated redisClient, computeCouncilResults
      expect err .to.be null
      expect updated.length .to.be computeCouncilResults.length
      done!

  describe "repeated insert" (_) ->
    before (done) ->
      <~ async.eachLimit computeCouncilResults, 20, (council, cb) ->
        redisClient.set do
          "sum:#{council.kod}:#{council.typ}"
          council.okrsky_spocteny
          cb
      done!

    it 'should detect no councils in repeated insert' (done) ->
      (err, updated) <~ CouncilUpdateDetector.filterUpdated redisClient, computeCouncilResults
      expect err .to.be null
      expect updated.length .to.be 0
      done!

  describe "Updated insert" (_) ->
    it 'should detect the changed record' (done) ->
      computeCouncilResults.2.okrsky_spocteny++
      (err, updated) <~ CouncilUpdateDetector.filterUpdated redisClient, computeCouncilResults
      expect updated .to.have.length 1
      expect updated.0 .to.be computeCouncilResults.2
      done!
