\echo 'TEST 1: Blogas el. pasto formatas (turetu nepavykti)'
INSERT INTO klientas (vardas, pavarde, el_pastas) 
VALUES ('Testas', 'Testauskas', 'blogas-email');

\echo 'TEST 2: Geras el. pasto formatas (turetu pavykti)'
INSERT INTO klientas (vardas, pavarde, el_pastas) 
VALUES ('Testas', 'Testauskas', 'testas@email.lt');

DELETE FROM klientas WHERE vardas = 'Testas';

\echo 'TEST 3: Neteisinga uzsakymo busena (turetu nepavykti)'
INSERT INTO uzsakymas (klientoID, busena) 
VALUES (1, 'Netinkama_busena');

\echo 'TEST 4: Teisinga uzsakymo busena (turetu pavykti)'
INSERT INTO uzsakymas (klientoID, busena) 
VALUES (1, 'Laukiama');

DELETE FROM uzsakymas WHERE klientoID = 1 AND busena = 'Laukiama' AND bendra_suma = 0;

\echo 'TEST 5: Neigiamas kiekis sandelyje (turetu nepavykti)'
UPDATE detale SET kiekis_sandelyje = -5 WHERE detalesID = 1;

\echo 'TEST 6: Neigiama kaina (turetu nepavykti)'
INSERT INTO detale (pavadinimas, kodas, kategorijaID, kaina) 
VALUES ('Test detale', 'TEST-001', 1, -10.00);

\echo 'TEST 7: Nuline kaina (turetu nepavykti)'
INSERT INTO detale (pavadinimas, kodas, kategorijaID, kaina) 
VALUES ('Test detale', 'TEST-002', 1, 0);

\echo 'TEST 8: Ivertinimas > 5 (turetu nepavykti)'
INSERT INTO atsiliepimas (klientoID, detalesID, ivertinimas, komentaras) 
VALUES (1, 1, 6, 'Per aukstas ivertinimas');

\echo 'TEST 9: Ivertinimas < 1 (turetu nepavykti)'
INSERT INTO atsiliepimas (klientoID, detalesID, ivertinimas, komentaras) 
VALUES (1, 1, 0, 'Per zemas ivertinimas');

\echo 'TEST 10: Teisingas ivertinimas 1-5 (turetu pavykti)'
INSERT INTO atsiliepimas (klientoID, detalesID, ivertinimas, komentaras) 
VALUES (2, 2, 4, 'Normalus ivertinimas');

DELETE FROM atsiliepimas WHERE klientoID = 2 AND detalesID = 2;

\echo 'TEST 11: Pristatymo data ankstesne nei uzsakymo (turetu nepavykti)'
INSERT INTO uzsakymas (klientoID, uzsakymo_data, pristatymo_data, busena) 
VALUES (1, '2024-11-20', '2024-11-10', 'Pristatyta');

\echo 'TEST 12: Teisingos datos (turetu pavykti)'
INSERT INTO uzsakymas (klientoID, uzsakymo_data, pristatymo_data, busena) 
VALUES (1, '2024-11-10', '2024-11-20', 'Pristatyta');

DELETE FROM uzsakymas WHERE klientoID = 1 AND uzsakymo_data = '2024-11-10';

\echo 'TEST 13: Nuolaida > 100% (turetu nepavykti)'
INSERT INTO uzsakymas (klientoID, nuolaida) 
VALUES (1, 150);

\echo 'TEST 14: Neigiama nuolaida (turetu nepavykti)'
INSERT INTO uzsakymas (klientoID, nuolaida) 
VALUES (1, -10);

\echo ''
\echo '=== TESTUOJAMOS NUMATYTOSIOS REIKSMES ==='

\echo 'TEST 15: Automatine uzsakymo_data (DEFAULT CURRENT_DATE)'
INSERT INTO uzsakymas (klientoID, busena) 
VALUES (1, 'Laukiama');

SELECT uzsakymoID, uzsakymo_data, busena, bendra_suma 
FROM uzsakymas 
WHERE klientoID = 1 
ORDER BY uzsakymoID DESC 
LIMIT 1;

DELETE FROM uzsakymas WHERE klientoID = 1 AND bendra_suma = 0 AND busena = 'Laukiama';

\echo 'TEST 16: Automatine registracijos_data (DEFAULT CURRENT_DATE)'
INSERT INTO klientas (vardas, pavarde, el_pastas) 
VALUES ('Auto', 'Data', 'auto@data.lt');

SELECT klientoID, vardas, registracijos_data 
FROM klientas 
WHERE el_pastas = 'auto@data.lt';

DELETE FROM klientas WHERE el_pastas = 'auto@data.lt';

\echo 'TEST 17: Automatinis kiekis_sandelyje = 0'
INSERT INTO detale (pavadinimas, kodas, kategorijaID, kaina) 
VALUES ('Auto kiekis', 'AUTO-001', 1, 25.00);

