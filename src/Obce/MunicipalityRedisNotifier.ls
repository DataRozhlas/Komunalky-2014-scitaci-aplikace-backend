require! async
module.exports.notify = (redis, muniId, cb) ->
  redis.publish "update" muniId
  cb?!

module.exports.update = (redis, data, cb) ->
  typy = []
  for typ, values of data
    if values.okrsky_spocteno
      typy.push {typ, value: that, kod: values.kod}
  <~ async.each typy, ({typ, kod, value}, cb) ->
    (err) <~ redis.set "sum:#kod:#typ", value
    console.error err if err
    cb!
  cb?!
