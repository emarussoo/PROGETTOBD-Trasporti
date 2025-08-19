SET SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';
DROP SCHEMA IF EXISTS `Trasporti`;

CREATE SCHEMA IF NOT EXISTS `Trasporti`;
USE `Trasporti`;

/*Tabella Fermata*/
DROP TABLE IF EXISTS `Trasporti`.`Fermata`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Fermata`(
    `codice` CHAR(5) NOT NULL,
    `longitudine` FLOAT NOT NULL,
    `latitudine` FLOAT NOT NULL,
    PRIMARY KEY (`codice`)
);

/*Tabella Tratta*/
DROP TABLE IF EXISTS `Trasporti`.`Tratta`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Tratta`(
    `numero` INT AUTO_INCREMENT NOT NULL,
    `capolinea_partenza` CHAR(5) NOT NULL,
    `capolinea_arrivo` CHAR(5) NOT NULL,
    PRIMARY KEY (`numero`),
    FOREIGN KEY (`capolinea_partenza`)
    REFERENCES `Trasporti`.`Fermata`(`codice`),
    FOREIGN KEY (`capolinea_arrivo`)
    REFERENCES `Trasporti`.`Fermata`(`codice`)
);

/*Tabella Appartenenza*/
DROP TABLE IF EXISTS `Trasporti`.`Appartenenza`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Appartenenza`(
    `codice_fermata` CHAR(5) NOT NULL,
    `numero_tratta` INT NOT NULL,
    `indice` FLOAT NOT NULL,
    PRIMARY KEY (`codice_fermata`, `numero_tratta`),
    FOREIGN KEY (`codice_fermata`)
    REFERENCES `Trasporti`.`Fermata`(`codice`),
    FOREIGN KEY (`numero_tratta`)
    REFERENCES `Trasporti`.`Tratta`(`numero`)
);

/*Tabella Veicolo*/
DROP TABLE IF EXISTS `Trasporti`.`Veicolo`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Veicolo`(
    `matricola` CHAR(4) NOT NULL,
    `data_acquisto` DATE NOT NULL,
    `fermata` CHAR(5),
    PRIMARY KEY (`matricola`),
    FOREIGN KEY (`fermata`)
    REFERENCES `Trasporti`.`Fermata`(`codice`)
);

/*Tabella Patente*/
DROP TABLE IF EXISTS `Trasporti`.`Patente`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Patente`(
    `numero` VARCHAR(10) NOT NULL,
    `scadenza` DATE NOT NULL,
    PRIMARY KEY (`numero`)
);

/*Tabella Conducente*/
DROP TABLE IF EXISTS `Trasporti`.`Conducente`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Conducente`(
    `CF` CHAR(16) NOT NULL,
    `nome` VARCHAR(45) NOT NULL,
    `cognome` VARCHAR(60) NOT NULL,
    `data_nascita` DATE NOT NULL,
    `luogo_nascita` VARCHAR(100) NOT NULL,
    `patente` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`CF`),
    FOREIGN KEY (`patente`)
    REFERENCES `Trasporti`.`Patente`(`numero`)

);


/*Tabella Corsa*/
DROP TABLE IF EXISTS `Trasporti`.`Corsa`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Corsa`(
    `numero_tratta` INT NOT NULL,
    `orario` TIME NOT NULL,
    `conducente` CHAR(16) NOT NULL,
    `veicolo` CHAR(4) NOT NULL,
    PRIMARY KEY (`numero_tratta`, `orario`),
    FOREIGN KEY (`numero_tratta`)
    REFERENCES `Trasporti`.`Tratta`(`numero`),
    FOREIGN KEY (`conducente`)
    REFERENCES `Trasporti`.`Conducente`(`CF`),
    FOREIGN KEY (`veicolo`)
    REFERENCES `Trasporti`.`Veicolo`(`matricola`)
);

/*Tabella Abbonamento*/
DROP TABLE IF EXISTS `Trasporti`.`Abbonamento`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Abbonamento`(
    `codice` VARCHAR(50) NOT NULL,
    `valido` BOOLEAN NOT NULL,
    `data_ultimo_utilizzo` DATE,
    PRIMARY KEY (`codice`)
);

