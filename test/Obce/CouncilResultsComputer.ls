require! {
  fs
  xml2js
  expect: 'expect.js'
  "../../src/Obce/CouncilResultsComputer.ls"
}

describe 'CouncilResultsComputer' (_) ->
  xml_secteno = null
  xml_pred    = null
  before (done) ->
    txt_secteno = fs.readFileSync "#__dirname/../data/CZ0100.xml" .toString!
    txt_pred    = txt_secteno.replace /<ZASTUPITEL(.)*\/>/g ''
    (err, xml) <~ xml2js.parseString txt_secteno
    xml_secteno := xml
    (err, xml) <~ xml2js.parseString txt_pred
    xml_pred := xml
    done!


  it 'should return party stats for councils' (done) ->
    councils = CouncilResultsComputer.computeCouncilResults xml_pred
    expect councils .to.have.length 58
    expect councils.0 .to.have.property \obvody
    expect councils.0.obvody .to.have.length 7
    expect councils.0.obvody.0 .to.have.property \strany
    expect councils.0.obvody.0.strany .to.have.length 17
    expect councils.0.obvody.0.strany.0 .to.have.property \id 7
    expect councils.0.obvody.0.strany.0 .to.have.property \nazev "Česká strana sociálně demokratická"
    expect councils.0.obvody.0.strany.0 .to.have.property \zastupitelu 2

    expect councils.1.obvody .to.have.length 1
    expect councils.1.obvody.0.strany .to.have.length 12
    expect councils.1.obvody.0.strany.0 .to.have.property \zastupitelu 5
    done!


  it 'should return complete candidate stats for councils' (done) ->
    councils = CouncilResultsComputer.computeCouncilResults xml_secteno
    expect councils .to.have.length 58
    expect councils.0 .to.have.property \obvody
    expect councils.0 .to.have.property \okrsky_spocteno 1130
    expect councils.0.obvody .to.have.length 7
    expect councils.0.obvody.0 .to.have.property \okrsky_spocteno 162
    expect councils.0.obvody.0 .to.have.property \strany
    expect councils.0.obvody.0.strany .to.have.length 17
    expect councils.0.obvody.0.strany.0 .to.have.property \zastupitele
    expect councils.0.obvody.0.strany.0.zastupitele .to.have.length 2
    expect councils.0.obvody.0.strany.0.zastupitele.0 .to.have.property \prijmeni \Dienstbier
    for council in councils
      for obvod, index in council.obvody
        for strana in obvod.strany
          expect (strana.zastupitele?length || 0) .to.equal strana.zastupitelu
    # fs.writeFileSync do
    #   "#__dirname/data/computeCouncilResults.json"
    #   JSON.stringify councils, 1, 2
    done!
