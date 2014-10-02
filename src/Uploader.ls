require! {
  azure: "azure-storage"
  zlib
  streamifier
}
module.exports = class Uploader
  parallelLimit: 30
  (@config) ->
    @blobService = azure.createBlobService do
      @config.storage_name
      @config.storage_key
    @blobOptions =
      contentEncoding: \gzip
      contentType: \application/json
    @running = 0
    @queue = []
    @queueAssoc = {}
    @uploadCounter = 0
    @lastReport = 0
    setInterval @~report, 1000

  upload: (muniId, data, cb) ->
    # console.log muniId
    json = JSON.stringify data
    if @queueAssoc[muniId] != void
      # console.log "Updated #muniId"
      @queueAssoc[muniId][1] = json
      @queueAssoc[muniId][2] = cb
    else
      queueObj = [muniId, json, cb]
      len = @queue.push queueObj
      @queueAssoc[muniId] = queueObj
    @uploadNext! if @running < @parallelLimit

  uploadNext: ->
    return if not @queue.length
    ++@running
    [muniId, json, cb] = @queue.shift!
    @queueAssoc[muniId] = void
    (err, compressed) <~ zlib.gzip json
    stream = streamifier.createReadStream compressed
    (err) <~ @blobService.createBlockBlobFromStream do
      @config.container_name
      "#muniId.json"
      stream
      compressed.length
      @blobOptions
    @uploadCounter++
    cb? err
    --@running
    @uploadNext!

  report: ->
    len = @queue.length
    if @queue.length
      console.log "Uploader queuing #{len} at #{@running} threads, #{@uploadCounter} uploaded, #{len - @lastReport}"
    @lastReport = len

  setCors: (cb) ->
    serviceProperties = {}
    serviceProperties.Cors = {
      CorsRule: [{
        AllowedOrigins: ['*']
        AllowedMethods: ['GET']
        AllowedHeaders: []
        ExposedHeaders: []
        MaxAgeInSeconds: 60
      }]
    }
    (err, result) <~ @blobService.setServiceProperties serviceProperties
    cb err
