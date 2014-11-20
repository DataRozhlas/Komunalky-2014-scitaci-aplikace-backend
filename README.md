# Backend sčítací aplikace komunálních voleb

Celá aplikace na webu rozhlasu: [Průběžné / celkové výsledky voleb 2014](http://www.rozhlas.cz/zpravy/volby2014_vysledky/)

> Projekt [datové rubriky Českého rozhlasu](http://www.rozhlas.cz/zpravy/data/). Uvolněno pod [MIT licencí](http://opensource.org/licenses/MIT).

Backend přepočítával XML ze stránek [ČSÚ](http://volby.cz) na výsledkové JSONy pro jednotlivé obce. Zároveň přepočtem (D'Hondtovou metodou)[https://github.com/economia/DHondt] předpovídá budoucí složení zastupitelstva.

Backend je součástí sady aplikací pro realtime zobrazování výsledků:

* [Frontend](https://github.com/rozhlas/Komunalky-2014-scitaci-aplikace-frontend)
* [Backend - přepočítávač výsledkových XML](https://github.com/rozhlas/Komunalky-2014-scitaci-aplikace-backend)
* [Realtime updater](https://github.com/rozhlas/Komunalky-2014-scitaci-aplikace-updater)

Podrobnější informace o architektuře: [Blog Samizdat.cz](https://samizdat.cz/blog/?p=74)

## Instalace

    npm install -g LiveScript@1.2.0
    npm install
    slake deploy
    node lib/base.js
