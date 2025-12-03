CREATE SCHEMA IF NOT EXISTS automobiliu_dalys;
SET search_path TO automobiliu_dalys, public;

CREATE TABLE klientas (
    klientoID SERIAL PRIMARY KEY,
    vardas VARCHAR(50) NOT NULL,
    pavarde VARCHAR(50) NOT NULL,
    telefonas VARCHAR(20),
    el_pastas VARCHAR(100),
    registracijos_data DATE DEFAULT CURRENT_DATE,
    CONSTRAINT klientas_el_pastas_unq UNIQUE (el_pastas),
    CONSTRAINT klientas_el_pastas_chk CHECK (el_pastas LIKE '%@%')
);

CREATE TABLE tiekejas (
    tiekejoID SERIAL PRIMARY KEY,
    pavadinimas VARCHAR(100) NOT NULL,
    telefonas VARCHAR(20),
    el_pastas VARCHAR(100),
    salis VARCHAR(50),
    sutarties_numeris VARCHAR(50) UNIQUE,
    CONSTRAINT tiekejas_el_pastas_chk CHECK (el_pastas LIKE '%@%')
);

CREATE TABLE kategorija (
    kategorijaID SERIAL PRIMARY KEY,
    pavadinimas VARCHAR(100) NOT NULL UNIQUE,
    aprasymas VARCHAR(500),
    tevine_kat_ID INT,
    aktyvus BOOLEAN DEFAULT TRUE,
    CONSTRAINT kategorija_tevine_fk FOREIGN KEY (tevine_kat_ID) 
        REFERENCES kategorija(kategorijaID) ON DELETE SET NULL
);

CREATE TABLE detale (
    detalesID SERIAL PRIMARY KEY,
    pavadinimas VARCHAR(100) NOT NULL,
    kodas VARCHAR(50) NOT NULL,
    kategorijaID INT NOT NULL,
    kiekis_sandelyje INT DEFAULT 0,
    kaina DECIMAL(10,2) NOT NULL,
    aprasymas TEXT,
    CONSTRAINT detale_kategorija_fk FOREIGN KEY (kategorijaID) 
        REFERENCES kategorija(kategorijaID) ON DELETE RESTRICT,
    CONSTRAINT detale_kiekis_chk CHECK (kiekis_sandelyje >= 0),
    CONSTRAINT detale_kaina_chk CHECK (kaina > 0)
);

CREATE TABLE uzsakymas (
    uzsakymoID SERIAL PRIMARY KEY,
    klientoID INT NOT NULL,
    uzsakymo_data DATE DEFAULT CURRENT_DATE,
    pristatymo_data DATE,
    busena VARCHAR(20) DEFAULT 'Laukiama',
    bendra_suma DECIMAL(10,2) DEFAULT 0,
    gatve VARCHAR(100),
    miestas VARCHAR(50),
    nuolaida DECIMAL(5,2) DEFAULT 0,
    apmokejimo_budas VARCHAR(30),
    CONSTRAINT uzsakymas_klientas_fk FOREIGN KEY (klientoID) 
        REFERENCES klientas(klientoID) ON DELETE CASCADE,
    CONSTRAINT uzsakymas_busena_chk CHECK (busena IN ('Laukiama', 'Patvirtinta', 'Vykdoma', 'Pristatyta', 'Atsaukta')),
    CONSTRAINT uzsakymas_datos_chk CHECK (pristatymo_data IS NULL OR pristatymo_data >= uzsakymo_data),
    CONSTRAINT uzsakymas_nuolaida_chk CHECK (nuolaida >= 0 AND nuolaida <= 100)
);

CREATE TABLE uzsakymo_eilute (
    uzsakymoID INT NOT NULL,
    detalesID INT NOT NULL,
    kiekis INT NOT NULL,
    PRIMARY KEY (uzsakymoID, detalesID),
    CONSTRAINT ue_uzsakymas_fk FOREIGN KEY (uzsakymoID) 
        REFERENCES uzsakymas(uzsakymoID) ON DELETE CASCADE,
    CONSTRAINT ue_detale_fk FOREIGN KEY (detalesID) 
        REFERENCES detale(detalesID) ON DELETE RESTRICT,
    CONSTRAINT ue_kiekis_chk CHECK (kiekis > 0)
);

