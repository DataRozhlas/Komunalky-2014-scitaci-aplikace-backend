require! {
  expect: 'expect.js'
  redis
  async
  './config.ls'
  '../src/ResultsUpdateDetector.ls'
}

describe 'ResultsUpdateDetector' (_) ->
  redisClient = null
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.auth config.redis.key
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    done!
  senatResults = {okrsky_spocteno: 5}

  it 'should detect change on first insert' (done) ->
    (err, updated) <~ ResultsUpdateDetector.isUpdated redisClient, "pago", senatResults
    expect err .to.be null
    expect updated .to.be true
    done!

  it 'should detect no councils in repeated insert' (done) ->
    <~ redisClient.set "sum_pago", 5
    (err, updated) <~ ResultsUpdateDetector.isUpdated redisClient, "pago", senatResults
    expect err .to.be null
    expect updated .to.be false
    done!

  it 'should detect the changed record' (done) ->
    senatResults.okrsky_spocteno++
    (err, updated) <~ ResultsUpdateDetector.isUpdated redisClient, "pago", senatResults
    expect err .to.be null
    expect updated .to.be true
    done!
