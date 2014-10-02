require! {
  expect: 'expect.js'
  redis
  async
  '../config.ls'
  '../../src/Obce/CouncilToMunicipality.ls'
  '../data/computeCouncilResults.json'
  councilToMunicipalityAssoc: '../../data/kod-zastup-to-obec.json'

}

describe 'CouncilToMunicipality' (_) ->
  redisClient = null
  munisChanged = null
  before (done) ->
    redisClient := redis.createClient config.redis.port, config.redis.host
    <~ redisClient.select config.redis.db
    <~ redisClient.flushdb!
    done!

  it 'should not crash on inserting' (done) ->
    (err, _munisChanged) <~ CouncilToMunicipality.save redisClient, computeCouncilResults
    munisChanged := _munisChanged
    done!

  it 'should return IDs of changed Munis' ->
    expect munisChanged .to.not.be null
    expect munisChanged.length .to.be.above 50
    pragueMuniIds = councilToMunicipalityAssoc[554782]
    for pragueMuniId in pragueMuniIds
      expect munisChanged .to.contain pragueMuniId

  it 'should save Magistrate to all Prague munis' (done) ->
    muniIds = councilToMunicipalityAssoc[554782]
    counter = 0
    <~ async.each muniIds, (muniId, cb) ->
      counter++
      (err, data) <~ redisClient.hget "results:#muniId" "obec"
      data = JSON.parse data
      expect data.kod .to.be 554782
      expect data .to.have.property \obvody
      expect data.obvody .to.have.length 7
      cb!
    expect counter .to.be muniIds.length
    done!

  it 'should save City Council to correct Munis' (done) ->
    (err, data) <~ redisClient.hget "results:500054" "mcmo"
    data = JSON.parse data
    expect data.kod .to.be 500054
    expect data.obvody .to.have.length 1
    expect data.obvody.0.strany.0 .to.have.property \zastupitelu 5
    done!
