-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mar. 11 août 2026 à 21:04
-- Version du serveur : 9.2.0
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `marieteam` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `marieteam`;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `marieteam`
--

DELIMITER $$
--
-- Fonctions
--
DROP FUNCTION IF EXISTS `generateIdTrajet`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `generateIdTrajet` () RETURNS CHAR(6) CHARSET utf8mb4 DETERMINISTIC BEGIN
    RETURN LPAD(FLOOR(RAND() * 1000000), 6, '0'); -- Génère un ID de 6 chiffres (ex: '012345')
END$$

DROP FUNCTION IF EXISTS `generate_id_reference`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `generate_id_reference` () RETURNS VARCHAR(10) CHARSET utf8mb4 DETERMINISTIC BEGIN
    DECLARE letters VARCHAR(4);
    DECLARE numbers VARCHAR(3);
    DECLARE full_id VARCHAR(10);
    DECLARE i INT;

    -- Générer les 4 lettres aléatoires
    SET letters = CONCAT(
        CHAR(65 + FLOOR(RAND() * 26)),
        CHAR(65 + FLOOR(RAND() * 26)),
        CHAR(65 + FLOOR(RAND() * 26)),
        CHAR(65 + FLOOR(RAND() * 26))
    );

    -- Générer les 3 chiffres aléatoires
    SET numbers = CONCAT(
        FLOOR(RAND() * 10),
        FLOOR(RAND() * 10),
        FLOOR(RAND() * 10)
    );

    -- Combiner lettres et chiffres en une seule chaîne
    SET full_id = CONCAT(letters, numbers);

    -- Mélanger les caractères de la chaîne complète (lettres + chiffres)
    SET full_id = CONCAT(
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1),
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1),
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1),
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1),
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1),
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1),
        SUBSTRING(full_id, FLOOR(RAND() * 7) + 1, 1)
    );
    
    -- Retourner le nouvel ID généré
    RETURN full_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `bateau`
--

