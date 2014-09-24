require! {
  expect: 'expect.js'
  redis
  async
  './config.ls'
  '../src/CouncilToMunicipality.ls'
  '../src/MunicipalityCombiner.ls'

  './data/computeCouncilResults.json'
  councilToMunicipalityAssoc: '../data/kod-zastup-to-obec.json'

}

describe 'CouncilToMunicipality' (_) ->
  redisClient = null
  munisChanged = null
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    (err, _munisChanged) <~ CouncilToMunicipality.save redisClient, computeCouncilResults
    munisChanged := _munisChanged
    done!

  it 'should emit changed and combined munis' (done) ->
    # munisChanged.length = 10
    municipalityCombiner = new MunicipalityCombiner redisClient
    i = 0
    municipalityCombiner.on \municipality (muniId, data) ->
      ++i
      expect data .to.have.property \geojson
      expect data.geojson .to.have.property \type \FeatureCollection
      expect data.geojson .to.have.property \features
      if i >= munisChanged.length
        done!
    municipalityCombiner.update munisChanged