SELECT detalesID, pavadinimas, kiekis_sandelyje 
FROM detale 
WHERE kodas = 'AUTO-001';

DELETE FROM detale WHERE kodas = 'AUTO-001';

\echo ''
\echo '=== TESTUOJAMI TRIGERIAI ==='

\echo 'TEST 18: Trigeris - automatinis uzsakymo sumos skaiciavimas'

INSERT INTO uzsakymas (klientoID, busena, nuolaida) 
VALUES (1, 'Laukiama', 10);

SELECT uzsakymoID INTO TEMP TABLE temp_uzsakymas 
FROM uzsakymas 
WHERE klientoID = 1 
ORDER BY uzsakymoID DESC 
LIMIT 1;

INSERT INTO uzsakymo_eilute (uzsakymoID, detalesID, kiekis) 
SELECT uzsakymoID, 1, 2 FROM temp_uzsakymas;

INSERT INTO uzsakymo_eilute (uzsakymoID, detalesID, kiekis) 
SELECT uzsakymoID, 2, 1 FROM temp_uzsakymas;

SELECT 
    u.uzsakymoID,
    u.bendra_suma as apskaiciuota_suma,
    u.nuolaida
FROM uzsakymas u
JOIN temp_uzsakymas t ON u.uzsakymoID = t.uzsakymoID;

DELETE FROM uzsakymo_eilute WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas);
DELETE FROM uzsakymas WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas);
DROP TABLE temp_uzsakymas;

\echo 'TEST 19: Trigeris - uzsakymo busenos kontrole'

\echo 'TEST 19a: Bandome keisti pristatyto uzsakymo busena (turetu nepavykti)'
UPDATE uzsakymas SET busena = 'Laukiama' 
WHERE uzsakymoID = 1 AND busena = 'Pristatyta';

\echo 'TEST 19b: Automatine pristatymo data, kai busena -> Pristatyta'
INSERT INTO uzsakymas (klientoID, busena) 
VALUES (1, 'Laukiama');

SELECT uzsakymoID INTO TEMP TABLE temp_uzsakymas2 
FROM uzsakymas 
WHERE klientoID = 1 
ORDER BY uzsakymoID DESC 
LIMIT 1;

UPDATE uzsakymas 
SET busena = 'Pristatyta' 
WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas2);

SELECT uzsakymoID, busena, pristatymo_data 
FROM uzsakymas 
WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas2);

DELETE FROM uzsakymas WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas2);
DROP TABLE temp_uzsakymas2;

\echo 'TEST 20: Trigeris - sandelio kiekio atnaujinimas'

SELECT kiekis_sandelyje INTO TEMP TABLE temp_kiekis 
FROM detale 
WHERE detalesID = 1;

\echo 'Pradinis kiekis sandelyje:'
SELECT * FROM temp_kiekis;

INSERT INTO uzsakymas (klientoID, busena) 
VALUES (1, 'Pristatyta');

SELECT uzsakymoID INTO TEMP TABLE temp_uzsakymas3 
FROM uzsakymas 
WHERE klientoID = 1 
ORDER BY uzsakymoID DESC 
LIMIT 1;

INSERT INTO uzsakymo_eilute (uzsakymoID, detalesID, kiekis) 
SELECT uzsakymoID, 1, 5 FROM temp_uzsakymas3;

\echo 'Kiekis sandelyje po pristatymo (turetu sumazeti 5 vienetais):'
SELECT detalesID, kiekis_sandelyje 
FROM detale 
WHERE detalesID = 1;

UPDATE detale 
SET kiekis_sandelyje = kiekis_sandelyje + 5 
WHERE detalesID = 1;

DELETE FROM uzsakymo_eilute WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas3);
DELETE FROM uzsakymas WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas3);
DROP TABLE temp_uzsakymas3;
DROP TABLE temp_kiekis;

\echo 'TEST 21: Trigeris - nepakankamos atsargos (turetu nepavykti)'

INSERT INTO uzsakymas (klientoID, busena) 
VALUES (1, 'Pristatyta');

SELECT uzsakymoID INTO TEMP TABLE temp_uzsakymas4 
FROM uzsakymas 
WHERE klientoID = 1 
ORDER BY uzsakymoID DESC 
LIMIT 1;

INSERT INTO uzsakymo_eilute (uzsakymoID, detalesID, kiekis) 
SELECT uzsakymoID, 5, 1000 FROM temp_uzsakymas4;

DELETE FROM uzsakymas WHERE uzsakymoID IN (SELECT uzsakymoID FROM temp_uzsakymas4);
DROP TABLE temp_uzsakymas4;

\echo 'TEST 22: Trigeris - atsiliepimo data ateityje (turetu nepavykti)'
INSERT INTO atsiliepimas (klientoID, detalesID, ivertinimas, komentaras, data) 
VALUES (1, 1, 5, 'Ateities atsiliepimas', '2099-12-31');

