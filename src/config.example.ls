module.exports =
  redis:
    host: '172.16.10.2'
    key: ''
    port: 6379
    db: 6
  azure:
    storage_name: "smzkomunalky"
    storage_key: "---=="
    container_name: "vysledky"
  downloader:
    addr:
      komunalky: \http://www.volby.cz/pls/kv2010
      senat: \http://www.volby.cz/pls/senat
    datum_voleb: \20101015
