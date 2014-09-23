require! {
  dhondt
}
module.exports.computeCountyResults = (xml) ->
  xml.VYSLEDKY_OBCE_OKRES.OBEC.map (obec) ->
    obecOut =
      kod: parseInt obec.$.KODZASTUP, 10
      typ: obec.$.OZNAC_TYPU.toLowerCase!
      voleno: parseInt obec.$.VOLENO_ZASTUP, 10
    if obec.VYSLEDEK?length
      obecOut.volicu          = parseInt obec.VYSLEDEK.0.UCAST.0.$.ZAPSANI_VOLICI,   10
      obecOut.volilo          = parseInt obec.VYSLEDEK.0.UCAST.0.$.ODEVZDANE_OBALKY, 10
      obecOut.okrsky_celkem   = parseInt obec.VYSLEDEK.0.UCAST.0.$.OKRSKY_CELKEM,    10
      obecOut.okrsky_spocteny = parseInt obec.VYSLEDEK.0.UCAST.0.$.OKRSKY_ZPRAC,     10
      obecOut.obvody = (obec.OBVOD || [obec]).map (obvod) ->
        obvodOut =
          voleno: parseInt obvod.$.VOLENO_ZASTUP, 10
        if obvod.VYSLEDEK.0.VOLEBNI_STRANA
          obvodOut.volicu          = parseInt obvod.VYSLEDEK.0.UCAST.0.$.ZAPSANI_VOLICI,   10
          obvodOut.volilo          = parseInt obvod.VYSLEDEK.0.UCAST.0.$.ODEVZDANE_OBALKY, 10
          obvodOut.okrsky_celkem   = parseInt obvod.VYSLEDEK.0.UCAST.0.$.OKRSKY_CELKEM,    10
          obvodOut.okrsky_spocteny = parseInt obvod.VYSLEDEK.0.UCAST.0.$.OKRSKY_ZPRAC,     10
          obvodOut.strany = obvod.VYSLEDEK.0.VOLEBNI_STRANA.map (strana) ->
            stranaOut =
              nazev: strana.$.NAZEV_STRANY
              hlasu: parseInt strana.$.HLASY, 10
            if strana.ZASTUPITEL?length
              stranaOut.zastupitele = strana.ZASTUPITEL.map ({$})->
                jmeno: $.JMENO
                prijmeni: $.PRIJMENI
                hlasu: parseInt $.HLASY, 10
            stranaOut
          dhondt.compute do
            * obvodOut.strany
            * obvodOut.voleno
            * voteAccessor   : (.hlasu)
              resultProperty : "zastupitelu"
          obvodOut
    obecOut
