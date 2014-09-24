require! {
  azure: "azure-storage"
  events.EventEmitter
  zlib
  streamifier
}
module.exports = class Uploader extends EventEmitter
  (@config) ->
    @blobService = azure.createBlobService do
      @config.storage_name
      @config.storage_key
    @blobOptions =
      contentEncoding: \gzip
      contentType: \application/json


  upload: (muniId, data, cb) ->
    json = JSON.stringify data
    (err, compressed) <~ zlib.gzip json
    stream = streamifier.createReadStream compressed
    (err) <~ @blobService.createBlockBlobFromStream do
      @config.container_name
      "#muniId.json"
      stream
      compressed.length
      @blobOptions
    @emit \uploaded muniId
    cb? err


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
