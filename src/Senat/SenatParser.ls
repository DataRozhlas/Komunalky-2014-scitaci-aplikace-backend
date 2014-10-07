module.exports.parse = (config, xml) ->
  try
    {kolo} = config
    koloStr = kolo.toString!
    out = {}
    root = xml.VYSLEDKY
    injectStats out, root.CELKEM.0, koloStr
    out.obvody = {}
    root.OBVOD?forEach (obvod) ->
      out.obvody[obvod.$.CISLO] = obvOut = {}
      injectStats obvOut, obvod, koloStr
      obvOut.kandidati = obvod.KANDIDAT.map (kandidat) ->
        id: parseInt kandidat.$.PORADOVE_CISLO, 10
        hlasu: parseInt kandidat.$.["HLASY_#{koloStr}KOLO"], 10
    out
  catch e
    console.error "Trouble parsing Senat XML" e
    null

injectStats = (out, elm, koloStr) ->
  ucastElm = getUcast elm, koloStr
  out.volicu = parseInt ucastElm.$.ZAPSANI_VOLICI, 10
  out.volilo = parseInt ucastElm.$.VYDANE_OBALKY, 10
  out.okrsky_celkem = parseInt ucastElm.$.OKRSKY_CELKEM, 10
  out.okrsky_spocteno = parseInt ucastElm.$.OKRSKY_ZPRAC, 10
  out

getUcast = (elm, kolo) ->
  elm.UCAST
    .filter -> it.$.KOLO == kolo
    .pop!
