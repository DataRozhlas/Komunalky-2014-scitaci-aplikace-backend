require! {
  expect: 'expect.js'
  redis
  async
  '../config.ls'
  '../../src/Senat/SenatUpdateDetector.ls'
}

describe 'SenatUpdateDetector' (_) ->
  redisClient = null
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    done!
  senatResults = {okrsky_spocteny: 5}

  it 'should detect change on first insert' (done) ->
    (err, updated) <~ SenatUpdateDetector.isUpdated redisClient, senatResults
    expect err .to.be null
    expect updated .to.be true
    done!

  it 'should detect no councils in repeated insert' (done) ->
    <~ redisClient.set "sum_senat", 5
    (err, updated) <~ SenatUpdateDetector.isUpdated redisClient, senatResults
    expect err .to.be null
    expect updated .to.be false
    done!

  it 'should detect the changed record' (done) ->
    senatResults.okrsky_spocteny++
    (err, updated) <~ SenatUpdateDetector.isUpdated redisClient, senatResults
    expect err .to.be null
    expect updated .to.be true
    done!
