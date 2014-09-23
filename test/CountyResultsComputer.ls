require! {
  fs
  xml2js
  expect: 'expect.js'
  "../src/CountyResultsComputer.ls"
  # fs
}

describe 'CountyResultsComputer' (_) ->
  xml_secteno = null
  xml_pred    = null
  before (done) ->
    txt_secteno = fs.readFileSync "#__dirname/data/CZ0100.xml" .toString!
    txt_pred    = txt_secteno.replace /<ZASTUPITEL(.)*\/>/g ''
    (err, xml) <~ xml2js.parseString txt_secteno
    xml_secteno := xml
    (err, xml) <~ xml2js.parseString txt_pred
    xml_pred := xml
    done!


  it 'should return party stats for counties' (done) ->
    counties = CountyResultsComputer.computeCountyResults xml_pred
    expect counties .to.have.length 58
    expect counties.0 .to.have.property \obvody
    expect counties.0.obvody .to.have.length 7
    expect counties.0.obvody.0 .to.have.property \strany
    expect counties.0.obvody.0.strany .to.have.length 17
    expect counties.0.obvody.0.strany.0 .to.have.property \id 7
    expect counties.0.obvody.0.strany.0 .to.have.property \zastupitelu 2

    expect counties.1.obvody .to.have.length 1
    expect counties.1.obvody.0.strany .to.have.length 12
    expect counties.1.obvody.0.strany.0 .to.have.property \zastupitelu 5
    done!


  it 'should return complete candidate stats for counties' (done) ->
    counties = CountyResultsComputer.computeCountyResults xml_secteno
    expect counties .to.have.length 58
    expect counties.0 .to.have.property \obvody
    expect counties.0 .to.have.property \okrsky_spocteny 1130
    expect counties.0.obvody .to.have.length 7
    expect counties.0.obvody.0 .to.have.property \okrsky_spocteny 162
    expect counties.0.obvody.0 .to.have.property \strany
    expect counties.0.obvody.0.strany .to.have.length 17
    expect counties.0.obvody.0.strany.0 .to.have.property \zastupitele
    expect counties.0.obvody.0.strany.0.zastupitele .to.have.length 2
    expect counties.0.obvody.0.strany.0.zastupitele.0 .to.have.property \prijmeni \Dienstbier
    # fs.writeFileSync do
    #   "#__dirname/data/computeCountyResults.json"
    #   JSON.stringify counties, 1, 2
    done!
