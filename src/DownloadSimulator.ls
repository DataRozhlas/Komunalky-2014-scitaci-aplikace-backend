require! {
  fs
  moment
  xml2js
  events.EventEmitter
}

module.exports = class DownloadSimulator extends EventEmitter
  ->
    @currentOffset = 0
    @interval = 1000
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
    records = @offsets[@currentOffset]
    @currentOffset++
    return if not records
    records.forEach ({name}) ~>
      noDate = name.substr 20
      [type, subtype, obec] = noDate.split '-'
      (err, content) <~ fs.readFile "#__dirname/../data/output/#name"
      (err, xml) <~ xml2js.parseString content
      console.log 'emitting' type, subtype
      @emit do
        [type, subtype].join '-'
        xml

