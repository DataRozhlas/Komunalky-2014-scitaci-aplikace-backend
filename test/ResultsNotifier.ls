require! {
  expect: 'expect.js'
  redis
  './config.ls'
  '../src/ResultsNotifier.ls'
}

describe "Redis notifier" (_) ->
  redisClient = null
  redisSubscriber = null
  messages = []
  data = {
    okrsky_spocteno: 20
  }
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.auth config.redis.key
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    redisSubscriber := redis.createClient config.redis.port, config.redis.host
    <~ redisSubscriber.auth config.redis.key
    <~ redisSubscriber.select config.redis.db
    <~ redisSubscriber.subscribe "update"
    done!

  it 'should send a redis message' (done) ->
    ResultsNotifier.notify redisClient, "pago"
    redisSubscriber.on \message (channel, message) ->
      expect channel .to.eql \update
      expect message .to.eql \pago
      done!

  it 'should update current okrsky_spocteno' (done) ->
    ResultsNotifier.update redisClient, "pago", data
    (err, value) <~ redisClient.get "sum_pago"
    expect value .to.eql 20
    done!

