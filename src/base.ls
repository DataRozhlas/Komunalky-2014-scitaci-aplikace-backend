require! {
  "./VolbyDownloader"
  "./config"
}
downloader = new VolbyDownloader config.downloader
downloader.start!