\echo ''
\echo '=== TESTUOJAMOS VIRTUALIOS LENTELES ==='

\echo 'TEST 23: View - v_klientu_uzsakymai'
SELECT * FROM v_klientu_uzsakymai ORDER BY uzsakymu_skaicius DESC LIMIT 3;

\echo 'TEST 24: View - v_detaliu_busena (Mazas kiekis)'
SELECT * FROM v_detaliu_busena WHERE busena = 'Mazas kiekis';

\echo 'TEST 25: View - v_uzsakymu_detales (uzsakymas 1)'
SELECT * FROM v_uzsakymu_detales WHERE uzsakymoID = 1;

\echo 'TEST 26: View - v_tiekeju_detales'
SELECT * FROM v_tiekeju_detales ORDER BY tiekejas, detale LIMIT 5;

\echo ''
\echo '=== TESTUOJAMA MATERIALIZUOTA LENTELE ==='

\echo 'TEST 27: Materializuota lentele PRIES atnaujinima'
SELECT * FROM mv_kategoriju_statistika ORDER BY kategorijaID;

INSERT INTO detale (pavadinimas, kodas, kategorijaID, kiekis_sandelyje, kaina) 
VALUES ('Test mat view', 'TMV-001', 1, 100, 55.00);

\echo 'Po naujos detales iterpimo (dar neatnaujinta)'
SELECT * FROM mv_kategoriju_statistika WHERE kategorijaID = 1;

REFRESH MATERIALIZED VIEW mv_kategoriju_statistika;

\echo 'PO materializuotos lenteles atnaujinimo'
SELECT * FROM mv_kategoriju_statistika WHERE kategorijaID = 1;

DELETE FROM detale WHERE kodas = 'TMV-001';
REFRESH MATERIALIZED VIEW mv_kategoriju_statistika;

\echo 'TEST 28: Materializuota lentele - tiekeju statistika'
SELECT * FROM mv_tiekeju_statistika ORDER BY tiekejoID;

\echo ''
\echo '=== TESTUOJAMI INDEKSAI ==='

\echo 'TEST 29: Unikalus indeksas (kodas) - bandome iterpti dublikata'
INSERT INTO detale (pavadinimas, kodas, kategorijaID, kaina) 
VALUES ('Dublikatas', 'OF-51515', 1, 10.00);

\echo 'TEST 30: Paieska su indeksu (busena)'
EXPLAIN SELECT * FROM uzsakymas WHERE busena = 'Laukiama';

\echo 'TEST 31: Paieska su sudetiniu indeksu (kategorija + kaina)'
EXPLAIN SELECT * FROM detale WHERE kategorijaID = 1 AND kaina < 50;

\echo ''
\echo '=== TESTUOJAMI ISORINIAI RAKTAI ==='

\echo 'TEST 32: ON DELETE CASCADE - istriname klienta'
INSERT INTO klientas (vardas, pavarde, el_pastas) 
VALUES ('Temp', 'Client', 'temp@test.lt');

SELECT klientoID INTO TEMP TABLE temp_klientas 
FROM klientas 
WHERE el_pastas = 'temp@test.lt';

INSERT INTO uzsakymas (klientoID, busena) 
SELECT klientoID, 'Laukiama' FROM temp_klientas;

\echo 'Pries kliento istryninma:'
SELECT COUNT(*) as uzsakymu_skaicius 
FROM uzsakymas u 
JOIN temp_klientas t ON u.klientoID = t.klientoID;

DELETE FROM klientas WHERE klientoID IN (SELECT klientoID FROM temp_klientas);

\echo 'Po kliento istrynimo (uzsakymai turetu buti istrinti automatiskai):'
SELECT COUNT(*) as uzsakymu_skaicius 
FROM uzsakymas u 
JOIN temp_klientas t ON u.klientoID = t.klientoID;

DROP TABLE temp_klientas;

\echo 'TEST 33: ON DELETE RESTRICT - bandome istrinti kategorija su detalemis'
DELETE FROM kategorija WHERE kategorijaID = 1;

\echo ''
\echo '=== TESTUOJAMAS AUTOMATINIS NUMERAVIMAS ==='

\echo 'TEST 34: Automatinis klientoID generavimas'
INSERT INTO klientas (vardas, pavarde, el_pastas) 
VALUES ('Auto', 'ID', 'autoid@test.lt');

SELECT klientoID, vardas 
FROM klientas 
WHERE el_pastas = 'autoid@test.lt';

DELETE FROM klientas WHERE el_pastas = 'autoid@test.lt';

\echo ''
\echo '=== TESTAVIMAS BAIGTAS ==='
\echo 'Patikrinkite, kurie testai pavyko ir kurie nepavyko (kaip ir tiketasi).'