/*Tabella Biglietto*/
DROP TABLE IF EXISTS `Trasporti`.`Biglietto`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Biglietto`(
    `codice` VARCHAR(50) NOT NULL,
    `orario_utilizzo` TIME,
    PRIMARY KEY (`codice`)
);

/*Tabella Utenti*/
DROP TABLE IF EXISTS `Trasporti`.`Utenti`;
CREATE TABLE IF NOT EXISTS `Trasporti`.`Utenti`(
    `username` VARCHAR(50) NOT NULL,
    `password` VARCHAR(45) NOT NULL,
    `ruolo` VARCHAR(25) NOT NULL,
    PRIMARY KEY (`username`)
);


/*procedura login*/
USE `Trasporti`;
DROP procedure IF EXISTS `Trasporti`.`login`;

DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `login` (in inputUsername VARCHAR(50), in inputPassword VARCHAR(45), out outputRuolo VARCHAR(25))
BEGIN
    select `ruolo` from `Utenti`
        where `username` = inputUsername and
        `password` = inputPassword
        into outputRuolo;
END$$

DELIMITER ;


/*procedura timbratura biglietto*/
USE `Trasporti`;
DROP procedure IF EXISTS `Trasporti`.`timbra_biglietto`;

DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `timbra_biglietto` (in codiceBiglietto VARCHAR(50), out stato_timbratura BOOLEAN)
BEGIN 
    declare isANewTicket TIME;
    
    select `orario_utilizzo`
    from `Biglietto`
    where `codice` = codiceBiglietto
    into isANewTicket;

    if isANewTicket IS NULL then
        update `Biglietto`
        set `orario_utilizzo` = NOW()
        where `codice` = codiceBiglietto;
        set stato_timbratura = 1;
    else    
        set stato_timbratura = 0;
    end if;
END$$

DELIMITER ;

/*procedura timbratura abbonamento*/
USE `Trasporti`;
DROP procedure IF EXISTS `Trasporti`.`timbra_abbonamento`;

DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `timbra_abbonamento` (in codiceAbbonamento VARCHAR(50), out stato_timbratura BOOLEAN)
BEGIN 
    declare isValid BOOLEAN;
    
    select `valido`
    from `Abbonamento`
    where `codice` = codiceAbbonamento
    into isValid;

    if isValid = 1 then
        update `Abbonamento`
        set `data_ultimo_utilizzo` = CURDATE()
        where `codice` = codiceAbbonamento;
        set stato_timbratura = 1;
    else    
        set stato_timbratura = 0;
    end if;
END$$

DELIMITER ;
/*procedura trova veicoli in arrivo*/
DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `veicoli_in_arrivo` (in codiceFermata CHAR(5))
BEGIN 
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    set transaction isolation level read committed;
    start transaction;
        select matricola, fermata, aa.indice as indice_fermata_posizione, a.indice as indice_fermata_passeggero, a.indice - aa.indice as distanza
        from `Appartenenza`a join `Corsa` c
        on a.numero_tratta = c.numero_tratta
        join `Veicolo` v
        on c.veicolo = v.matricola
        join appartenenza aa
        on v.fermata = aa.codice_fermata
        where a.codice_fermata = codiceFermata and a.numero_tratta = aa.numero_tratta
        and a.indice > aa.indice;
    commit;
END$$

DELIMITER ;


/*procedura aggiorna posizione*/
DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `aggiorna_posizione` (in matricolaVeicolo CHAR(4), in codiceFermata CHAR(5))
BEGIN 
    update `Veicolo`
    set `fermata` = codiceFermata
    where `matricola` = matricolaVeicolo;
END$$

DELIMITER ;

/*procedura trova prossima partenza*/

DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `prossima_partenza` (in CF_conducente CHAR(16), in matricolaVeicolo CHAR(4), in codiceCapolinea CHAR(5), out prossimaPartenza TIME)
BEGIN 
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    set transaction isolation level repeatable read;
    start transaction;
        select `orario` as `prossima_corsa`
        from Tratta t join Corsa c 
        on t.numero = c.numero_tratta
        where capolinea_partenza = codiceCapolinea and
        veicolo = matricolaVeicolo and
        conducente = CF_conducente and
        `orario`> NOW() 
        order by (TIMESTAMPDIFF(SECOND, `orario`, NOW())) asc
        limit 1
        into prossimaPartenza;

        if prossimaPartenza IS NULL then
        select `orario` as `prossima_corsa`
        from Tratta t join Corsa c 
        on t.numero = c.numero_tratta
        where capolinea_partenza = codiceCapolinea and
        veicolo = matricolaVeicolo and
        conducente = CF_conducente
        order by (TIMESTAMPDIFF(SECOND, `orario`, '00:00:00')) asc
        limit 1
        into prossimaPartenza;
        end if;
    commit;
END$$

DELIMITER ;

/*procedura associare veicolo a corsa*/
DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `corsa_veicolo` (in numeroTratta INT, in orarioCorsa TIME, in matricolaVeicolo CHAR(4))
BEGIN 
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    set transaction isolation level serializable;
    start transaction;

        update `Corsa`
        set `veicolo` = matricolaVeicolo
        where `numero_tratta` = numeroTratta
        and `orario` = orarioCorsa;

    commit;
END$$

DELIMITER ;


/*procedura associare corsa conducente*/
DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `corsa_conducente` (in numeroTratta INT, in orarioCorsa TIME, in CF_conducente CHAR(16))
BEGIN 
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    set transaction isolation level serializable;
    start transaction;

        update `Corsa`
        set `conducente` = CF_conducente
        where `numero_tratta` = numeroTratta
        and `orario` = orarioCorsa;

    commit;
END$$

DELIMITER ;


/*procedura aggiunta biglietto*/
DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `aggiunta_biglietto` (in codiceBiglietto VARCHAR(50))
BEGIN 
    insert into Biglietto(`codice`)
        values (codiceBiglietto);
END$$

DELIMITER ;


/*procedura aggiunta abbonamento*/
DELIMITER $$
USE `Trasporti`$$
CREATE PROCEDURE `aggiunta_abbonamento` (in codiceAbbonamento VARCHAR(50), in isValid BOOLEAN)
BEGIN 
    insert into Abbonamento(`codice`, `valido`)
        values (codiceAbbonamento, isValid);
END$$

DELIMITER ;

-- --------------------------- definizione users ---------------------------------------- 

-- --------------------------- login ---------------------------------------- 
-- GRANT USAGE ON *.* TO login;
DROP USER IF EXISTS login;
CREATE USER 'login' IDENTIFIED BY 'login';

GRANT EXECUTE ON PROCEDURE `Trasporti`.`login` TO 'login';

-- --------------------------- gestore ---------------------------------------- 
DROP USER IF EXISTS gestore;
CREATE USER 'gestore' IDENTIFIED BY 'gestore';

GRANT EXECUTE ON PROCEDURE `Trasporti`.`aggiunta_biglietto` TO 'gestore';
GRANT EXECUTE ON PROCEDURE `Trasporti`.`aggiunta_abbonamento` TO 'gestore';
GRANT EXECUTE ON PROCEDURE `Trasporti`.`corsa_conducente` TO 'gestore';
GRANT EXECUTE ON PROCEDURE `Trasporti`.`corsa_veicolo` TO 'gestore';

-- --------------------------- passeggero ---------------------------------------- 
DROP USER IF EXISTS passeggero;
CREATE USER 'passeggero' IDENTIFIED BY 'passeggero';

GRANT EXECUTE ON PROCEDURE `Trasporti`.`veicoli_in_arrivo` TO 'passeggero';


-- --------------------------- autista ---------------------------------------- 
DROP USER IF EXISTS autista;
CREATE USER 'autista' IDENTIFIED BY 'autista';

GRANT EXECUTE ON PROCEDURE `Trasporti`.`prossima_partenza` TO 'autista';


-- --------------------------- mezzo ---------------------------------------- 
DROP USER IF EXISTS mezzo;
CREATE USER 'mezzo' IDENTIFIED BY 'mezzo';

GRANT EXECUTE ON PROCEDURE `Trasporti`.`timbra_biglietto` TO 'mezzo';
GRANT EXECUTE ON PROCEDURE `Trasporti`.`timbra_abbonamento` TO 'mezzo';
GRANT EXECUTE ON PROCEDURE `Trasporti`.`aggiorna_posizione` TO 'mezzo';

-- --------------------------- inserimento dati patenti ---------------------------------------- 
start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('AAABBBCCDD','2034-01-31');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('BBCCDDDEE1','2035-02-28');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('CCDDFFGGHI','2036-03-15');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('DDFFGGHIJK','2037-04-12');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('EEGGHHIIKL','2038-05-20');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('FFHHIIJKLM','2039-06-30');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('GGIIJJKKLN','2040-07-25');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('HHJJKKLLMO','2041-08-14');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('IIKKLLMMNP','2042-09-22');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('JJLLMMNNOQ','2043-10-18');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('KKMMNNOOQR','2044-11-30');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('LLNNOPPQR1','2045-12-31');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('MMOOPPQQRS','2046-01-20');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('NNOOQQRRTS','2047-02-14');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('OOPPRRRTTU','2048-03-18');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('PQQRRSSUUV','2049-04-27');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('QRRSSSTTUV','2050-05-19');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('RRSSSUTTUV','2051-06-22');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('SSSTTUUUWX','2052-07-14');
INSERT INTO `Trasporti`.`Patente` (`numero`, `scadenza`) VALUES('TTUUUXXYZA','2053-08-30');
commit;


-- --------------------------- inserimento dati conducenti ---------------------------------------- 

start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('RSSMRA77Y21P545U', 'Mario', 'Rossi', '1977-05-03', 'Bari', 'AAABBBCCDD');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('LNSNDR85B51A794L', 'Luca', 'Sandri', '1985-06-15', 'Milano', 'BBCCDDDEE1');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('GVCRML92D12C980D', 'Giovanni', 'Verdi', '1992-02-10', 'Roma', 'CCDDFFGGHI');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('LMLLNC94C14G784E', 'Lina', 'Malini', '1994-11-28', 'Napoli', 'DDFFGGHIJK');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('CCRRRG86G04T365H', 'Carlo', 'Ruggeri', '1986-09-20', 'Torino', 'EEGGHHIIKL');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('NNSBLS91F28Z404P', 'Simona', 'Bassani', '1991-07-11', 'Firenze', 'FFHHIIJKLM');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('PRJLGN85M56M098Q', 'Pietro', 'Longo', '1985-12-02', 'Bologna', 'GGIIJJKKLN');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('FBRNDM93D16A260R', 'Francesco', 'Bernardi', '1993-04-08', 'Venezia', 'HHJJKKLLMO');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('LNSRDS88T09N725V', 'Laura', 'Serafini', '1988-08-27', 'Pisa', 'IIKKLLMMNP');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('GSMLPS89S07D477J', 'Gianluca', 'Salvini', '1989-10-21', 'Catania', 'JJLLMMNNOQ');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('GRDCTR82T14Y991M', 'Giorgio', 'Cattani', '1982-01-14', 'Vercelli', 'KKMMNNOOQR');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('BNDNMR76E23F160C', 'Andrea', 'Bernini', '1976-11-04', 'Perugia', 'LLNNOPPQR1');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('VDSCNF94D14J982P', 'Valerio', 'Domenici', '1994-05-30', 'Reggio Emilia', 'MMOOPPQQRS');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('MNTNPR84T21V328H', 'Martina', 'Venturi', '1984-03-07', 'Lecce', 'NNOOQQRRTS');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('FMRGLD92R11P495A', 'Federico', 'Mongelli', '1992-06-19', 'Livorno', 'OOPPRRRTTU');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('GNSSTP80F15J741K', 'Giulia', 'Stefani', '1980-12-04', 'Trieste', 'PQQRRSSUUV');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('VRMDLL76T24A128P', 'Vittoria', 'Dellapiana', '1976-09-22', 'Cagliari', 'QRRSSSTTUV');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('CRRNPS88F28Z581G', 'Carolina', 'Piseri', '1988-04-16', 'Messina', 'RRSSSUTTUV');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('PLKNTM89G02V826A', 'Paolo', 'Kantor', '1989-01-25', 'Siena', 'SSSTTUUUWX');
INSERT INTO `Trasporti`.`Conducente` (`CF`, `nome`, `cognome`, `data_nascita`, `luogo_nascita`, `patente`) VALUES('RLDNTB87Y22E407F', 'Rachele', 'Nitti', '1987-11-19', 'Vibo Valentia', 'TTUUUXXYZA');
commit;


-- --------------------------- inserimento dati veicoli ---------------------------------------- 
start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Veicolo` (`matricola`,`data_acquisto`,`fermata`) VALUES('0000','2004-08-30', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0001', '2004-08-30', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0002', '2005-04-12', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0003', '2006-06-23', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0004', '2007-09-18', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0005', '2008-11-30', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0006', '2009-02-14', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0007', '2010-01-06', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0008', '2011-05-16', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0009', '2012-08-22', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0010', '2013-03-03', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0011', '2014-07-29', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0012', '2015-12-18', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0013', '2016-04-06', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0014', '2017-09-20', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0015', '2018-11-10', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0016', '2019-06-13', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0017', '2020-08-29', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0018', '2021-03-14', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0019', '2022-10-05', null);
INSERT INTO `Trasporti`.`Veicolo` (`matricola`, `data_acquisto`, `fermata`) VALUES('0020', '2023-07-16', null);
commit;

-- --------------------------- inserimento dati fermate ---------------------------------------- 
start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00001', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00002', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00003', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00004', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00005', -0.1278, 51.5074);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00006', 2.1929, 41.3784);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00007', 13.4050, 52.5200);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00008', -73.9352, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00009', -118.2437, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00010', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00011', 116.4074, 39.9042);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00012', 37.6176, 55.7558);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00013', -73.9997, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00014', -118.2430, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00015', -122.4190, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00016', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00017', -0.1278, 51.5074);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00018', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00019', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00020', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00021', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00022', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00023', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00024', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00025', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00026', 13.4050, 52.5200);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00027', -0.1278, 51.5074);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00028', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00029', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00030', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00031', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00032', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00033', -73.9352, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00034', -118.2437, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00035', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00036', 116.4074, 39.9042);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00037', 37.6176, 55.7558);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00038', -73.9997, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00039', -118.2430, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00040', -122.4190, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00041', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00042', -0.1278, 51.5074);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00043', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00044', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00045', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00046', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00047', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00048', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00049', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00050', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00051', 13.4050, 52.5200);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00052', -73.9352, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00053', -118.2437, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00054', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00055', 116.4074, 39.9042);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00056', 37.6176, 55.7558);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00057', -73.9997, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00058', -118.2430, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00059', -122.4190, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00060', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00061', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00062', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00063', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00064', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00065', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00066', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00067', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00068', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00069', 13.4050, 52.5200);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00070', -73.9352, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00071', -118.2437, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00072', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00073', 116.4074, 39.9042);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00074', 37.6176, 55.7558);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00075', -73.9997, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00076', -118.2430, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00077', -122.4190, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00078', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00079', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00080', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00081', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00082', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00083', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00084', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00085', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00086', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00087', 13.4050, 52.5200);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00088', -73.9352, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00089', -118.2437, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00090', -122.4194, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00091', 116.4074, 39.9042);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00092', 37.6176, 55.7558);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00093', -73.9997, 40.7306);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00094', -118.2430, 34.0522);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00095', -122.4190, 37.7749);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00096', 2.3522, 48.8566);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00097', 12.4964, 41.9028);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00098', 9.1900, 45.4642);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00099', -74.0060, 40.7128);
INSERT INTO `Trasporti`.`Fermata` (`codice`, `longitudine`, `latitudine`) VALUES('00100', 2.3522, 48.8566);
commit;


