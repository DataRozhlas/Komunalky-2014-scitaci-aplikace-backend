require! {
  fs
}

lines = fs.readFileSync "#__dirname/../data/senat_obvody.csv"
  .toString!
  .split "\n"
  .map (.split ';')
lines.shift!
out = {}
for [_, _, _, obec, _, obvod] in lines
  obvod = parseInt obvod, 10
  obec = parseInt obec, 10
  out[obvod] ?= []
  out[obvod].push obec
fs.writeFile "#__dirname/../data/senat-obv-to-muni.js", JSON.stringify out, 1, 2
