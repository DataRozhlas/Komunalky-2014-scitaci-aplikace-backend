module.exports.notify = (redis, muniId) ->
  redis.publish "update" muniId
