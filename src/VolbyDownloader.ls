require! {
  async
  iconv.Iconv
  xml2js
  request
  moment
  fs
  events.EventEmitter
  './okresy'
}
iconv = new Iconv 'iso-8859-2' 'utf-8'
module.exports = class VolbyDowloader extends EventEmitter
  minimumInterval: 10
  (@config) ->
    @sources =
      * url: "#{@config.addr.komunalky}/vysledky?datumvoleb=#{@config.datum_voleb}"
        interval: 60
        type: \komunalky-vysledky
        short: \komunalky-vysledky
      * url: "#{@config.addr.senat}/vysledky?datum_voleb=#{@config.datum_voleb}"
        interval: 60
        type: \senat-vysledky
        short: \senat-vysledky

    okresy.forEach ~>
      @sources.push do
        url: "#{@config.addr.komunalky}/vysledky_obce_okres?datumvoleb=#{@config.datum_voleb}&nuts=#{it}"
        interval: 60
        type: \komunalky-obec
        short: "komunalky-obec-#{it}"

  start: ->
    @sources.forEach (source, index) ~>
      @downloadSourceIn source, index

  downloadSource: (source) ->
    opts =
      uri: source.url
      encoding: null
    (err, response, body) <~ request.get opts
    console.log "Downloaded #{source.short}"
    if err or not body.length
      if err
        console.error "Error downloading #{opts.uri}", err
      else
        console.error "Error downloading #{opts.uri}: zero content length"
      @downloadSourceIn source, 15
      return
    data = iconv.convert body
    (err, xml) <~ xml2js.parseString data
    try
      throw err if err
      root = null
      for rootName, rootContent of xml
        root = rootContent

      date = root.$.DATUM_GENEROVANI
      time = root.$.CAS_GENEROVANI
      generated = moment do
        date + " " + time + " +0200"
        "DD/MM/YYYY HH:mm:ss Z"
      difference = Date.now! - generated.valueOf!
      difference /= 1000
      difference = Math.floor difference
      interval = source.interval - difference
      if interval < @minimumInterval then interval = @minimumInterval
      niceTime = moment!format "YYYY-MM-DD-HH-mm-ss"
      @downloadSourceIn source, interval + 2
      console.log "Parsed #{source.short}. Next download in #{interval + 2}"
      @emit do
        source.type
        xml
        data
      fs.writeFile "#__dirname/../data/output/#{niceTime}-#{source.short}", data

    catch ex
      console.error "Error parsing #{opts.uri}", ex
      @downloadSourceIn source, 15

  downloadSourceIn: (source, seconds) ->
    fn = ~> @downloadSource source
    setTimeout fn, seconds * 1e3
