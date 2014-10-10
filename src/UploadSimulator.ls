require! fs
module.exports = class UploadSimulator
  upload: (muniId, data, cb) ->
    json = JSON.stringify data
    <~ fs.writeFile "#__dirname/../data/output_formatted/#muniId.json", json
    cb!
