DROP TRIGGER IF EXISTS tr_apskaiciuoti_uzsakymo_suma ON uzsakymo_eilute;
DROP TRIGGER IF EXISTS tr_atnaujinti_sandelio_kieki ON uzsakymo_eilute;
DROP TRIGGER IF EXISTS tr_tikrinti_uzsakymo_busena ON uzsakymas;
DROP TRIGGER IF EXISTS tr_atnaujinti_atsiliepimo_data ON atsiliepimas;

DROP FUNCTION IF EXISTS f_apskaiciuoti_uzsakymo_suma();
DROP FUNCTION IF EXISTS f_atnaujinti_sandelio_kieki();
DROP FUNCTION IF EXISTS f_tikrinti_uzsakymo_busena();
DROP FUNCTION IF EXISTS f_atnaujinti_atsiliepimo_data();

DROP MATERIALIZED VIEW IF EXISTS mv_kategoriju_statistika;
DROP MATERIALIZED VIEW IF EXISTS mv_tiekeju_statistika;
DROP VIEW IF EXISTS v_klientu_uzsakymai;
DROP VIEW IF EXISTS v_detaliu_busena;
DROP VIEW IF EXISTS v_uzsakymu_detales;
DROP VIEW IF EXISTS v_tiekeju_detales;

DROP INDEX IF EXISTS idx_detale_kodas;
DROP INDEX IF EXISTS idx_tiekejas_sutartis;
DROP INDEX IF EXISTS idx_uzsakymas_busena;
DROP INDEX IF EXISTS idx_detale_kategorija_kaina;

DROP TABLE IF EXISTS atsiliepimas CASCADE;
DROP TABLE IF EXISTS detale_tiekejas CASCADE;
DROP TABLE IF EXISTS uzsakymo_eilute CASCADE;
DROP TABLE IF EXISTS uzsakymas CASCADE;
DROP TABLE IF EXISTS detale CASCADE;
DROP TABLE IF EXISTS kategorija CASCADE;
DROP TABLE IF EXISTS tiekejas CASCADE;
DROP TABLE IF EXISTS klientas CASCADE;