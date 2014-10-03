require! {
  fs
  xml2js
  expect: 'expect.js'
  "../../src/obce/ObceResultParser.ls"
}

describe 'ObceResultParser' (_) ->
  xml = null
  out = null

  before (done) ->
    data = fs.readFileSync "#__dirname/../data/vysledky.xml" .toString!
    (err, _xml) <~ xml2js.parseString data
    xml := _xml
    done!

  it 'should reformat the XML' ->
    out := ObceResultParser.parse xml
    expect out .to.be.an \object
    expect out .to.have.property \strany
    expect out .to.have.property \volicu 1807145 + 8408941
    expect out .to.have.property \volilo 756074 + 4078052
    expect out .to.have.property \okrsky_celkem 14765 + 2183
    expect out .to.have.property \okrsky_spocteno 14765 + 2183

  it 'should compute parties' ->
    expect out.strany .to.be.an \array
    expect out.strany.0 .to.have.property \id 1
    expect out.strany.0 .to.have.property \nazev "Křesťanská a demokratická unie - Československá strana lidová"
    expect out.strany.0 .to.have.property \hlasu 4305663 + 633297
    expect out.strany.0 .to.have.property \zastupitelu 3643 + 95

  # it '-- save data --' (done) ->
  #   <~ fs.writeFile "#__dirname/../data/computeObceResults.json", JSON.stringify out, 1, 2
  #   done!
