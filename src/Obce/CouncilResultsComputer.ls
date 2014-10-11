require! {
  dhondt
}
module.exports.computeCouncilResults = (xml) ->
  xml.VYSLEDKY_OBCE_OKRES.OBEC.map (obec) ->
    obecOut =
      kod: parseInt obec.$.KODZASTUP, 10
      typ: obec.$.OZNAC_TYPU.toLowerCase!
      voleno: parseInt obec.$.VOLENO_ZASTUP, 10
    if obec.VYSLEDEK?length
      obecOut.volicu          = parseInt obec.VYSLEDEK.0.UCAST.0.$.ZAPSANI_VOLICI,   10
      obecOut.volilo          = parseInt obec.VYSLEDEK.0.UCAST.0.$.ODEVZDANE_OBALKY, 10
      obecOut.okrsky_celkem   = parseInt obec.VYSLEDEK.0.UCAST.0.$.OKRSKY_CELKEM,    10
      obecOut.okrsky_spocteno = parseInt obec.VYSLEDEK.0.UCAST.0.$.OKRSKY_ZPRAC,     10
      obecOut.obvody = (obec.OBVOD || [obec]).map (obvod) ->
        obvodOut =
          voleno: parseInt obvod.$.VOLENO_ZASTUP, 10
        if obvod.VYSLEDEK.0.VOLEBNI_STRANA
          obvodOut.volicu          = parseInt obvod.VYSLEDEK.0.UCAST.0.$.ZAPSANI_VOLICI,   10
          obvodOut.volilo          = parseInt obvod.VYSLEDEK.0.UCAST.0.$.ODEVZDANE_OBALKY, 10
          obvodOut.okrsky_celkem   = parseInt obvod.VYSLEDEK.0.UCAST.0.$.OKRSKY_CELKEM,    10
          obvodOut.okrsky_spocteno = parseInt obvod.VYSLEDEK.0.UCAST.0.$.OKRSKY_ZPRAC,     10
          obvodOut.hlasu           = parseInt obvod.VYSLEDEK.0.UCAST.0.$.PLATNE_HLASY,     10
          quora = []
          obvodOut.strany = obvod.VYSLEDEK.0.VOLEBNI_STRANA.map (strana) ->
            stranaOut =
              id: parseInt strana.$.VSTRANA
              nazev: strana.$.NAZEV_STRANY
              hlasu: parseInt strana.$.HLASY, 10
              zastupitelu: 0
            quora.push obvodOut.hlasu * 0.05 / obvodOut.voleno * (parseInt strana.$.KANDIDATU_POCET, 10)
            if strana.ZASTUPITEL?length
              stranaOut.zastupitele = strana.ZASTUPITEL.map ({$})->
                jmeno: $.JMENO
                prijmeni: $.PRIJMENI
                hlasu: parseInt $.HLASY, 10
            stranaOut
          if obvodOut.okrsky_spocteno
            try
              dhondt.compute do
                * obvodOut.strany.filter (d, i) -> d.hlasu >= quora[i]
                * obvodOut.voleno
                * voteAccessor   : (.hlasu)
                  resultProperty : "zastupitelu"
          obvodOut
    obecOut