-- --------------------------- inserimento dati tratte ---------------------------------------- 
start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00054','00031');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00052', '00055');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00068', '00089');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00068', '00060');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00068', '00097');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00081', '00079');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00075', '00040');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00083', '00056');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00085', '00095');
INSERT INTO `Trasporti`.`Tratta` (`capolinea_partenza`, `capolinea_arrivo`) VALUES('00057', '00071');
commit;


-- --------------------------- inserimento dati appartenenza ---------------------------------------- 
start transaction;
USE `Trasporti`;
-- Tratta 1 (00001)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00054', 1, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00095', 1, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00099', 1, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00052', 1, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00031', 1, 4);

-- Tratta 2 (00002)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00052', 2, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00068', 2, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00075', 2, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00083', 2, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00055', 2, 4);

-- Tratta 3 (00003)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00068', 3, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00060', 3, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00080', 3, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00056', 3, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00089', 3, 4);

-- Tratta 4 (00004)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00068', 4, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00075', 4, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00095', 4, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00031', 4, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00060', 4, 4);

-- Tratta 5 (00005)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00068', 5, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00085', 5, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00031', 5, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00079', 5, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00097', 5, 4);

-- Tratta 6 (00006)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00081', 6, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00071', 6, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00056', 6, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00054', 6, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00079', 6, 4);

