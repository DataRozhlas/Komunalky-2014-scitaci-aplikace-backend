require! fs
lines = fs.readFileSync "#__dirname/../data/kvrzcoco.csv" .toString!split "\n"
  ..shift!
assoc = {}
for line in lines
  [kraj, okres, typzastup, druhzastup, kodzastup, nazevzast, obec] = line.split "\t"
  if obec != kodzastup
    obec = parseInt obec, 10
    assoc[kodzastup] ?= []
    if obec not in assoc[kodzastup]
      assoc[kodzastup].push obec
    console.log line
    # process.exit!
fs.writeFile do
  "#__dirname/../data/kod-zastup-to-obec.json"
  JSON.stringify assoc, 1, 2
