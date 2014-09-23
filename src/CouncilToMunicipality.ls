require! {
  councilToMunicipality: '../data/kod-zastup-to-obec.json'
  async
}
module.exports.save = (redis, councils, cb) ->
  muniChangedAssoc = {}
  (err) <~ async.eachLimit councils, 10, (council, cb) ->
    muniIds = councilToMunicipality[council.kod] || [council.kod]
    <~ async.eachSeries muniIds, (muniId, cb) ->
      muniChangedAssoc[muniId] = muniChangedAssoc[muniId] + 1 || 1
      (err) <~ redis.hset do
        "results:#muniId"
        council.typ
        JSON.stringify council
      console.error err if err
      cb!
    cb!
  munisChanged = for muniIdChanged, count of muniChangedAssoc
    parseInt muniIdChanged, 10
  cb err, munisChanged


