require! {
  events.EventEmitter
  fs
  async
}

module.exports = class MunicipalityCombiner extends EventEmitter
  (@redis) ->

  update: (muniIds, cb) ->
    <~ async.eachLimit muniIds, 10, (muniId, cb) ~>
      (err, outputData, allData) <~ @combine muniId
      if err
        console.error err
        return
      @emit \municipality muniId, outputData, allData
      cb!
    cb?!


  combine: (muniId, cb) ->
    (err, results) <~ async.parallel do
      * (cb) ~> @loadVysledky muniId, cb
        (cb) ~> @loadGeoJson muniId, cb
    return cb err if err
    [{outputData, allData}, geojson] = results
    outputData.geojson = geojson
    cb null outputData, allData


  loadVysledky: (muniId, cb) ->
    (err, hash) <~ @redis.hgetall "results:#muniId"
    return cb err if err
    outputData = {}
    allData = {}
    for typ, data of hash
      outputData[typ] = JSON.parse data
      allData[typ] = JSON.parse data
      delete outputData[typ].typ
      delete outputData[typ].kod
    cb null, {outputData, allData}


  loadGeoJson: (muniId, cb) ->
    (err, data) <~ fs.readFile "#__dirname/../../data/geojsons/#muniId.geo.json"
    return cb err if err
    cb null JSON.parse data
