require! {
  fs
  moment
  xml2js
  events.EventEmitter
}

module.exports = class DownloadSimulator extends EventEmitter
  ->
    @currentOffset = 1873
    @interval = 100
    (err, files) <~ fs.readdir "#__dirname/../data/output"
    files .= filter -> it[0] != '.'
    records = files.map ->
      time = moment it, "YYYY-MM-DD-HH-mm-ss"
      name: it
      date: time.format "HH:mm:ss"
      time: parseInt time.format "X", 10
    records.sort (a, b) -> a.time - b.time
    firstTime = records[0].time
    @offsets = []
    records.forEach ~>
      offset = it.time - firstTime
      @offsets[offset] ?= []
        ..push it

  start: ->
    setTimeout @~loadNext, 20
    setInterval @~loadNext, @interval

  loadNext: ->
    @currentOffset %= @offsets.length
    records = @offsets[@currentOffset]
    @currentOffset++
    return if not records
    records.forEach ({name}) ~>
      noDate = name.substr 20
      [type, subtype, obec] = noDate.split '-'
      (err, content) <~ fs.readFile "#__dirname/../data/output/#name"
      (err, xml) <~ xml2js.parseString content
      # console.log name
      @emit do
        [type, subtype].join '-'
        xml
        null
        @currentOffset

