require! async
module.exports.updateCounties = (redis, counties, cb) ->

filterUpdated = ->
  (err, output) <~ async.eachLimit counties, 20, (county, cb) ->
    console.log 'fooo'
    cb!
  output
