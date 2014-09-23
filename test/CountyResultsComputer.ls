require! {
  fs
  xml2js
  expect: 'expect.js'
  "../src/CountyResultsComputer.ls"
}

describe 'CountyResultsComputer' (_) ->
  xml_secteno = null
  xml_pred    = null
  before (done) ->
    txt_secteno = fs.readFileSync "#__dirname/data/CZ0202.xml" .toString!
    txt_pred    = txt_secteno.replace /<ZASTUPITEL(.)*\/>/g ''
    (err, xml) <~ xml2js.parseString txt_secteno
    xml_secteno := xml
    (err, xml) <~ xml2js.parseString txt_pred
    xml_pred := xml
    done!

  it 'should return party stats for counties' (done) ->
    counties = CountyResultsComputer.computeCountyResults xml_pred
    expect counties .to.have.length 85
    expect counties.0 .to.have.property \strany
    expect counties.0.strany .to.have.length 2
    expect counties.0.strany.0 .to.have.property \zastupitelu 3
    done!

  it 'should return complete candidate stats for counties' (done) ->
    counties = CountyResultsComputer.computeCountyResults xml_secteno
    expect counties .to.have.length 85
    expect counties.0 .to.have.property \strany
    expect counties.0.strany.0 .to.have.property \zastupitele
    expect counties.0.strany.0.zastupitele .to.have.length 3
    expect counties.0.strany.0.zastupitele.0 .to.have.property \jmeno \Josef
    done!