CREATE TABLE detale_tiekejas (
    detalesID INT NOT NULL,
    tiekejoID INT NOT NULL,
    tiekimo_kaina DECIMAL(10,2) NOT NULL,
    pristatymo_laikas_d INT,
    sutarties_data DATE,
    PRIMARY KEY (detalesID, tiekejoID),
    CONSTRAINT dt_detale_fk FOREIGN KEY (detalesID) 
        REFERENCES detale(detalesID) ON DELETE CASCADE,
    CONSTRAINT dt_tiekejas_fk FOREIGN KEY (tiekejoID) 
        REFERENCES tiekejas(tiekejoID) ON DELETE CASCADE,
    CONSTRAINT dt_kaina_chk CHECK (tiekimo_kaina > 0)
);

CREATE TABLE atsiliepimas (
    atsiliepimID SERIAL PRIMARY KEY,
    klientoID INT NOT NULL,
    detalesID INT NOT NULL,
    ivertinimas INT NOT NULL,
    komentaras TEXT,
    data DATE DEFAULT CURRENT_DATE,
    CONSTRAINT atsiliepimas_klientas_fk FOREIGN KEY (klientoID) 
        REFERENCES klientas(klientoID) ON DELETE CASCADE,
    CONSTRAINT atsiliepimas_detale_fk FOREIGN KEY (detalesID) 
        REFERENCES detale(detalesID) ON DELETE CASCADE,
    CONSTRAINT atsiliepimas_ivertinimas_chk CHECK (ivertinimas >= 1 AND ivertinimas <= 5)
);

CREATE UNIQUE INDEX idx_detale_kodas ON detale(kodas);

CREATE UNIQUE INDEX idx_tiekejas_sutartis ON tiekejas(sutarties_numeris);

CREATE INDEX idx_uzsakymas_busena ON uzsakymas(busena);

CREATE INDEX idx_detale_kategorija_kaina ON detale(kategorijaID, kaina);

CREATE OR REPLACE VIEW v_klientu_uzsakymai AS
SELECT 
    k.klientoID,
    k.vardas || ' ' || k.pavarde AS pilnas_vardas,
    k.el_pastas,
    COUNT(u.uzsakymoID) AS uzsakymu_skaicius,
    COALESCE(SUM(u.bendra_suma), 0) AS bendra_suma,
    MAX(u.uzsakymo_data) AS paskutinis_uzsakymas
FROM klientas k
LEFT JOIN uzsakymas u ON k.klientoID = u.klientoID
GROUP BY k.klientoID, k.vardas, k.pavarde, k.el_pastas;

CREATE OR REPLACE VIEW v_detaliu_busena AS
SELECT 
    d.detalesID,
    d.pavadinimas,
    d.kodas,
    k.pavadinimas AS kategorija,
    d.kiekis_sandelyje,
    d.kaina,
    COUNT(DISTINCT dt.tiekejoID) AS tiekeju_skaicius,
    CASE 
        WHEN d.kiekis_sandelyje = 0 THEN 'Nera sandelyje'
        WHEN d.kiekis_sandelyje < 10 THEN 'Mazas kiekis'
        ELSE 'Pakankama'
    END AS busena
FROM detale d
JOIN kategorija k ON d.kategorijaID = k.kategorijaID
LEFT JOIN detale_tiekejas dt ON d.detalesID = dt.detalesID
GROUP BY d.detalesID, d.pavadinimas, d.kodas, k.pavadinimas, 
         d.kiekis_sandelyje, d.kaina;

CREATE OR REPLACE VIEW v_uzsakymu_detales AS
SELECT 
    u.uzsakymoID,
    k.vardas || ' ' || k.pavarde AS klientas,
    u.uzsakymo_data,
    u.busena,
    d.pavadinimas AS detale,
    ue.kiekis,
    d.kaina,
    ue.kiekis * d.kaina AS eilutes_suma
FROM uzsakymas u
JOIN klientas k ON u.klientoID = k.klientoID
JOIN uzsakymo_eilute ue ON u.uzsakymoID = ue.uzsakymoID
JOIN detale d ON ue.detalesID = d.detalesID;

CREATE OR REPLACE VIEW v_tiekeju_detales AS
SELECT 
    t.tiekejoID,
    t.pavadinimas AS tiekejas,
    t.salis,
    d.pavadinimas AS detale,
    d.kodas,
    dt.tiekimo_kaina,
    dt.pristatymo_laikas_d,
    d.kaina - dt.tiekimo_kaina AS marza
FROM tiekejas t
JOIN detale_tiekejas dt ON t.tiekejoID = dt.tiekejoID
JOIN detale d ON dt.detalesID = d.detalesID;

