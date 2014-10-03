require! {
  "./VolbyDownloader"
  "./DownloadSimulator"
  "./config"
  redis
  http

  "./Obce/CouncilResultsComputer"
  "./Obce/CouncilUpdateDetector"
  "./Obce/CouncilToMunicipality"
  "./Obce/MunicipalityCombiner"
  "./Obce/MunicipalityRedisNotifier"

  "./Senat/SenatParser"

  "./ResultsUpdateDetector"
  "./ResultsNotifier"
  "./Uploader"
}

http.globalAgent.maxSockets = 100
console.log "Starting"
redisClient = redis.createClient config.redis.port, config.redis.host
(err) <~ redisClient.auth config.redis.key
# <~ redisClient.flushdb!
if err
  console.error err
  process.exit!
console.log "Redis connected & authenticated"
municipalityCombiner = new MunicipalityCombiner redisClient
downloader = new VolbyDownloader config.downloader
# downloader = new DownloadSimulator
uploader = new Uploader config.azure
downloader
  ..start!
  ..on \senat-vysledky (xml, data, index) ->
    results = SenatParser.parse config.senat, xml
    (err, isUpdated) <~ ResultsUpdateDetector.isUpdated redisClient, "senat", results
    if not isUpdated
      console.log "Senat not updated"
      return
    console.log "Senat updated"
    <~ uploader.upload "senat", results
    ResultsNotifier.update redisClient, "senat", results
    ResultsNotifier.notify redisClient, "senat"

  ..on \komunalky-obec (xml, data, index) ->
    councils = CouncilResultsComputer.computeCouncilResults xml
    (err, updatedCouncils) <~ CouncilUpdateDetector.filterUpdated redisClient, councils
    return console.error err if err
    (err, munisChanged) <~ CouncilToMunicipality.save redisClient, updatedCouncils
    return console.error err if err
    console.log "#index: downloaded #{councils.length} councils, #{updatedCouncils.length} updated, #{munisChanged.length} municipalities"
    municipalityCombiner.update munisChanged


municipalityCombiner.on \municipality (muniId, outputData, allData) ->
  <~ uploader.upload muniId, outputData
  MunicipalityRedisNotifier.update redisClient, allData
  MunicipalityRedisNotifier.notify redisClient, muniId
