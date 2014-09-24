require! {
  events.EventEmitter
  fs
  async
}

module.exports = class MunicipalityCombiner extends EventEmitter
  (@redis) ->

  update: (muniIds, cb) ->
    <~ async.eachLimit muniIds, 10, (muniId, cb) ~>
      (err, outputData) <~ @combine muniId
      if err
        console.error err
        return
      @emit \municipality muniId, outputData
      cb!
    cb?!


  combine: (muniId, cb) ->
    (err, results) <~ async.parallel do
      * (cb) ~> @loadVysledky muniId, cb
        (cb) ~> @loadGeoJson muniId, cb
    return cb err if err
    [vysledky, geojson] = results
    vysledky.geojson = geojson
    cb null vysledky


  loadVysledky: (muniId, cb) ->
    (err, hash) <~ @redis.hgetall "results:#muniId"
    return cb err if err
    output = {}
    for typ, data of hash
      output[typ] = JSON.parse data
      delete output[typ].typ
      delete output[typ].kod
    cb null output


  loadGeoJson: (muniId, cb) ->
    (err, data) <~ fs.readFile "#__dirname/../data/geojsons/#muniId.geo.json"
    return cb err if err
    cb null JSON.parse data
