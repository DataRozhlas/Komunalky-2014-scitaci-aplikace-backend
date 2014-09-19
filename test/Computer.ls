require! {
  fs
  expect: 'expect.js'
  "../src/Computer.ls"
}

describe 'Computer' (_) ->
  data_secteno = fs.readFileSync "#__dirname/data/CZ0202.xml" .toString!
  data_pred = data_secteno.replace /<ZASTUPITEL(.)*\/>/g ''
  it 'should return party stats for counties' (done) ->
    (err, result) <~ Computer.compute data_pred
    expect result .to.have.property \counties
    counties = result.counties
    expect counties .to.have.length 85
    expect counties.0 .to.have.property \strany
    expect counties.0.strany .to.have.length 2
    expect counties.0.strany.0 .to.have.property \zastupitelu 3
    done!
  it 'should return complete candidate stats for counties' (done) ->
    (err, result) <~ Computer.compute data_secteno
    expect result .to.have.property \counties
    counties = result.counties
    expect counties .to.have.length 85
    expect counties.0 .to.have.property \strany
    expect counties.0.strany.0 .to.have.property \zastupitele
    expect counties.0.strany.0.zastupitele .to.have.length 3
    expect counties.0.strany.0.zastupitele.0 .to.have.property \jmeno \Josef
    done!
