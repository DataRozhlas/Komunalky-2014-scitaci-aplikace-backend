module.exports.isUpdated = (redis, json, cb) ->
  (err, count) <~ redis.get "sum_senat"
  return cb err if err
  count = parseInt count, 10
  cb null count != json.okrsky_spocteny
