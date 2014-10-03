module.exports.isUpdated = (redis, type, json, cb) ->
  (err, count) <~ redis.get "sum_#type"
  return cb err if err
  count = parseInt count, 10
  cb null count != json.okrsky_spocteno