CREATE MATERIALIZED VIEW mv_kategoriju_statistika AS
SELECT 
    k.kategorijaID,
    k.pavadinimas AS kategorija,
    COUNT(d.detalesID) AS detaliu_skaicius,
    SUM(d.kiekis_sandelyje) AS bendras_kiekis,
    AVG(d.kaina) AS vidutine_kaina,
    MIN(d.kaina) AS minimali_kaina,
    MAX(d.kaina) AS maksimali_kaina,
    CURRENT_TIMESTAMP AS atnaujinta
FROM kategorija k
LEFT JOIN detale d ON k.kategorijaID = d.kategorijaID
GROUP BY k.kategorijaID, k.pavadinimas;

CREATE MATERIALIZED VIEW mv_tiekeju_statistika AS
SELECT 
    t.tiekejoID,
    t.pavadinimas AS tiekejas,
    t.salis,
    COUNT(DISTINCT dt.detalesID) AS tiekiamu_detaliu_skaicius,
    AVG(dt.tiekimo_kaina) AS vidutine_tiekimo_kaina,
    AVG(dt.pristatymo_laikas_d) AS vidutinis_pristatymo_laikas,
    CURRENT_TIMESTAMP AS atnaujinta
FROM tiekejas t
LEFT JOIN detale_tiekejas dt ON t.tiekejoID = dt.tiekejoID
GROUP BY t.tiekejoID, t.pavadinimas, t.salis;

CREATE OR REPLACE FUNCTION f_apskaiciuoti_uzsakymo_suma()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE uzsakymas
    SET bendra_suma = (
        SELECT COALESCE(SUM(ue.kiekis * d.kaina), 0)
        FROM uzsakymo_eilute ue
        JOIN detale d ON ue.detalesID = d.detalesID
        WHERE ue.uzsakymoID = NEW.uzsakymoID
    ) * (1 - COALESCE((SELECT nuolaida FROM uzsakymas WHERE uzsakymoID = NEW.uzsakymoID), 0) / 100)
    WHERE uzsakymoID = NEW.uzsakymoID;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_apskaiciuoti_uzsakymo_suma
AFTER INSERT OR UPDATE ON uzsakymo_eilute
FOR EACH ROW
EXECUTE FUNCTION f_apskaiciuoti_uzsakymo_suma();

CREATE OR REPLACE FUNCTION f_atnaujinti_sandelio_kieki()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT busena FROM uzsakymas WHERE uzsakymoID = NEW.uzsakymoID) = 'Pristatyta' THEN
        UPDATE detale
        SET kiekis_sandelyje = kiekis_sandelyje - NEW.kiekis
        WHERE detalesID = NEW.detalesID;
        
        IF (SELECT kiekis_sandelyje FROM detale WHERE detalesID = NEW.detalesID) < 0 THEN
            RAISE EXCEPTION 'Nepakanka atsargu detalei ID=%', NEW.detalesID;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_atnaujinti_sandelio_kieki
AFTER INSERT OR UPDATE ON uzsakymo_eilute
FOR EACH ROW
EXECUTE FUNCTION f_atnaujinti_sandelio_kieki();

CREATE OR REPLACE FUNCTION f_tikrinti_uzsakymo_busena()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.busena = 'Pristatyta' AND NEW.busena != 'Pristatyta' THEN
        RAISE EXCEPTION 'Negalima keisti jau pristatyto uzsakymo busenos';
    END IF;
    
    IF OLD.busena = 'Atsaukta' AND NEW.busena != 'Atsaukta' THEN
        RAISE EXCEPTION 'Negalima keisti atsaukto uzsakymo busenos';
    END IF;
    
    IF NEW.busena = 'Pristatyta' AND NEW.pristatymo_data IS NULL THEN
        NEW.pristatymo_data := CURRENT_DATE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_tikrinti_uzsakymo_busena
BEFORE UPDATE ON uzsakymas
FOR EACH ROW
EXECUTE FUNCTION f_tikrinti_uzsakymo_busena();

CREATE OR REPLACE FUNCTION f_atnaujinti_atsiliepimo_data()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data IS NULL THEN
        NEW.data := CURRENT_DATE;
    END IF;
    
    IF NEW.data > CURRENT_DATE THEN
        RAISE EXCEPTION 'Atsiliepimo data negali buti ateityje';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_atnaujinti_atsiliepimo_data
BEFORE INSERT OR UPDATE ON atsiliepimas
FOR EACH ROW
EXECUTE FUNCTION f_atnaujinti_atsiliepimo_data();