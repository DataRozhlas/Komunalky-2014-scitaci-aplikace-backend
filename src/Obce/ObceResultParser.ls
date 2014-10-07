module.exports.parse = (xml) ->
  out = {}
  ucast1              = xml.VYSLEDKY.TYP_ZASTUP.0.UCAST.0
  ucast2              = xml.VYSLEDKY.TYP_ZASTUP.1.UCAST.0
  out.volicu          = (parseInt ucast1.$.ZAPSANI_VOLICI, 10) + (parseInt ucast2.$.ZAPSANI_VOLICI, 10)
  out.volilo          = (parseInt ucast1.$.VYDANE_OBALKY,  10) + (parseInt ucast2.$.VYDANE_OBALKY,  10)
  out.hlasu           = (parseInt ucast1.$.PLATNE_HLASY,   10) + (parseInt ucast2.$.PLATNE_HLASY,   10)
  out.okrsky_celkem   = (parseInt ucast1.$.OKRSKY_CELKEM,  10) + (parseInt ucast2.$.OKRSKY_CELKEM,  10)
  out.okrsky_spocteno = (parseInt ucast1.$.OKRSKY_ZPRAC,   10) + (parseInt ucast2.$.OKRSKY_ZPRAC,   10)
  strany_assoc = {}
  xml.VYSLEDKY.TYP_ZASTUP.0.VOLEBNI_STRANA ?= []
  xml.VYSLEDKY.TYP_ZASTUP.1.VOLEBNI_STRANA ?= []
  all = xml.VYSLEDKY.TYP_ZASTUP.0.VOLEBNI_STRANA ++ xml.VYSLEDKY.TYP_ZASTUP.1.VOLEBNI_STRANA
  all.forEach (data) ->
    strany_assoc[data.$.VSTRANA] ?=
      hlasu: 0
      zastupitelu: 0
      nazev: data.$.NAZEV_STRANY
      id: parseInt data.$.VSTRANA, 10
    strana             = strany_assoc[data.$.VSTRANA]
    strana.hlasu       += parseInt data.$.HLASY, 10
    strana.zastupitelu += parseInt data.$.ZASTUPITELE_POCET, 10

  out.strany = for id, strana of strany_assoc
    strana
  out