-- Tratta 7 (00007)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00075', 7, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00052', 7, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00031', 7, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00068', 7, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00040', 7, 4);

-- Tratta 8 (00008)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00083', 8, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00068', 8, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00031', 8, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00052', 8, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00056', 8, 4);

-- Tratta 9 (00009)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00085', 9, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00079', 9, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00097', 9, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00056', 9, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00095', 9, 4);

-- Tratta 10 (00010)
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00057', 10, 0);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00075', 10, 1);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00040', 10, 2);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00060', 10, 3);
INSERT INTO `Trasporti`.`Appartenenza`(`codice_fermata`, `numero_tratta`, `indice`) VALUES('00071', 10, 4);

commit;


-- --------------------------- inserimento dati corse ---------------------------------------- 
start transaction;
USE `Trasporti`;

INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('06:00:00', 1, 'RSSMRA77Y21P545U', '0000');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('08:00:00', 1, 'LNSNDR85B51A794L', '0001');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('10:00:00', 1, 'GVCRML92D12C980D', '0002');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('12:00:00', 1, 'LMLLNC94C14G784E', '0003');

INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('06:30:00', 2, 'CCRRRG86G04T365H', '0004');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('08:30:00', 2, 'NNSBLS91F28Z404P', '0005');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('10:30:00', 2, 'PRJLGN85M56M098Q', '0006');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('12:30:00', 2, 'FBRNDM93D16A260R', '0007');

INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('07:50:00', 3, 'LNSRDS88T09N725V', '0008');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('09:00:00', 3, 'GSMLPS89S07D477J', '0009');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('11:00:00', 3, 'GRDCTR82T14Y991M', '0010');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('13:00:00', 3, 'BNDNMR76E23F160C', '0011');

INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('07:30:00', 4, 'VDSCNF94D14J982P', '0012');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('09:30:00', 4, 'MNTNPR84T21V328H', '0013');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('11:30:00', 4, 'FMRGLD92R11P495A', '0014');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('13:30:00', 4, 'LNSRDS88T09N725V', '0008');

INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('08:00:00', 5, 'VRMDLL76T24A128P', '0016');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('10:00:00', 5, 'CRRNPS88F28Z581G', '0017');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('12:00:00', 5, 'PLKNTM89G02V826A', '0018');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('23:20:00', 5, 'LNSRDS88T09N725V', '0008');

INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('08:30:00', 6, 'RSSMRA77Y21P545U', '0020');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('10:30:00', 6, 'LNSNDR85B51A794L', '0000');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('12:30:00', 6, 'GVCRML92D12C980D', '0001');
INSERT INTO `Trasporti`.`Corsa`(`orario`, `numero_tratta`, `conducente`, `veicolo`) VALUES('14:30:00', 6, 'LMLLNC94C14G784E', '0002');