DROP TABLE IF EXISTS `bateau`;
CREATE TABLE IF NOT EXISTS `bateau` (
  `idBateau` int NOT NULL AUTO_INCREMENT,
  `idCapitaine` int DEFAULT NULL,
  `nomBateau` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `marque` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `longueur` float DEFAULT NULL,
  `largeur` float DEFAULT NULL,
  `vitesse` int DEFAULT NULL,
  `image` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`idBateau`),
  KEY `idCapitaine` (`idCapitaine`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `bateau`
--

INSERT INTO `bateau` (`idBateau`, `idCapitaine`, `nomBateau`, `marque`, `longueur`, `largeur`, `vitesse`, `image`) VALUES
(1, NULL, 'MS Stena Britannica', 'Stena Line', 240, 32, 22, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEv1w-1i4JJZQJF61VRy91IcM6Ew2w8B9jYg&s'),
(2, NULL, 'MS Silja Europa', 'Tallink Silja Line', 202, 33, 21, 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/2011-06-11_01_MS_Silja_EUROPA_-_IMO_8919805_coming_into_Stockholm%2C_Sweden.jpg/1200px-2011-06-11_01_MS_Silja_EUROPA_-_IMO_8919805_coming_into_Stockholm%2C_Sweden.jpg'),
(3, NULL, 'MS Silja Symphony', 'Tallink Silja Line', 203, 32, 23, 'https://www.meyerturku.fi/de/schiffe/mt/faehren/mt_faehre_silja_symphony_1240x530.jpg'),
(4, NULL, 'MS Pride of Hull', 'P&O Ferries', 215, 32, 22, 'https://i2-prod.hulldailymail.co.uk/incoming/article1927150.ece/ALTERNATES/s1200/0_POY_163.jpg'),
(5, NULL, 'MS Color Magic', 'Color Line', 224, 35, 22, 'https://www.cruisemapper.com/images/ships/1883-072f4ad8f98.jpg'),
(6, NULL, 'MS Cruise Roma', 'Grimaldi Lines', 225, 31, 28, 'https://www.shippax.com/backnet/media_archive/cache/491141a6ad64e135efc9e80f3d26e223_1200x630.jpg'),
(7, NULL, 'MS Pride of Rotterdam', 'P&O Ferries', 215, 32, 22, 'https://www.ferry-site.dk/picture/ferry/9208617v.jpg'),
(8, NULL, 'MS Color Fantasy', 'Color Line', 224, 35, 22, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1W4FfxLMHJyEMi6KbFW51D9iF5kKEvbP6NA&s'),
(9, NULL, 'MS Mega Express Five', 'Corsica Ferries', 178, 25, 26, 'https://assets.meretmarine.com/s3fs-public/styles/large_lg/public/images/2012-07/24912.jpg?h=9b53e01e&itok=_uUrCK8T'),
(10, NULL, 'MS Finnswan', 'Finnlines', 218, 30, 23, 'https://static.vesselfinder.net/ship-photo/9336256-230671000-204da8f87f5b920022c100b87cce9577/1?v1'),
(11, NULL, 'MS Pont-Aven', 'Brittany Ferries', 185, 31, 27, 'https://assets.meretmarine.com/s3fs-public/styles/large_lg/public/images/2016-05/pont-aven_0.jpg?h=34bbd072&itok=cktiqvnF'),
(12, NULL, 'MS Blue Star 1', 'Blue Star Ferries', 175, 26, 27, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRE24jR4Jju7Sia05OxRrEtfAbAZ--H6RuZH_aZVQekYeZVeoPzaAVyXo-hl9sBF4FA_zI&usqp=CAU'),
(13, NULL, 'MS Spirit of Tasmania I', 'Spirit of Tasmania', 194, 25, 30, 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Spirit_of_Tasmania_Port_Melbourne.jpg/1200px-Spirit_of_Tasmania_Port_Melbourne.jpg'),
(14, NULL, 'MS SuperSpeed 1', 'Color Line', 212, 26, 27, 'https://upload.wikimedia.org/wikipedia/commons/8/81/SuperSpeed_1_%281%29.jpg'),
(15, NULL, 'MS Moby Dada', 'Moby Lines', 166, 28, 22, 'https://www.cruisemapper.com/images/ships/2089-b8cd3b12727.jpg'),
(16, NULL, 'MS Viking Grace', 'Viking Line', 218, 31, 22, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGyGsgoYaaW3F2ppjLpUuiEJSc8yixMJlMoA&s'),
(17, NULL, 'MS Hellenic Spirit', 'ANEK Lines', 204, 26, 30, 'https://www.cruisemapper.com/images/ships/1823-89b1f332156.jpg'),
(18, NULL, 'MS Cap Finistère', 'Brittany Ferries', 204, 26, 28, 'https://image.jimcdn.com/app/cms/image/transf/dimension=1920x400:format=jpg/path/s8cd60784106f83d9/image/i0d5ec329e70f8e40/version/1473094652/image.jpg'),
(19, NULL, 'MS Vizzavona', 'Corsica Linea', 180, 28, 23, 'https://upload.wikimedia.org/wikipedia/commons/4/40/Corsica-Linea-Vizzavona-2021_%28cropped%29.jpg'),
(20, NULL, 'MS Nova Star', 'Bay Ferries', 161, 26, 21, 'https://polferries.com/assets/uploads/promy/nova-star/nova-star-900x500.jpg'),
(21, NULL, 'MS Aurora', 'P&O Ferries', 240, 32, 22, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5Tr4GFrEftjKZ3Cmchf95S03UQ7gWnv6ML5dwwOGRjjnMqmtI_Iq5lZPKqeEhehoX4F8&usqp=CAU'),
(22, NULL, 'MS Gotland', 'Destination Gotland', 196, 25, 28, 'https://www.cruisemapper.com/images/ships/1610-576a49f9595.jpg'),
(23, NULL, 'MS Isle of Inishmore', 'Irish Ferries', 193, 27, 22, 'https://upload.wikimedia.org/wikipedia/commons/0/02/%27Isle_of_Inishmore%27.jpg'),
(24, NULL, 'MS Festos Palace', 'Minoan Lines', 214, 26, 29, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxV8E6DybRuwfwyKaK0RQSasBEf0iagzz5SA&s'),
(25, NULL, 'MS Fjord FSTR', 'Fjord Line', 110, 30, 37, 'https://i.ytimg.com/vi/VBSlH9L9A4k/maxresdefault.jpg');

-- --------------------------------------------------------

--
-- Structure de la table `billet`
--

DROP TABLE IF EXISTS `billet`;
CREATE TABLE IF NOT EXISTS `billet` (
  `reference` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `idType` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `quantite` int NOT NULL,
  KEY `idType` (`idType`),
  KEY `reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `billet`
--

INSERT INTO `billet` (`reference`, `idType`, `quantite`) VALUES
('W292922', 'A1', 3),
('W292922', 'A3', 1),
('W292922', 'C1', 1),
('EI84ES8', 'A1', 1),
('EI84ES8', 'A2', 1),
('R97R5RJ', 'A1', 2),
('R97R5RJ', 'A3', 1),
('O0XI77O', 'A1', 2),
('O0XI77O', 'A3', 1),
('2ORKO00', 'A1', 2),
('9N6N76H', 'A1', 10),
('9N6N76H', 'A2', 10),
('9N6N76H', 'A3', 10),
('9WW1WRR', 'A1', 2);

-- --------------------------------------------------------

--
-- Structure de la table `capacite`
--

DROP TABLE IF EXISTS `capacite`;
CREATE TABLE IF NOT EXISTS `capacite` (
  `idBateau` int NOT NULL,
  `idCategorie` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `capacite` int DEFAULT NULL,
  PRIMARY KEY (`idBateau`,`idCategorie`),
  KEY `idCategorie` (`idCategorie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `capacite`
--

INSERT INTO `capacite` (`idBateau`, `idCategorie`, `capacite`) VALUES
(1, 'A', 110),
(1, 'B', 50),
(1, 'C', 110),
(1, 'D', 10),
(2, 'A', 230),
(2, 'B', 30),
(2, 'C', 150),
(2, 'D', 40),
(3, 'A', 100),
(3, 'B', 40),
(3, 'C', 60),
(3, 'D', 10),
(4, 'A', 200),
(4, 'B', 30),
(4, 'C', 140),
(4, 'D', 30),
(5, 'A', 110),
(5, 'B', 50),
(5, 'C', 50),
(5, 'D', 30),
(6, 'A', 200),
(6, 'B', 70),
(6, 'C', 40),
(6, 'D', 30),
(7, 'A', 180),
(7, 'B', 80),
(7, 'C', 100),
(7, 'D', 10),
(8, 'A', 370),
(8, 'B', 90),
(8, 'C', 120),
(8, 'D', 10),
(9, 'A', 290),
(9, 'B', 80),
(9, 'C', 150),
(9, 'D', 30),
(10, 'A', 190),
(10, 'B', 40),
(10, 'C', 40),
(10, 'D', 20),
(11, 'A', 180),
(11, 'B', 80),
(11, 'C', 50),
(11, 'D', 8),
(12, 'A', 330),
(12, 'B', 90),
(12, 'C', 150),
(12, 'D', 30),
(13, 'A', 370),
(13, 'B', 50),
(13, 'C', 60),
(13, 'D', 40),
(14, 'A', 90),
(14, 'B', 20),
(14, 'C', 120),
(14, 'D', 30),
(15, 'A', 420),
(15, 'B', 70),
(15, 'C', 30),
(15, 'D', 40),
(16, 'A', 380),
(16, 'B', 30),
(16, 'C', 100),
(16, 'D', 50),
(17, 'A', 410),
(17, 'B', 50),
(17, 'C', 120),
(17, 'D', 50),
(18, 'A', 220),
(18, 'B', 80),
(18, 'C', 70),
(18, 'D', 40),
(19, 'A', 140),
(19, 'B', 80),
(19, 'C', 90),
(19, 'D', 10),
(20, 'A', 380),
(20, 'B', 80),
(20, 'C', 50),
(20, 'D', 20),
(21, 'A', 250),
(21, 'B', 60),
(21, 'C', 100),
(21, 'D', 10),
(22, 'A', 100),
(22, 'B', 70),
(22, 'C', 120),
(22, 'D', 50),
(23, 'A', 230),
(23, 'B', 90),
(23, 'C', 150),
(23, 'D', 10),
(24, 'A', 190),
(24, 'B', 40),
(24, 'C', 20),
(24, 'D', 20),
(25, 'A', 280),
(25, 'B', 100),
(25, 'C', 100),
(25, 'D', 50);

-- --------------------------------------------------------

--
-- Structure de la table `categorie`
--

DROP TABLE IF EXISTS `categorie`;
CREATE TABLE IF NOT EXISTS `categorie` (
  `idCategorie` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `libelleCategorie` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`idCategorie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `categorie`
--

INSERT INTO `categorie` (`idCategorie`, `libelleCategorie`) VALUES
('A', 'Passager'),
('B', 'Deux roues'),
('C', 'Voiture < 5m'),
('D', 'Grand gabari');

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
  `idClient` int NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `prenom` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `telephone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`idClient`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`idClient`, `nom`, `prenom`, `telephone`, `email`) VALUES
(2, 'Gournay', 'Julien', '0768845070', 'julien.grny@gmail.com');

-- --------------------------------------------------------

--
-- Structure de la table `equipement`
--

DROP TABLE IF EXISTS `equipement`;
CREATE TABLE IF NOT EXISTS `equipement` (
  `idEquipement` int NOT NULL AUTO_INCREMENT,
  `labelle` varchar(100) NOT NULL,
  PRIMARY KEY (`idEquipement`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `equipement`
--

INSERT INTO `equipement` (`idEquipement`, `labelle`) VALUES
(1, 'Accès Handicapé'),
(2, 'Caméras de Surveillance'),
(3, 'Cafétéria'),
(4, 'Bar'),
(5, 'Distributeurs automatiques'),
(6, 'Salon Vidéo'),
(7, 'Wi-Fi'),
(8, 'Salon intérieur climatisé'),
(9, 'Pont promenade extérieur'),
(10, 'Espace jeux enfants'),
(11, 'Toilette');

-- --------------------------------------------------------

--
-- Structure de la table `incident`
--

DROP TABLE IF EXISTS `incident`;
CREATE TABLE IF NOT EXISTS `incident` (
  `idIncident` int NOT NULL AUTO_INCREMENT,
  `dateHeureIncident` datetime DEFAULT NULL,
  `idTrajet` int DEFAULT NULL,
  `typeIncident` enum('Retard','Annulé','Méteo') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `retardEstime` time DEFAULT NULL,
  `raison` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`idIncident`),
  KEY `idTrajet` (`idTrajet`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `liaison`
--

DROP TABLE IF EXISTS `liaison`;
CREATE TABLE IF NOT EXISTS `liaison` (
  `idLiai` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `idvilleDepart` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `idvilleArrivee` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `duree` time DEFAULT NULL,
  PRIMARY KEY (`idLiai`),
  KEY `idvilleDepart` (`idvilleDepart`),
  KEY `idvilleArrivee` (`idvilleArrivee`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `liaison`
--

INSERT INTO `liaison` (`idLiai`, `idvilleDepart`, `idvilleArrivee`, `duree`) VALUES
('ALC-CIU', 'ALC', 'CIU', '01:00:00'),
('ALC-SET', 'ALC', 'SET', '15:00:00'),
('ALC-TOU', 'ALC', 'TOU', '15:00:00'),
('CAL-DOU', 'CAL', 'DOU', '01:30:00'),
('CHE-DUB', 'CHE', 'DUB', '03:00:00'),
('CHE-HEL', 'CHE', 'HEL', '02:00:00'),
('CHE-ROS', 'CHE', 'ROS', '18:00:00'),
('CIU-ALC', 'CIU', 'ALC', '01:00:00'),
('CIU-TOU', 'CIU', 'TOU', '18:00:00'),
('DIE-NEW', 'DIE', 'NEW', '04:00:00'),
('DOU-CAL', 'DOU', 'CAL', '01:30:00'),
('DOU-DUB', 'DOU', 'DUB', '03:15:00'),
('DOU-DUN', 'DOU', 'DUN', '02:00:00'),
('DOU-ROS', 'DOU', 'ROS', '03:30:00'),
('DUB-CHE', 'DUB', 'CHE', '03:00:00'),
('DUB-DOU', 'DUB', 'DOU', '03:15:00'),
('DUB-HEL', 'DUB', 'HEL', '03:15:00'),
('DUB-NEW', 'DUB', 'NEW', '03:30:00'),
('DUN-DOU', 'DUN', 'DOU', '02:00:00'),
('HEL-CHE', 'HEL', 'CHE', '02:00:00'),
('HEL-DUB', 'HEL', 'DUB', '03:15:00'),
('LEH-NEW', 'LEH', 'NEW', '04:30:00'),
('NEW-DIE', 'NEW', 'DIE', '04:00:00'),
('NEW-DUB', 'NEW', 'DUB', '03:30:00'),
('NEW-LEH', 'NEW', 'LEH', '04:30:00'),
('NEW-ROS', 'NEW', 'ROS', '03:30:00'),
('ROS-CHE', 'ROS', 'CHE', '18:00:00'),
('ROS-DOU', 'ROS', 'DOU', '03:30:00'),
('ROS-NEW', 'ROS', 'NEW', '03:30:00'),
('SET-ALC', 'SET', 'ALC', '15:00:00'),
('TOU-ALC', 'TOU', 'ALC', '15:00:00'),
('TOU-CIU', 'TOU', 'CIU', '18:00:00');

--
-- Déclencheurs `liaison`
--
DROP TRIGGER IF EXISTS `before_insert_liaison`;
DELIMITER $$
CREATE TRIGGER `before_insert_liaison` BEFORE INSERT ON `liaison` FOR EACH ROW BEGIN
    -- Prendre les 3 premières lettres de idVilleDepart et idVilleArrivee,
    -- les convertir en majuscules et les séparer par un tiret '-'
    SET NEW.idLiai = CONCAT(UPPER(LEFT(NEW.idvilleDepart, 3)), '-', UPPER(LEFT(NEW.idvilleArrivee, 3)));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `pays`
--

DROP TABLE IF EXISTS `pays`;
CREATE TABLE IF NOT EXISTS `pays` (
  `idPays` int NOT NULL AUTO_INCREMENT,
  `nomPays` varchar(50) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `langue` varchar(50) NOT NULL,
  PRIMARY KEY (`idPays`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `pays`
--

INSERT INTO `pays` (`idPays`, `nomPays`, `description`, `langue`) VALUES
(1, 'France', NULL, 'Français'),
(2, 'Espagne', NULL, 'Espagnol'),
(3, 'Irlande', NULL, 'Irlandais'),
(4, 'Royaume-Uni', NULL, 'Anglais'),
(5, 'Tunisie', NULL, 'Arabe');

-- --------------------------------------------------------

--
-- Structure de la table `periode`
--

DROP TABLE IF EXISTS `periode`;
CREATE TABLE IF NOT EXISTS `periode` (
  `idPeriode` int NOT NULL AUTO_INCREMENT,
  `libelle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dateDebut` date DEFAULT NULL,
  `dateFin` date DEFAULT NULL,
  PRIMARY KEY (`idPeriode`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `periode`
--

INSERT INTO `periode` (`idPeriode`, `libelle`, `dateDebut`, `dateFin`) VALUES
(1, 'Basse Période', '2024-11-28', '2025-04-30'),
(2, 'Haute Période', '2025-05-01', '2025-09-30'),
(3, 'Basse Période', '2025-10-01', '2026-04-30');

-- --------------------------------------------------------

--
-- Structure de la table `personnel`
--

DROP TABLE IF EXISTS `personnel`;
CREATE TABLE IF NOT EXISTS `personnel` (
  `idPers` int NOT NULL AUTO_INCREMENT,
  `role` enum('capitaine','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `nom` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `prenom` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `nomUtilisateur` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `mdp` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`idPers`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `personnel`
--

INSERT INTO `personnel` (`idPers`, `role`, `nom`, `prenom`, `nomUtilisateur`, `mdp`) VALUES
(1, 'admin', 'Gournay', 'Julien', 'admin', 'admin');

-- --------------------------------------------------------

--
-- Structure de la table `port`
--

DROP TABLE IF EXISTS `port`;
CREATE TABLE IF NOT EXISTS `port` (
  `idVille` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ville` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `idPays` int DEFAULT NULL,
  `photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`idVille`),
  KEY `idPays` (`idPays`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `port`
--

INSERT INTO `port` (`idVille`, `ville`, `idPays`, `photo`, `description`) VALUES
('ALC', 'Alcúdia', 2, 'https://content.r9cdn.net/rimg/dimg/28/3f/f0347ffc-city-40544-1697c82a29a.jpg?crop=true&width=1020&height=498', 'Alcúdia est une ville du nord de l\'île espagnole de Majorque. Elle est connue pour ses plages méditerranéennes, comme Platja d’Alcúdia et Platja de Muro dans la baie panoramique d\'Alcúdia. L\'église néo-gothique Sant Jaume est édifiée à l\'intérieur des fortifications restaurées de la ville. Ce mur d\'enceinte entoure la vieille ville bien préservée, avec ses rues étroites et ses bâtiments vieux de plusieurs siècles.'),
('CAL', 'Calais', 1, 'https://ignrando.fr/fr/media/upload/community_photo/2017/05/29/09//450x1200c/2%20CAPS_14960704420401.jpg.png', 'Calais est une ville portuaire du nord de la France. Séparée des falaises de Douvres par la Manche, c\'est le principal point de passage des ferrys entre la France et l\'Angleterre. Sa vieille ville, Calais-Nord, occupe une île artificielle entourée de canaux. Son imposant hôtel de ville possède un beffroi de 78 mètres de haut offrant une vue sur la ville, et une célèbre statue en bronze de Rodin, Les Bourgeois de Calais.'),
('CHE', 'Cherbourg', 1, 'https://www.encotentin.fr/app/uploads/2024/05/armel-vrac-fastnet-18.webp', 'Cherbourg-en-Cotentin est une commune française située dans le département de la Manche en région Normandie, au nord de la péninsule du Cotentin. Peuplée de 77 808 habitants, elle est une ville portuaire, possédant la plus grande rade artificielle d\'Europe et la deuxième au monde.'),
('CIU', 'Ciutadella', 2, 'https://www.mallorcaauthentic.com/images/destinations/Ciutadella1.jpg', 'Ciutadella de Menorca est une ville portuaire sur la côte ouest de Minorque, l\'une des îles Baléares espagnoles. Elle est connue pour son vieux quartier et ses rues médiévales. La place principale, Plaça des Born, est le site de l\'hôtel de ville, au style gothique, et des palais Salort et Torre-Saura, datant du XIXe siècle. La cathédrale Sainte-Marie de Ciutadella, du XIVe siècle, abrite un immense autel en marbre et la chapelle des Âmes, de style baroque.'),
('DIE', 'Dieppe', 1, 'https://www.dieppetourisme.com/app/uploads/dieppe-maritime-tourisme/2021/03/thumbs/quai-henri-iv-teddy-verneuil-3-1920x960-crop-1616418393.jpg', 'Dieppe est une commune française située dans le département de la Seine-Maritime en région Normandie. Les habitants de la ville de Dieppe sont appelés les Dieppois.'),
('DOU', 'Douvres', 4, 'https://images.ctfassets.net/mivicpf5zews/55cKBW45igFPwMImoDdGzJ/e502f59ee3464410a1723c89399775a1/Explore_nature_-_2nd_Box.jpg?q=75', 'Douvres (anglais : Dover) est une ville côtière et portuaire du comté du Kent, dans le Sud-Est de l\'Angleterre. Douvres et son château. Elle est située au bord de la Manche, à 35 km des côtes françaises et du cap Gris-Nez. C\'est donc la ville du Royaume-Uni la plus proche de la France.'),
('DUB', 'Dublin', 3, 'https://blog.action-sejours.com/wp-content/uploads/2018/12/visiter-dublin.jpg', 'Dublin, capitale de l\'Irlande, est située sur la côte est de l\'Irlande à l\'embouchure de la rivière Liffey. Ses monuments historiques incluent le château de Dublin, datant du XIIIe siècle, et l\'imposante cathédrale Saint-Patrick fondée en 1191. Les grands espaces verts de la ville sont le parc paysager St Stephen\'s Green et l\'immense Phoenix Park où se trouve le zoo de Dublin. Le Musée national d\'Irlande met en avant la culture et le patrimoine irlandais.'),
('DUN', 'Dunkerque', 1, 'https://fort-des-dunes.fr/wp-content/uploads/dunkerque-768x512.jpeg', 'Dunkerque est une commune française, sous-préfecture du département du Nord. L\'histoire de Dunkerque est liée à la mer du Nord. La ville se développa autour de son port.'),
('HEL', 'Hélier', 1, 'https://a.travel-assets.com/findyours-php/viewfinder/images/res70/301000/301249-Jersey-Chan.jpg', 'Saint-Hélier est la paroisse la plus peuplée et la capitale de l\'île Anglo-Normande de Jersey. Elle se situe au sud de l\'île, à l\'est de la baie de Saint-Aubin. La paroisse comprend la plupart de la ville du même nom et un peu de la zone rurale. En langage populaire, la paroisse est couramment appelée la Ville.'),
('LEH', 'Le Havre', 1, 'https://i-de.unimedias.fr/2024/06/03/le-havre-472.jpg?auto=format%2Ccompress&crop=faces&cs=tinysrgb&fit=max&w=1050', 'Le Havre est une commune du nord-ouest de la France située dans le département de la Seine-Maritime en région Normandie. Elle se trouve sur la rive droite de l\'estuaire de la Seine, au bord de la Manche.'),
('MAL', 'Malo', 1, 'https://www.thalasso-saintmalo.com/wp-content/uploads/2018/09/saint-malo.jpg', 'Saint-Malo est une ville portuaire de Bretagne, au nord-ouest de la France. De hauts murs en granite ceignent la vieille ville, qui fut autrefois un bastion pour les corsaires (pirates approuvés par le roi). La cathédrale de Saint-Malo, au centre de la vieille ville, arbore des styles roman et gothique, et possède des vitraux narrant l\'histoire de la ville. La Demeure de Corsaire, à proximité, est une maison de corsaire datant du XVIIIe siècle. Elle sert à présent de musée.'),
('NEW', 'Newhaven', 4, 'https://images.ctfassets.net/mivicpf5zews/47H3l3LjmwIM1XqjgoWzF8/3bcb90aa84719ed6291cac70c4a6d1ee/NewHaven-Hero-1200x600.jpg', 'Newhaven est une ville portuaire d\'Angleterre, située dans le Sussex de l\'Est, sur la Manche à environ 20 minutes de Brighton. La ville est reliée par ferry à Dieppe.'),
('ROS', 'Rosslare', 3, 'https://aidfdouaniers.org/wp-content/uploads/2021/01/city-5340616_640.jpg', 'Rosslare Strand, ou plus simplement Rosslare, est une ville située au sud-est de l\'Irlande dans le comté de Wexford. Le nom de Rosslare Strand est utilisé pour distinguer la ville de l\'agglomération voisine qui s\'est développée autour du port de Rosslare.'),
('SET', 'Sète', 1, 'https://images.winalist.com/blog/wp-content/uploads/2021/05/26144006/AdobeStock_207403023.jpeg', 'Sète est une importante ville portuaire du sud-est de la France, située en Occitanie. Elle est bordée par l\'étang de Thau, un lagon d\'eau salée qui abrite diverses espèces animales. Longeant un isthme étroit, la côte méditerranéenne de Sète est constituée de plages de sable. Le sommet du mont Saint-Clair offre une vue sur la ville, aussi appelée la \"Venise du Languedoc\" en raison de son réseau de canaux. Le musée Paul Valéry présente des expositions sur l\'histoire de Sète et comporte une collection d\'œuvres d\'art'),
('TOU', 'Toulon', 1, 'https://toulon.fr/sites/new.toulon.fr/files/styles/full/public/lvs_bleumediterranee_port_002.jpg?itok=wUReHvqJ', 'Toulon est une ville portuaire située sur la côté méditerranéenne, dans le Sud de la France, bordée de plages de sable et de criques de galets. Importante base navale, son port abrite des sous-marins et des navires de guerre, ainsi que des bateaux de pêche et des ferrys. Le grand musée national de la Marine, dans le port de Toulon, expose des objets maritimes. Des sommets calcaires abrupts forment la toile de fond de la ville. Un funiculaire emmène les visiteurs jusqu\'au sommet du mont Faron.');

--
-- Déclencheurs `port`
--
DROP TRIGGER IF EXISTS `before_insert_port`;
DELIMITER $$
CREATE TRIGGER `before_insert_port` BEFORE INSERT ON `port` FOR EACH ROW BEGIN
    -- Prendre les 3 premières lettres de la colonne 'ville', les convertir en majuscule et les affecter à 'idVille'
    SET NEW.idVille = UPPER(LEFT(NEW.ville, 3));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `possede`
--

DROP TABLE IF EXISTS `possede`;
CREATE TABLE IF NOT EXISTS `possede` (
  `idBateau` int NOT NULL,
  `idEquipement` int NOT NULL,
  UNIQUE KEY `idBateau` (`idBateau`,`idEquipement`),
  KEY `idEquipement` (`idEquipement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `possede`
--

INSERT INTO `possede` (`idBateau`, `idEquipement`) VALUES
(11, 2),
(21, 2),
(3, 3),
(4, 4),
(11, 4),
(3, 5),
(21, 5),
(3, 6),
(17, 6),
(11, 7),
(21, 7),
(11, 8);

-- --------------------------------------------------------

--
-- Structure de la table `recommandation`
--

DROP TABLE IF EXISTS `recommandation`;
CREATE TABLE IF NOT EXISTS `recommandation` (
  `idRecommandation` int NOT NULL AUTO_INCREMENT,
  `idPays` int NOT NULL,
  `description` varchar(250) NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`idRecommandation`),
  KEY `idPays` (`idPays`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `recommandation`
--

INSERT INTO `recommandation` (`idRecommandation`, `idPays`, `description`, `date`) VALUES
(1, 4, 'Infection pulmonaire - Coronavirus Covid-19.', '2021-05-31'),
(2, 4, 'Visa en vigueur pour rentrer sur le territoire.', '2025-04-01'),
(3, 2, 'Une stricte limitation des déplacements.', '2021-05-31');

-- --------------------------------------------------------

--
-- Structure de la table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
CREATE TABLE IF NOT EXISTS `reservation` (
  `reference` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `idClient` int DEFAULT NULL,
  `idTrajet` int DEFAULT NULL,
  `etat` enum('Validé','Archivé','Annulé','En attente') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'En attente',
  `dateResa` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reference`),
  KEY `idClient` (`idClient`),
  KEY `idTrajet` (`idTrajet`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `reservation`
--

INSERT INTO `reservation` (`reference`, `idClient`, `idTrajet`, `etat`, `dateResa`) VALUES
('2ORKO00', 2, 139179, 'Archivé', '2025-05-03 20:56:28'),
('3G3XKKX', 2, NULL, 'Validé', '2025-05-06 15:05:38'),
('9N6N76H', 2, 281857, 'Archivé', '2025-05-05 23:06:01'),
('9WW1WRR', 2, 392409, 'Archivé', '2025-05-06 15:02:14'),
('EI84ES8', 2, 280299, 'Archivé', '2025-02-06 11:38:20'),
('O0XI77O', 2, 636475, 'Archivé', '2025-04-22 09:36:00'),
('R97R5RJ', 2, 491877, 'Archivé', '2025-02-06 11:42:52'),
('W292922', 2, 276244, 'Archivé', '2025-01-23 11:56:01');

--
-- Déclencheurs `reservation`
--
DROP TRIGGER IF EXISTS `before_insert_reference`;
DELIMITER $$
CREATE TRIGGER `before_insert_reference` BEFORE INSERT ON `reservation` FOR EACH ROW BEGIN
    SET NEW.reference  = generate_id_reference();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `tarif`
--

DROP TABLE IF EXISTS `tarif`;
CREATE TABLE IF NOT EXISTS `tarif` (
  `idTarif` int NOT NULL AUTO_INCREMENT,
  `idLiaison` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `idPeriode` int DEFAULT NULL,
  `idType` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `tarif` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`idTarif`),
  KEY `idTrajet` (`idLiaison`),
  KEY `idPeriode` (`idPeriode`),
  KEY `idType` (`idType`)
) ENGINE=InnoDB AUTO_INCREMENT=641 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `tarif`
-- ATTENTION : Les tarifs sont fictifs et ne reflètent pas les prix réels des traversées.
-- ATTENTION : Il s'agit d'une table de grande taille, seul un échantillon de 100 lignes est fourni sur les 650 lignes de la table.
--

INSERT INTO `tarif` (`idTarif`, `idLiaison`, `idPeriode`, `idType`, `tarif`) VALUES
(1, 'ALC-CIU', 1, 'A1', 95.00),
(2, 'ALC-CIU', 1, 'A2', 85.50),
(3, 'ALC-CIU', 1, 'A3', 71.25),
(4, 'ALC-CIU', 1, 'B1', 5.00),
(5, 'ALC-CIU', 1, 'B2', 123.50),
(6, 'ALC-CIU', 1, 'C1', 145.35),
(7, 'ALC-CIU', 1, 'C2', 171.00),
(8, 'ALC-CIU', 1, 'C3', 175.75),
(9, 'ALC-CIU', 1, 'D1', 204.25),
(10, 'ALC-CIU', 1, 'D2', 199.50),
(11, 'ALC-SET', 1, 'A1', 70.00),
(12, 'ALC-SET', 1, 'A2', 63.00),
(13, 'ALC-SET', 1, 'A3', 52.50),
(14, 'ALC-SET', 1, 'B1', 5.00),
(15, 'ALC-SET', 1, 'B2', 91.00),
(16, 'ALC-SET', 1, 'C1', 107.10),
(17, 'ALC-SET', 1, 'C2', 126.00),
(18, 'ALC-SET', 1, 'C3', 129.50),
(19, 'ALC-SET', 1, 'D1', 150.50),
(20, 'ALC-SET', 1, 'D2', 147.00),
(21, 'ALC-TOU', 1, 'A1', 36.00),
(22, 'ALC-TOU', 1, 'A2', 32.40),
(23, 'ALC-TOU', 1, 'A3', 27.00),
(24, 'ALC-TOU', 1, 'B1', 5.00),
(25, 'ALC-TOU', 1, 'B2', 46.80),
(26, 'ALC-TOU', 1, 'C1', 55.08),
(27, 'ALC-TOU', 1, 'C2', 64.80),
(28, 'ALC-TOU', 1, 'C3', 66.60),
(29, 'ALC-TOU', 1, 'D1', 77.40),
(30, 'ALC-TOU', 1, 'D2', 75.60),
(31, 'CAL-DOU', 1, 'A1', 35.00),
(32, 'CAL-DOU', 1, 'A2', 31.50),
(33, 'CAL-DOU', 1, 'A3', 26.25),
(34, 'CAL-DOU', 1, 'B1', 5.00),
(35, 'CAL-DOU', 1, 'B2', 45.50),
(36, 'CAL-DOU', 1, 'C1', 53.55),
(37, 'CAL-DOU', 1, 'C2', 63.00),
(38, 'CAL-DOU', 1, 'C3', 64.75),
(39, 'CAL-DOU', 1, 'D1', 75.25),
(40, 'CAL-DOU', 1, 'D2', 73.50),
(41, 'CHE-DUB', 1, 'A1', 130.00),
(42, 'CHE-DUB', 1, 'A2', 117.00),
(43, 'CHE-DUB', 1, 'A3', 97.50),
(44, 'CHE-DUB', 1, 'B1', 5.00),
(45, 'CHE-DUB', 1, 'B2', 169.00),
(46, 'CHE-DUB', 1, 'C1', 198.90),
(47, 'CHE-DUB', 1, 'C2', 234.00),
(48, 'CHE-DUB', 1, 'C3', 240.50),
(49, 'CHE-DUB', 1, 'D1', 279.50),
(50, 'CHE-DUB', 1, 'D2', 273.00),
(51, 'CHE-HEL', 1, 'A1', 55.00),
(52, 'CHE-HEL', 1, 'A2', 49.50),
(53, 'CHE-HEL', 1, 'A3', 41.25),
(54, 'CHE-HEL', 1, 'B1', 5.00),
(55, 'CHE-HEL', 1, 'B2', 71.50),
(56, 'CHE-HEL', 1, 'C1', 84.15),
(57, 'CHE-HEL', 1, 'C2', 99.00),
(58, 'CHE-HEL', 1, 'C3', 101.75),
(59, 'CHE-HEL', 1, 'D1', 118.25),
(60, 'CHE-HEL', 1, 'D2', 115.50),
(61, 'CHE-ROS', 1, 'A1', 130.00),
(62, 'CHE-ROS', 1, 'A2', 117.00),
(63, 'CHE-ROS', 1, 'A3', 97.50),
(64, 'CHE-ROS', 1, 'B1', 5.00),
(65, 'CHE-ROS', 1, 'B2', 169.00),
(66, 'CHE-ROS', 1, 'C1', 198.90),
(67, 'CHE-ROS', 1, 'C2', 234.00),
(68, 'CHE-ROS', 1, 'C3', 240.50),
(69, 'CHE-ROS', 1, 'D1', 279.50),
(70, 'CHE-ROS', 1, 'D2', 273.00),
(71, 'CIU-ALC', 1, 'A1', 95.00),
(72, 'CIU-ALC', 1, 'A2', 85.50),
(73, 'CIU-ALC', 1, 'A3', 71.25),
(74, 'CIU-ALC', 1, 'B1', 5.00),
(75, 'CIU-ALC', 1, 'B2', 123.50),
(76, 'CIU-ALC', 1, 'C1', 145.35),
(77, 'CIU-ALC', 1, 'C2', 171.00),
(78, 'CIU-ALC', 1, 'C3', 175.75),
(79, 'CIU-ALC', 1, 'D1', 204.25),
(80, 'CIU-ALC', 1, 'D2', 199.50),
(81, 'CIU-TOU', 1, 'A1', 45.00),
(82, 'CIU-TOU', 1, 'A2', 40.50),
(83, 'CIU-TOU', 1, 'A3', 33.75),
(84, 'CIU-TOU', 1, 'B1', 5.00),
(85, 'CIU-TOU', 1, 'B2', 58.50),
(86, 'CIU-TOU', 1, 'C1', 68.85),
(87, 'CIU-TOU', 1, 'C2', 81.00),
(88, 'CIU-TOU', 1, 'C3', 83.25),
(89, 'CIU-TOU', 1, 'D1', 96.75),
(90, 'CIU-TOU', 1, 'D2', 94.50),
(91, 'DIE-NEW', 1, 'A1', 40.00),
(92, 'DIE-NEW', 1, 'A2', 36.00),
(93, 'DIE-NEW', 1, 'A3', 30.00),
(94, 'DIE-NEW', 1, 'B1', 5.00),
(95, 'DIE-NEW', 1, 'B2', 52.00),
(96, 'DIE-NEW', 1, 'C1', 61.20),
(97, 'DIE-NEW', 1, 'C2', 72.00),
(98, 'DIE-NEW', 1, 'C3', 74.00),
(99, 'DIE-NEW', 1, 'D1', 86.00),
(100, 'DIE-NEW', 1, 'D2', 84.00),
(101, 'DOU-CAL', 1, 'A1', 35.00);

-- --------------------------------------------------------

--
-- Structure de la table `trajet`
--

DROP TABLE IF EXISTS `trajet`;
CREATE TABLE IF NOT EXISTS `trajet` (
  `idTrajet` int NOT NULL AUTO_INCREMENT,
  `idLiaison` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `idBateau` int DEFAULT NULL,
  `dateDepart` date DEFAULT NULL,
  `heureDepart` time DEFAULT NULL,
  `dateArrivee` date DEFAULT NULL,
  `heureArrivee` time DEFAULT NULL,
  PRIMARY KEY (`idTrajet`),
  KEY `idLiai` (`idLiaison`),
  KEY `idBateau` (`idBateau`)
) ENGINE=InnoDB AUTO_INCREMENT=999981 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `trajet`
-- ATTENTION : Il s'agit d'une table de grande taille, seul un échantillon de 250 lignes est fourni sur les 80000 lignes de la table.
--

INSERT INTO `trajet` (`idTrajet`, `idLiaison`, `idBateau`, `dateDepart`, `heureDepart`, `dateArrivee`, `heureArrivee`) VALUES
(9, 'ALC-CIU', 16, '2025-07-14', '06:14:00', '2025-07-14', '07:14:00'),
(23, 'CAL-DOU', 7, '2025-07-25', '11:04:00', '2025-07-25', '12:34:00'),
(37, 'DOU-DUB', 20, '2025-01-21', '15:14:00', '2025-01-21', '18:29:00'),
(45, 'NEW-LEH', 11, '2025-09-28', '18:46:00', '2025-09-28', '23:16:00'),
(50, 'ROS-CHE', 1, '2025-01-23', '20:06:00', '2025-01-23', '14:06:00'),
(70, 'NEW-LEH', 7, '2025-02-24', '20:21:00', '2025-02-24', '00:51:00'),
(76, 'CHE-HEL', 16, '2025-03-23', '12:40:00', '2025-03-23', '14:40:00'),
(81, 'NEW-DUB', 12, '2025-06-02', '08:21:00', '2025-06-02', '11:51:00'),
(82, 'DUB-HEL', 22, '2025-08-04', '16:24:00', '2025-08-04', '19:39:00'),
(115, 'DOU-DUN', 16, '2025-07-22', '10:12:00', '2025-07-22', '12:12:00'),
(122, 'CAL-DOU', 19, '2025-12-16', '07:59:00', '2025-12-16', '09:29:00'),
(130, 'DOU-DUN', 22, '2025-08-11', '20:37:00', '2025-08-11', '22:37:00'),
(140, 'NEW-ROS', 21, '2025-08-14', '17:31:00', '2025-08-14', '21:01:00'),
(152, 'HEL-DUB', 6, '2025-05-08', '13:15:00', '2025-05-08', '16:30:00'),
(178, 'NEW-DUB', 20, '2025-06-02', '12:24:00', '2025-06-02', '15:54:00'),
(180, 'NEW-DIE', 19, '2025-11-09', '07:54:00', '2025-11-09', '11:54:00'),
(190, 'DIE-NEW', 22, '2025-10-01', '16:34:00', '2025-10-01', '20:34:00'),
(200, 'CHE-HEL', 20, '2025-05-15', '20:20:00', '2025-05-15', '22:20:00'),
(206, 'CIU-ALC', 25, '2025-08-01', '16:58:00', '2025-08-01', '17:58:00'),
(207, 'NEW-DUB', 16, '2025-01-26', '07:59:00', '2025-01-26', '11:29:00'),
(223, 'ALC-CIU', 8, '2025-02-02', '18:16:00', '2025-02-02', '19:16:00'),
(286, 'DUB-CHE', 23, '2025-07-23', '17:06:00', '2025-07-23', '20:06:00'),
(321, 'NEW-LEH', 6, '2025-08-08', '14:28:00', '2025-08-08', '18:58:00'),
(323, 'ALC-TOU', 1, '2025-04-29', '09:17:00', '2025-04-29', '00:17:00'),
(334, 'NEW-DIE', 15, '2025-02-18', '10:29:00', '2025-02-18', '14:29:00'),
(374, 'NEW-DIE', 3, '2025-08-12', '13:30:00', '2025-08-12', '17:30:00'),
(375, 'CHE-DUB', 16, '2025-11-17', '07:57:00', '2025-11-17', '10:57:00'),
(406, 'ALC-TOU', 4, '2025-08-14', '20:18:00', '2025-08-14', '11:18:00'),
(408, 'DUB-NEW', 24, '2025-02-28', '12:32:00', '2025-02-28', '16:02:00'),
(420, 'CHE-ROS', 22, '2025-02-18', '21:38:00', '2025-02-18', '15:38:00'),
(468, 'DOU-DUN', 18, '2025-07-31', '12:47:00', '2025-07-31', '14:47:00'),
(481, 'ROS-NEW', 2, '2025-07-07', '18:30:00', '2025-07-07', '22:00:00'),
(488, 'DOU-DUN', 15, '2025-04-23', '15:27:00', '2025-04-23', '17:27:00'),
(495, 'DOU-DUN', 4, '2025-06-11', '20:16:00', '2025-06-11', '22:16:00'),
(497, 'ROS-NEW', 15, '2025-08-15', '13:25:00', '2025-08-15', '16:55:00'),
(519, 'DOU-DUB', 4, '2025-12-21', '07:03:00', '2025-12-21', '10:18:00'),
(520, 'CIU-ALC', 2, '2025-09-30', '19:31:00', '2025-09-30', '20:31:00'),
(523, 'NEW-LEH', 2, '2025-05-29', '07:29:00', '2025-05-29', '11:59:00'),
(524, 'DUN-DOU', 16, '2025-01-19', '19:19:00', '2025-01-19', '21:19:00'),
(529, 'CHE-ROS', 19, '2025-02-08', '16:41:00', '2025-02-08', '10:41:00'),
(540, 'NEW-LEH', 23, '2025-05-14', '17:23:00', '2025-05-14', '21:53:00'),
(550, 'ROS-CHE', 13, '2025-09-08', '12:42:00', '2025-09-08', '06:42:00'),
(569, 'DOU-DUN', 14, '2025-12-25', '14:39:00', '2025-12-25', '16:39:00'),
(590, 'DOU-CAL', 21, '2025-04-17', '06:38:00', '2025-04-17', '08:08:00'),
(594, 'DOU-CAL', 22, '2025-10-17', '21:00:00', '2025-10-17', '22:30:00'),
(596, 'ALC-CIU', 10, '2025-07-28', '12:02:00', '2025-07-28', '13:02:00'),
(600, 'NEW-DIE', 11, '2025-07-13', '10:10:00', '2025-07-13', '14:10:00'),
(621, 'SET-ALC', 23, '2025-11-13', '11:08:00', '2025-11-13', '02:08:00'),
(629, 'NEW-DUB', 14, '2025-12-14', '13:37:00', '2025-12-14', '17:07:00'),
(642, 'ROS-NEW', 7, '2025-03-10', '10:54:00', '2025-03-10', '14:24:00'),
(646, 'NEW-DUB', 23, '2025-06-02', '08:13:00', '2025-06-02', '11:43:00'),
(662, 'HEL-DUB', 14, '2025-06-10', '08:56:00', '2025-06-10', '12:11:00'),
(688, 'NEW-DUB', 12, '2025-02-09', '06:00:00', '2025-02-09', '09:30:00'),
(692, 'DUB-DOU', 17, '2025-09-05', '18:14:00', '2025-09-05', '21:29:00'),
(697, 'DOU-ROS', 24, '2025-08-10', '16:45:00', '2025-08-10', '20:15:00'),
(700, 'CIU-ALC', 24, '2025-10-28', '14:56:00', '2025-10-28', '15:56:00'),
(717, 'DOU-ROS', 23, '2025-11-17', '09:13:00', '2025-11-17', '12:43:00'),
(727, 'NEW-ROS', 25, '2025-09-12', '14:43:00', '2025-09-12', '18:13:00'),
(730, 'ALC-CIU', 17, '2025-10-15', '09:45:00', '2025-10-15', '10:45:00'),
(737, 'CIU-ALC', 24, '2025-08-02', '10:34:00', '2025-08-02', '11:34:00'),
(749, 'CHE-ROS', 1, '2025-12-09', '07:54:00', '2025-12-09', '01:54:00'),
(818, 'DUB-DOU', 12, '2025-03-29', '18:05:00', '2025-03-29', '21:20:00'),
(827, 'ROS-DOU', 25, '2025-05-18', '07:20:00', '2025-05-18', '10:50:00'),
(832, 'TOU-ALC', 3, '2025-04-05', '07:27:00', '2025-04-05', '22:27:00'),
(846, 'ROS-CHE', 25, '2025-03-30', '21:38:00', '2025-03-30', '15:38:00'),
(864, 'CIU-TOU', 21, '2025-06-21', '15:32:00', '2025-06-21', '09:32:00'),
(879, 'NEW-DIE', 14, '2025-02-08', '06:42:00', '2025-02-08', '10:42:00'),
(881, 'DIE-NEW', 12, '2025-07-31', '16:22:00', '2025-07-31', '20:22:00'),
(894, 'CAL-DOU', 19, '2025-05-12', '20:05:00', '2025-05-12', '21:35:00'),
(897, 'NEW-DUB', 19, '2025-02-19', '14:02:00', '2025-02-19', '17:32:00'),
(898, 'DOU-ROS', 7, '2025-12-24', '12:16:00', '2025-12-24', '15:46:00'),
(910, 'DUN-DOU', 9, '2025-07-06', '06:54:00', '2025-07-06', '08:54:00'),
(911, 'ROS-NEW', 19, '2025-11-06', '17:28:00', '2025-11-06', '20:58:00'),
(926, 'DOU-DUB', 8, '2025-07-08', '17:55:00', '2025-07-08', '21:10:00'),
(927, 'DOU-CAL', 4, '2025-02-16', '14:56:00', '2025-02-16', '16:26:00'),
(932, 'CAL-DOU', 15, '2025-09-03', '12:23:00', '2025-09-03', '13:53:00'),
(940, 'CHE-DUB', 19, '2025-07-31', '07:18:00', '2025-07-31', '10:18:00'),
(978, 'DUB-NEW', 21, '2025-06-09', '18:40:00', '2025-06-09', '22:10:00'),
(982, 'DUB-CHE', 11, '2025-09-15', '14:26:00', '2025-09-15', '17:26:00'),
(998, 'HEL-CHE', 8, '2025-11-25', '07:20:00', '2025-11-25', '09:20:00'),
(1009, 'ALC-TOU', 21, '2025-07-14', '13:57:00', '2025-07-14', '04:57:00'),
(1015, 'DIE-NEW', 3, '2025-07-05', '07:38:00', '2025-07-05', '11:38:00'),
(1019, 'ALC-SET', 1, '2025-10-20', '10:29:00', '2025-10-20', '01:29:00'),
(1036, 'NEW-LEH', 7, '2025-09-09', '07:48:00', '2025-09-09', '12:18:00'),
(1045, 'NEW-DUB', 6, '2025-09-12', '07:14:00', '2025-09-12', '10:44:00'),
(1051, 'DUB-DOU', 7, '2025-12-01', '19:24:00', '2025-12-01', '22:39:00'),
(1053, 'CHE-ROS', 14, '2025-07-31', '08:46:00', '2025-07-31', '02:46:00'),
(1067, 'SET-ALC', 4, '2025-04-09', '13:55:00', '2025-04-09', '04:55:00'),
(1071, 'DUN-DOU', 21, '2025-02-03', '16:13:00', '2025-02-03', '18:13:00'),
(1103, 'TOU-CIU', 15, '2025-07-05', '20:16:00', '2025-07-05', '14:16:00'),
(1109, 'DIE-NEW', 17, '2025-03-17', '18:10:00', '2025-03-17', '22:10:00'),
(1111, 'NEW-LEH', 20, '2025-11-04', '07:13:00', '2025-11-04', '11:43:00'),
(1125, 'ROS-NEW', 21, '2025-12-13', '15:59:00', '2025-12-13', '19:29:00'),
(1128, 'TOU-ALC', 11, '2025-04-13', '19:14:00', '2025-04-13', '10:14:00'),
(1137, 'CAL-DOU', 8, '2025-12-23', '08:43:00', '2025-12-23', '10:13:00'),
(1145, 'DOU-ROS', 9, '2025-08-17', '09:31:00', '2025-08-17', '13:01:00'),
(1151, 'LEH-NEW', 13, '2025-10-21', '19:34:00', '2025-10-21', '00:04:00'),
(1157, 'DOU-CAL', 15, '2025-06-21', '09:05:00', '2025-06-21', '10:35:00'),
(1158, 'NEW-ROS', 15, '2025-07-02', '21:54:00', '2025-07-02', '01:24:00'),
(1184, 'CIU-TOU', 3, '2025-10-01', '11:14:00', '2025-10-01', '05:14:00'),
(1185, 'NEW-DUB', 15, '2025-09-26', '14:17:00', '2025-09-26', '17:47:00'),
(1229, 'DOU-ROS', 9, '2025-12-18', '20:52:00', '2025-12-18', '00:22:00'),
(1250, 'DIE-NEW', 6, '2025-07-15', '21:48:00', '2025-07-15', '01:48:00'),
(1255, 'ROS-CHE', 19, '2025-04-19', '20:00:00', '2025-04-19', '14:00:00'),
(1295, 'CAL-DOU', 21, '2025-02-01', '15:15:00', '2025-02-01', '16:45:00'),
(1297, 'DOU-CAL', 21, '2025-05-17', '12:31:00', '2025-05-17', '14:01:00'),
(1306, 'DOU-CAL', 18, '2025-11-24', '06:47:00', '2025-11-24', '08:17:00'),
(1318, 'ALC-CIU', 4, '2025-06-23', '07:02:00', '2025-06-23', '08:02:00'),
(1320, 'DUN-DOU', 20, '2025-02-10', '08:59:00', '2025-02-10', '10:59:00'),
(1329, 'DIE-NEW', 7, '2025-08-13', '20:07:00', '2025-08-13', '00:07:00'),
(1354, 'CAL-DOU', 5, '2025-07-06', '12:03:00', '2025-07-06', '13:33:00'),
(1377, 'NEW-DIE', 7, '2025-06-29', '14:21:00', '2025-06-29', '18:21:00'),
(1380, 'CIU-TOU', 5, '2025-12-07', '08:41:00', '2025-12-07', '02:41:00'),
(1403, 'DOU-ROS', 19, '2025-03-14', '20:17:00', '2025-03-14', '23:47:00'),
(1414, 'DUB-DOU', 23, '2025-10-13', '08:32:00', '2025-10-13', '11:47:00'),
(1426, 'CHE-DUB', 6, '2025-03-02', '06:18:00', '2025-03-02', '09:18:00'),
(1430, 'NEW-DIE', 7, '2025-04-11', '21:25:00', '2025-04-11', '01:25:00'),
(1431, 'ALC-CIU', 12, '2025-11-03', '09:57:00', '2025-11-03', '10:57:00'),
(1446, 'CIU-ALC', 9, '2025-03-24', '20:41:00', '2025-03-24', '21:41:00'),
(1450, 'DUB-CHE', 14, '2025-01-20', '12:30:00', '2025-01-20', '15:30:00'),
(1457, 'ALC-SET', 2, '2025-04-28', '18:50:00', '2025-04-28', '09:50:00'),
(1470, 'NEW-DIE', 24, '2025-03-23', '18:35:00', '2025-03-23', '22:35:00'),
(1495, 'ALC-CIU', 14, '2025-08-16', '11:57:00', '2025-08-16', '12:57:00'),
(1498, 'ALC-TOU', 6, '2025-04-05', '06:46:00', '2025-04-05', '21:46:00'),
(1509, 'CHE-HEL', 8, '2025-08-01', '19:13:00', '2025-08-01', '21:13:00'),
(1525, 'CHE-DUB', 9, '2025-12-22', '07:46:00', '2025-12-22', '10:46:00'),
(1532, 'DUB-DOU', 5, '2025-06-30', '16:45:00', '2025-06-30', '20:00:00'),
(1539, 'DOU-DUN', 22, '2025-02-20', '21:26:00', '2025-02-20', '23:26:00'),
(1541, 'ROS-DOU', 7, '2025-10-04', '16:31:00', '2025-10-04', '20:01:00'),
(1542, 'DOU-ROS', 14, '2025-05-25', '17:35:00', '2025-05-25', '21:05:00'),
(1548, 'ALC-TOU', 6, '2025-01-21', '17:32:00', '2025-01-21', '08:32:00'),
(1554, 'ALC-CIU', 8, '2025-02-24', '08:20:00', '2025-02-24', '09:20:00'),
(1556, 'ROS-DOU', 20, '2025-09-04', '09:50:00', '2025-09-04', '13:20:00'),
(1575, 'DIE-NEW', 8, '2025-03-13', '12:52:00', '2025-03-13', '16:52:00'),
(1586, 'NEW-ROS', 24, '2025-10-22', '12:55:00', '2025-10-22', '16:25:00'),
(1590, 'DOU-CAL', 16, '2025-08-07', '16:35:00', '2025-08-07', '18:05:00'),
(1600, 'DOU-DUB', 13, '2025-10-08', '15:47:00', '2025-10-08', '19:02:00'),
(1619, 'ROS-CHE', 14, '2025-12-01', '18:42:00', '2025-12-01', '12:42:00'),
(1665, 'CHE-ROS', 19, '2025-04-01', '11:42:00', '2025-04-01', '05:42:00'),
(1668, 'NEW-ROS', 21, '2025-08-24', '13:45:00', '2025-08-24', '17:15:00'),
(1681, 'ALC-CIU', 7, '2025-10-04', '20:05:00', '2025-10-04', '21:05:00'),
(1683, 'DUB-CHE', 14, '2025-06-17', '18:40:00', '2025-06-17', '21:40:00'),
(1689, 'NEW-LEH', 8, '2025-02-06', '08:39:00', '2025-02-06', '13:09:00'),
(1692, 'DIE-NEW', 5, '2025-02-04', '07:39:00', '2025-02-04', '11:39:00'),
(1700, 'HEL-CHE', 15, '2025-01-31', '19:09:00', '2025-01-31', '21:09:00'),
(1703, 'DIE-NEW', 17, '2025-02-07', '15:20:00', '2025-02-07', '19:20:00'),
(1704, 'LEH-NEW', 24, '2025-01-28', '07:56:00', '2025-01-28', '12:26:00'),
(1727, 'ALC-TOU', 10, '2025-12-16', '08:35:00', '2025-12-16', '23:35:00'),
(1755, 'ALC-CIU', 3, '2025-08-20', '14:02:00', '2025-08-20', '15:02:00'),
(1784, 'LEH-NEW', 14, '2025-07-11', '21:02:00', '2025-07-11', '01:32:00'),
(1817, 'DOU-CAL', 4, '2025-03-19', '19:24:00', '2025-03-19', '20:54:00'),
(1822, 'DOU-DUN', 24, '2025-10-02', '18:31:00', '2025-10-02', '20:31:00'),
(1823, 'DIE-NEW', 23, '2025-10-24', '13:18:00', '2025-10-24', '17:18:00'),
(1829, 'CAL-DOU', 21, '2025-02-21', '15:30:00', '2025-02-21', '17:00:00'),
(1830, 'NEW-DUB', 22, '2025-12-24', '18:30:00', '2025-12-24', '22:00:00'),
(1834, 'CHE-DUB', 9, '2025-01-21', '08:20:00', '2025-01-21', '11:20:00'),
(1859, 'ALC-TOU', 24, '2025-06-04', '19:07:00', '2025-06-04', '10:07:00'),
(1861, 'DIE-NEW', 17, '2025-12-11', '08:07:00', '2025-12-11', '12:07:00'),
(1863, 'CIU-TOU', 21, '2025-04-09', '08:45:00', '2025-04-09', '02:45:00'),
(1870, 'NEW-DUB', 24, '2025-06-09', '15:50:00', '2025-06-09', '19:20:00'),
(1879, 'NEW-DUB', 17, '2025-12-07', '15:24:00', '2025-12-07', '18:54:00'),
(1903, 'CIU-ALC', 9, '2025-10-12', '18:17:00', '2025-10-12', '19:17:00'),
(1910, 'ALC-TOU', 4, '2025-01-18', '20:08:00', '2025-01-18', '11:08:00'),
(1928, 'TOU-ALC', 16, '2025-04-16', '13:35:00', '2025-04-16', '04:35:00'),
(1937, 'ALC-TOU', 5, '2025-09-23', '19:25:00', '2025-09-23', '10:25:00'),
(1947, 'ALC-SET', 5, '2025-12-10', '20:24:00', '2025-12-10', '11:24:00'),
(1951, 'ALC-TOU', 19, '2025-05-29', '12:09:00', '2025-05-29', '03:09:00'),
(1958, 'ROS-CHE', 3, '2025-03-18', '12:39:00', '2025-03-18', '06:39:00'),
(1969, 'DUB-DOU', 11, '2025-08-14', '11:47:00', '2025-08-14', '15:02:00'),
(1972, 'CHE-HEL', 2, '2025-12-06', '08:13:00', '2025-12-06', '10:13:00'),
(1973, 'NEW-DIE', 4, '2025-09-04', '20:15:00', '2025-09-04', '00:15:00'),
(1975, 'HEL-DUB', 4, '2025-05-17', '11:21:00', '2025-05-17', '14:36:00'),
(1979, 'DUB-DOU', 21, '2025-05-16', '11:39:00', '2025-05-16', '14:54:00'),
(1980, 'NEW-DIE', 4, '2025-12-26', '10:03:00', '2025-12-26', '14:03:00'),
(1988, 'DOU-DUN', 25, '2025-02-11', '22:00:00', '2025-02-11', '00:00:00'),
(1989, 'ALC-CIU', 12, '2025-11-04', '21:57:00', '2025-11-04', '22:57:00'),
(1995, 'CIU-ALC', 1, '2025-09-05', '11:16:00', '2025-09-05', '12:16:00'),
(2002, 'TOU-CIU', 15, '2025-03-02', '14:51:00', '2025-03-02', '08:51:00'),
(2041, 'CIU-TOU', 12, '2025-11-19', '12:33:00', '2025-11-19', '06:33:00'),
(2048, 'SET-ALC', 25, '2025-10-22', '19:26:00', '2025-10-22', '10:26:00'),
(2060, 'DUN-DOU', 23, '2025-07-03', '13:28:00', '2025-07-03', '15:28:00'),
(2076, 'CIU-ALC', 1, '2025-03-09', '19:55:00', '2025-03-09', '20:55:00'),
(2081, 'DOU-DUN', 23, '2025-09-25', '09:51:00', '2025-09-25', '11:51:00'),
(2094, 'DUB-NEW', 12, '2025-05-13', '18:54:00', '2025-05-13', '22:24:00'),
(2095, 'CHE-ROS', 5, '2025-04-25', '10:05:00', '2025-04-25', '04:05:00'),
(2097, 'CHE-DUB', 22, '2025-10-28', '20:19:00', '2025-10-28', '23:19:00'),
(2099, 'CHE-DUB', 20, '2025-08-29', '16:07:00', '2025-08-29', '19:07:00'),
(2109, 'TOU-CIU', 22, '2025-03-18', '06:45:00', '2025-03-18', '00:45:00'),
(2131, 'NEW-ROS', 19, '2025-10-07', '14:07:00', '2025-10-07', '17:37:00'),
(2138, 'ALC-SET', 9, '2025-08-11', '21:32:00', '2025-08-11', '12:32:00'),
(2142, 'DUB-DOU', 16, '2025-12-12', '17:37:00', '2025-12-12', '20:52:00'),
(2149, 'CHE-HEL', 6, '2025-03-06', '11:52:00', '2025-03-06', '13:52:00'),
(2164, 'NEW-ROS', 25, '2025-02-08', '10:05:00', '2025-02-08', '13:35:00'),
(2168, 'ROS-DOU', 14, '2025-04-15', '10:10:00', '2025-04-15', '13:40:00'),
(2170, 'TOU-CIU', 12, '2025-09-17', '21:08:00', '2025-09-17', '15:08:00'),
(2176, 'TOU-CIU', 18, '2025-06-07', '21:19:00', '2025-06-07', '15:19:00'),
(2202, 'SET-ALC', 6, '2025-06-07', '17:27:00', '2025-06-07', '08:27:00'),
(2216, 'DOU-DUB', 22, '2025-04-22', '07:54:00', '2025-04-22', '11:09:00'),
(2220, 'LEH-NEW', 14, '2025-01-30', '19:54:00', '2025-01-30', '00:24:00'),
(2240, 'SET-ALC', 20, '2025-03-25', '07:15:00', '2025-03-25', '22:15:00'),
(2244, 'DUB-CHE', 7, '2025-01-19', '07:14:00', '2025-01-19', '10:14:00'),
(2252, 'DUN-DOU', 8, '2025-08-01', '08:32:00', '2025-08-01', '10:32:00'),
(2253, 'DUN-DOU', 25, '2025-04-17', '19:12:00', '2025-04-17', '21:12:00'),
(2256, 'ALC-SET', 14, '2025-06-27', '11:25:00', '2025-06-27', '02:25:00'),
(2257, 'ALC-CIU', 3, '2025-05-12', '18:35:00', '2025-05-12', '19:35:00'),
(2262, 'DUB-CHE', 4, '2025-04-11', '09:16:00', '2025-04-11', '12:16:00'),
(2274, 'HEL-CHE', 24, '2025-04-10', '07:37:00', '2025-04-10', '09:37:00'),
(2279, 'LEH-NEW', 5, '2025-10-31', '12:25:00', '2025-10-31', '16:55:00'),
(2295, 'CHE-HEL', 24, '2025-09-04', '07:54:00', '2025-09-04', '09:54:00'),
(2337, 'NEW-ROS', 5, '2025-09-09', '12:27:00', '2025-09-09', '15:57:00'),
(2348, 'ALC-SET', 16, '2025-05-06', '10:13:00', '2025-05-06', '01:13:00'),
(2355, 'CHE-HEL', 22, '2025-05-21', '16:17:00', '2025-05-21', '18:17:00'),
(2414, 'DUN-DOU', 4, '2025-05-14', '12:25:00', '2025-05-14', '14:25:00'),
(2424, 'SET-ALC', 2, '2025-09-16', '16:10:00', '2025-09-16', '07:10:00'),
(2445, 'DUB-DOU', 15, '2025-09-04', '09:14:00', '2025-09-04', '12:29:00'),
(2447, 'ROS-CHE', 25, '2025-10-27', '09:14:00', '2025-10-27', '03:14:00'),
(2448, 'LEH-NEW', 17, '2025-07-21', '15:59:00', '2025-07-21', '20:29:00'),
(2454, 'TOU-CIU', 14, '2025-11-09', '16:39:00', '2025-11-09', '10:39:00'),
(2457, 'ROS-CHE', 8, '2025-06-05', '09:10:00', '2025-06-05', '03:10:00'),
(2462, 'DOU-CAL', 22, '2025-01-22', '13:44:00', '2025-01-22', '15:14:00'),
(2471, 'ROS-NEW', 13, '2025-05-11', '13:25:00', '2025-05-11', '16:55:00'),
(2497, 'SET-ALC', 24, '2025-04-21', '12:23:00', '2025-04-21', '03:23:00'),
(2508, 'SET-ALC', 16, '2025-02-28', '15:28:00', '2025-02-28', '06:28:00'),
(2510, 'ALC-SET', 12, '2025-10-03', '14:23:00', '2025-10-03', '05:23:00'),
(2516, 'CHE-ROS', 21, '2025-01-17', '09:36:00', '2025-01-17', '03:36:00'),
(2521, 'ROS-DOU', 8, '2025-04-26', '13:09:00', '2025-04-26', '16:39:00'),
(2522, 'DOU-DUB', 25, '2025-12-15', '19:48:00', '2025-12-15', '23:03:00'),
(2550, 'DUN-DOU', 9, '2025-07-03', '21:13:00', '2025-07-03', '23:13:00'),
(2555, 'ROS-NEW', 24, '2025-12-13', '13:07:00', '2025-12-13', '16:37:00'),
(2567, 'NEW-DUB', 20, '2025-06-24', '19:16:00', '2025-06-24', '22:46:00'),
(2615, 'NEW-DIE', 9, '2025-01-22', '11:33:00', '2025-01-22', '15:33:00'),
(2658, 'DOU-ROS', 23, '2025-02-26', '21:15:00', '2025-02-26', '00:45:00'),
(2665, 'ROS-NEW', 15, '2025-07-02', '15:05:00', '2025-07-02', '18:35:00'),
(2695, 'CIU-ALC', 9, '2025-08-19', '16:31:00', '2025-08-19', '17:31:00'),
(2699, 'NEW-DUB', 2, '2025-06-03', '08:00:00', '2025-06-03', '11:30:00'),
(2704, 'CHE-ROS', 13, '2025-04-30', '06:06:00', '2025-04-30', '00:06:00'),
(2725, 'ALC-CIU', 2, '2025-03-03', '21:48:00', '2025-03-03', '22:48:00'),
(2730, 'ALC-TOU', 22, '2025-06-02', '11:30:00', '2025-06-02', '02:30:00'),
(2742, 'TOU-CIU', 14, '2025-01-21', '20:24:00', '2025-01-21', '14:24:00'),
(2745, 'ROS-DOU', 5, '2025-07-22', '20:20:00', '2025-07-22', '23:50:00'),
(2749, 'CHE-HEL', 19, '2025-12-18', '20:37:00', '2025-12-18', '22:37:00'),
(2750, 'ALC-TOU', 9, '2025-03-30', '09:47:00', '2025-03-30', '00:47:00'),
(2751, 'DUN-DOU', 21, '2025-07-22', '20:14:00', '2025-07-22', '22:14:00'),
(2758, 'DUB-NEW', 10, '2025-06-12', '13:34:00', '2025-06-12', '17:04:00'),
(2760, 'ROS-CHE', 25, '2025-04-05', '21:03:00', '2025-04-05', '15:03:00'),
(2765, 'DUB-HEL', 18, '2025-08-11', '21:11:00', '2025-08-11', '00:26:00'),
(2772, 'DUB-NEW', 23, '2025-10-26', '10:51:00', '2025-10-26', '14:21:00'),
(2780, 'TOU-ALC', 2, '2025-08-09', '17:44:00', '2025-08-09', '08:44:00'),
(2783, 'ALC-SET', 21, '2025-09-25', '10:40:00', '2025-09-25', '01:40:00'),
(2789, 'HEL-DUB', 11, '2025-07-19', '12:41:00', '2025-07-19', '15:56:00');



--
-- Déclencheurs `trajet`
--
DROP TRIGGER IF EXISTS `before_insert_trajet`;
DELIMITER $$
CREATE TRIGGER `before_insert_trajet` BEFORE INSERT ON `trajet` FOR EACH ROW BEGIN
    DECLARE newId CHAR(6);
    DECLARE idExists INT;

    -- Répéter jusqu'à trouver un ID unique
    REPEAT
        SET newId = generateIdTrajet(); -- Génère un nouvel ID
        SELECT COUNT(*) INTO idExists FROM trajet WHERE idTrajet = newId; -- Vérifie unicité
    UNTIL idExists = 0 -- Continue jusqu'à ce qu'il n'existe pas
    END REPEAT;

    -- Assigne l'ID unique à la nouvelle ligne
    SET NEW.idTrajet = newId;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `type`
--

DROP TABLE IF EXISTS `type`;
CREATE TABLE IF NOT EXISTS `type` (
  `idType` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `idCategorie` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `libelleType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`idType`),
  KEY `idCategorie` (`idCategorie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `type`
--

INSERT INTO `type` (`idType`, `idCategorie`, `libelleType`) VALUES
('A1', 'A', 'Adulte'),
('A2', 'A', 'Jeune (12 à 20 ans)'),
('A3', 'A', 'Enfant (0 à 12 ans)'),
('B1', 'B', 'Vélo'),
('B2', 'B', 'Moto'),
('C1', 'C', 'Voiture'),
('C2', 'C', 'Fourgon'),
('C3', 'C', 'Camping Car'),
('D1', 'D', 'Camion'),
('D2', 'D', 'Bus');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `bateau`
--
ALTER TABLE `bateau`
  ADD CONSTRAINT `bateau_ibfk_1` FOREIGN KEY (`idCapitaine`) REFERENCES `personnel` (`idPers`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `billet`
--
ALTER TABLE `billet`
  ADD CONSTRAINT `billet_ibfk_1` FOREIGN KEY (`idType`) REFERENCES `type` (`idType`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `billet_ibfk_2` FOREIGN KEY (`reference`) REFERENCES `reservation` (`reference`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `capacite`
--
ALTER TABLE `capacite`
  ADD CONSTRAINT `capacite_ibfk_1` FOREIGN KEY (`idBateau`) REFERENCES `bateau` (`idBateau`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `capacite_ibfk_2` FOREIGN KEY (`idCategorie`) REFERENCES `categorie` (`idCategorie`);

--
-- Contraintes pour la table `incident`
--
ALTER TABLE `incident`
  ADD CONSTRAINT `incident_ibfk_1` FOREIGN KEY (`idTrajet`) REFERENCES `trajet` (`idTrajet`);

--
-- Contraintes pour la table `liaison`
--
ALTER TABLE `liaison`
  ADD CONSTRAINT `liaison_ibfk_1` FOREIGN KEY (`idvilleDepart`) REFERENCES `port` (`idVille`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `liaison_ibfk_2` FOREIGN KEY (`idvilleArrivee`) REFERENCES `port` (`idVille`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `port`
--
ALTER TABLE `port`
  ADD CONSTRAINT `port_ibfk_1` FOREIGN KEY (`idPays`) REFERENCES `pays` (`idPays`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `possede`
--
ALTER TABLE `possede`
  ADD CONSTRAINT `possede_ibfk_1` FOREIGN KEY (`idBateau`) REFERENCES `bateau` (`idBateau`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `possede_ibfk_2` FOREIGN KEY (`idEquipement`) REFERENCES `equipement` (`idEquipement`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `recommandation`
--
ALTER TABLE `recommandation`
  ADD CONSTRAINT `recommandation_ibfk_1` FOREIGN KEY (`idPays`) REFERENCES `pays` (`idPays`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`idTrajet`) REFERENCES `trajet` (`idTrajet`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `tarif`
--
ALTER TABLE `tarif`
  ADD CONSTRAINT `tarif_ibfk_1` FOREIGN KEY (`idLiaison`) REFERENCES `liaison` (`idLiai`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `tarif_ibfk_2` FOREIGN KEY (`idPeriode`) REFERENCES `periode` (`idPeriode`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `tarif_ibfk_3` FOREIGN KEY (`idType`) REFERENCES `type` (`idType`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `trajet`
--
ALTER TABLE `trajet`
  ADD CONSTRAINT `trajet_ibfk_1` FOREIGN KEY (`idLiaison`) REFERENCES `liaison` (`idLiai`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `trajet_ibfk_2` FOREIGN KEY (`idBateau`) REFERENCES `bateau` (`idBateau`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `type`
--
ALTER TABLE `type`
  ADD CONSTRAINT `type_ibfk_1` FOREIGN KEY (`idCategorie`) REFERENCES `categorie` (`idCategorie`) ON DELETE RESTRICT ON UPDATE RESTRICT;

DELIMITER $$
--
-- Évènements
--
DROP EVENT IF EXISTS `archive_old_reservations`$$
CREATE DEFINER=`root`@`localhost` EVENT `archive_old_reservations` ON SCHEDULE EVERY 1 DAY STARTS '2025-02-18 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE reservation
    JOIN trajet ON reservation.idTrajet = trajet.idTrajet
    SET reservation.etat = 'Archivé'
    WHERE trajet.dateArrivee < (CURDATE()+2)
    AND reservation.etat != 'Annulé';
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
