require! {
  dhondt
  xml2js
}
module.exports.compute = (data, cb) ->
  (err, xml) <~ xml2js.parseString data
  counties = xml.VYSLEDKY_OBCE_OKRES.OBEC.map (obec) ->
    out =
      kod: parseInt obec.$.KODZASTUP, 10
      voleno: parseInt obec.$.VOLENO_ZASTUP, 10
    if obec.VYSLEDEK?length
      out.volicu: parseInt obec.VYSLEDEK.0.UCAST.0.$.ZAPSANI_VOLICI, 10
      out.volilo: parseInt obec.VYSLEDEK.0.UCAST.0.$.ODEVZDANE_OBALKY, 10
      out.okrsky_celkem: parseInt obec.VYSLEDEK.0.UCAST.0.$.OKRSKY_CELKEM, 10
      out.okrsky_spocteny: parseInt obec.VYSLEDEK.0.UCAST.0.$.OKRSKY_ZPRAC, 10
      if obec.VYSLEDEK.0.VOLEBNI_STRANA?length
        out.strany = obec.VYSLEDEK.0.VOLEBNI_STRANA.map ->
          out =
            nazev: it.$.NAZEV_STRANY
            hlasu: parseInt it.$.HLASY, 10
          if it.ZASTUPITEL?length
            out.zastupitele = it.ZASTUPITEL.map ({$})->
              jmeno: $.JMENO
              prijmeni: $.PRIJMENI
              hlasu: parseInt $.HLASY, 10
          out
        dhondt.compute do
          * out.strany
          * out.voleno
          * voteAccessor   : (.hlasu)
            resultProperty : "zastupitelu"
    out
  cb null, {counties}
