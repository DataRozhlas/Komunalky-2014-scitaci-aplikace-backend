require! {
  expect: 'expect.js'
  redis
  '../config.ls'
  '../../src/Obce/MunicipalityRedisNotifier.ls'
}

describe "Redis notifier" (_) ->
  redisClient = null
  redisSubscriber = null
  messages = []
  data = {
    obec: okrsky_spocteno: 20
    mcmo: okrsky_spocteno: 90
    geojson: 'foobar'
  }
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    redisSubscriber := redis.createClient config.redis.port, config.redis.host
    <~ redisSubscriber.select config.redis.db
    <~ redisSubscriber.subscribe "update"
    done!

  it 'should send a redis message' (done) ->
    MunicipalityRedisNotifier.notify redisClient, 9999, data
    redisSubscriber.on \message (channel, message) ->
      expect channel .to.eql \update
      expect message .to.eql \9999
      done!

  it 'should update current okrsky_spocteno' (done) ->
    (err, value) <~ redisClient.get "sum:9999:obec"
    expect value .to.eql 20
    (err, value) <~ redisClient.get "sum:9999:mcmo"
    expect value .to.eql 90
    done!

