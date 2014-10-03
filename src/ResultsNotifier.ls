module.exports.notify = (redis, type, cb) ->
  <~ redis.publish "update" type
  cb?!

module.exports.update = (redis, type, data, cb) ->
  (err) <~ redis.set "sum_#type", data.okrsky_spocteno
  cb?!
