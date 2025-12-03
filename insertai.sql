INSERT INTO kategorija (pavadinimas, aprasymas, tevine_kat_ID, aktyvus) VALUES
('Variklio detales', 'Visos su varikliu susijusios detales', NULL, TRUE),
('Stabdziu sistema', 'Stabdziu detales ir komponentai', NULL, TRUE),
('Pakabos detales', 'Pakabos sistema', NULL, TRUE),
('Elektronika', 'Elektronines sistemos', NULL, TRUE),
('Variklio filtrai', 'Ivairius variklio filtrai', 1, TRUE);

INSERT INTO tiekejas (pavadinimas, telefonas, el_pastas, salis, sutarties_numeris) VALUES
('AutoParts UAB', '+37061234567', 'info@autoparts.lt', 'Lietuva', 'ST-2024-001'),
('GlobalParts GmbH', '+4930123456', 'contact@globalparts.de', 'Vokietija', 'ST-2024-002'),
('SpeedySupply Inc', '+14155551234', 'sales@speedysupply.com', 'JAV', 'ST-2024-003');

INSERT INTO klientas (vardas, pavarde, telefonas, el_pastas, registracijos_data) VALUES
('Jonas', 'Jonaitis', '+37061111111', 'jonas.jonaitis@email.lt', '2024-01-15'),
('Petras', 'Petraitis', '+37062222222', 'petras.petraitis@email.lt', '2024-02-20'),
('Marija', 'Kazlauskaite', '+37063333333', 'marija.k@email.lt', '2024-03-10'),
('Antanas', 'Antanaitis', '+37064444444', 'antanas.a@email.lt', '2024-04-05');

INSERT INTO detale (pavadinimas, kodas, kategorijaID, kiekis_sandelyje, kaina, aprasymas) VALUES
('Alyvos filtras WIX51515', 'OF-51515', 5, 150, 8.50, 'Universalus alyvos filtras'),
('Oro filtras K&N33-2304', 'AF-33-2304', 5, 75, 45.00, 'Didelio nasumo oro filtras'),
('Stabdziu kaladeles Brembo', 'BK-P85020', 2, 200, 85.00, 'Priekines stabdziu kaladeles'),
('Stabdziu diskai ATE', 'BD-24.0110-0156.1', 2, 50, 120.00, 'Priekiniai stabdziu diskai'),
('Amortizatorius Monroe', 'AM-G16397', 3, 30, 95.00, 'Priekinis amortizatorius'),
('Guma stabilizatoriaus', 'GS-8200261772', 3, 300, 3.50, 'Stabilizatoriaus ivore'),
('Zvakes NGK', 'ZV-4824', 1, 500, 12.00, 'Uzdegimo zvakes (4vnt)'),
('Generatoriaus dirzas Gates', 'GD-K016PK1140', 1, 80, 25.00, 'Daugiaadapis dirzas');

INSERT INTO detale_tiekejas (detalesID, tiekejoID, tiekimo_kaina, pristatymo_laikas_d, sutarties_data) VALUES
(1, 1, 7.20, 2, '2024-01-01'),
(1, 2, 7.50, 5, '2024-01-01'),
(2, 1, 38.00, 3, '2024-01-01'),
(3, 2, 75.00, 7, '2024-01-01'),
(4, 2, 105.00, 7, '2024-01-01'),
(5, 3, 82.00, 14, '2024-02-01'),
(6, 1, 2.80, 1, '2024-01-01'),
(7, 1, 10.50, 2, '2024-01-01'),
(8, 3, 22.00, 10, '2024-02-01');

INSERT INTO uzsakymas (klientoID, uzsakymo_data, pristatymo_data, busena, gatve, miestas, nuolaida, apmokejimo_budas) VALUES
(1, '2024-11-01', '2024-11-03', 'Pristatyta', 'Gedimino pr. 10', 'Vilnius', 0, 'Kortele'),
(2, '2024-11-15', NULL, 'Vykdoma', 'Laisves al. 25', 'Kaunas', 5, 'Grynais'),
(1, '2024-11-20', NULL, 'Patvirtinta', 'Gedimino pr. 10', 'Vilnius', 10, 'Kortele'),
(3, '2024-11-25', NULL, 'Laukiama', 'Savanorių pr. 5', 'Vilnius', 0, 'Banko pavedimu');

INSERT INTO uzsakymo_eilute (uzsakymoID, detalesID, kiekis) VALUES
(1, 1, 2),
(1, 7, 4),
(2, 3, 1),
(2, 4, 1),
(3, 1, 1),
(3, 2, 1),
(3, 8, 1),
(4, 5, 2),
(4, 6, 4);

INSERT INTO atsiliepimas (klientoID, detalesID, ivertinimas, komentaras, data) VALUES
(1, 1, 5, 'Puiki kokybe, greitas pristatymas', '2024-11-04'),
(1, 7, 4, 'Geras produktas, atitinka aprasyma', '2024-11-04'),
(2, 3, 5, 'Labai patiko, veikia puikiai', '2024-11-16');

REFRESH MATERIALIZED VIEW mv_kategoriju_statistika;
REFRESH MATERIALIZED VIEW mv_tiekeju_statistika;