commit;


-- --------------------------- inserimento dati biglietti ---------------------------------------- 
start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K', '08:30:15');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L', '09:45:32');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M', '10:15:47');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N', '11:23:56');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O', '12:34:12');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P', '13:45:23');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q', '14:56:34');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R', '15:12:45');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S', '16:23:56');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T', '17:34:12');
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I', NULL);
INSERT INTO `Trasporti`.`Biglietto`(`codice`, `orario_utilizzo`) VALUES ('M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J', NULL);
commit;


-- --------------------------- inserimento dati abbonamenti ---------------------------------------- 
start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X', 1, '2024-01-15');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y', 0, '2024-02-20');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z', 1, '2024-03-10');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A', 0, '2024-04-25');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B', 1, '2024-05-30');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C', 0, '2024-06-15');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D', 1, '2024-07-20');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E', 0, '2024-08-10');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F', 1, '2024-09-25');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G', 0, '2024-10-30');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H', 1, '2024-11-15');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I', 0, '2024-12-20');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J', 1, '2024-01-10');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K', 0, '2024-02-25');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('O5P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L', 1, '2024-03-30');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('P6Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M', 0, '2024-04-15');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('Q7R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N', 1, '2024-05-20');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('R8S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O', 0, '2024-06-10');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('S9T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P', 1, '2024-07-25');
INSERT INTO `Trasporti`.`Abbonamento`(`codice`,`valido`,`data_ultimo_utilizzo`) VALUES ('T0U1V2W3X4Y5Z6A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q', 0, '2024-08-30');
commit;

