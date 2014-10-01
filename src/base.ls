require! {
  "./VolbyDownloader"
  "./DownloadSimulator"
  "./config"
}
# downloader = new VolbyDownloader config.downloader
downloader = new DownloadSimulator
downloader.start!
