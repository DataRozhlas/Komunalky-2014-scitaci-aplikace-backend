require! {
  fs
  xml2js
  expect: 'expect.js'
  "../../src/Senat/SenatParser.ls"
}

describe 'SenatParser' (_) ->
  xml = null
  out = null

  before (done) ->
    data = fs.readFileSync "#__dirname/../data/senat.xml" .toString!
    (err, _xml) <~ xml2js.parseString data
    xml := _xml
    done!

  it 'should reformat the XML' ->
    out := SenatParser.parse kolo: 1, xml
    expect out .to.be.an \object
    expect out .to.have.property \obvody
    expect out .to.have.property \volicu 2774178
    expect out .to.have.property \volilo 1237072
    expect out .to.have.property \okrsky_celkem 4860
    expect out .to.have.property \okrsky_spocteno 4860

  it 'should correctly compute Obvody' ->
    {obvody} = out
    expect obvody .to.be.an \object
    expect obvody .to.only.have.keys <[1 4 7 10 13 16 19 22 25 28 31 34 37 40 43 46 49 52 55 58 61 64 67 70 73 76 79]>
    expect obvody["1"] .to.have.property \volicu 90828
    expect obvody["1"] .to.have.property \volilo 35992
    expect obvody["1"] .to.have.property \okrsky_celkem 137
    expect obvody["1"] .to.have.property \okrsky_spocteno 137
    kandidati = obvody["1"].kandidati
    expect kandidati .to.have.length 10
    expect kandidati.0 .to.have.property \id 1
    expect kandidati.0 .to.have.property \hlasu 1746

  # it '-- save data --' (done) ->
  #   <~ fs.writeFile "#__dirname/../data/computeSenatResults.json", JSON.stringify out, 1, 2
  #   done!

  it 'should get correct values for 2nd round' ->
    out := SenatParser.parse kolo: 2, xml
    expect out.obvody['1'].kandidati .to.have.length 2
    expect out .to.have.property \volicu 2774982
    expect out .to.have.property \volilo 683705
