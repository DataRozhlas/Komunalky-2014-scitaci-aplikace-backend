require! async
module.exports.notify = (redis, muniId, data, cb) ->
  redis.publish "update" muniId
  typy = []
  for typ, values of data
    if values.okrsky_spocteno
      typy.push {typ, value: that}
  <~ async.each typy, ({typ, value}, cb) ->
    redis.set "sum:#muniId:#typ", value, cb
  cb?!
