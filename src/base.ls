require! {
  "./VolbyDownloader"
  "./DownloadSimulator"
  "./config"
  redis
}
console.log "Starting"
redisClient = redis.createClient config.redis.port, config.redis.host
(err) <~ redisClient.auth config.redis.key
if err
  console.error err
  process.exit!
console.log "Redis connected & authenticated"
downloader = new VolbyDownloader config.downloader
# downloader = new DownloadSimulator
downloader.start!
