require! async
module.exports.filterUpdated = (redis, councils, cb) ->
  (err, isIncremented) <~ async.mapLimit councils, 10, (council, cb) ->
    (err, num) <~ redis.get "sum:#{council.kod}:#{council.typ}"
    return cb null true if err
    num = parseInt num, 10
    cb do
      null
      num != council.okrsky_spocteno
  cb do
    null
    councils.filter (council, index) ->  isIncremented[index]
