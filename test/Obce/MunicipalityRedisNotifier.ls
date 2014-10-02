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
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    redisSubscriber := redis.createClient config.redis.port, config.redis.host
    <~ redisSubscriber.select config.redis.db
    <~ redisSubscriber.subscribe "update"
    done!

  it 'should send a redis message' (done) ->
    MunicipalityRedisNotifier.notify redisClient, 9999
    redisSubscriber.on \message (channel, message) ->
      expect channel .to.eql \update
      expect message .to.eql \9999
      done!