-- --------------------------- inserimento dati utenti ---------------------------------------- 

start transaction;
USE `Trasporti`;
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user123456', 'pwA1B2C3D4', 'gestore');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user234567', 'pwE5F6G7H8I', 'passeggero');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user345678', 'pwJ9K0L1M2N', 'autista');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user456789', 'pwO3P4Q5R6S', 'gestore');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user567890', 'pwT7U8V9W0X', 'passeggero');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user678901', 'pwY1Z2A3B4C', 'autista');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user789012', 'pwD5E6F7G8H', 'gestore');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user890123', 'pwI9J0K1L2M', 'passeggero');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user901234', 'pwN3O4P5Q6R', 'autista');
INSERT INTO `Trasporti`.`Utenti`(`username`,`password`,`ruolo`) VALUES ('user012345', 'pwS7T8U9V0W', 'gestore');
commit;



-- --------------------------- trigger regole aziendali ---------------------------------------- 

-- controlla se il codice fermata è composto da esattamente 5 cifre numeriche

DELIMITER $$
USE `Trasporti`$$
DROP TRIGGER IF EXISTS `Trasporti`. `checkfermata`$$
USE `Trasporti`$$
create trigger `checkfermata`
before insert on `fermata`
for each row
begin
	if not new.codice regexp '^[0-9]{5}$' then
		signal sqlstate '45001'
		set message_text = 'codice fermata non valido';
		end if;
end$$

DELIMITER ;

-- controlla se la matricola veicolo è composta da esattamente 5 cifre numeriche
DELIMITER $$
USE `Trasporti`$$
DROP TRIGGER IF EXISTS `Trasporti`. `checkveicolo`$$
USE `Trasporti`$$
create trigger `checkveicolo`
before insert on `veicolo`
for each row
begin
	if not new.matricola regexp '^[0-9]{4}$' then
		signal sqlstate '45002'
		set message_text = 'matricola veicolo non valida';
		end if;
end$$

DELIMITER ;

-- si assicura che quando viene inserito un utente, il ruolo sia esistente
DELIMITER $$
USE `Trasporti`$$
DROP TRIGGER IF EXISTS `Trasporti`. `checkruolo`$$
USE `Trasporti`$$
create trigger `checkruolo`
before insert on `utenti`
for each row
begin
	if not (new.ruolo in('gestore', 'passeggero', 'autista')) then
		signal sqlstate '45003'
		set message_text = 'ruolo utente non valido';
		end if;
end$$

DELIMITER ;





