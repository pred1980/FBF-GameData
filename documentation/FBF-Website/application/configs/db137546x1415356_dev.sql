-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 08. Jan 2015 um 20:55
-- Server Version: 5.5.40
-- PHP-Version: 5.3.10-1ubuntu3.15

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Datenbank: `db137546x1415356`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `changelog`
--

CREATE TABLE IF NOT EXISTS `changelog` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `version` varchar(6) NOT NULL,
  `changes` varchar(2048) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='dotu changelog' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `creeps`
--

CREATE TABLE IF NOT EXISTS `creeps` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('melee','ranged','caster') NOT NULL,
  `name` varchar(128) NOT NULL,
  `image` varchar(1024) NOT NULL,
  `fname` varchar(128) NOT NULL,
  `description` varchar(4096) NOT NULL,
  `information` varchar(8192) NOT NULL,
  `damage` varchar(64) NOT NULL,
  `armor` varchar(32) NOT NULL,
  `HP` int(11) NOT NULL,
  `Mana` int(11) NOT NULL,
  `attack_type` varchar(128) NOT NULL,
  `weapon_type` varchar(128) NOT NULL,
  `armor_type` varchar(128) NOT NULL,
  `cooldown` float NOT NULL,
  `health_reg` varchar(128) NOT NULL,
  `mana_reg` varchar(128) NOT NULL,
  `range` varchar(128) NOT NULL,
  `movementspeed` varchar(128) NOT NULL,
  `affilation` varchar(64) NOT NULL,
  `race` varchar(128) NOT NULL,
  `bounty` tinyint(5) unsigned NOT NULL DEFAULT '0',
  `rounds` varchar(128) NOT NULL,
  `meta_keywords` varchar(256) NOT NULL,
  `meta_description` varchar(1024) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1503 ;

--
-- Daten für Tabelle `creeps`
--

INSERT INTO `creeps` (`ID`, `type`, `name`, `image`, `fname`, `description`, `information`, `damage`, `armor`, `HP`, `Mana`, `attack_type`, `weapon_type`, `armor_type`, `cooldown`, `health_reg`, `mana_reg`, `range`, `movementspeed`, `affilation`, `race`, `bounty`, `rounds`, `meta_keywords`, `meta_description`) VALUES
(2, 'melee', 'Footman', 'footman.jpg', 'footman', '', 'A sword, a shield, a suit of armor and a healthy young man are the ingredients for a Regnum footman. Essentially employed as grunts of the army, the footman is a common sight wherever the Regnum army marches. Using the basic “quantity over quality” strategy in combat, the footmen easily overwhelm any opposing forces as long as they are not outnumbered.', '12 - 13', '2', 0, 0, 'normal', 'normal', 'large', 1.35, '0.25', '0', '90', '270', 'Infidel', 'Human', 2, '', '', ''),
(5, 'melee', 'Grunt', 'grunt.jpg', 'grunt', '', 'Ajdari males are born with a savage nature inside a gifted physique, perfect components for an enforcer of Ajdari ideology. The method through which they carry this out is irrelevant, it can be their favorite oversized double axe or old-fashioned fisticuffs. As long as the rebels are laying dead on the ground in their own poodle of blood, they will have fulfilled the task given. Although Ajdari grunts are mighty bruisers in their own right, their incapability to match the speed of nimble foes could be their deadly weakness during the coming battle on foreign shores.', '18 - 21', '1', 0, 0, 'normal', 'normal', 'large', 1.6, '0.25', '0', '100', '270', 'Infidel', 'Orc', 5, '', '', ''),
(13, 'ranged', 'Archer', 'archer.jpg', 'archer', '', 'Female warriors who choose the bow as their weapon of choice, Archers are the quintessential force of the Order of the Moon. New recruits are trained in basic archery so they can snipe at enemies from far away, incapacitating or killing them with relative ease. As they lack both the physical strength of a man and the ability to fight in melee combat. Archers are scared of enemies that can quickly approach and end their life.', '16 - 18', '0', 0, 0, 'pierce', 'missile', 'medium', 1.5, '0.25', '0', '500', '270', 'Infidel', 'Nightelf', 1, '', '', ''),
(14, 'ranged', 'Rifleman', 'rifleman.jpg', 'rifleman', '', 'The greatest breakthrough in the history of the Regnum military is the invention of gunpowder, which leads to the next logical step that is the appearance of the rifle. Those who wish to serve in the army but is not physically built to be a footman or a knight can apply to become a rifleman. Each rifleman is assigned a basic rifle and has to endure vigorous training sessions to ensure that their marksmanship is pitch-perfect. Riflemen systematically terminate their enemies from afar but become vulnerable when engaged in melee combat.', '18 - 24', '0', 0, 0, 'pierce', 'instant', 'medium', 1.5, '0.25', '0', '400', '270', 'Infidel', 'Human', 2, '', '', ''),
(4, 'melee', 'Raider', 'raider.jpg', 'raider', '', 'Wolves have long since been a companion of the Ajdar tribe. In the Ajdari army, wolves are carefully bred to create powerful mounts for a division of warriors known as Riders. Riders utilize the speed of their trusty wolf to perform hit-and-run tactics and wreak havoc upon enemy structures with their specially crafted broadsword. The wolf riders are also equipped with a net to bring down airborne foes, forcing them to lay helpless on the ground and at the mercy of the Riders.', '23 - 27', '0', 0, 0, 'siege', 'normal', 'medium', 1.85, '0.25', '0', '100', '350', 'Infidel', 'Orc', 4, '', '', ''),
(3, 'melee', 'Huntress', 'huntress.jpg', 'huntress', '', 'The Huntresses are panther-mounting female warriors of the Order of the Moon. Whereas the Archers prefer to battle from behind cover with bows and arrows, the Huntresses employ a fine glaive that is devastating at close range. The panther’s great speed allows a Huntress to quickly cut distance with enemies and throw her glaive that bounces between foes, injuring many with only one strike. Huntresses have to undergo vigorous trainings in order to form a perfect battle pair with her mount, for failing to reach the enemies fast enough may lead to a Huntress’ unworthy death.', '21 - 23', '2', 0, 0, 'normal', 'mbounce', 'none', 1.8, '0.25', '0', '225', '350', 'Infidel', 'Nightelf', 3, '', '', ''),
(18, 'ranged', 'Motar Team', 'motar-team.jpg', 'motar-team', '', 'Pack a hefty dose of gunpowder and a steel cannonball inside a humongous metal tube, use two short men to carry it around to blow ghouls and zombies to tiny bits. That is how the mortal teams operate. They fulfill one single role in the Regnum army: artillery. Repeated exposure to gunpowder smoke and the thrills of blowing up stuffs cause the mortar teams to become reckless than ever before. Now they only use a single scope to determine how to fire a shot that is more likely to kill both friends and foes alike.', '52 - 64', '0', 0, 0, 'siege', 'artillery', 'none', 3.5, '0.25', '0', '1150', '270', 'Infidel', 'Human', 3, '', '', ''),
(15, 'ranged', 'Troll Headhunter', 'troll-headhunter.jpg', 'troll-headhunter', '', 'Bloodtooth Headhunters earn their title for the special ritual they conduct each time an enemy is slain. The foe’s head would be cut off and hanged near their lifeless body as an offering to the Bloodtooth deity, Shu''Chue. Headhunters use impaling spears that are thrown with pinpoint accuracy to provide long-range support for the melee Ajdari Grunts in battle. Unfortunately, their deadly spears are designed solely for throwing and will snap when used to parry even a basic iron sword, which leads to Headhunters being forced to keep throwing their spears even if the foe is right in front of them.', '23 - 27', '0', 0, 0, 'pierce', 'missile', 'medium', 2.3, '0.25', '0', '450', '270', 'Infidel', 'Orc', 3, '', '', ''),
(17, 'ranged', 'Dryad', 'dryad.jpg', 'dryad', '', 'Those followers that commit more diligently to the Order are named and honored as Priestesses but those that wish to dedicate their life to the Goddess and prove the strenght of their spirit and an unbreakable faith are given the Touch of the Dryad in a ritual lead only by Ta''Ta Leafbeard. Their bodies are merged with nature and magic, empowering them and making of them a symbol of their faith, a symbol of balance between Mankind, Animalkind and Earthkind. To their foes, Dryads translate into unpredictable enemies, ones that can strike from the shadows unseen and unheard or lead a devastating charge to the frontilnes.', '17 - 19', '0', 0, 0, 'pierce', 'missile', 'none', 2, '0.25', '0.75', '500', '350', 'Infidel', 'Nightelf', 3, '', '', ''),
(22, 'caster', 'Priest', 'priest.jpg', 'priest', '', 'The priests of the Regnum army are holy men looking for an opportunity to serve the country more directly. Knowledge of supportive sorceries, including but not limited to healing and mending wounds, makes the priest an indispensable individual in any battle. However, they will be unable to put up any resistance if left exposed to enemies, as they have zero fighting experience.', '8 - 9', '0', 0, 0, 'magic', 'missile', 'none', 2, '0.25', '0.67', '600', '270', 'Infidel', 'Human', 3, '', '', ''),
(27, 'caster', 'Shaman', 'shaman.jpg', 'shaman', '', 'The Ajdar tribe worships nature deities that grant them blessings of various forms. Tasked with performing rituals and tending to temples are Ajdari Shamans. Even though Shamans possess magical powers due to their closer affiliation with the deities, they are initially not very well respected in society due to the Ajdari tendency of favoring dumb muscles over mystical arts. That is until the higher-ups in the Ajdari military discovered how devastating Shamans can be on the battlefield. No enemy can remain calm once they witness the terrifying sight of the Ajdari Shamans in ceremonial robes, ready to bring the full might of nature upon all who oppose the Ajdar tribe.', '8 - 9', '0', 0, 0, 'magic', 'missile', 'none', 2.1, '0.25', '0.67', '600', '270', 'Infidel', 'Orc', 3, '', '', ''),
(21, 'caster', 'Druid of the Talon', 'druid-of-the-talon.jpg', 'druid-of-the-talon', '', 'Druids in the Order of the Moon army, based on how strong they are physically, are classified into two lesser classes, Talon and Claw. Druids of the Talon are the weaker, staff-wielding druids who prefer to battle enemies from where they cannot reach. To fulfill that purpose, they study and master powerful wind magic to disable the enemy’s fighting capability. Those who are willing to advance further can even shapeshift into a raven, becoming an airborne threat against all evil of the land.', '12 - 16', '0', 0, 0, 'magic', 'missile', 'none', 1.6, '0.25', '0.67', '600', '270', 'Infidel', 'Nightelf', 3, '', '', ''),
(24, 'caster', 'Sorceress', 'sorceress.jpg', 'sorceress', '', 'Whereas holy men serve as priests voluntarily, the sorceresses are witches or female wizards looking for chances to test their new potions and hexes on the ill-fated bodies of adversaries. A surprise arsenal of nasty tricks always accompanies a sorceress whenever she traverses. Similar to the priests, they would also fall quickly once engaged in close quarters combat with enemies.', '10 - 12', '0', 0, 0, 'magic', 'missile', 'none', 1.75, '0.25', '0.67', '600', '270', 'Infidel', 'Human', 3, '', '', ''),
(23, 'caster', 'Witch Doctor', 'witch-doctor.jpg', 'witch-doctor', '', 'Eternally worship and serve the Bloodtooth deity, Shu''Chue without question in exchange for voodoo powers. So be the oath that binds every Witch Doctor in the Bloodtooth tribe. Many an Ajdari Shaman has wondered what voodoo powers exactly mean, the only thing that they know is that these powers differ greatly from the shamanic arts they are granted. They know that they certainly allow Witch Doctors to perform magical feats of various extents to devastate their enemies with little trouble.', '10 - 14', '0', 0, 0, 'magic', 'missile', 'none', 1.75, '0.25', '0.67', '600', '270', 'Infidel', 'Orc', 3, '', '', ''),
(7, 'melee', 'Druid of the Claw', 'druid-of-the-claw.jpg', 'druid-of-the-claw', '', 'Contrary to how the Talon Druids function, the Claw Druids study life-related arcane arts to support allies in battle. Great physical strength allows a Claw Druid to fight as well as any fighter on the battlefield. Should the need arise, a Claw Druid can temporarily abandon his human form to become a brown bear with deadly mauls to combat even the worst of foes.', '20 - 30', '1', 0, 0, 'normal', 'normal', 'large', 1.5, '0.25', '0.67', '100', '270', 'Infidel', 'Nightelf', 2, '', '', ''),
(1, 'melee', 'Murgul Reaver', 'murgul-reaver.jpg', 'murgul-reaver', '', '', '18 - 21', '0', 0, 0, 'normal', 'normal', 'large', 1.6, '1.0', '0', '100', '270', 'Infidel', 'Naga', 1, '', 'murgul reaver, naga, fbf murgul reaver, fbf creep, wc3', ''),
(6, 'melee', 'Spell Breaker', 'spell-breaker.jpg', 'spell-breaker', '', 'During the early days when the Regnum legion is pitched against the unholy magic of the Forsaken warlocks and suffers major setbacks, the Regnum strategists is forced to come up with an effective counter-measure. The result is the spell breaker; a stout magician equipped with an anti-magic shield and mystically enchanted glaives. The spell breakers can confront even the worst of wicked witchcraft without faltering in the slightest, yet they can hardly put up a fight when faced with physical attackers.', '13 - 15', '3', 0, 0, 'normal', 'missile', 'large', 1.9, '0.5', '0.8', '300', '300', 'Infidel', 'Human', 3, '', '', ''),
(8, 'melee', 'Druid of the Claw Bear', 'druid-of-the-claw-bear.jpg', 'druid-of-the-claw-bear', '', 'Contrary to how the Talon Druids function, the Claw Druids study life-related arcane arts to support allies in battle. Great physical strength allows a Claw Druid to fight as well as any fighter on the battlefield. Should the need arise, a Claw Druid can temporarily abandon his human form to become a brown bear with deadly mauls to combat even the worst of foes.', '27 - 32', '3', 0, 0, 'normal', 'normal', 'large', 1.5, '1.0', '0.33', '100', '270', 'Infidel', 'Nightelf', 5, '', '', ''),
(9, 'melee', 'Knight', 'knight.jpg', 'knight', '', 'A vital component of any land bound army, the cavalry force of Regnum is comprised of powerful mounted swordsmen honorably entitled knights. The training process for a knight is harsh and unforgiving. It has been estimated that only 1 out of 20 recruits can don the knight helm and receive his own mount for battle when boot camp is over. Elite and inspiring, the cavalry battalion is the symbol of the Regnum military might.', '30 - 38', '5', 0, 0, 'normal', 'normal', 'large', 1.5, '0.25', '0', '100', '350', 'Infidel', 'Human', 6, '', '', ''),
(10, 'melee', 'Mountain Giant', 'mountain-giant.jpg', 'mountain-giant', '', 'Mountain Giants are spawns of E’lal the Guardian Spirit, forged from the rocks of the mountains itself and given sentience. Although they only possess a small portion of E’lal’s strength and fortitude, the rock giants present a force to be reckoned with in battle. A single swing of the arm can and will kill any foes unfortunate enough to be hit. Their giant size, while intimidating to all smaller enemies, is also their greatest weakness. One that can and will be exploited by enemies whenever they have the chance.', '28 - 40', '0', 0, 0, 'normal', 'normal', 'medium', 2.5, '1.5', '0', '128', '270', 'Infidel', 'Nightelf', 8, '', '', ''),
(11, 'melee', 'Tauren', 'tauren.jpg', 'tauren', '', 'Following the liberation of the Tau race and the subsequent escape to the Peninsula, the Tau males begin to learn to use their gifted physical strength for more than simple labors. Years of carrying heavy logs of wood have created an unseen bond between the object and the slave that allows Tau warriors to wield them as effective weapons with little difficulty. A single strike could instantly incapacitate or kill the primary target on the spot and disorient nearby enemies. However, the Tau warriors are unable to move quickly due to the weight of their weapon and their natural body frame, which may end up becoming their own undoing on the battlefield.', '30 - 36', '3', 0, 0, 'normal', 'normal', 'large', 1.9, '0.25', '0', '100', '270', 'Infidel', 'Orc', 7, '', '', ''),
(12, 'melee', 'Naga Royal Guard', 'naga-royal-guard.jpg', 'naga-royal-guard', '', '', '30 - 42', '5', 0, 0, 'chaos', 'normal', 'large', 1.7, '1.0', '1.25', '128', '320', 'Infidel', 'Naga', 9, '', '', ''),
(16, 'ranged', 'Snap Dragon', 'snap-dragon.jpg', 'snap-dragon', '', '', '25 - 29', '0', 0, 0, 'pierce', 'missile', 'medium', 2, '1.0', '0', '550', '350', 'Infidel', 'Naga', 4, '', '', ''),
(19, 'ranged', 'Kodo Beast', 'kodo-beast.jpg', 'kodo-beast', '', 'Channeling their inner powers through violence against adversaries has always been the motto of the Ajdar tribe. However, the truth remains that many are not born warriors like others. They are gifted in a different aspect, an aspect that has always remained alien to the Ajdar: music. These musicians harness their natural talent to compose songs that hearten whoever hear them, making them stronger, faster, and braver. Ajdari commanders make use of these war musicians, letting them ride atop Kodo Beasts, slow but powerful war mounts that offer greater protection to the rider. Wherever the Ajdari armies march, the sound of the Kodo Riders’ drums mixes with the battle cry of the warriors, creating a chant that signals the victory to come.', '16 - 20', '1', 0, 0, 'pierce', 'missile', 'small', 1.45, '0.25', '0', '500', '220', 'Infidel', 'Orc', 5, '', '', ''),
(20, 'ranged', 'Dragon Turtle', 'dragon-turtle.jpg', 'dragon-turtle', '', '', '23 - 26', '1', 0, 0, 'pierce', 'missile', 'large', 1.75, '1.0', '0', '480', '270', 'Infidel', 'Naga', 6, '', '', ''),
(25, 'caster', 'Siren', 'siren.jpg', 'siren', '', '', '9 - 12', '0', 0, 0, 'magic', 'missile', 'none', 1.75, '1.0', '0.5', '600', '270', 'Infidel', 'Naga', 4, '', '', ''),
(26, 'caster', 'Spirit Walker', 'spirit-walker.jpg', 'spirit-walker', '', 'Tau, a race born with wondrous features for physical labor, can never be thought of as beings with knowledge of the arcane. Tau Nabi Baccar thought likewise until the day he witnessed some of his people began to display traits of sorcery. Exposure to Shams’ magic bestowed upon Baccar has caused the innate abilities of chosen Tau to resonate and develop on their own. Their outside appearance begins to change to a more humble form that trade physical prowess for mental enhancement. Honoring Shams, these Tau shamans, better known by their chosen title Spirit Walkers, carry an enchanted lamp and a ritual axe to battle all the non-believers who dare undermine Shams’ powers.', '17 - 22', '0', 0, 0, 'magic', 'missile', 'none', 1.75, '0.25', '1.0', '400', '270', 'Infidel', 'Orc', 5, '', '', '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `creeps_x_round`
--

CREATE TABLE IF NOT EXISTS `creeps_x_round` (
  `creepId` int(11) NOT NULL,
  `round` tinyint(4) NOT NULL,
  `count` tinyint(4) NOT NULL DEFAULT '1',
  UNIQUE KEY `creepId` (`creepId`,`round`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `creeps_x_round`
--

INSERT INTO `creeps_x_round` (`creepId`, `round`, `count`) VALUES
(1, 1, 14),
(1, 2, 5),
(1, 3, 2),
(2, 2, 8),
(2, 3, 3),
(2, 4, 5),
(2, 17, 3),
(3, 3, 6),
(3, 5, 6),
(3, 6, 8),
(3, 7, 4),
(3, 10, 6),
(3, 14, 10),
(3, 18, 4),
(4, 4, 8),
(4, 8, 6),
(4, 12, 9),
(4, 16, 6),
(4, 19, 3),
(5, 5, 6),
(5, 7, 4),
(5, 8, 4),
(5, 9, 5),
(5, 10, 6),
(5, 11, 10),
(5, 13, 4),
(5, 15, 9),
(5, 19, 3),
(6, 6, 5),
(6, 7, 2),
(6, 9, 4),
(6, 13, 4),
(6, 17, 3),
(6, 20, 1),
(7, 16, 2),
(7, 18, 2),
(7, 20, 1),
(8, 16, 2),
(8, 18, 3),
(8, 20, 2),
(9, 17, 4),
(9, 20, 2),
(10, 18, 1),
(11, 19, 5),
(11, 20, 2),
(12, 20, 1),
(13, 1, 6),
(13, 2, 3),
(13, 3, 4),
(13, 5, 2),
(13, 18, 5),
(14, 2, 4),
(14, 3, 5),
(14, 4, 5),
(14, 5, 2),
(14, 7, 2),
(14, 9, 2),
(14, 17, 4),
(15, 4, 2),
(15, 5, 4),
(15, 6, 5),
(15, 9, 4),
(15, 19, 4),
(16, 6, 2),
(16, 7, 2),
(16, 8, 4),
(16, 11, 5),
(16, 13, 2),
(16, 15, 3),
(17, 7, 2),
(17, 8, 2),
(17, 9, 3),
(17, 10, 5),
(17, 12, 2),
(17, 13, 3),
(17, 14, 4),
(17, 18, 3),
(17, 20, 3),
(18, 8, 4),
(18, 12, 4),
(18, 16, 3),
(19, 11, 1),
(19, 12, 1),
(19, 14, 1),
(19, 16, 2),
(19, 19, 1),
(19, 20, 1),
(20, 16, 2),
(21, 7, 4),
(21, 10, 1),
(21, 11, 1),
(21, 13, 1),
(21, 18, 2),
(22, 9, 2),
(22, 10, 1),
(22, 11, 2),
(22, 12, 2),
(22, 16, 3),
(22, 17, 3),
(23, 10, 1),
(23, 11, 1),
(23, 13, 2),
(23, 14, 2),
(23, 19, 1),
(23, 20, 1),
(24, 12, 2),
(24, 13, 3),
(24, 15, 3),
(24, 17, 3),
(24, 20, 2),
(25, 13, 1),
(25, 15, 3),
(25, 20, 1),
(26, 14, 3),
(26, 19, 1),
(26, 20, 1),
(27, 15, 2),
(27, 19, 2),
(27, 20, 2);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `creep_spells`
--

CREATE TABLE IF NOT EXISTS `creep_spells` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `creep_ID` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `description` varchar(1024) NOT NULL,
  `information` varchar(4096) NOT NULL,
  `duration` varchar(256) NOT NULL,
  `mana_cost` varchar(256) NOT NULL,
  `cooldown` varchar(128) NOT NULL,
  `range` varchar(128) NOT NULL,
  `aoe` varchar(128) NOT NULL,
  `targets` varchar(256) NOT NULL,
  `effects` varchar(256) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Daten für Tabelle `creep_spells`
--

INSERT INTO `creep_spells` (`ID`, `creep_ID`, `name`, `description`, `information`, `duration`, `mana_cost`, `cooldown`, `range`, `aoe`, `targets`, `effects`) VALUES
(1, 4, 'Ensnare', 'Causes a target enemy unit to be bound to the ground so that it cannot move. Air units that are ensnared can be attacked as though they were land units. ', '<li>Use Ensnare to bring flying units to the ground so that you can kill them with melee units such as Grunts and Tauren. </li> <li>Use Ensnare to stop units from running away. If the enemy is running away, cast Ensnare on the tail end of their train. Pick off whatever units you can which will reduce the enemy army and make them pay for running. </li> <li>Use Ensnare to break away powerful enemy melee units so they can no longer contribute to the battle as shown in a below screenshot. </li> <li>Don''t bother casting Ensnare on ranged troops unless you''re trying to prevent them from running away. </li> <li>You can continue to cast Ensnare on enemy Heroes to trap them if you have multiple Raiders with Ensnare ready to go. Just keep casting until your army can finish the Hero off. </li> <li>When Assaulting a town, Peons or Peasants etc. will try to repair. Use Ensnare to stop them. </li>', '12 (2) seconds', 'None', '16 seconds', '500', '300', 'Air, Ground, Enemy', 'Target caught by net');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `download_ip`
--

CREATE TABLE IF NOT EXISTS `download_ip` (
  `ip` varchar(24) NOT NULL,
  `time` varchar(11) NOT NULL,
  `today` varchar(11) NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `download_ip`
--

INSERT INTO `download_ip` (`ip`, `time`, `today`) VALUES
('94.101.33.114', '1392886338', '1392886338');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `download_stats`
--

CREATE TABLE IF NOT EXISTS `download_stats` (
  `hits` int(11) NOT NULL,
  KEY `hits` (`hits`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `download_stats`
--

INSERT INTO `download_stats` (`hits`) VALUES
(203);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `glossary`
--

CREATE TABLE IF NOT EXISTS `glossary` (
  `name` varchar(64) NOT NULL,
  `description` varchar(1024) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `glossary`
--

INSERT INTO `glossary` (`name`, `description`) VALUES
('1k', '<strong>one thousand</strong>'),
('1v1', 'a <strong>one on one</strong> battle'),
('abos', '<strong>Abominations</strong> - heavy Undead melee units'),
('acos', '<strong>Acolytes</strong> - Undead workers'),
('air', 'all <strong>air units</strong>'),
('am', '<strong>Archmage</strong> - a Human hero'),
('AoE', '<strong>Area of Effect</strong> spells, e.g. Flame Strike'),
('arch', '<strong>Archers</strong> - basic Night Elves'' ranged units that can mount Hippogryphs in order to turn into Hippogryph Riders'),
('b', 'Get <strong>back!</strong>'),
('bears', '<strong>Druids of the Claw</strong> - Night Elves'' melee units with useful spells and the ability to morph into bears'),
('bl', '<strong>Blood Lust</strong> - the most popular buff in game, cast by Orc Shamans'),
('bm', '1. <strong>Blade Master</strong> - a very popular Orc hero<br />2. <strong>Blood Mage</strong> - a Human hero< br />3. <strong>Beastmaster</strong> - a neutral hero'),
('chief', 'the clan leader, who calls and promotes <strong>clan members</strong> as well as sets up clan wars'),
('dk', '<strong>Death Knight</strong> - a hero of the undead army '),
('fl', 'the Battle.Net <strong>friends list</strong> that allows you to keep track of your WC3 mates');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `heroes`
--

CREATE TABLE IF NOT EXISTS `heroes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET latin1 NOT NULL,
  `text` varchar(4096) CHARACTER SET latin1 NOT NULL,
  `image` varchar(100) CHARACTER SET latin1 NOT NULL,
  `fname` varchar(70) CHARACTER SET latin1 NOT NULL,
  `primary_attribute_name` varchar(12) CHARACTER SET latin1 NOT NULL,
  `HP` int(5) NOT NULL,
  `Mana` int(5) NOT NULL,
  `str_value` varchar(10) CHARACTER SET latin1 NOT NULL,
  `agi_value` varchar(10) CHARACTER SET latin1 NOT NULL,
  `int_value` varchar(10) CHARACTER SET latin1 NOT NULL,
  `str_bonus` varchar(4) NOT NULL,
  `agi_bonus` varchar(4) NOT NULL,
  `int_bonus` varchar(4) NOT NULL,
  `damage` varchar(11) CHARACTER SET latin1 NOT NULL,
  `armor` tinyint(4) NOT NULL,
  `health_reg` varchar(128) CHARACTER SET latin1 NOT NULL,
  `mana_reg` varchar(128) CHARACTER SET latin1 NOT NULL,
  `sight_range` varchar(16) CHARACTER SET latin1 NOT NULL,
  `race` varchar(32) CHARACTER SET latin1 NOT NULL,
  `affilation` varchar(15) CHARACTER SET latin1 NOT NULL,
  `weapen_type` varchar(15) CHARACTER SET latin1 NOT NULL,
  `cooldown` float NOT NULL,
  `movementspeed` int(11) NOT NULL,
  `range` varchar(20) CHARACTER SET latin1 NOT NULL,
  `attack_animation` varchar(15) CHARACTER SET latin1 NOT NULL,
  `casting_animation` varchar(15) CHARACTER SET latin1 NOT NULL,
  `title` varchar(128) CHARACTER SET latin1 NOT NULL,
  `gender` varchar(32) CHARACTER SET latin1 NOT NULL,
  `role` varchar(64) CHARACTER SET latin1 NOT NULL,
  `tips` varchar(2048) CHARACTER SET latin1 NOT NULL,
  `ingame_quotes` varchar(512) CHARACTER SET latin1 NOT NULL,
  `meta_keywords` varchar(256) CHARACTER SET latin1 NOT NULL,
  `meta_description` varchar(160) CHARACTER SET latin1 NOT NULL,
  `ext_images` varchar(1024) CHARACTER SET latin1 NOT NULL,
  `ext_videos` varchar(1024) CHARACTER SET latin1 NOT NULL,
  `ext_links` varchar(1024) CHARACTER SET latin1 NOT NULL,
  `enabled` int(1) NOT NULL,
  `ability1` varchar(128) CHARACTER SET latin1 NOT NULL,
  `ability2` varchar(128) CHARACTER SET latin1 NOT NULL,
  `ability3` varchar(128) CHARACTER SET latin1 NOT NULL,
  `ability4` varchar(128) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=28 ;

--
-- Daten für Tabelle `heroes`
--

INSERT INTO `heroes` (`ID`, `name`, `text`, `image`, `fname`, `primary_attribute_name`, `HP`, `Mana`, `str_value`, `agi_value`, `int_value`, `str_bonus`, `agi_bonus`, `int_bonus`, `damage`, `armor`, `health_reg`, `mana_reg`, `sight_range`, `race`, `affilation`, `weapen_type`, `cooldown`, `movementspeed`, `range`, `attack_animation`, `casting_animation`, `title`, `gender`, `role`, `tips`, `ingame_quotes`, `meta_keywords`, `meta_description`, `ext_images`, `ext_videos`, `ext_links`, `enabled`, `ability1`, `ability2`, `ability3`, `ability4`) VALUES
(1, 'Behemoth', 'It was thus written in old legends that on the clearest of nights, when the winds of the Peninsula were calm and peaceful, and the traveling merchants felt safe and secure, little would they suspect that they were being watched by an uncanny rider called Mundzuk and Octar, his ride, whose might and savageness were matched only by Mundzuk''s battle proficiency. Rushing from the shadows with speed like a midnight blast, the victims of this duo never had a chance to retaliate before they were slain mercilessly. As if on the wings of the wind, the mysterious figures, having gathered up their trophies of the hunt, would vanish without a trace. The Behemoth''s reign of terror lasted for many years until the day the hands of death claimed their life.<br /> <br />Centuries later, the Wizard, by the machinations of fate, discovered a nameless tomb containing the remains of the legendary rider, who had always been thought of as a myth. The Wizard offered them a second chance in life in exchange for their unquestionable loyalty. The fearsome Behemoth has returned, serving in the frontline of the Forsaken army and crushing all who dare oppose his new master''s will.', 'behemoth.jpg', 'behemoth', 'Strength', 850, 240, '34', '18', '16', '2.90', '1.2', '2.3', '48 - 54', 7, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Normal', 1.8, 305, 'Melee', '1.07 | 0.56', '0.21 | 0.45', '', 'Male', 'Slayer', '', '', 'behemoth, behemoth skills, fbf behemoth, fbf hero', 'Behemoth - An uncanny rider of legends old. Mundzuk''s sole name would terrorize the travelling merchants, his favorite kind of prey.', '', '', '', 1, 'Explosive Tantrum', 'Beast Stomp', 'Roar', 'Adrenalin Rush'),
(2, 'Nerubian Widow', 'Warriors often laugh at arachnophobia.   They always think spiders are nothing comparing to the beasts they fight daily.  But little they know of the Spiders underground.  Legs as tall as a door and fangs open as wide as a man''s head,  The Widow crawls from beneath the earth to haunt on her victims.  Caught up. Webbed. Swarmed. Incapacitated. Consumed.  The Nerubian Widow finishes her meal quickly and spits out pieces of armor.  She then proceeds to the next prey.', 'nerubian-widow.jpg', 'nerubian-widow', 'Agility', 450, 195, '18', '17', '13', '1.70', '2.4', '1.9', '20 - 29', 3, '0.25', '0.01', '1800 | 1000', 'Nerubian', 'Forsaken', 'Missile', 1.7, 295, '500', '0.36 | 0.64', '0.3 | 0.51', '', 'Female', 'Hunter', '', '', 'nerubian widow, crypt lord, nerubian widow skills, fbf nerubian widow, fbf hero', 'Nerubian Widow - Crawling forth from underground, the Widow catches her preys in silence and slowly poisons them to death. She kills to feed herrself and ...', '', '', '', 1, 'Adolescence', 'Spider Web', 'Sprint', 'Widow Bite'),
(3, 'Ice Avatar', '<i>When hell freezes over, the cold shall traverse the Peninsula.</i> - Akull, the Cold Jester. <br/> <br />A tale that sent chills down one’s spine told of a frosty jester who was cold and ever-bitter. Fed up with being given the cold shoulder all the time by this unfunny buffoon, his Lord used the harsh harvest of one winter as an excuse to kill off the jester in cold blood, proclaiming his death as a sacrifice to the Winter God. The jester''s heart was the only thing left, frozen and buried in the snow.<br /><br />Many years later, when the Lord was taking a stroll in his winter garden, as the cool breezes brushed past him, a freezing mist that materialized into a monstrous being exuding a bone-chilling aura appeared in front of him. “Ice to meet you, m''lord” were the last words the Lord heard before he was frozen solid and shattered. It is said that the former jester has returned, now known only as the Ice Avatar, and he has brought the icy apocalypse to this world.', 'ice-avatar.jpg', 'ice-avatar', 'Intelligence', 625, 375, '25', '20', '25', '1.4', '1.3', '3.3', '34 - 43', 4, '0.25', '0.01', '1800 | 1000', 'Elementar', 'Forsaken', 'Missile', 1.7, 300, '600', '0.45 | 0.833', '0.3 | 0.51', '', 'Male', 'Magician', '', '', 'ice avatar, ice avatar skills, fbf ice avatar, fbf hero', 'Ice Avatar - A court buffon sacrificed by his lord for his dull and embarrassing jokes. Forced to die frozen under the snow,…', '', '', '', 1, 'Ice Tornado', 'Freezing Breath', 'Frost Aura', 'Fog of Death'),
(4, 'Ghoul', 'Renowned for his unmatched valor and prowess, Edmund Shieldbearer --brother to Edgar Shieldbearer, a Paladin of the Twin Suns Church--, was a general of the Regnum respected by his allies and feared by his enemies. During the war against the Empire, he regrettably fell in battle at the tip of a dozen spears. The proper ceremonies were made, but soon after, the body disappeared.<br /><br />The cruel strings of fate designated that his body become the ingredient for the Wizard’s daring experiment to create an undead abomination. Unholy magic from ancient eldritch grimoire ended up creating a frightening monstrosity. This being no longer feels fear, remorse or self-preservation. Charging into the battlefield with zero hesitation and maximum ferocity, ''the Ghoul'' claws its way through the corpses of its former brethren in a never-ending fervor, as they stand frozen in awe, witnesses to the cruel fate of their hero, and ideal role model.', 'ghoul.jpg', 'ghoul', 'Agility', 450, 150, '18', '27', '10', '2.0', '2.6', '0.7', '54 - 66', 6, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Normal', 1.65, 360, 'Melee', '0.44 | 0.39', '0.05 | 0.05', '', 'Male', 'Hunter', '', '', 'ghoul, ghoul skills, fbf ghoul, fbf hero', 'Ghoul - Edmund Shieldbearer, former General of the Regnum''s army and an example of grace, honor and military cunning to friend and foe alike.', '', '', '', 1, 'Claws Attack', 'Cannibalize', 'Flesh Wound', 'Rage'),
(5, 'Master Banshee', 'Legend has it that many years ago there lived a beautiful woman who was loved and cherished by all, called Lady Venefica. As time went by, she grew old and lost her appeal. Turning to witchcraft as her last resort, the woman followed an ancient ritual of sacrificing children and absorbing their essence to restore her youth. Her actions were noticed by the holy men and she was hanged afterwards. Suffering for days as the stolen life force slowly slipped away, until one day she finally died.<br /><br />A few years later, the holy men who had hanged the woman before were met on the road with mysterious sounds  that began to emanate from all around them. Desperately casting all their holy spells and magic to no avail, they ran in terror as fear invaded their mighty hearts. The wailing and weeping, like a child''s cry, split the silence of the night unyielding. What ensued next was a symphony of screams and blood, concluding with a sonata of eerie silence.<br /><br />Beware, for you may be the next…', 'master-banshee.jpg', 'master-banshee', 'Intelligence', 525, 300, '21', '14', '20', '1.7', '1.6', '2.8', '22 - 36', 2, '0.25', '0.01', '1800 | 800', 'Ghost', 'Forsaken', 'Missle', 1.8, 270, '600', '0.51 / 0.56', '0.5 | 0.83', '', 'Female', 'Magician', '', '', 'master banshee, banshee, master banshee skills, fbf master banshee, fbf hero', 'Master Banshee - Master Banshee - egend has it that many years ago there lived a beautiful woman who was loved and cherished by all, called Lady Venefica.', '', '', '', 1, 'Dark Obedience', 'Spirit Burn', 'Cursed Soul', 'Barrage'),
(6, 'Death Marcher', 'The Knights d’Or was an army of elite knights handpicked by King Mithas himself. Under the leadership of, Great Knight Dorian a battle-hardened general, the army was able to hold its ground against overwhelming odds on numerous occasions. However, even the mightiest will eventually fall.<br /><br />A loyal and close subject to the King, he was a liability to the Wizard who personally slain the trusting soldier while disguised as his liege. In a twist of irony, Dorian became a horrifying being known only as the Death Marcher. Now he stands tall and relentless as an impenetrable wall that protects the Forsaken Bastion. The combination of deadly magic and inhuman strength in the hand of such a merciless being demoralize all who witness its presence.', 'death-marcher.jpg', 'death-marcher', 'Strength', 700, 255, '28', '12', '17', '3.0', '1.6', '1.9', '30 - 40', 8, '0.25', '0.01', '1800 | 800', 'Ghost', 'Forsaken', 'Normal', 2.2, 270, 'Melee', '0.3 | 0.6', '0.5 | 0.5', '', 'Male', 'Defender', '', '', 'death marcher, orc warlord, death knight, death marcher skills, fbf death marcher, fbf hero', 'Death Marcher - The General of the Knights d''Or, the smallest yet strongest army ever to have marched on the fields of battle.', '', '', '', 1, 'Death Pact', 'Soul Trap', 'Mana Concentration', 'Boiling Blood'),
(7, 'Skeleton Mage', 'The Magi’s Guild, an advanced school of magic ruled by the Philosopher''s Council, had once been the utopia of all magicians in the land. They were the first to witness the blighted Forsaken Army as they were the deadly enemies of the Wizard, who had lost his brethren at the hands of these magic wielders. All were slain in the onslaught.<br /><br />Now the guild has become the domain of the Skeleton Mage, The Archmage and leader of the former council, punished to eternal undeath and servitude by the Wizard. Employing empowered necromantic magic sliding towards decay and soul manipulation, this shamble of bones seeks pleasure in cursing enemies with horrendous plagues, watching them die in agony and absorb their souls to grow stronger. Only eternal damnation awaits those who encounter this creature.', 'skeleton-mage.jpg', 'skeleton-mage', 'Intelligence', 400, 375, '16', '11', '25', '1.3', '0.9', '3.8', '28 - 37', 1, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Missile', 1.5, 295, '600', '0.5 | 0.5', '0.5 | 0.51 ', '', 'Male', 'Magician', '', '', 'skeleton mage, skeleton, skeletal mage, skeletal, skeleton mage skills, fbf skeleton mage, fbf hero', 'Skeleton Mage - This dark magician and soul devouring creature is what remains of the leader of the Magi''s Guild, nemesis to the Wizard for having vanquished...', '', '', '', 1, 'Plague Infection', 'Soul Extraction', 'Spawn Zombie', 'Call of the Damned'),
(8, 'Master Necromancer', 'Necromancers. Masters of the dark arts of death. Renowned for their ability to summon undead forces from the corpses of slain enemies and turn even their former comrades into mindless, brutal skeletons. They are an indispensable portion of the Wizard’s army. One among them, however, wishes beyond being a mere death caller.<br /><br />Kakos Tabularius researched forbidden tomes and descended further into the dark art, obtaining powers that far exceed a normal necromancer’s capability. Careless, he went a step too far and experimented secret necromastery arts on his own body, turning himself into an undead being. The unexpected result did not disappoint him in the slightest, for he had finally made a breakthrough by being the only to actually tread the border of life and death. This nameless magician, now known among his enemies as the Master Necromancer, walks into battle alone and comes out escorted by loyal minions that trample the lifeless bodies of his foes.', 'master-necromancer.jpg', 'master-necromancer', 'Intelligence', 425, 420, '17', '16', '28', '1.3', '1.1', '3.8', '30 - 38', 3, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Missile', 1.7, 240, '600', '0.47 | 0.53', '0.5 | 0.5', '', 'Male', 'Magician', '', '', 'kel’thuzad, master necromancer, necromancer, lich king, master necromancer skills, fbf master necromancer, fbf hero', 'Master Necromancer - Necromancy is the Wizard''s specialty, but Kakos is the best in the field. A dedicated conjurer that walks the line between life and death..', '', '', '', 1, 'Necromancy', 'Malicious Curse', 'Dark Spirit', 'Internal Decay'),
(9, 'Crypt Lord', 'Reports from a remote region of the Peninsula detailed how a small village was wiped out virtually overnight and the bodies of the villagers were all murdered in a horrendous, brutal manner. The Wizard, who was situated nearby, did not miss out the occasion to investigate this mystery. Arriving at the scene, his men were ambushed by oversized, vicious beetles. However, the attack proved to be fruitless as the Wizard effortlessly repelled the creatures and pushed them back to their hive: a tremendous ancient temple.<br /><br />The subsequent excavation resulted in the unearthing of the skeleton of a giant, monstrous beetle. Figuring an apparent link between this skeleton and the earlier attacks, the Wizard decided on a whim to resurrect this enigmatic being, injecting an unwavering loyalty to it in the process. This ''Lord of the Crypt'', called so by his new master is considered an exceptionally filthy and despicable being even among the undead masses as it possesses horrifying abilities, including ambushing the enemies from below, injecting his spawn to them and watching with pleasure as his young bursts forth from the corpse of the victim.', 'crypt-lord.jpg', 'crypt-lord', 'Strength', 525, 225, '21', '17', '15', '2.7', '1.8', '1.4', '41 - 53', 4, '0.25', '0.01', '1300 | 700', 'Nerubian', 'Forsaken', 'Normal', 1.85, 285, 'Melee', '0.54 | 0.46', '0.4 | 1.1', '', 'Male', 'Slayer', '', '', 'crypt lord, crypt lord skills, fbf crypt lord, fbf hero', 'Crypt Lord - It is thought to have been a subject of worship in ancient times because of the luxurious Tomb he was found in.', '', '', '', 1, 'Burrow Strike', 'Burrow Move', 'Carrion Swarm', 'Metamorphosis'),
(10, 'Abomination', 'Ancient tomes speak of a malicious necromantic ritual involving sewing the corpses of different beings together and attaching them to a single frame to create a grotesque being. The Wizard did not miss out the opportunity to experiment this ritual first hand and aptly named the resulting creature an ''Abomination''. Needless to say, he went far beyond creating one simple ''Abomination'' and developed a machine run with steam technology to mass produce the tortured freaks.<br /><br/>One of this ''Abominations'' is called Blight Cleaver. Hidden beneath his monstrous and brutish exterior is a cunning intelligence that allows this creature to plan tactics and stratagems, that exceed those of the common brutes that define his brethren; often reduced to running and smashing all that moves and can scream. Blight Cleaver roams the battlefield, a blob of meat planning the best way to snack upon his preys and push the battle line, as the unspeakable horror ensues in deadly silence.', 'abomination.jpg', 'abomination', 'Strength', 700, 210, '24', '14', '14', '2.9', '1.5', '1.5', '52 - 67', 3, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Normal', 1.95, 285, 'Melee', '1.17 | 0.5', '0.3 | 0.51', '', 'Male', 'Slayer', '', '', 'abomination, abomination skills, fbf abomination, fbf hero', 'Abomination - There''s a steam machine, deep within the Bastion that creates creatures out ''parts'' en masse.', '', '', '', 1, 'Cleave', 'Consume himself', 'Plague Cloud', 'Snack'),
(11, 'Destroyer', 'Many centuries ago, there existed a great mage with an unquenchable thirst for exploring the secret arts. This caused him to venture into forbidden territories and be branded a menace by the Twin Suns Church and the Magi''s Guild alike; institutions that often find themselves one against the other. Finding himself cornered in the Tomb he made his hideout, the mage cast a desperate spell that turned his body into a sphere of pure mana quickly dissipating into thin air. An abandoned obsidian construct nearby, retaining traces of necromantic magic of its initial creation, absorbed the mage’s essence over the years and finally reconstituted his consciousness within its structure.<br /><br />This nature-defying creature now serves the Forsaken as the official torturer and executor of the Wizard''s enemies, acomplice of the creation of many of the creatures under the Great Conjurer''s command. The Destroyer serves under the promise of a new body. Psionic annihilation is the only thing that awaits those who cross his path.', 'destroyer.jpg', 'destroyer', 'Intelligence', 525, 285, '17', '16', '19', '2.1', '2.0', '2.0', '36 - 43', 4, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Missile', 1.35, 320, '500', '0.337 | 0.633', '0.830 | 0.510', '', 'Male', 'Slayer', '', '', 'destroyer, destroyer skills, fbf destroyer, fbf hero', 'Destroyer - A renegade mage and archaelogist, an expert in forbidden spells and tombs.', '', '', '', 1, 'Arcane Swap', 'Mind Burst', 'Mana Steal', 'Release Mana'),
(12, 'Dread Lord', 'Before the coming of the Wizard, King Mithas had Tristan Langue d''Argent, his right hand, his chancellor, his advisor. This man had the unique ability to make the best our of any situation, specially when it came at the cost of others. His many tasks ranged from attending to important diplomatic meetings in the name of his liege, to making sure the people always owed the crown tax money and payed the debts in full amount. Interest rates included.<br /><br />The Wizard soon took his place at the King''s side with his silver tongue. But the Chancellor could see he and the Conjurer had much in common. This meant it was obvious to Tristan his new rival was lying and acting his way through a plot. At just the right moment he approched the outsider and offered him a devil''s deal: he would betray his King in exchange of power and a high position under the Wizard''s new rule, whom didn''t consider him an equal as much as a useful pet. The deal came through, but at the cost of his sanity and image. He follows his new master with blind faith, too crazed to see the consequences of his actions.', 'dread-lord.jpg', 'dread-lord', 'Intelligence', 650, 300, '26', '14', '20', '2.0', '1.0', '3.4', '22 - 28', 5, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Normal', 1.9, 270, '600', '0.55 | 0.55', '0.3 | 1.53', '', 'Male', 'Supporter', '', '', 'dread lord, lich king, arthas, dread lord skills, fbf dread lord, fbf hero', 'Dread Lord - Tristan was nothing but snake in life and even in death. Betraying King Mithas for a position in the Forsaken''s realm.', '', '', '', 1, 'Vampire Blood', 'Purify', 'Sleepy Dust', 'Night Dome'),
(13, 'Tauren Chieftain', 'The Tau, a bull-like race of Bel''Trama tribals, have been subject to slavery for as long as their ancestors lived. They have a long lifespan, incredibly strong bodies, and a very submissive and peaceful nature. These traits make them the perfect and most valued slaves. Baccar was a vassal of the Ajdar tribe. While the Bel''Trama believe in many gods, Baccar pledged his faith to only one: Shams, the omnipotent Sun-God. For insulting the Ajdari and their beliefs, he''s gotten the worst treatment a slave can receive.<br /><br />Every so often, Baccar received the visit of Shams'' Messenger who eased his pain and spoke to him about his god''s teachings, how all the Tau seek freedom deep within their hearts, and how they would acquire it in due time. Baccar became anxious but patiently awaited through the years. The dreams came more often until one night the Messenger simply said “Freedom is paid with Patience. Justice is paid with Blood. The Sun''s light is paid with Repentance. The Tau have paid.”  The next morning, Baccar''s slave group was woken earlier for the weekly “head-count”. The slaves'' work was judged by the Tamers. Those that didn''t pass were beheaded, and their bodies saved for the dinner''s soup. The first slave judged didn''t pass and the moment his severed head hit the ground, the Tau were free.<br /><br />With a roar that made the ground tremble, Baccar broke his chains. Fists so closed in anger his claws pierced his hands, he began tearing through the Ajdari tamers. Skulls were crushed, jaws were broken, and the green-skinned beasts were torn in half as if they were made of bread. The incesant roaring clouded the screams and pleas for help. The other slaves watched in awe. At the master tent, Baccar''s owner was kneeling, frozen, whispering meaningless apologies as the Tau slave raised his fists high and swinged downwards, breaking his foe''s neck, thrusting the head into the body below the shoulder line. In the aftermath, Baccar felt both released and ashamed, unsure of himself and his actions.<br /><br />For the Tau, he became the prophet that guides them to freedom, the true Tau Nabi. Baccar also became the Tau''ren, Chieftain of the Tribe and organized them as an army that grew larger in number as more of their kin were fred. Yet, along the way, he became the enemy of the Bel''Trama tribes and in order to escape and divide them the Tau have set sail southward. South towards the Peninsula. Right into a war that was not their own.', 'tauren-chieftain.jpg', 'tauren-chieftain', 'Strength', 700, 300, '28', '13', '20', '2.6', '1.7', '1.5', '52 - 64', 5, '0.25', '0.01', '1800 | 800', 'Tauren', 'Coalition', 'Normal', 2.1, 285, 'Melee', '0.97 | 0.36', '0.47 | 0.8', '', 'Male', 'Slayer', '', '', 'tauren chieftain, tauren, tauren chieftain skills, fbf tauren chieftain, fbf hero', 'Tauren Chieftain - The ''Tau Nabi'' or ''Prophet of the Tau'' is on a quest to lead his enslaved people to the freedom they''ve long forgotten.', '', '', '', 1, 'Fire Totem', 'Stomp Blaster', 'Fervor', 'Shockwave'),
(14, 'Archmage', 'The creation of the Magi''s Guild, over a hundred years ago, became the perfect solution to the ''Forsaken problem''. The best magi all around the Regnum were, for the first time, brought together to fight the necromantic cultists that called themselves ''The Forsaken'', and brought their campaign of terror to the ground with overwhelming might. Yet, that victory was not enough. The wizard Cáligo, last of The Forsaken, has returned and overcame his enemies with his vast undead army.<br /><br />Belenus, the last Archmage of the Guild, survived the aftermath just like the Wizard did before. A wise but deceptive man, of order and honor, that now seeks revenge as much as he seeks knowledge on a crusade fueled by anger. But now that the Guild is no more, he feels free. Free to learn from his nemesis. Free to learn the forbidden. Free to start anew, to exchange order for chaos, honor for power, to become a master of the Dark Art. His brothers in arms charge vigorously behind him, blinded by the facade.', 'archmage.jpg', 'archmage', 'Intelligence', 500, 360, '20', '16', '24', '1.70', '1.6', '2.7', '27 - 45', 3, '0.25', '0.01', '1800 | 1000', 'Human', 'Coalition', 'Missile', 1.95, 320, '600', '0.85 | 0.55', '0.3 | 2.4', '', 'Male', 'Magician', '', '', 'archmage, archmage skills, fbf archmage, fbf hero', 'Archmage - Former Archmage of the Magi''s Guild and the only one to survive the masacre that disbanded his order.', '', '', '', 1, 'Holy Chain', 'Trappy Swap', 'Refreshing Aura', 'Fireworks'),
(15, 'Priestess of the Moon', 'At the age of seventeen, the young devoted priestess of the Church of the Twin Suns met the Moon Goddess in a dream. The deity showed her the grim future, one of chaos and death. An endless battle between light and darkness would tear the world apart. One man, both deranged and very powerful, would be the cause of such an end. His war fueled by the reckless actions of the Twin Suns and the Regnum. The yound girl was told to find an old legend, a wise man that would become her most trusted ally -none other than the druid Ta’Ta, an age old mage known only through old stories-, and gather men to fight united against their own doom.<br /><br />The druid welcomed the girl, he had received the Goddess just like her. Toghether, they preached the word of the Moon and drove many to their side. The Twin Suns soon noticed them, and fought against them on both the political field and the field of battle. However strong the efforts to shut them down, the Twin Suns and the Regnum’s army were set back by the following wars and, whatever treaties they’d arrange with the newfound Order, were twisted around and made useless. But, with the Forsaken, the Moon prophecy became true. The Order of the Moon arranged a ceasefire with the Regnum and both armies marched against their common foe.<br /><br />After many battles, Anahi stands with her army at the Bastion’s gates, ready to smite the enemies of her Goddess and drive darkness out of their land. Her faith is unbreakable but, will her prophecies come true?', 'priestess-of-the-moon.jpg', 'priestess-of-the-moon', 'Agility', 625, 285, '25', '22', '19', '1.7', '2.4', '1.9', '32 - 40', 4, '0.25', '0.01', '1700 | 1100', 'Night Elf', 'Coalition', 'Missile', 2.1, 325, '650', '0.70 | 0.30', '0.5 | 0.83', '', 'Female', 'Supporter', '', '', 'priestess of the moon, potm, priestess of the moon skills, potm skills, fbf priestess of the moon, fbf hero', 'Priestess of the Moon - A young girl devoted to her Goddess that leads the Order against the Forsaken. Her accomplishments are many but the truth behind her...', '', '', '', 1, 'Life Vortex', 'Moonlight', 'Night Aura', 'Revenge Owl'),
(16, 'Naga Matriarch', 'Among the sailors all over the Regnum, there''s an old story of a reckless king, in love with the seas and oceans, that abandonned his family, riches and kingdom just to sail the western waves. The King ventured too far and was met with the sea witch. As they fought each other away from the shores, a thunderstorm hit the Regnum''s ports. The waves crushed with enough violence to destroy a dock or two and to drag and sink boats stationed on the shores. Moments before the storm stopped, the wind brought forth a woman''s dark laugh.<br /> <br />It was assumed the King had perished in his journey and sailors dared not venture into the seas. Thruth is, the King came close to death. As his ship was destroy by the powerful witch Sa''gara and his crew lost to the roaring salty waters, his shinnning golden armor brought his foe''s attention. The witch rescued him and both lived in her underwater caves. He told her of the majesty of his kingdom as he now missed his family and his land. She listened as a child drawn by a fantasy tale. As the king passed, she took it upon herself to find the old man''s land of glory. After years of searching, Sa''gara found her way to the Regnum''s shores but, in place of fiendly taverns and beatiful woods, she found scarred battlefields and a land engulfed in a great war, of which she''s never seen.', 'naga-matriarch.jpg', 'naga-matriarch', 'Agility', 500, 255, '20', '22', '17', '2.9', '2.3', '1.8', '44 - 62', 6, '0.25', '0.01', '1800 | 800', 'Naga', 'Coalition', 'Missile', 1.6, 285, '600', '0.5 | 0.5', '0 | 0.51', '', 'Female', 'Defender', '', '', 'naga matriarch, naga matriarch skills, fbf naga warlord, fbf hero', 'Naga Matriarch - The Witch from ancient tales. Sa''gara can control the waves and struck her enemies with the sea''s might.', '', '', '', 1, 'Tidal Shield', 'Impaling Spine', 'Crushing Wave', 'Maelstrom'),
(17, 'Orcish Warlock', 'Just like one lion rules a pack, one tribe rules the Bel''Trama, one clan rules a tribe, and one man rules a clan. Sahkra, the Oathbreaker rules the Ajdar Tribe and the Bel''Trama through sheer strenght and a cunning mind. Even if old he is unmatched, and to keep his reputation and seat of power he provokes even his closest friends into a deathmatch that, by tradition, one''s rejection means one''s loss of honor, and dignity. Even if everyone knows Sahkra''s forbidden spells and traps are always the cause of his rivals'' deaths, they dare not decline the match. The Ajdar Chieftain made it his hobby and enjoys every bit of these duels, particularly the crowd''s reaction to his grand finale: slowly plucking his thumbs into his foe''s eyes until his long nails pierce the skull.<br /><br />Upon learning of the rising of the Tau slaves and the story of their great prophet, Sahkra gathered his clan and marched west towards the slave mines to meet the rebels. Too unprepared and relaxed at the sight of an easy battle, the Ajdari army was caught offguard midway through. On a foggy night, the Tau greeted them with bloddied clubs and sharp horns. The mist covered their entrance and the massacre began. Before the Ajdar could organize themselves and before Sahkra got out of his tent, the field was painted with green blood and the gutted bodies of half his army. The rest threw their weapons at the order of a young Tau who revealed himself as Tau Nabi Baccar. He spoke to a grudgeful Sahkra about his encounter with his god, Shams, and his plan to free the Tau. He finished by saying “Shams wants you alive. I want you to row.” <br /><br />The dishonored green-skins rowed the Tau''s stolen boats southwards into the Peninsula. For the first time, Sahkra''s men are losing hope in him. They begin to see him as a frail old Ajdar whose time has ran out. A feeling worsened by the unending battles they have found in the new land and their new foe, the Forsaken. But Sahkra feels this enemy is his chance to get his men back and to prove the falsehood of the Tau Nabi.', 'orcish-warlock.jpg', 'orcish-warlock', 'Agility', 300, 255, '12', '21', '17', '1.7', '2.5', '2.1', '27 - 33', 4, '0.25', '0.01', '1800 | 800', 'Orc', 'Coalition', 'Missile', 1.8, 290, '600', '0.47 | 0.53', '0.5 | 0.5', '', 'Male', 'Supporter', '', '', 'orcish warlock, orcs, thrall, orcish warlock skills, fbf orcish warlock, fbf hero', 'Orcish Warlock - The leader of the Ajdar Tribe, the strongest among the Bel''Trama, Sahkra is as proud as he is cunning and a powerful sorcerer.', '', '', '', 1, 'Thunderbolt', 'Spirit Link', 'Mana Ward', 'Dark Summoning'),
(18, 'Dark Ranger', 'Among the numerous mercenary clans scattering around the Peninsula, there is a unique nameless guild operated by a single assassin, who is also the one to take care of contracted jobs. This female archer is tricky, treacherous and possesses an unrivaled marksmanship, befitting her title of the Dark Ranger. The origin of the Dark Ranger is shrouded in mystery. Some say she descended from a secret tribe of female warriors to the North that worships the gods of war, while others claim she is an assassin raised from birth and her arrows had never missed ever since she knew how to use a bow.<br /><br />Enemies of the Dark Ranger often find themselves being chased by a ghostly archer and incapacitated by spectral arrows that pierce their soul. Even if the Ranger is missing from sight, her arrow is as deadly as ever and the victims only hear of the whizzing sound before their lives are forfeited. Fighting among the undead masses for sole monetary purposes, her bow is ready to bring the holy warriors to their knees.', 'dark-ranger.jpg', 'dark-ranger', 'Agility', 500, 225, '20', '21', '15', '1.9', '1.7', '2.6', '23 - 31', 4, '0.25', '0.01', '1800 | 800', 'Undead', 'Forsaken', 'Missile', 2.35, 320, '700', '0.7 | 0.3', '0.4 | 0.5', '', 'Female', 'Hunter', '', '', 'dark ranger, high elf, sylvanas windrunner, dark ranger skills, fbf dark ranger, fbf hero', 'Dark Ranger - The deadliest woman to hold a bow. Many rumours have been spread about her but none is as terrifying as reality.', '', '', '', 1, 'Ghost Form', 'Crippling Arrow', 'Snipe', 'Coup de Grace'),
(19, 'Blood Mage', '"The man with true power" is what people calll the King, but ever since the creation of the Regnum, the Crown has been contending the Nobility for the real "true power", as they fight each other even over the most meaningless of things. Ironically, this age-long rivalry has maintained a political balance. In the Regnum, anyone who owns a piece of land is considered a nobleman, yet there are very few and rarely do they share or give away their property. And just like the King, they need a court of advisors to rule such pieces of land.<br /> <br />Joos Ignis is a courtsman to one of the Regnum''s Lords. He is his most trusted servant, his right hand, and also a former member of the Magi''s Guild and, as such, a powerful magician himself. At his peak, he was a master magician, unbeatable and cunning. His specialised in offensive magic and became the title of Firelord for his supreme control over the Fire element. The title became a part of him even as he drifted from his studies in the Guild to politics and diplomacy. Joos'' cunning in this field is as strong as his cunning in battle, and he''s respected by politicians as much as he''s respected by all magi for his gifts. Acting as his Lord''s main advisor and personal bodyguard, he has earned his trust. That of an old heirless noble, father only to the most prized bride-to-be who''s ready to open her heart only to one man, Joos. But his Lord demands proof of his honour, something he can only get fighting in the warfront, facing death for the realm and the woman he''s fallen for. He must return bearing the scars of countless battles, a proof of his courage and nobility, or not return at all.', 'blood-mage.jpg', 'blood-mage', 'Intelligence', 500, 285, '20', '14', '19', '2.0', '1.2', '2.8', '21 - 27', 2, '0.25', '0.01', '1800 | 1000', 'High Elf', 'Coalition', 'Missile', 2, 300, '600', '0.85 | 0.55', '0.3 | 2.4', '', 'Male', 'Magician', '', '', 'blood mage, blood mage skills, fbf blood mage, fbf hero', 'Blood Mage - A Mage that turned to politics long ago. Driven to war by true love and the promise of a sizeable inheritance.', '', '', '', 1, 'Fire Blast', 'Boon and Bane', 'Burning Skin', 'Fire Storm'),
(20, 'Royal Knight', 'The Kingdom d''Or, now home to the Forsaken, and it''s elite ''Knights d''Or'' proved the Regnum how a small regiment of expert warriors and tacticians could easily win when outnumbered by the peasants and militia that made up it''s army, in a battle that secured the Kingdom''s independence. The Regnum was then forced to make huge changes in it''s military organization. One of them was the training and creation of an elite batallion of heavilly armored knights that, in the present, serve as a sort of special police and the King''s personal guard. They are known as the ''Royal Knights''.<br /> <br />Used to bringing down rebellious nobles or dealing with simple bands of robers, Darius felt uneasy at the first sight of the Forsaken army. He was never a man of faith, but of logic and reason, and seeing such terrible creatures brought awe and fear to his heart. The way to the Forsaken''s last Bastion has been long and dangerous. He became used to the smell of their black blood, hacking and slashing through their worm-infected dead flesh. But the feeling of dread, of anticipation, of a coming doom crawled deeper into his heart. Darius is ready to die, he accepts it, and although his hand will never tremble, nor will his mind know what makes his heart shrink and shiver with every step he makes.', 'royal-knight.jpg', 'royal-knight', 'Strength', 775, 255, '27', '15', '17', '2.90', '1.6', '1.8', '29 - 39', 5, '0.25', '0.01', '1800 | 800', 'Human', 'Coalition', 'Normal', 1.95, 280, 'Melee', '0.567 | 0.433', '0.5 | 1.67', '', 'Male', 'Slayer', '', '', 'royal knight, royal knight skills, fbf royal knight, fbf hero', 'Royal Knight - The Royal Knight Darius is one of an elite batallion of heavilly armored riders. Smart and strong, he uses his fast horse...', '', '', '', 1, 'Battle Fury', 'Shattering Javelin', 'Animal War Training', 'Charge'),
(21, 'Paladin', 'An institution older than the Regnum itself, The Church of the Twin Suns preaches the word of the the Father, and lords over the work of the Mother. The religion with the most followers in the Peninsula is organized in three major groups: The Monks, represented by a pair of begging hands; The Bishops, rulers of the church represented by the Sun; and the Paladins, the disciplined and well-thaught knight-friars represented by the warhammer, as of the last centuries splintered into several orders with different political and ideological positions due to the Crown having more and more Paladins under it''s command.<br /> <br />Son of the late Eoghan Shieldbearer and Knight Master of the Order of the Sun -the original order that united every Paladin under it''s banner- Edgar has set himself with the mission of uniting all of the orders once again and declaring it''s independence from the state. A daunting task he was sure he would complete, but the tragic death and ultimate revival of Edmund, his brother in blood and in arms, has weakened his will and his conviction. Duty, sadness and justice have brought Edgar to the Bastion''s gates. His eyes stare into the future: the inevitable battle, the blood stained soil and the painful mission of honoring his brother''s life by beating his dead corpse to a pulp.', 'paladin.jpg', 'paladin', 'Strength', 750, 285, '26', '14', '19', '2.5', '1.3', '1.6', '28 - 38', 4, '0.25', '0.01', '1800 | 800', 'Human', 'Coalition', 'Normal', 1.9, 270, 'Melee', '0.567 | 0.433', '0.5 | 1.67', '', 'Male', 'Defender', '', '', 'paladin, the paladin, the holy paladin, paladin skills, fbf paladin, fbf hero', 'Paladin - Edgar Shieldbearer, Master Paladin of the Order of the Sun is a devout defender of the common men and the Church of the Twin Suns'' teachings.', '', '', '', 1, 'God''s Seal', 'Star Impact', 'Holy Strike', 'Holy Cross'),
(22, 'Giant Turtle', '', 'giant-turtle.jpg', 'giant-turtle', 'Strength', 625, 225, '25', '11', '15', '2.7', '0.9', '1.9', '28 - 46', 1, '0.25', '0.01', '1800 | 800', 'Tortoise', 'Coalition', 'Normal', 1.9, 265, 'Melee', '0.3 | 0.5', '0.75 | 0.51', '', 'Male', 'Defender', '', '', 'giant turtle, the giant turtle, giant turtle skills, fbf giant turtle, fbf hero', 'Giant Turtle - The Naga first bred turtles as pets, like cats and dogs were on the surface. But the high background magic near the sun well affected these small', '', '', '', 1, 'Surf', 'Aqua Shield', 'Scaled Shell', 'Fountain Blast'),
(23, 'Fire Panda', 'There is a black sheep to any shepherd''s flock. For the late Magi''s Guild there was Master Pan''Chou. The only man that became an archmage for only one week -when the actual archmage fell sick-. He taught alchemy to the Guild''s students and, actually, didn''t have any powers over magic. For his akwardness and unorthodox way of life, he was branded a fool and a buffoon by the other mages and the King''s court. Something to which he seemed to not pay attention but eventually came to hurt his feelings. He ultimately earned his indefinitive expulsion from the Guild as he brewed a potion that would give him control over magic, a potion that would earn him his due respect. But to no avail. He drank the infusion in front of the whole Guild only to turn into a cute fury animal. The Archmage was repulsed by the show and the embarrasement Pan''Chou made of himself. He was exiled before he could prove his succes: he had become a fire-mage!<br /><br />He lived as a hermit, training and mastering his new abilities but the fall of the Magi''s Guild at the hands of the Forsaken drove him out of his exile. He felt the death of the magi deep within his heart. The wound left a scar and he swore to avenge them. The Master of alchemy and fire will torch wave after wave of undead, but he can''t fight alone. He could go back to the nation that has always rejected him or join the divine Order of the Moon. But he also feels very familiar with the Bel''trama. Whatever side he chooses, he will fight the Forsaken and prove himself a true warrior, not a dumb buffoon.', 'fire-panda.jpg', 'fire-panda', 'Agility', 600, 255, '24', '20', '17', '1.79', '2.0', '2', '24 - 52', 5, '0.25', '0.01', '1800 | 800', 'Pandaren', 'Coalition', 'Normal', 1.9, 310, 'Melee', '0.65 | 0.35', '0.4 | 0.5', '', 'Male', 'Slayer', '', '', 'fire panda, fire panda skills, fbf fire panda, fbf hero', 'Fire Panda - A Master of alchemy, Pan''Chou brewed a potion that granted him control over fire, and made him into a furry panda!', '', '', '', 1, 'Hack''n Slash', 'High Jump', 'Bladethrow', 'Art of Fire'),
(24, 'Ogre Warrior', 'Not only the Tau or the Aj''dar are part of the Bel''trama. There are many other tribes and small clans that make the nation, but these often fight among themselves. There was a clan, long ago, of very few members. They were tall, fat and very strong brutes. Honor among themselves was so high they wouldn''t dare betrayed each other or their clan. They were the Abbari. They made their home in the Abbar Peaks, two lone mountains, an oasis of water springs and lush forests in the middle of a wide desert. As dumb as they were, the Abbari were also very hospitable to travellers. In one occassion, they welcomed a group of wounded Aj''dari. Foolishly betrayed, the travellers proved to have been acting their pain out and quickly murdered the whole of the Abbari. Only to prove the power of their tribe, to prove they could easily defeat the clan none wanted to mess with.<br /><br />When Jabbar came home from a long exile he found the forests burned and the waters tainted red. Not even his rain of tears could cleanse such a lifeless land. The last of the Abbari, he found the culprits but was ultimately defeated and made a prisoner. As such, he suffered the same fate as the Aj''dari and the Tau and now finds himself on a massive war. The undead fight a kingdom of tiny men, a cult of moon lovers and the Bel''trama that forced him into such a wat. A giant beast and a great asset to any side, Jabbar''s future depends under which banner he chooses to fight for.', 'ogre-warrior.jpg', 'ogre-warrior', 'Strength', 650, 255, '26', '18', '17', '3.0', '2.1', '1.0', '56 - 70', 8, '0.25', '0.01', '1800 | 800', 'Ogre', 'Coalition', 'Normal', 2.1, 295, 'Melee', '0.3 | 0.3', '0.56 | 0.51', '', 'Male', 'Slayer', '', '', 'ogre warrior, ogre warrior skills, fbf ogre warrior, fbf hero', 'Ogre Warrior - The last of a Bel''trama clan called the Abbari. He''s a giant blob of fat and pure brawns, a tank with a skin hard as stone.', '', '', '', 1, 'Axe Throw', 'Decapitate', 'Mighty Swing', 'Consumption'),
(25, 'Farseer', 'Almost by rule, the Bel''trama know the Ajdar as the most savage and selfish brutes but Hakim, a green-skinned eventhough a hermit, is an exception. He lives within the tribe''s lands but distanced from it''s towns, avoiding most social contact. He prefers the purity of the wilderness and a life cultivating his spirit over warmongering. When he comes accross a caravan he begs for a bowl of food instead of stealing and killing. When he spends long periods of time in the wilds he feeds off what nature gives him or not at all. But even if he seems defenseless, raiders and robbers fear him for his ability to “summon the Thunders”.<br /><br />On a muddy trail, below a full moon night, a party of hooded riders blocked Hakim''s path; surrounding him but at a reasonable distance. Even if they wanted to attack, the wolves they rode wouldn''t obey out of respect to The Wise as if he was their pack''s alpha male. One rider dismounted and threw his weapons to the side of the muddy road. With just a nod he signalled the others to rush back to their camp. Unhooded he was when he spoke to Hakim. The Wise had never seen his friend so troubled, afraid of his failures and of the death that creeped behind him; it was the only thing he spoke of. This Ajdari always came to Hakim for advice in times of trouble and even so he was rude, The Wise always complied kindly. Even if usually they went separate ways after their secret meetings, this time the Farseer decided to join his party. He too could feel the death that haunted him.<br /><br />He journeyed with the Ajdari. He hadn''t done so in decades, and the stench of blood brought back memories and the spirits of those that fell at his hands. Yet, just like the wolves, they respected Hakim. They showed him a glimpse of his future: a land unknown, a sea of blood, a castle of rusty gates and old stones, death, and rebirth.', 'farseer.jpg', 'farseer', 'Intelligence', 500, 330, '20', '14', '22', '2.0', '1.2', '2.9', '31 - 58', 3, '0.25', '0.01', '1800 | 800', 'Orc', 'Coalition', 'Missile', 2.1, 320, '600', '0.5 | 0.3', '0.3 | 1.070', '', 'Male', 'Magician', '', '', 'farseer, farseer skills, fbf farseer, fbf hero', 'Farseer - A lone and peaceful hermit, yet, the most powerful mage among the Bel''Trama.', '', '', '', 1, 'Lightning Balls', 'Volty Crush', 'Reflective Shield', 'Spirit Arrows'),
(26, 'Mountain Giant', 'There was one time on the Order''s early days that Anahi, the Oracle, and Ta''Ta Leafbeard, her mentor-druid, were waiting for their execution. The Paladins of the Twin Suns had captured them and taken them to their headquarters. She was offered a second chance at life by accepting their faith as the only true one and a home in a remote monastery. Ta''Ta''s deal was less merciful: a clean painless death and the promise he would be buried in a beautiful grave on the woods. The Order''s leaders rejected the Regnum''s proposition and so, were declared traitors of the nation.<br /><br />On their last night, Anahi pleaded her Goddess for help, desperate her faith may have been untrue all along. But her mentor revealed to her their capture was a part of the deity''s plan. At sunrise they were surrounded by a crowd of peasants and soldiers and the executioner had just finished sharpening his axe. They were kneeled down in front of him, and a monk began preaching against their actions, humiliating them. But his speech was cut short by a huge rock form the sky that crashed and shattered in front of him. The man was pushed away and left in awe as smaller faintly glowing rocks slowly rolled one into each other until they took the shape of a giant man. At the head, two eyes opened like from a long slumber and the Giant of rock scream it''s name: "<i>E''lal!!</i>"<br /><br />The Giant saved both Anahi and Ta''Ta and has followed them to the very gates of death''s Bastion. Always silent save for the time of his miraculous appearance, he''s always at the side of his master, ready to sacrifice his life for her cause.', 'mountain-giant.jpg', 'mountain-giant', 'Strength', 550, 210, '22', '7', '14', '4.5', '1.0', '1.0', '60 - 72', 10, '0.25', '0.01', '1800 | 800', 'Nightelf', 'Coalition', 'Normal', 4, 270, 'Melee', '1.000 | 0.49', '0 | 3.000', '', 'Male', 'Defender', '', '', 'mountain giant, mountain giant skills, fbf mountain giant, fbf hero', 'Mountain Giant - From the time of his amazing appearance -falling from the skies and saving Anahi and Ta''Ta- he has safeguarded his young master of all dangers.', '', '', '', 1, 'Crag', 'Hurl Boulder', 'Craggy Exterior', 'Endurance'),
(27, 'Cenarius', 'A legend as old as time, Ta''ta was a mage in love with nature. He studied with masters of fire, water, wind and ice magic but no teacher or scholar could show him the ways of the druids, the wizards of nature. The first of this magi were said to be sentient trees themselves created by the Gods to shape the land. But the young “Ta''Ta” believed they were actually humans that, through their powers over nature, became a part of it. His first studies of this forgotten art were mere observations but, nonetheless, were kept a secret from his peers and teachers. Soon enough, he began venturing into the forests for weeks until he disappeared from the academy he studied at. He simply vanished and was never again seen. At times, his story became a tale to frighten children and to encourage lost travelers, but has always been told with faint touch of romanticism.<br /><br />Little time before the wars that raged the Peninsula, The Moon Goddess called him out hiding. She warned him of a dark future and instructed him to wait for a young priestess, Anahi. Toghether, they would help the world save itself from it''s own demise. She found Ta''Ta''s den in the woods little after. As per the Goddess'' instructions, he followed the young girl as her mentor and wise counselor. They gathered many followers of what they called the ''Order of the Moon'' and now, alongside their devout troops, they face the Forsaken. His centuries of practice finally have an end, an objective, a reason to be. He finally realises what the Goddess'' plans are and how he fits. He accepts them, but with sadness for the sacrifices he will have to make.', 'cenarius.jpg', 'cenarius', 'Intelligence', 500, 325, '20', '12', '18', '2.8', '0.9', '3.6', '29 - 57', 2, '0.25', '0.01', '1800 | 800', 'Night Elf', 'Coalition', 'Missile', 2.1, 350, '800', '0.77 | 0.4', '0.3 | 0.51', '', 'Male', 'Magician', '', '', 'cenarius, nightelf, cenarius skills, fbf cenarius, fbf hero', 'Cenarius - An age old mage that became one with nature. He''s Anahi''s mentor and guide. Through his teachings, she and the Order of the Moon,...', '', '', '', 1, 'Natural Sphere', 'Magic Seed', 'Pollen Aura', 'Leaf Storm');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `heroes_x_items`
--

CREATE TABLE IF NOT EXISTS `heroes_x_items` (
  `heroId` int(10) NOT NULL,
  `itemId` int(10) NOT NULL,
  UNIQUE KEY `heroId_itemId` (`heroId`,`itemId`),
  KEY `FK_items_id` (`itemId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `heroes_x_items`
--

INSERT INTO `heroes_x_items` (`heroId`, `itemId`) VALUES
(4, 13),
(8, 13),
(11, 13),
(1, 14),
(5, 15),
(7, 15),
(8, 15),
(10, 15),
(12, 15),
(6, 16),
(7, 16),
(18, 16),
(3, 17),
(5, 17),
(9, 17),
(11, 17),
(12, 17),
(2, 18),
(18, 18),
(1, 19),
(2, 19),
(4, 19),
(6, 19),
(10, 19),
(9, 20),
(3, 22),
(1, 23),
(7, 23),
(1, 25),
(1, 26),
(3, 26),
(4, 26),
(5, 26),
(8, 26),
(10, 26),
(12, 26),
(4, 27),
(9, 27),
(18, 27),
(3, 28),
(5, 28),
(6, 28),
(12, 28),
(1, 29),
(2, 29),
(9, 29),
(18, 29),
(2, 30),
(4, 30),
(10, 30),
(18, 30),
(3, 31),
(6, 31),
(8, 31),
(11, 31),
(18, 31),
(2, 32),
(9, 32),
(10, 32),
(3, 33),
(5, 33),
(6, 33),
(7, 33),
(8, 33),
(11, 33),
(5, 34),
(7, 34),
(8, 34),
(11, 34),
(12, 34),
(6, 35),
(9, 35),
(10, 35),
(12, 35),
(2, 36),
(4, 36),
(7, 36),
(11, 36),
(17, 49),
(13, 51),
(25, 51),
(17, 53),
(13, 55),
(25, 58),
(17, 63),
(13, 64),
(25, 64),
(13, 66),
(13, 67),
(17, 67),
(13, 68),
(17, 69),
(25, 69),
(25, 70),
(25, 71),
(17, 72),
(14, 87),
(19, 87),
(19, 89),
(20, 89),
(21, 89),
(14, 91),
(20, 91),
(21, 92),
(19, 96),
(14, 98),
(19, 98),
(21, 98),
(21, 99),
(20, 100),
(21, 100),
(20, 101),
(20, 102),
(14, 103),
(19, 103),
(20, 104),
(14, 105),
(19, 106),
(14, 107),
(21, 107),
(27, 121),
(15, 123),
(15, 126),
(26, 126),
(26, 127),
(27, 127),
(27, 132),
(26, 133),
(26, 134),
(26, 135),
(15, 136),
(26, 136),
(15, 137),
(15, 138),
(27, 138),
(27, 141),
(15, 142),
(27, 142);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `heroes_x_media`
--

CREATE TABLE IF NOT EXISTS `heroes_x_media` (
  `heroId` int(10) NOT NULL,
  `mediaId` int(10) NOT NULL,
  `position` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`heroId`,`mediaId`),
  KEY `FK_heroes_x_media_media` (`mediaId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `hero_changelog`
--

CREATE TABLE IF NOT EXISTS `hero_changelog` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `hero_id` int(11) NOT NULL,
  `version` varchar(5) NOT NULL,
  `description` varchar(1024) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=25 ;

--
-- Daten für Tabelle `hero_changelog`
--

INSERT INTO `hero_changelog` (`ID`, `hero_id`, `version`, `description`) VALUES
(1, 1, '', ''),
(2, 2, '', ''),
(3, 3, '', ''),
(4, 4, '', ''),
(5, 5, '', ''),
(6, 6, '', ''),
(7, 7, '0.2.6', '<strong>Spawn Zombie: </strong>changed the amount of zombies from 2/3/4/5/6 to 2/2/3/3/4'),
(8, 8, '0.2.8', '<strong>Dead Souls: </strong>decreased the amount of flying souls from 120 to 20'),
(9, 9, '', ''),
(10, 10, '', ''),
(11, 11, '', ''),
(12, 12, '', ''),
(13, 13, '', ''),
(14, 14, '0.2.4', '<strong>Trappy Swap: </strong>Death Wardens can''t control anymore'),
(15, 15, '', ''),
(16, 16, '0.2.4', '<strong>Impaling Spine: </strong>set the hero stun from 2s/2.5s/3s/3.5s/4s to 1.5s per level'),
(17, 17, '', ''),
(18, 18, '0.2.9', '<strong>Statistics: </strong>increased the Range from 600 to 700'),
(19, 19, '', ''),
(20, 20, '', ''),
(21, 21, '', ''),
(22, 22, '0.2.4', '<strong>Fountain Blast: </strong>decreased the flight time from units taken by a projectile from 1.75s to 0.9s'),
(23, 23, '0.2.3', '<strong>Hack''n Slash: </strong>decreased damage values from 60/90/120/150/180 to 50/80/110/140/170|<strong>Hack''n Slash: </strong>increased target damage reducer from 10% to 15%'),
(24, 24, '0.2.1', 'decreased INT from 1.3 to 1.0');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `items`
--

CREATE TABLE IF NOT EXISTS `items` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(256) CHARACTER SET latin1 NOT NULL,
  `f-name` varchar(256) NOT NULL,
  `description` varchar(1024) CHARACTER SET latin1 NOT NULL,
  `image` varchar(256) DEFAULT NULL,
  `costs` int(6) NOT NULL,
  `bonus` varchar(1024) CHARACTER SET latin1 NOT NULL,
  `affiliation` varchar(20) CHARACTER SET latin1 NOT NULL,
  `shop_id` int(1) NOT NULL,
  `type` int(1) NOT NULL,
  `order_id` int(11) NOT NULL,
  `hero_ids` varchar(256) NOT NULL,
  `changelog_ids` varchar(256) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=145 ;

--
-- Daten für Tabelle `items`
--

INSERT INTO `items` (`ID`, `name`, `f-name`, `description`, `image`, `costs`, `bonus`, `affiliation`, `shop_id`, `type`, `order_id`, `hero_ids`, `changelog_ids`) VALUES
(1, 'Healing Potion', 'healing-potion', 'Regenerate 100 hit points when used. When drunk, the magic quickly heals the body, but wears off fast.', 'healing-potion.jpg', 30, '+100 HP Regeneration', 'UD', 10, 0, 0, '', '""'),
(2, 'Mana Potion', 'mana-potion', 'Restores 75 Mana when used. Nothing more than water infused with magic, this drink can restore small portions of mana in crucial moments.', 'mana-potion.jpg', 30, '+75 Mana Regeneration', 'UD', 10, 0, 1, '', '""'),
(3, 'Healing Elexir', 'healing-elexir', 'Regenerates 500 hit points over 30 seconds. Effect is cancelled when taking damage. Like any medicine, this potion can do much good, but only if one avoids stress.', 'healing-elexir.jpg', 100, '+500 HP Regeneration over 30s', 'UD', 10, 0, 2, '', '""'),
(4, 'Mana Elixir', 'mana-elexir', 'Restores 400 Mana over 30 seconds. Effect is cancelled when under attack. The magic particles filter energy out of the air and convert them to mana, but only as long as they can work undisturbed.', 'mana-elexir.jpg', 100, '+400 Mana Regeneration over 30s', 'UD', 10, 0, 3, '', '""'),
(5, 'Antimagic Potion\r\n', 'antimagic-potion\r\n', 'Gives the Hero immunity to magical spells for 20 seconds.', 'antimagic-potion.jpg', 80, '+20s Spell Immunity', 'UD', 10, 0, 4, '', '""'),
(6, 'Invulnerability Potion', 'invulnerability-potion', 'Makes the Hero invulnerable to damage for 15 seconds when used. An invulnerable Hero may not be the target of spells or effects.', 'invulnerability-potion.jpg', 85, '+15s invulnerable', 'UD', 10, 0, 5, '', '""'),
(7, 'Potion of Invisibility', 'potion-of-invisibility', 'Renders the Hero invisible for 60 seconds when used. An invisible Hero is untargetable by the enemy unless detected. If the Hero attacks, uses an ability, or casts a spell, the invisibility effect is lost.', 'potion-of-invisibility.jpg', 60, '+60s invisible', 'UD', 10, 0, 6, '', '""'),
(8, 'Speed Up Potion', 'speed-up-potion', 'This little bottle increases the movement speed of the Hero for 10 seconds.', 'speed-up-potion.jpg', 50, 'increases movement speed for 10s', 'UD', 10, 0, 7, '', '""'),
(13, 'Bone Helmet', 'bone-helmet', 'Since many Undead had experienced severe head trauma bevor being revived, an additional layer of bone is often needed. ', 'bone-helmet.jpg', 320, '+250 HP', 'UD', 11, 1, 0, '', '""'),
(14, 'Belt of Giant Strength', 'belt-of-giant-strength', 'The lifedrinking gem in this belt can extend the "life" span of an Undead by a tenfold.', 'belt-of-giant-strength-jpg', 260, '+8 Strength', 'UD', 11, 1, 1, '', '""'),
(15, 'Dark Plates', 'dark-plates', 'Reforged from salvaged armor, the featureless plates can withstand great punishment.', 'dark-plates.jpg', 225, '+5 Armor', 'UD', 11, 1, 2, '', '""'),
(16, 'Plate Glove', 'plate-glove', 'A quick grab with this glove can prevent unlucky strikes and shots, but can''t deflect well-placed thrusts.', 'plate-glove.jpg', 310, '+10% Evasion', 'UD', 11, 1, 3, '', '""'),
(17, 'Blood Blade', 'blood-blade', 'A weapon so simple and effective that only the decaying imagination of an Undead could have created it.', 'blood-blade.jpg', 285, '+15 Damage', 'UD', 11, 1, 4, '', '""'),
(18, 'Spider Bracelet', 'spider-bracelet', 'Clearly of Nerubian design, this magic item serves as counterweight for the often unbalanced Undead weapons.', 'spider-bracelet.jpg', 270, '+6 Agility', 'UD', 11, 1, 5, '', '""'),
(19, 'Twin Axe', 'twin-axe', 'The second edge of this weapon allows the wielder to cut again during the backswing.', 'twin-axe.jpg', 360, '+15% Attack Speed', 'UD', 11, 1, 6, '', '""'),
(20, 'Frenzy Boots', 'frenzy-boots', 'Based on High Elf design, these boots are cheap, but do not decay faster than the average wearer.', 'frenzy-boots.jpg', 215, '+40 Movement Speed', 'UD', 11, 1, 7, '', '""'),
(21, 'Runic Charm', 'runic-charm', 'This simple charm can store only small amounts of mana, but can be mass-produced and handed out to entire armies.', 'runic-charm.jpg', 185, '+100 Mana', 'UD', 11, 1, 8, '', '""'),
(22, 'Cursed Robe', 'cursed-robe', 'The robes of Necromancers are actually cursed, but only against any living that would try to wear it.', 'cursed-robe.jpg', 210, '+7 Intelligence', 'UD', 11, 1, 9, '', '""'),
(23, 'Unholy Icon', 'unholy-icon', 'This ram skull is so corrupted by the Darkness that it emanates a constant malice, inspiring all Undead.', 'unholy-icon.jpg', 300, 'Unholy Aura (+15% MOV, + 0.25 HP/sec)', 'UD', 11, 1, 10, '', '""'),
(24, 'Skull Rod', 'skull-rod', 'The quality of ''wand-produced'' Undead is low, but makes the job easier for the overworked Necromancers.', 'skull-rod.jpg', 265, 'Necromancy (2 Skeletons, 30 sec. CD, 80 sec. Dur)', 'UD', 11, 1, 11, '', '""'),
(25, 'Blood Plate Armor', 'blood-plate-armor', 'One of the most massive armor designs. It is rumored that the alloy it is made of is the one used by Deathwing for his armor.', 'blood-plate-armor.jpg', 1520, '+20 Strength|+18 Armor|+15 Damage Reduction', 'UD', 12, 2, 0, '', '""'),
(26, 'Demonic Amulet', 'demonic-amulet', 'The Felguard were warriors and mages and tried to enhance both skills with these amulets.', 'demonic-amulet.jpg', 1260, '+17 Strength|+300 Mana | 35% chance to cast Meteor on Hero Kill', 'UD', 12, 2, 1, '', '""'),
(27, 'Metal Hand', 'metal-hand', 'When it comes to replacing body parts, Undead have no moral issues with replacing what they need with magic items.', 'metal-hand.jpg', 2240, '+35% Evasion|+26 Agility | 3% chance to cast Fully Heal Self over 12s when Hero get hit', 'UD', 12, 2, 2, '', '""'),
(28, 'Corrupted Icon', 'corrupted-icon', 'To see their own religious symbols turned into weapons can weaken the morale of every enemy.', 'corrupted-icon.jpg', 1680, '+15% Evasion|+23 Armor | Possession', 'UD', 12, 2, 3, '', '""'),
(29, 'Spear of Vengeance', 'spear-of-vengeance', 'The perfect balance and sharpness of this weapon is surprising. Untrained wielders often cut themselves in the first fight.', 'spear-of-vengeance.jpg', 1900, '+47 Damage|+16 Agility|Critical (0,75x, 5%)', 'UD', 12, 2, 4, '', '""'),
(30, 'Morning Star', 'morning-star', 'Made for a brutal fighting style, this weapon is best used with both hands and no concerns about safety.', 'morning-star.jpg', 1320, '+150HP|Berserk (+80% Attack Speed, +60% Damage taken + 35% Movement Speed)', 'UD', 12, 2, 5, '', '""'),
(31, 'Magic Axe', 'magic-axe', 'Made from ore with high magical density, this axe is rumored to randomly discharge arcane energy that gives its attacks an edge.', 'magic-axe.jpg', 2320, '+62 Damage|+31 Intelligence | Experience rate increased by 32%', 'UD', 12, 2, 6, '', '""'),
(32, 'Raving Sword', 'raving-sword', 'Originally an Elfish design, the sword shows clear signs of its adaptation by Undead, but is incredibly fast nonetheless.', 'raving-sword.jpg', 2440, '+12% Attack Speed|+95 Damage|+35 Movement Speed | Bash (8% 2s/1s)', 'UD', 12, 2, 7, '', '""'),
(33, 'Arcane Flare', 'arcane-flare', 'The runes on this amulet can not only store magic energy, but also release it into the environment to help other mages.', 'arcane-flare.jpg', 980, '+400 Mana|Mana Flare (+165 Mana restored in 600 AoE, CD 45s)', 'UD', 12, 2, 8, '', '""'),
(34, 'Necromancer''s Robe', 'necromancers-robe', 'Made of pelt of questionable origin, this robe serves not only as a magic catalyst, but also as protection against blows.', 'necromancers-robe.jpg', 1340, '+21 Intelligence|+300 HP|+150 Mana | Experience rate for enemy Heroes is decreased by 10%', 'UD', 12, 2, 9, '', '""'),
(35, 'Bone Charm', 'bone-charm', 'This literal exoskeleton is magically enhanced to protect the wearer against enemy spells.', 'bone-charm.jpg', 1840, '+200 HP|+31 Armor |Spell Shield(30s)', 'UD', 12, 2, 10, '', '""'),
(36, 'Tempest Skull', 'tempest-skull', 'This skull gathers free time to release it when neccessary, giving the wielder more time to walk to his destination.', 'tempest-skull.jpg', 620, '+60 Movement Speed|Dash (Max. Movement Speed, 5s Duration, 45s Cooldown)', 'UD', 12, 2, 11, '', '""'),
(37, 'Healing Potion', 'healing-potion', 'Regenerate 100 hit points when used. When drunk, the magic quickly heals the body, but wears off fast.', 'healing-potion.jpg', 100, '+100 HP Regeneration', 'ORC', 4, 0, 0, '', '""'),
(38, 'Mana Potion', 'mana-potion', 'Restores 75 Mana when used. Nothing more than water infused with magic, this drink can restore small portions of mana in crucial moments.', 'mana-potion.jpg', 30, '+75 Mana Regeneration', 'ORC', 4, 0, 1, '', '""'),
(39, 'Healing Elexir', 'healing-elexir', 'Regenerates 500 hit points over 30 seconds. Effect is cancelled when taking damage. Like any medicine, this potion can do much good, but only if one avoids stress.', 'healing-elexir.jpg', 100, '+500 HP Regeneration over 30s', 'ORC', 4, 0, 2, '', '""'),
(40, 'Mana Elixir', 'mana-elixir', 'Restores 400 Mana over 30 seconds. Effect is cancelled when under attack. The magic particles filter energy out of the air and convert them to mana, but only as long as they can work undisturbed.', 'mana-elixir.jpg', 100, '+400 Mana Regeneration over 30s', 'ORC', 4, 0, 3, '', '""'),
(41, 'Antimagic Potion', 'antimagic-potion', 'Gives the Hero immunity to magical spells for 20 seconds.', 'antimagic-potion.jpg', 80, '+20s Spell Immunity', 'ORC', 4, 0, 4, '', '""'),
(42, 'Invulnerability Potion', 'invulnerability-potion', 'Makes the Hero invulnerable to damage for 15 seconds when used. An invulnerable Hero may not be the target of spells or effects.', 'invulnerability-potion.jpg', 85, '+15s invulnerable', 'ORC', 4, 0, 5, '', '""'),
(43, 'Potion of Invisibility', 'potion-of-invisibility', 'Renders the Hero invisible for 60 seconds when used. An invisible Hero is untargetable by the enemy unless detected. If the Hero attacks, uses an ability, or casts a spell, the invisibility effect is lost.', 'potion-of-invisibility.jpg', 60, '+60s invisible', 'ORC', 4, 0, 6, '', '""'),
(44, 'Speed Up Potion', 'speed-up-potion', 'This little bottle increases the movement speed of the Hero for 10 seconds.', 'speed-up-potion.jpg', 50, 'increases movement speed for 10s', 'ORC', 4, 0, 7, '', '""'),
(49, 'Blood Stone', 'blood-stone', 'This gem was soaked in blood for several days, and now fills the wearer with new life force to survive the greatest wounds.', 'blood-stone.jpg', 237, '+185 HP', 'ORC', 5, 1, 0, '', '""'),
(50, 'Spiked Collar', 'spiked-collar', 'This small leather band is mostly of symbolic value - it stands for a lifestyle filled with hatred and violence.', 'spiked-collar.jpg', 228, '+7 Strength', 'ORC', 5, 1, 1, '', '""'),
(51, 'Ogrimmar Shield', 'ogrimmar-shield', 'Made only from the best wood, the shields of Orcs are sturdy and cheaper than comparable human products.', 'ogrimmar-shield.jpg', 270, '+6 Armor', 'ORC', 5, 1, 2, '', '""'),
(52, 'Darkspear Mask', 'darkspear-mask', 'This mask makes the opponent unable to guess what the other is looking at, making feint attacks less useful.', 'darkspear-mask.jpg', 341, '+11% Evasion', 'ORC', 5, 1, 3, '', '""'),
(53, 'Blackrock Axe', 'blackrock-axe', 'Orc metalwork may be simple, but is horribly effective. What other races achieve through balance, they achieve with momentum.', 'blackrock-axe.jpg', 190, '+10 Damage', 'ORC', 5, 1, 4, '', '""'),
(54, 'Troll Dagger', 'troll-dagger', 'The small weapons of the Trolls are often the target of jokes from Orcs - but only as long as no Troll has one nearby.', 'troll-dagger.jpg', 225, '+5 Agility', 'ORC', 5, 1, 5, '', '""'),
(55, 'Mace', 'mace', 'When Orcs need to hit faster, they take blunt weapons, as those do not have to be pulled out of the enemy again.', 'mace.jpg', 288, '+12% Attack Speed', 'ORC', 5, 1, 6, '', '""'),
(56, 'Centaur Boots', 'centaur-boots', 'Centaurs eat Tauren. In return, Tauren use Centaur hide for leatherwork, and the results are certainly top quality.', 'centaur-boots.jpg', 215, '+40 Movement', 'ORC', 5, 1, 7, '', '""'),
(57, 'Pipe', 'pipe', 'The magic ingredient is of course not the pipe, but the herbs smoked to broaden one\\''s horizon.', 'pipe.jpg', 194, '+105 Mana', 'ORC', 5, 1, 8, '', '""'),
(58, 'Shaman Glove', 'shaman-glove', 'The robe of a shaman is made from animal hides to show his connection with the Spirit of Nature.', 'shaman-glove.jpg', 180, '+6 Intelligence', 'ORC', 5, 1, 9, '', '""'),
(59, 'Warsong Drums', 'warsong-drums', 'Before the Tauren entered the Horde, war drums were portable. Some of them are still around and are used when Kodos are rare.', 'warsong-drums.jpg', 480, 'Command Aura (+15% Bonus Damage)', 'ORC', 5, 1, 10, '', '""'),
(60, 'Thunder Ring', 'thunder-ring', 'The alloy used is a perfect conduit for electricity, making the lightning called with it even stronger.', 'thunder-ring.jpg', 380, 'Lightning Shield (+15 Dps, 20s Duration, 60s CD)', 'ORC', 5, 1, 11, '', '""'),
(61, 'Blackrock Armor', 'blackrock-armor', 'Based on the armor of Orgrim Doomhammer, these plates are light and yet strong enough to withstand even Orc weapons.', 'blackrock-armor.jpg', 1760, '+15 Strength|+25 Armor|+23 Damage Reduction', 'ORC', 6, 2, 0, '', '""'),
(62, 'Kodo Vest', 'kodo-vest', 'The Trolls began to use Kodo hides for their armor instead of the traditional wooden plates.', 'kodo-vest.jpg', 2580, '+21 Armor|+16 Agility | Aura of Redemption ', 'ORC', 6, 2, 1, '', '""'),
(63, 'Shaman Hood', 'shaman-hood', 'Unlike the traditional wolf pelts, this headdress doesn''t limit the wearer''s field of view and has no teeth that could chafe.', 'shaman-hood.jpg', 2840, '+20% Evasion|+225 Mana | Anger of Thrall ( 15% chance )', 'ORC', 6, 2, 2, '', '""'),
(64, 'Defensive Charm', 'defensive-charm', 'The magic of this amulet hardens the skin of its wearer and those around it, but requires additional magic to function.', 'defensive-charm.jpg', 1020, '+15% Evasion|Scroll of Armor (+15 Armor, 500 AoE, 20s Duration, 90s CD)', 'ORC', 6, 2, 3, '', '""'),
(65, 'Assassin''s Dagger', 'assassins-dagger', 'The new Horde does not often hace the need to use assassins, but no race would dare to forget what the old achieved with them.', 'assassins-dagger.jpg', 2300, '+80 Damage|+12 Agility|Critical (0.75x, 5%)', 'ORC', 6, 2, 4, '', '""'),
(66, 'Broad Axe', 'broad-axe', 'This weapon is designed for Tauren strength, and even some Orcs struggle with the massive weight of this axe.', 'broad-axe.jpg', 2080, '+58 Damage|Cleaving Attack (+25%)', 'ORC', 6, 2, 5, '', '""'),
(67, 'Longsword', 'longsword', 'While in favor of axes, the art of making balanced weapons like swords is not unknown to Orcs, and the results are rather effective.', 'longsword.jpg', 1980, '+37 Strength|+30% Attack Speed | Orb of Fire (+15)', 'ORC', 6, 2, 6, '', '""'),
(68, 'Kodo Boots', 'kodo-boots', 'Kodo leather is one of the favourite materials for boots and light armor since the Horde\\''s landing on Kalimdor.', 'kodo-boots.jpg', 2080, '+375 HP| Speed Boost (100%, 25s) | War Drums Aura ( +40% )', 'ORC', 6, 2, 7, '', '""'),
(69, 'Stone Amulet', 'stone-amulet', 'In comparison to the complex shamanism of the Orcs, Tauren magic may seem simple, but it is nonetheless deadly.', 'stone-amulet.jpg', 1340, '+175 Mana|+30 Intelligence | Experience rate increased by 18%', 'ORC', 6, 2, 8, '', '""'),
(70, 'Frenzy Ring', 'frenzy-ring', 'This ring is used by Shamans to boost their combat prowess, both with claws and with spells.', 'frenzy-ring.jpg', 1520, '+27% Attack Speed|+35 Intelligence', 'ORC', 6, 2, 9, '', '""'),
(71, 'Tauren Totem', 'tauren-totem', 'No Orc could stand the shame of falling behind when the leader rushed ahead while carrying a heavy totem.', 'tauren-totem.jpg', 1620, '+55 Movement Speed|Endurance Aura (+30% Attack Speed)', 'ORC', 6, 2, 10, '', '""'),
(72, 'Dragon Ring', 'dragon-ring', 'Some say these rings were forged with the blood of Alexstraza, but it was probably a lesser Red Dragon.', 'dragon-ring.jpg', 1020, '+230 HP|Fire Bolt (+160 Damage, 2/1s Stun, 30s CD, 75 Mana)', 'ORC', 6, 2, 11, '', '""'),
(73, 'Healing Potion', 'healing-potion', 'Regenerate 100 hit points when used. When drunk, the magic quickly heals the body, but wears off fast.', 'healing-potion.jpg', 30, '+100 HP Regeneration', 'HUM', 7, 0, 0, '', '""'),
(74, 'Mana Potion', 'mana-potion', 'Restores 75 Mana when used. Nothing more than water infused with magic, this drink can restore small portions of mana in crucial moments.', 'mana-potion.jpg', 30, '+75 Mana Regeneration', 'HUM', 7, 0, 1, '', '""'),
(75, 'Healing Elexir', 'healing-elexir', 'Regenerates 500 hit points over 30 seconds. Effect is cancelled when taking damage. Like any medicine, this potion can do much good, but only if one avoids stress.', 'healing-elexir.jpg', 100, '+500 HP Regeneration over 30s', 'HUM', 7, 0, 2, '', '""'),
(76, 'Mana Elixir', 'mana-elixir', 'Restores 400 Mana over 30 seconds. Effect is cancelled when under attack. The magic particles filter energy out of the air and convert them to mana, but only as long as they can work undisturbed.', 'mana-elixir.jpg', 100, '+400 Mana Regeneration over 30s', 'HUM', 7, 0, 3, '', '""'),
(77, 'Antimagic Potion', 'antimagic-potion', 'Gives the Hero immunity to magical spells for 20 seconds.', 'antimagic-potion.jpg', 80, '+20s Spell Immunity', 'HUM', 7, 0, 4, '', '""'),
(78, 'Invulnerability Potion', 'invulnerability-potion', 'Makes the Hero invulnerable to damage for 15 seconds when used. An invulnerable Hero may not be the target of spells or effects.', 'invulnerability-potion.jpg', 85, '+15s invulnerable', 'HUM', 7, 0, 5, '', '""'),
(79, 'Potion of Invisibility', 'potion-of-invisibility', 'Renders the Hero invisible for 60 seconds when used. An invisible Hero is untargetable by the enemy unless detected. If the Hero attacks, uses an ability, or casts a spell, the invisibility effect is lost.', 'potion-of-invisibility.jpg', 60, '+60s invisible', 'HUM', 7, 0, 6, '', '""'),
(80, 'Speed Up Potion', 'speed-up-potion', 'This little bottle increases the movement speed of the Hero for 10 seconds.', 'speed-up-potion.jpg', 50, 'increases movement speed for 10s', 'HUM', 7, 0, 7, '', '""'),
(85, 'Silvermoon Shield', 'silvermoon-shield', 'The Blood Elves no longer create these shields, and only a handful remains, given to most trusted commanders.', 'silvermoon-shield.jpg', 256, '+200 HP', 'HUM', 8, 1, 0, '', '""'),
(86, 'Guardian Helmet', 'guardian-helmet', 'Dwarf Guardians are not only body guards for kings and nobility, but also fearsome shock troops.', 'guardian-helmet.jpg', 325, '+10 Strength', 'HUM', 8, 1, 1, '', '""'),
(87, 'Chainmail', 'chainmail', 'Unlike heavy plate armor, chainmail leaves the wearer fully mobile, but offers also less protection.', 'chainmail.jpg', 180, '+4 Armor', 'HUM', 8, 1, 2, '', '""'),
(88, 'Sunray Blossom', 'sunray-blossom', 'Growing around the site of the Sun Well, these flowers are not only believed to be lucky - experiments confirmed it.', 'sunray-blossom.jpg', 279, '+9% Evasion', 'HUM', 8, 1, 3, '', '""'),
(89, 'Dwarven Hammer', 'dwarven-hammer', 'The Dwarves of Khaz Modan prefer the raw strength of a hammer over the human finesse with the sword.', 'dwarven-hammer.jpg', 228, '+12 Damage', 'HUM', 8, 1, 4, '', '""'),
(90, 'Fencing Sword', 'fencing-sword', 'Perfected over centuries, the human blacksmiths produce swords perfecty balanced, envied even by the High Elves.', 'fencing-sword.jpg', 315, '+7 Agility', 'HUM', 8, 1, 5, '', '""'),
(91, 'Time Amulet', 'time-amulet', 'This amulet can bend the time slightly in favor of the wearer, giving him an edge in combat.', 'time-amulet.jpg', 240, '+10% Attack Speed', 'HUM', 8, 1, 6, '', '""'),
(92, 'Boots of Quel''Thalas', 'boots-of-quelthalas', 'Like most of the Elfish equipment, these boots require magic to be crafted, and rose in price after the destruction of Silvermoon.', 'boots-of-quelthalas.jpg', 161, '+30 Movement', 'HUM', 8, 1, 7, '', '""'),
(93, 'Tiger''s-Eye', 'tigers-eye', 'These semiprecious stones are surprisingly affectable by magic and even unprocessed specimens can be used as mana stores.', 'tigers-eye.jpg', 222, '+120 Mana', 'HUM', 8, 1, 8, '', '""'),
(94, 'Pointy Hat', 'pointy-hat', 'While not mandatory, many mages wear these out of a sense of tradition, although no one remembers what they stand for.', 'pointy-hat.jpg', 180, '+6 Intelligence', 'HUM', 8, 1, 9, '', '""'),
(95, 'Arcane Circlet', 'arcane-circlet', 'The gems inlaid in this diadem are magically enhanced to filter raw magic out of the air and to distribute it to nearby mages.', 'arcane-circlet.jpg', 250, 'Brilliance Aura (+0.50 MP/s)', 'HUM', 8, 1, 10, '', '""'),
(96, 'Anti-Magic Wand', 'anti-magic-wand', 'If the Blood Elves are short on trained Priests, they often give these items to the Alliance armies to partially replace the lack.', 'anti-magic-wand.jpg', 270, 'Neutralization (6 Targets, 30s)', 'HUM', 8, 1, 11, '', '""'),
(97, 'Knight Helmet', 'knight-helmet', 'Made of the best steel and created in tandem by Humans and Dwarfs, this helmet is guaranteed to survive a drop into lava.', 'knight-helmet.jpg', 1860, '+20 Armor|+20 Strength|+35 Damage Reduction', 'HUM', 9, 2, 0, '', '""'),
(98, 'Lucky Ring', 'lucky-ring', 'The amethyst in this ring seems to refract the light in an odd way, but it actually bends reality.', 'lucky-ring.jpg', 2120, '+20% Evasion|+40% Attack Speed | 9% chance on kill to regenerate 500 HP over 10s for nearby ally units', 'HUM', 9, 2, 1, '', '""'),
(99, 'Stormwind Shield', 'stormwind-shield', 'The kingdom of Stormwind may have fallen, but many of its artifacts still remain, trophies of battles against the orcs.', 'stormwind-shield.jpg', 2340, '+40 Armor|Infliction ( 150HP, 25 HP-Reg., CD 30s )', 'HUM', 9, 2, 2, '', '""'),
(100, 'Holy Shield', 'holy-shield', 'When Paladins march to fight corruption and destroy the wicked, they do not go without blessing their armor.', 'holy-shield.jpg', 1480, '+300 HP|Seed of Life', 'HUM', 9, 2, 3, '', '""'),
(101, 'War Flail', 'war-flail', 'While considered a lowly weapon, not fit for nobility, this originally agricultural implement can wreak a lot of havoc.', 'war-flail.jpg', 2220, '+45 Damage|+25 Agility|Critical (0.75x, 5%)', 'HUM', 9, 2, 4, '', '""'),
(102, 'Volcano Hammer', 'volcano-hammer', 'This design packs all of a Dwarven Berserker\\''s rage and force into one weapon that can punch any armor into a pulpy mass.', 'volcano-hammer.jpg', 1720, '+38 Damage|+30 Strength | Storm Bolt (25% chance on hero kill)', 'HUM', 9, 2, 5, '', '""'),
(103, 'Crowbar', 'crowbar', 'Developed after the battle of Mount Hyjal, this weapon should give the wielder the nimbleness of the Druids of the Talon.', 'crowbar.jpg', 1900, '+18 Agility|+23 Intelligence | +75 Magic Damage on every third hit on the same unit and a 1.2s slow', 'HUM', 9, 2, 6, '', '""'),
(104, 'Seven League Boots', 'seven-league-boots', 'The only type of boots that do not actually help the wearer to walk faster. Instead, they move the universe around him.', 'seven-league-boots.jpg', 720, '+20% Attack Speed|+60 Movement Speed', 'HUM', 9, 2, 7, '', '""'),
(105, 'Gryphon''s-Eye', 'gryphons-eye', 'Cut and polished Tiger\\''s-Eye, infused with magic, is an even better catalyst for casting than the raw gem.', 'gryphons-eye.jpg', 1480, '+325 Mana|+35 Intelligence', 'HUM', 9, 2, 8, '', '""'),
(106, 'Runestone', 'runestone', 'To create a store for either life or mana, one requires only one rune. But to fit both into one, a lot more are needed.', 'runestone.jpg', 1040, '+250 Mana|+250 HP | Experience rate increased by 25%', 'HUM', 9, 2, 9, '', '""'),
(107, 'Fire Wand', 'fire-wand', 'The eternal flame on top of this staff fills the wielder with renewed vigor and burns those unworthy to touch it.', 'fire-wand.jpg', 1020, '+70 Movement Speed|Damage Return (+25%)', 'HUM', 9, 2, 10, '', '""'),
(108, 'Seeing Staff', 'seeing-staff', 'The extra eye on top of the staff helps the wielder in combat when it is not used to see faraway lands.', 'seeing-staff.jpg', 1440, '+15% Evasion|Confused Sight (30s)', 'HUM', 9, 2, 11, '', '""'),
(109, 'Healing Potion', 'healing-potion', 'Regenerate 100 hit points when used. When drunk, the magic quickly heals the body, but wears off fast.', 'healing-potion.jpg', 30, '+100 HP Regeneration', 'NE', 1, 0, 0, '', '""'),
(110, 'Mana Potion', 'mana-potion', 'Restores 75 Mana when used. Nothing more than water infused with magic, this drink can restore small portions of mana in crucial moments.', 'mana-potion.jpg', 30, '+75 Mana Regeneration', 'NE', 1, 0, 1, '', '""'),
(111, 'Healing Elexir', 'healing-elexir', 'Regenerates 500 hit points over 30 seconds. Effect is cancelled when taking damage. Like any medicine, this potion can do much good, but only if one avoids stress.', 'healing-elexir.jpg', 100, '+500 HP Regeneration over 30s', 'NE', 1, 0, 2, '', '""'),
(112, 'Mana Elixir', 'mana-elexir', 'Restores 400 Mana over 30 seconds. Effect is cancelled when under attack. The magic particles filter energy out of the air and convert them to mana, but only as long as they can work undisturbed.', 'mana-elexir.jpg', 100, '+400 Mana Regeneration over 30s', 'NE', 1, 0, 3, '', '""'),
(113, 'Antimagic Potion\r\n', 'antimagic-potion\r\n', 'Gives the Hero immunity to magical spells for 20 seconds.', 'antimagic-potion.jpg', 80, '+20s Spell Immunity', 'NE', 1, 0, 4, '', '""'),
(114, 'Invulnerability Potion', 'invulnerability-potion', 'Makes the Hero invulnerable to damage for 15 seconds when used. An invulnerable Hero may not be the target of spells or effects.', 'invulnerability-potion.jpg', 85, '+15s invulnerable', 'NE', 1, 0, 5, '', '""'),
(115, 'Potion of Invisibility', 'potion-of-invisibility', 'Renders the Hero invisible for 60 seconds when used. An invisible Hero is untargetable by the enemy unless detected. If the Hero attacks, uses an ability, or casts a spell, the invisibility effect is lost.', 'potion-of-invisibility.jpg', 60, '+60s invisible', 'NE', 1, 0, 6, '', '""'),
(116, 'Speed Up Potion', 'speed-up-potion', 'This little bottle increases the movement speed of the Hero for 10 seconds.', 'speed-up-potion.jpg', 50, 'increases movement speed for 10s', 'NE', 1, 0, 7, '', '""'),
(121, 'Bark Skin', 'bark-skin', 'Some plants can be transformed into a living armor with a small spell.', 'bark-skin.jpg', 224, '+175 HP', 'NE', 2, 1, 0, '', '""'),
(122, 'Treant Root', 'treant-root', 'Enchanted by novice druids, the life force of the roots strengthens anyone who wields it.', 'treant-root.jpg', 228, '+7 Strength', 'NE', 2, 1, 1, '', '""'),
(123, 'Ancient Shield', 'ancient-shield', 'The mobile Night Elf troops prefer light armor to heavy shields, but nonetheless know how to forge them.', 'ancient-shield.jpg', 225, '+5 Armor', 'NE', 2, 1, 2, '', '""'),
(124, 'Reinforced Glove', 'reinforced-glove', 'The metal plate on the back of the glove is hard enough to deflect strikes, but is difficult to use.', 'reinforced-glove.jpg', 403, '+13% Evasion', 'NE', 2, 1, 3, '', '""'),
(125, 'Suramar Blade', 'suramar-blade', 'The knowledge to forge these swords was lost with the Well of Eternity.', 'suramar-blade.jpg', 190, '+10 Damage', 'NE', 2, 1, 4, '', '""'),
(126, 'Sun Bow', 'sun-bow', 'Designed to be easily carried, quickly strung and effortlessly drawn, this bow is favored by scouts and saboteurs.', 'sun-bow.jpg', 360, '+8 Agility', 'NE', 2, 1, 5, '', '""'),
(127, 'Huntress Steel', 'huntress-steel', 'The perfectly balanced Elfish short swords allow the wielder to fight fast and precise.', 'huntress-steel.jpg', 312, '+13% Attack Speed', 'NE', 2, 1, 6, '', '""'),
(128, 'Scout Boots', 'scout-boots', 'The light weight and high durability  of the Elf boots is still unmatched by those of other Alliance races.', 'scout-boots.jpg', 269, '+50 Movement Speed', 'NE', 2, 1, 7, '', '""'),
(129, 'Bound Wisp', 'bound-wisp', 'Pet Wisps are sometimes used by Night Elf Druids as mobile mana stores.', 'bound-wisp.jpg', 213, '+115 Mana', 'NE', 2, 1, 8, '', '""'),
(130, 'Druid Staff', 'druid-staff', 'Magically enhanced wood helps to wielder to link with the nature, increasing his power.', 'druid-staff.jpg', 240, '+8 Intelligence', 'NE', 2, 1, 9, '', '""'),
(131, 'Moon Blossom', 'moon-blossom', 'Considered as lucky among Night Elves, archers often stick one of these flowers into their quivers.', 'moon-blossom.jpg', 465, 'Trueshot Aura (+15% Damage)', 'NE', 2, 1, 10, '', '""'),
(132, 'Cyclone Wand', 'cyclone-wand', 'The Druids of the Talon crafted these wands to help the troops they could not protect personally.', 'cyclone-wand.jpg', 225, 'Cyclone (25s)', 'NE', 2, 1, 11, '', '""'),
(133, 'Twilight Armor', 'twilight-armor', 'When facing Legion Warlocks, Demon Hunters often use this massive armor, as usual plating fails against Hellfire.', 'twilight-armor.jpg', 1180, '+150 HP|+14 Armor|+32 Damage Reduction', 'NE', 3, 2, 0, '', '""'),
(134, 'Moon Guard Robe', 'moon-guard-robe', 'While the Moon Guard was disbanded after the War of the Ancients, their magic items were stored for future battles.', 'moon-guard-robe.jpg', 2460, '+21 Strength|+20 Agility|+9 Intelligence | Poison Marker', 'NE', 3, 2, 1, '', '""'),
(135, 'Midnight Armor', 'midnight-armor', 'Preferred by many Night Elves, this chainmail doesn''t hinder the mobility of the wearer in the least while offering good protection.', 'midnight-armor.jpg', 1500, '+18 Strength|+15% Evasion | 5% chance to cast Fully Heal Self on kill', 'NE', 3, 2, 2, '', '""'),
(136, 'Chimera Boots', 'chimera-boots', 'Chimera scales make sturdy leather, but are rather heavy - by Night Elf standards.', 'chimera-boots.jpg', 1540, '+28 Armor|+85 Movement Speed', 'NE', 3, 2, 3, '', '""'),
(137, 'Dawn Bow', 'dawn-bow', 'The Night Elves quickly learned to use the bowmaking skills of the High Elves alongside their own after the Battle of Mount Hyjal.', 'dawn-bow.jpg', 1980, '+55 Damage|+15 Agility|Critical (0,75x,5%)', 'NE', 3, 2, 4, '', '""'),
(138, 'Emerald Sword', 'emerald-sword', 'This sword was named after Ysera, as the blacksmith who made it imagined the design of the blade during a dream.', 'emerald-sword.jpg', 1240, '+30% Attack Speed|+21% Evasion', 'NE', 3, 2, 5, '', '""'),
(139, 'Demonslayer', 'demonslayer', 'Despite being incredibly sharp and overflowing with magic, these swords are considered ''ligh armament'' by Demon Hunters.', 'demonslayer.jpg', 2260, '+75 Damage|Immolation (25 Dps)', 'NE', 3, 2, 6, '', '""'),
(140, 'Warden Chakram', 'warden-chakram', 'The weaponry of the Wardens is deadly in many ways, but requires much skill to use.', 'warden-chakram.jpg', 1580, '+50 % Attack Speed|Fan of Knives (25 Damage, 400 AoE, 18s)', 'NE', 3, 2, 7, '', '""'),
(141, 'Keeper Staff', 'keeper-staff', 'Since the death of Cenarius, many Keepers tend to the woods and try to uphold the serenity the halfgod created.', 'keeper-staff.jpg', 1620, '+245 Mana|+35 Intelligence | Experience rate increased by 20%', 'NE', 3, 2, 8, '', '""'),
(142, 'Everyoung Leaf', 'everyoung-leaf', 'Taken from the sacred grove of Cenarius, these plants can bring strength and endurance to anyone who carries them.', 'everyoung-leaf.jpg', 1020, '+350 HP|+165 Mana | Entangle the nearest opponent (9% 6.5s/2.25s)', 'NE', 3, 2, 9, '', '""'),
(143, 'Druid Boots', 'druid-boots', 'Druid Boots are incredibly durable. They do not only survive hundreds of miles of forced marching, but also shapeshifting.', 'druid-boots.jpg', 1160, '+80 Movement Speed|+20 Intelligence | Rocket Boots', 'NE', 3, 2, 10, '', '""'),
(144, 'Anti-Magic Staff', 'anti-magic-staff', 'After the War of the Ancients, the Night Elves learned ways to protect themselves against magic backlashes.', 'anti-magic-staff.jpg', 860, 'Scroll of SpellShield (20s, 200 AoE) | Nether Charge (10%)', 'NE', 3, 2, 11, '', '""');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `media`
--

CREATE TABLE IF NOT EXISTS `media` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `type` enum('photo','link','video') DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `description` varchar(511) DEFAULT NULL,
  `source` varchar(511) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=21 ;

--
-- Daten für Tabelle `media`
--

INSERT INTO `media` (`id`, `type`, `title`, `description`, `source`) VALUES
(1, 'photo', 'The World of Forsaken Bastion''s Fall', 'This is the complete Map of Forsaken Bastion''s Fall.', 'FBF-Map.jpg'),
(2, 'photo', 'FBF Undead Heroes - 1', 'FBF Some Undead Heroes', 'FBF-Undead-Heroes-1.jpg'),
(3, 'photo', 'AoS Part', 'This is a small Part of the AoS Area', 'FBF-AoS-Part.jpg'),
(4, 'photo', 'Human Base', 'This is the human base.', 'FBF-Human-Base.jpg'),
(5, 'photo', 'All Items', 'All Items', 'FBF-Items.jpg'),
(6, 'photo', 'Nightelf Base', 'This is the nightelf base.', 'FBF-Nightelf-Base.jpg'),
(7, 'photo', 'Orc Base', 'This is the orc base.', 'FBF-Orc-Base.jpg'),
(8, 'photo', 'The Dome', 'The Dome', 'FBF-The-Dome.jpg'),
(9, 'photo', 'The Entrance', 'The Entrance to the Undead Land.', 'FBF-The-Entrance.jpg'),
(10, 'photo', 'The Great Final', 'This is the part for the great Final of the Game.', 'FBF-The-Final.jpg'),
(11, 'photo', 'The Graveyard', 'The Graveyard - A area for epic battles.', 'FBF-The-Graveyard.jpg'),
(12, 'photo', 'The Nerubian Part', 'A scary area with deadly traps.', 'FBF-The-Nerubian-Area.jpg'),
(13, 'photo', 'Gameplay 1', 'Gameplay 1', 'FBF-GamePlay-1.jpg'),
(14, 'photo', 'Gameplay 2', 'Gameplay 2', 'FBF-GamePlay-2.jpg'),
(15, 'photo', 'Gameplay 3', 'Gameplay 3', 'FBF-GamePlay-3.jpg'),
(16, 'photo', 'Gameplay 4', 'Gameplay 4', 'FBF-GamePlay-4.jpg'),
(17, 'photo', 'Gameplay 5', 'Gameplay 5', 'FBF-GamePlay-5.jpg'),
(18, 'photo', 'Gameplay 6', 'Gameplay 6', 'FBF-GamePlay-6.jpg'),
(19, 'photo', 'Gameplay 7', 'Gameplay 7', 'FBF-GamePlay-7.jpg'),
(20, 'photo', 'Gameplay 8', 'Gameplay 8', 'FBF-GamePlay-8.jpg');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mediaPosition`
--

CREATE TABLE IF NOT EXISTS `mediaPosition` (
  `mediaId` int(10) DEFAULT NULL,
  `area` enum('start_slider1','start_slider2','about') DEFAULT NULL,
  `positionInArea` int(10) unsigned NOT NULL,
  UNIQUE KEY `position_number` (`area`,`positionInArea`),
  KEY `FK_mediaPosition_media` (`mediaId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `mediaPosition`
--

INSERT INTO `mediaPosition` (`mediaId`, `area`, `positionInArea`) VALUES
(1, 'start_slider1', 1),
(1, 'start_slider2', 1),
(2, 'start_slider1', 2),
(3, 'start_slider1', 3),
(4, 'start_slider1', 4),
(5, 'start_slider1', 5),
(6, 'start_slider1', 6),
(7, 'start_slider1', 7),
(8, 'start_slider1', 8),
(9, 'start_slider1', 9),
(10, 'start_slider1', 10),
(11, 'start_slider1', 11),
(12, 'start_slider1', 12),
(13, 'start_slider1', 13),
(14, 'start_slider1', 14),
(15, 'start_slider1', 15),
(16, 'start_slider1', 16),
(17, 'start_slider1', 17),
(18, 'start_slider1', 18),
(19, 'start_slider1', 19),
(20, 'start_slider1', 20);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `quotes`
--

CREATE TABLE IF NOT EXISTS `quotes` (
  `hero_id` int(11) NOT NULL AUTO_INCREMENT,
  `ready` varchar(768) NOT NULL,
  `what` varchar(768) NOT NULL,
  `yes` varchar(768) NOT NULL,
  `attack` varchar(768) NOT NULL,
  `warcry` varchar(768) NOT NULL,
  `pissed` varchar(768) NOT NULL,
  PRIMARY KEY (`hero_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Daten für Tabelle `quotes`
--

INSERT INTO `quotes` (`hero_id`, `ready`, `what`, `yes`, `attack`, `warcry`, `pissed`) VALUES
(4, 'The pact is sealed!', 'You called?|My patience has ended!|I am the Darkness!|My vengeance is yours!', 'Let battle be joined!|As you order!|Yah!|At last!|For the Lich King!', 'Feel my wrath!|By Ner\\''\\zhul!|Ride… or die!', 'Let terror reign!', 'Has Hell frozen over yet?|I am the one horseman of the Apocalypse!|I hate people, but I love gatherings.|I\\''\\m a <strong>Death Knight</strong> Rider! Muh ha ha ha|Blucher!|Don\\''\\t touch me. I\\''\\m evil.');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `recipe_x_items`
--

CREATE TABLE IF NOT EXISTS `recipe_x_items` (
  `recipeId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  PRIMARY KEY (`recipeId`,`itemId`),
  KEY `FK_itemId_items` (`itemId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `recipe_x_items`
--

INSERT INTO `recipe_x_items` (`recipeId`, `itemId`) VALUES
(34, 13),
(35, 13),
(25, 14),
(26, 14),
(25, 15),
(28, 15),
(27, 16),
(28, 16),
(29, 17),
(31, 17),
(27, 18),
(29, 18),
(30, 19),
(32, 19),
(32, 20),
(36, 20),
(26, 21),
(33, 21),
(31, 22),
(34, 22),
(33, 23),
(35, 23),
(30, 24),
(36, 24);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `shops`
--

CREATE TABLE IF NOT EXISTS `shops` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `affiliation` varchar(20) NOT NULL,
  `image` varchar(512) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- Daten für Tabelle `shops`
--

INSERT INTO `shops` (`ID`, `name`, `affiliation`, `image`) VALUES
(1, 'Moon Elixirs', 'Nightelf', ''),
(2, 'Natura Gratia', 'Nightelf', ''),
(3, 'Timeless Items', 'Nightelf', ''),
(4, 'Thirst Quencher', 'Orc', ''),
(5, 'Wulfric''s Items', 'Orc', ''),
(6, 'Martyr''s Legacy', 'Orc', ''),
(7, 'Piero''s Tonics', 'Human', ''),
(8, 'Seneca Sales', 'Human', ''),
(9, 'Scared Relics', 'Human', ''),
(10, 'Potiondigger', 'Undead', ''),
(11, 'Coffin Scraps', 'Undead', ''),
(12, 'The Forgotten', 'Undead', '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `spells`
--

CREATE TABLE IF NOT EXISTS `spells` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `hero_ID` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `description` varchar(1024) NOT NULL,
  `ability_type` varchar(30) NOT NULL,
  `targeting_type` varchar(30) NOT NULL,
  `ability_hotkey` varchar(5) NOT NULL,
  `level` int(11) NOT NULL,
  `duration` varchar(256) NOT NULL,
  `mana_cost` varchar(256) NOT NULL,
  `cooldown` varchar(128) NOT NULL,
  `range` varchar(128) NOT NULL,
  `aoe` varchar(128) NOT NULL,
  `targets` varchar(256) NOT NULL,
  `effects` varchar(256) NOT NULL,
  `required_level` int(11) NOT NULL,
  `note` varchar(2048) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=531 ;

--
-- Daten für Tabelle `spells`
--

INSERT INTO `spells` (`ID`, `hero_ID`, `name`, `description`, `ability_type`, `targeting_type`, `ability_hotkey`, `level`, `duration`, `mana_cost`, `cooldown`, `range`, `aoe`, `targets`, `effects`, `required_level`, `note`) VALUES
(1, 1, 'Explosive Tantrum', 'Mundzuk orders Octar to thrust with his horn, damaging and knocking it''s target back.', 'Active', 'Unit', 'Q', 1, 'N/A', '105', '10 seconds', '128', 'N/A', 'Ground, Enemy', '100 damage | knock back', 1, ''),
(2, 1, 'Explosive Tantrum', '', 'Active', 'Unit', 'Q', 2, 'N/A', '105', '10 seconds', '128', 'N/A', 'Ground, Enemy', '175 damage | knock back', 3, ''),
(3, 1, 'Explosive Tantrum', '', 'Active', 'Unit', 'Q', 3, 'N/A', '105', '10 seconds', '128', 'N/A', 'Ground, Enemy', '250 damage | knock back', 5, ''),
(4, 1, 'Explosive Tantrum', '', 'Active', 'Unit', 'Q', 4, 'N/A', '105', '10 seconds', '128', 'N/A', 'Ground, Enemy', '325 damage | knock back', 7, ''),
(5, 1, 'Explosive Tantrum', '', 'Active', 'Unit', 'Q', 5, 'N/A', '105', '10 seconds', '128', 'N/A', 'Ground, Enemy', '400 damage | knock back', 9, ''),
(6, 1, 'Beast Stomp', 'Octar slams the ground, stunning and damaging nearby enemy units.', 'Active', 'Instant', 'W', 1, 'N/A', '95', '7 seconds', 'N/A', '250', 'Ground, Enemy', '50 damage | 1.5 sec. stun', 1, ''),
(7, 1, 'Beast Stomp', 'Behemot slams the ground, stunning and damaging nearby enemy units.', 'Active', 'Instant', 'W', 2, 'N/A', '95', '7 seconds', 'N/A', '250', 'Ground, Enemy', '100 damage | 1.5 sec. stun', 3, ''),
(8, 1, 'Beast Stomp', '', 'Active', 'Instant', 'W', 3, 'N/A', '95', '7 seconds', 'N/A', '250', 'Ground, Enemy', '150 damage | 1.5 sec. stun', 5, ''),
(9, 1, 'Beast Stomp', '', 'Active', 'Instant', 'W', 4, 'N/A', '95', '7 seconds', 'N/A', '250', 'Ground, Enemy', '200 damage | 1.5 sec. stun', 7, ''),
(10, 1, 'Beast Stomp', '', 'Active', 'Instant', 'W', 5, 'N/A', '95', '7 seconds', 'N/A', '250', 'Ground, Enemy', '250 damage | 1.5 sec. stun', 9, ''),
(11, 1, 'Roar', 'Mundzuk & Octar send out a battelcry giving a bonus to damage and health regeneration to friendly units around them, for a short duration.', 'Active', 'Unit', 'E', 1, '25/35 seconds', '100', '12 seconds', 'N/A', '500', 'Air, Ground, Friend, Self', '+25% damage | +0.75 HP/s', 1, ''),
(12, 1, 'Roar', '', 'Active', 'Unit', 'E', 2, '25/35 seconds', '100', '12 seconds', 'N/A', '500', 'Air, Ground, Friend, Self', '+35% damage | +1.75 HP/s', 3, ''),
(13, 1, 'Roar', '', 'Active', 'Unit', 'E', 3, '25/35 seconds', '100', '12 seconds', 'N/A', '500', 'Air, Ground, Friend, Self', '+45% damage | +2.75 HP/s', 5, ''),
(14, 1, 'Roar', '', 'Active', 'Unit', 'E', 4, '25/35 seconds', '100', '12 seconds', 'N/A', '500', 'Air, Ground, Friend, Self', '+55% damage | +3.75 HP/s', 7, ''),
(15, 1, 'Roar', '', 'Active', 'Unit', 'E', 5, '25/35 seconds', '100', '12 seconds', 'N/A', '500', 'Air, Ground, Friend, Self', '+65% damage | +4.75 HP/s', 9, ''),
(16, 1, 'Adrenaline Rush', 'Mundzuk and Octar become enraged, damaging and knocking back enemy units on their path.', 'Active', 'Point', 'R', 1, 'N/A', '140', '140 seconds', '750', '150', 'Ground, Enemy', '275 damage | knock back', 6, ''),
(17, 1, 'Adrenaline Rush', '', 'Active', 'Point', 'R', 2, 'N/A', '140', '140 seconds', '750', '150', 'Ground, Enemy', '435 damage | knock back', 12, ''),
(18, 1, 'Adrenaline Rush', '', 'Active', 'Point', 'R', 3, 'N/A', '140', '140 seconds', '750', '150', 'Ground, Enemy', '595 damage | knock back', 18, ''),
(25, 2, 'Spider Web', 'Spiders are known as the world best weavers. The Widow is no different, with her webs she''s able to both catch her enemies and keep them at a distance. Once a vitcim is caught by her webs, it will be unable to even move a finger.', 'Active', 'Instant', 'W', 1, '6 seconds', '30', '1 second', 'N/A', '175', 'Ground, Ally, Enemy', 'movement speed ( -40% )<br />  attack speed ( -40% )', 1, ''),
(20, 2, 'Adolescence', 'The Nerubian Widow lays eggs that spawn spiderlings. Growing up, these sworn companions support the Widow in teaching her enemies the real meaning of Arachnophobia.', 'Active', 'Point', 'Q', 1, '85 seconds', '110', '10 seconds', '128', 'N/A', 'N/A', 'growing up spiderling<br /> max. HP: 575 / max. Dmg: 85', 1, ''),
(21, 2, 'Adolescence', '', 'Active', 'Point', 'Q', 2, '85 seconds', '120', '10 seconds', '128', 'N/A', 'N/A', 'growing up spiderling<br /> max. HP: 685 / max. Dmg: 170', 3, ''),
(22, 2, 'Adolescence', '', 'Active', 'Point', 'Q', 3, '85 seconds', '130', '10 seconds', '128', 'N/A', 'N/A', 'growing up spiderling<br /> max. HP: 795 / max. Dmg: 255', 5, ''),
(23, 2, 'Adolescence', '', 'Active', 'Point', 'Q', 4, '85 seconds', '140', '10 seconds', '128', 'N/A', 'N/A', 'growing up spiderling<br /> max. HP: 905 / max. Dmg: 340', 7, ''),
(24, 2, 'Adolescence', '', 'Active', 'Point', 'Q', 5, '85 seconds', '150', '10 seconds', '128', 'N/A', 'N/A', 'growing up spiderling<br /> max. HP: 1015 / max. Dmg: 425', 9, ''),
(26, 2, 'Spider Web', '', 'Active', 'Instant', 'W', 2, '6.5 seconds', '30', '1 second', 'N/A', '175', 'Ground, Ally, Enemy', 'movement speed ( -50% )<br />  attack speed ( -40% ', 3, ''),
(27, 2, 'Spider Web', '', 'Active', 'Instant', 'W', 3, '7 seconds', '30', '1 second', 'N/A', '175', 'Ground, Ally, Enemy', 'movement speed ( -60% )<br /> attack speed ( -40% )', 5, ''),
(28, 2, 'Spider Web', '', 'Active', 'Instant', 'W', 4, '7.5 seconds', '30', '1 second', 'N/A', '175', 'Ground, Ally, Enemy', 'movement speed ( -70% )<br /> attack speed ( -40% )', 7, ''),
(29, 2, 'Spider Web', '', 'Active', 'Instant', 'W', 5, '8 seconds', '30', '1 second', 'N/A', '175', 'Ground, Ally, Enemy', 'movement speed ( -80% )<br /> attack speed ( -40% )', 9, ''),
(30, 2, 'Sprint', 'The Widow whispers a forbidden curse that increases her movement speed at a constant mana cost.', 'Active', 'Instant', 'E', 1, 'N/A', '20 + 10/sec', 'N/A', 'N/A', 'N/A', 'N/A', 'movement speed ( +45 )', 1, ''),
(31, 2, 'Sprint', '', 'Active', 'Instant', 'E', 2, 'N/A', '20 + 12/sec', 'N/A', 'N/A', 'N/A', 'N/A', 'movement speed ( +90 )', 3, ''),
(32, 2, 'Sprint', '', 'Active', 'Instant', 'E', 3, 'N/A', '20 + 14/sec', 'N/A', 'N/A', 'N/A', 'N/A', 'movement speed ( +135 )', 5, ''),
(33, 2, 'Sprint', '', 'Active', 'Instant', 'E', 4, 'N/A', '20 + 16/sec', 'N/A', 'N/A', 'N/A', 'N/A', 'movement speed ( +180 )', 7, ''),
(34, 2, 'Sprint', '', 'Active', 'Instant', 'E', 5, 'N/A', '20 + 18/sec', 'N/A', 'N/A', 'N/A', 'N/A', 'movement speed ( +225 )', 9, ''),
(35, 2, 'Widow Bite', 'The Widow strikes an enemy with her deadly fangs, injecting lethal posion to the victim. The grim venom paralyzes and cripples the unit, until it finally causes a massive amount of damage on it.', 'Active', 'Unit', 'R', 1, '40 seconds', '180', '150 seconds', '128', 'N/A', 'Ground, Enemy', 'ms: -40% > -100%<br /> as: -15% > -60%<br />  475 damage over 5s', 6, ''),
(36, 2, 'Widow Bite', '', 'Active', 'Unit', 'R', 2, '40 seconds', '220', '150 seconds', '128', 'N/A', 'Ground, Enemy', 'ms: -40% > -100%<br /> as: -15% > -60%<br /> 700 damage over 5s', 12, ''),
(37, 2, 'Widow Bite', '', 'Active', 'Unit', 'R', 3, '40 seconds', '260', '150 seconds', '128', 'N/A', 'Ground, Enemy', 'ms: -40% > -100%<br /> as: -15% > -60%<br /> 925 damage over 5s', 18, ''),
(40, 3, 'Ice Tornado', 'The Cold Jester summons a frightful twister of frozen shrapnels around himself, hurting every enemy unit standing in his way.', 'Active', 'Instant', 'Q', 1, '8 seconds', '120', '14 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', 'deals 69 damage to the enemy unit', 1, ''),
(41, 3, 'Ice Tornado', '', 'Active', 'Instant', 'Q', 2, '8 seconds', '145', '14 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', 'deals 95 damage to the enemy unit', 3, ''),
(42, 3, 'Ice Tornado', '', 'Active', 'Instant', 'Q', 3, '8 seconds', '170', '14 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', 'deals 132 damage to the enemy unit', 5, ''),
(43, 3, 'Ice Tornado', '', 'Active', 'Instant', 'Q', 4, '8 seconds', '195', '14 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', 'deals 167 damage to the enemy unit', 7, ''),
(44, 3, 'Ice Tornado', '', 'Active', 'Instant', 'Q', 5, '8 seconds', '220', '14 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', 'deals 190 damage to the enemy unit', 9, ''),
(45, 3, 'Freezing Breath', 'Akull''s foul, freezing breath chills the air to a sub zero level, slowing enemy''s movement and attack down.', 'Active', 'Area', 'W', 1, '6 seconds', '75', '12 seconds', '800', '350', 'Air, Ground, Enemy', '10 damage<br />slows enemy movement and attack speed', 1, ''),
(46, 3, 'Freezing Breath', '', 'Active', 'Area', 'W', 2, '6.5 seconds', '75', '12 seconds', '800', '350', 'Air, Ground, Enemy', '20 damage<br /> slows enemy movement and attack speed', 3, ''),
(47, 3, 'Freezing Breath', '', 'Active', 'Area', 'W', 3, '7 seconds', '75', '12 seconds', '800', '350', 'Air, Ground, Enemy', '30 damage<br /> slows enemy movement and attack speed', 5, ''),
(48, 3, 'Freezing Breath', '', 'Active', 'Area', 'W', 4, '7.5 seconds', '75', '12 seconds', '800', '350', 'Air, Ground, Enemy', '40 damage<br /> slows enemy movement and attack speed', 7, ''),
(49, 3, 'Freezing Breath', '', 'Active', 'Area', 'W', 5, '8 seconds', '75', '12 seconds', '800', '350', 'Air, Ground, Enemy', '50 damage<br /> slows enemy movement and attack speed', 9, ''),
(50, 3, 'Frost Aura', 'He freezes the air around him, creating solid particles of ice that slows enemies within a 500 range around him and hinders their healing processes.', 'Passive', 'Instant', '', 1, 'Unlimited', 'None', 'N/A', '500', '200', 'Air, Ground, Enemy', '-5% Attack Speed <br />  -5% Movementspeed <br /> max 5 Life Degeneration', 1, ''),
(51, 3, 'Frost Aura', '', 'Passive', 'Instant', '', 2, 'Unlimited', 'None', 'N/A', '500', '200', 'Air, Ground, Enemy', '-10% Attack Speed <br />  -10% Movementspeed <br /> max 10 Life Degeneration', 3, ''),
(52, 3, 'Frost Aura', '', 'Passive', 'Instant', '', 3, 'Unlimited', 'None', 'N/A', '500', '200', 'Air, Ground, Enemy', '-15% Attack Speed <br />  -15% Movementspeed <br /> max 15 Life Degeneration', 5, ''),
(53, 3, 'Frost Aura', '', 'Passive', 'Instant', '', 4, 'Unlimited', 'None', 'N/A', '500', '200', 'Air, Ground, Enemy', '-20% Attack Speed <br />  -20% Movementspeed <br /> max 20 Life Degeneration', 7, ''),
(54, 3, 'Frost Aura', '', 'Passive', 'Instant', '', 5, 'Unlimited', 'None', 'N/A', '500', '200', 'Air, Ground, Enemy', '-25% Attack Speed <br />  -25% Movementspeed <br /> max 25 Life Degeneration', 9, ''),
(55, 3, 'Fog of Death', 'Akull partially evaporates into a bone-chilling mist that deals damage over time to all units inside. As long as the spell is active, he''s mostly formless, making 50% of the attacks on him miss.', 'Active', 'Instant', 'R', 1, '30 seconds', '350', '240 seconds', 'N/A', '700', 'Air, Ground, Enemy', '20 damage per second', 6, ''),
(56, 3, 'Fog of Death', '', 'Active', 'Instant', 'R', 2, '30 seconds', '350', '210 seconds', 'N/A', '700', 'Air, Ground, Enemy', '30 damage per second', 12, ''),
(57, 3, 'Fog of Death', '', 'Active', 'Instant', 'R', 3, '30 seconds', '350', '180 seconds', 'N/A', '700', 'Air, Ground, Enemy', '40 damage per second', 18, ''),
(60, 4, 'Claws Attack', 'The former Paladin flings his claws around aimlessly dealing bonus physical damage to heroes, but hurting himself in the process.', 'Active', 'Unit', 'Q', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Enemy Heroes', '10% bonus damage to heroes <br /> -20HP/s', 1, ''),
(61, 4, 'Claws Attack', '', 'Active', 'Unit', 'Q', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Enemy Heroes', '20% bonus damage to heroes<br /> -20HP/s', 3, ''),
(62, 4, 'Claws Attack', '', 'Active', 'Unit', 'Q', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Enemy Heroes', '30% bonus damage to heroes<br /> -20HP/s', 5, ''),
(63, 4, 'Claws Attack', '', 'Active', 'Unit', 'Q', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Enemy Heroes', '40% bonus damage to heroes<br /> -20HP/s', 7, ''),
(64, 4, 'Claws Attack', '', 'Active', 'Unit', 'Q', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Enemy Heroes', '50% bonus damage to heroes<br /> -20HP/s', 9, ''),
(65, 4, 'Cannibalize', 'Edmund kneels down and consumes the raw flesh form a near corpse for up to 5 seconds to regenerate some hitpoints.', 'Active', 'Dead Unit', 'W', 1, '5 seconds', '65', '5 seconds', 'N/A', 'N/A', 'Dead', 'heals 20 HP/s', 1, ''),
(66, 4, 'Cannibalize', '', 'Active', 'Dead Unit', 'W', 2, '5 seconds', '65', '5 seconds', 'N/A', 'N/A', 'Dead', 'heals 40 HP/s', 3, ''),
(67, 4, 'Cannibalize', '', 'Active', 'Dead Unit', 'W', 3, '5 seconds', '65', '5 seconds', 'N/A', 'N/A', 'Dead', 'heals 60 HP/s', 5, ''),
(68, 4, 'Cannibalize', '', 'Active', 'Dead Unit', 'W', 4, '5 seconds', '65', '5 seconds', 'N/A', 'N/A', 'Dead', 'heals 80 HP/s', 7, ''),
(69, 4, 'Cannibalize', '', 'Active', 'Dead Unit', 'W', 5, '5 seconds', '65', '5 seconds', 'N/A', 'N/A', 'Dead', 'heals 100 HP/s', 9, ''),
(70, 4, 'Flesh Wound', 'Every second hit weakens the enemy''s armor by 2 points for 3 seconds. The effect can stack several times.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'stacks up to 2 times', 1, ''),
(71, 4, 'Flesh Wound', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'stacks up to 4 times', 3, ''),
(72, 4, 'Flesh Wound', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'stacks up to 6 times', 5, ''),
(73, 4, 'Flesh Wound', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'stacks up to 8 times', 7, ''),
(74, 4, 'Flesh Wound', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'stacks up to 10 times', 9, ''),
(75, 4, 'Rage', 'The Ghoul charges forward carelessly, thrusting and slashing with tremendous strenght and speed, but leaving himself open to attacks.', 'Active', 'Unit', 'R', 1, '7 seconds', '120', '75 seconds', 'N/A', 'N/A', 'Ground, Enemy', 'max movement speed<br /> max attack speed', 6, ''),
(76, 4, 'Rage', '', 'Active', 'Unit', 'R', 2, '9 seconds', '120', '65 seconds', 'N/A', 'N/A', 'Ground, Enemy', 'max movement speed<br /> max attack speed', 12, ''),
(77, 4, 'Rage', '', 'Active', 'Unit', 'R', 3, '11 seconds', '120', '55 seconds', 'N/A', 'N/A', 'Ground, Enemy', 'max movement speed<br /> max attack speed', 18, ''),
(80, 5, 'Dark Obedience', 'The Grim Lady expels a magic orb that chases her target around, dealing damage to all units it passes through.', 'Active', 'Unit/Area', 'Q', 1, '5 seconds', '140', '8 seconds', '600', 'N/A', 'Ground, Enemy', '50 damage per hit', 1, ''),
(81, 5, 'Dark Obedience', '', 'Active', 'Unit/Area', 'Q', 2, '5 seconds', '140', '8 seconds', '600', 'N/A', 'Ground, Enemy', '100 damage per hit', 3, ''),
(82, 5, 'Dark Obedience', '', 'Active', 'Unit/Area', 'Q', 3, '5 seconds', '140', '8 seconds', '600', 'N/A', 'Ground, Enemy', '150 damage per hit', 5, ''),
(83, 5, 'Dark Obedience', '', 'Active', 'Unit/Area', 'Q', 4, '5 seconds', '140', '8 seconds', '600', 'N/A', 'Ground, Enemy', '200 damage per hit', 7, ''),
(84, 5, 'Dark Obedience', '', 'Active', 'Unit/Area', 'Q', 5, '5 seconds', '140', '8 seconds', '600', 'N/A', 'Ground, Enemy', '250 damage per hit', 9, ''),
(85, 5, 'Spirit Burn', 'Lady Venefica slowly consumes the spirit of the targeted unit, draining some of it''s mana every second. If the unit''s mana reaches 0 before the spell is over, the unit detonates violently, dealing damage equal to half of it''s current health in an area. Units that do not have mana, instantly detonate. Heroes detonate for only 10% of their current health.', 'Active', 'Unit', 'W', 1, '5 seconds', '90', '10 seconds', '600', '350', 'Air, Ground, Enemy', 'drain 20 mana/s', 1, ''),
(86, 5, 'Spirit Burn', '', 'Active', 'Unit', 'W', 2, '5 seconds', '100', '10 seconds', '600', '350', 'Air, Ground, Enemy', 'drain 30 mana/s', 3, ''),
(87, 5, 'Spirit Burn', '', 'Active', 'Unit', 'W', 3, '5 seconds', '110', '10 seconds', '600', '350', 'Air, Ground, Enemy', 'drain 40 mana/s', 5, ''),
(88, 5, 'Spirit Burn', '', 'Active', 'Unit', 'W', 4, '5 seconds', '120', '10 seconds', '600', '350', 'Air, Ground, Enemy', 'drain 50 mana/s', 7, ''),
(89, 5, 'Spirit Burn', '', 'Active', 'Unit', 'W', 5, '5 seconds', '130', '10 seconds', '600', '350', 'Air, Ground, Enemy', 'drain 60 mana/s', 9, ''),
(90, 5, 'Cursed Soul', 'She takes the soul from a near corpse, forcing it to possess a random enemy land unit. If that unit is different to the cursed soul, it will deal damage to the unit, else it will take control of that unit temporally, draining its life.', 'Active', 'N/A', 'E', 1, '10 seconds', '100', '15 seconds', '600', '600', 'Dead', 'Raises a dead soul', 1, ''),
(91, 5, 'Cursed Soul', '', 'Active', 'N/A', 'E', 2, '20 seconds', '115', '15 seconds', '600', '600', 'Dead', 'Raises a dead soul', 3, ''),
(92, 5, 'Cursed Soul', '', 'Active', 'N/A', 'E', 3, '30 seconds', '130', '15 seconds', '600', '600', 'Dead', 'Raises a dead soul', 5, ''),
(93, 5, 'Cursed Soul', '', 'Active', 'N/A', 'E', 4, '40 seconds', '145', '15 seconds', '600', '600', 'Dead', 'Raises a dead soul', 7, ''),
(94, 5, 'Cursed Soul', '', 'Active', 'N/A', 'E', 5, '50 seconds', '160', '15 seconds', '600', '600', 'Dead', 'Raises a dead soul', 9, ''),
(95, 5, 'Barrage', 'Venefica shoots a barrage of unwordly missiles at a target area. These deal small area damage when they collide with a unit.', 'Active', 'Area', 'R', 1, 'N/A', '180', '140 seconds', '800', 'N/A', 'Ground, Enemy', '200 damage per Missile', 6, ''),
(96, 5, 'Barrage', '', 'Active', 'Area', 'R', 2, 'N/A', '220', '140 seconds', '800', 'N/A', 'Ground, Enemy', '320 damage per Missile', 12, ''),
(97, 5, 'Barrage', '', 'Active', 'Area', 'R', 3, 'N/A', '260', '140 seconds', '800', 'N/A', 'Ground, Enemy', '440 damage per Missile', 18, ''),
(101, 6, 'Death Pact', '', 'Active', 'Unit', 'Q', 2, '5 seconds', '85', '10 seconds', '500', '800', 'Air, Ground, Ally', 'heals with 15 HP per second (Heroes 20 HP)', 3, ''),
(100, 6, 'Death Pact', 'The Death Marcher sacrifices an allied organic unit to use their HP to fuel an Aura that heals all allied Units nearby. Heroes get a further bonus to regeneration. Mana Concentration increases the healing and reduces the speed at which the HP is consumend.', 'Active', 'Unit', 'Q', 1, '5 seconds', '95', '10 seconds', '500', '800', 'Air, Ground, Ally', 'heals with 20 HP per second (Heroes 25 HP)', 1, ''),
(102, 6, 'Death Pact', '', 'Active', 'Unit', 'Q', 3, '5 seconds', '105', '10 seconds', '500', '800', 'Air, Ground, Ally', 'heals with 25 HP per second (Heroes 30 HP)', 5, ''),
(103, 6, 'Death Pact', '', 'Active', 'Unit', 'Q', 4, '5 seconds', '115', '10 seconds', '500', '800', 'Air, Ground, Ally', 'heals with 30 HP per second (Heroes 35 HP)', 7, ''),
(104, 6, 'Death Pact', '', 'Active', 'Unit', 'Q', 5, '5 seconds', '125', '10 seconds', '500', '800', 'Air, Ground, Ally', 'heals with 35 HP per second (Heroes 40 HP)', 9, ''),
(105, 6, 'Soul Trap', 'The Gatekeeper traps a unit in within his tormented soul, removing it from the battlefield and damaging it in the process. Mana Concentration increases the damage done.', 'Active', 'Unit', 'W', 1, '5/8 seconds', '75', '12 seconds', '800', 'N/A', 'Air, Ground, Enemy', 'unit disappears <br /> 150 damage', 1, ''),
(106, 6, 'Soul Trap', '', 'Active', 'Unit', 'W', 2, '5/8 seconds', '75', '12 seconds', '800', 'N/A', 'Air, Ground, Enemy', 'unit disappears <br /> 250 damage', 3, ''),
(107, 6, 'Soul Trap', '', 'Active', 'Unit', 'W', 3, '5/8 seconds', '75', '12 seconds', '800', 'N/A', 'Air, Ground, Enemy', 'unit disappears <br /> 350 damage', 5, ''),
(108, 6, 'Soul Trap', '', 'Active', 'Unit', 'W', 4, '5/8 seconds', '75', '12 seconds', '800', 'N/A', 'Air, Ground, Enemy', 'unit disappears <br /> 450 damage', 7, ''),
(109, 6, 'Soul Trap', '', 'Active', 'Unit', 'W', 5, '5/8 seconds', '75', '12 seconds', '800', 'N/A', 'Air, Ground, Enemy', 'unit disappears <br /> 550 damage', 9, ''),
(110, 6, 'Mana Concentration', 'Dorian sacrifices half of his current Mana to amplify the effects of his spells. The bonus is greater the more Mana is sacrificed.', 'Active', 'Instant', 'E', 1, '10 seconds', '50% of current Mana', '20 seconds', 'N/A', 'N/A', 'Self', '1% Mana Sacrificed = 2% Bonus', 1, ''),
(111, 6, 'Mana Concentration', '', 'Active', 'Instant', 'E', 2, '15 seconds', '50% of current Mana', '20 seconds', 'N/A', 'N/A', 'Self', '1% Mana Sacrificed = 3% Bonus', 3, ''),
(112, 6, 'Mana Concentration', '', 'Active', 'Instant', 'E', 3, '20 seconds', '50% of current Mana', '25 seconds', 'N/A', 'N/A', 'Self', '1% Mana Sacrificed = 4% Bonus', 5, ''),
(113, 6, 'Mana Concentration', '', 'Active', 'Instant', 'E', 4, '25 seconds', '50% of current Mana', '25 seconds', 'N/A', 'N/A', 'Self', '1% Mana Sacrificed = 5% Bonus', 7, ''),
(114, 6, 'Mana Concentration', '', 'Active', 'Instant', 'E', 5, '30 seconds', '50% of current Mana', '30 seconds', 'N/A', 'N/A', 'Self', '1% Mana Sacrificed = 6% Bonus', 9, ''),
(115, 6, 'Boiling Blood', 'Dorian''s dismal presence makes the blood of all his enemies reach boling point, burning them from within. The spell''s effects last as long as they stay around The Gatekeeper. When their HP falls below 25%, they have a chance to implode, dealing area damage to nearby units. Mana Concentration increases damage and implosion chance.', 'Channeled', 'Area', 'R', 1, '15 seconds', '250', '150 seconds', '1000', '400', 'Air, Ground, Enemy', '20 Damage per second <br /> 8% Explosion Chance per second', 6, ''),
(116, 6, 'Boiling Blood', '', 'Channeled', 'Area', 'R', 2, '15 seconds', '250', '150 seconds', '1000', '400', 'Air, Ground, Enemy', '30 Damage per second <br /> 12% Explosion Chance per second', 12, ''),
(117, 6, 'Boiling Blood', '', 'Channeled', 'Area', 'R', 3, '15 seconds', '250', '150 seconds', '1000', '400', 'Air, Ground, Enemy', '40 Damage per second <br /> 16% Explosion Chance per second', 18, ''),
(120, 7, 'Plague Infection', 'The curse afflicts the targeted unit with a deadly disease, dealing damage and slowing it''s movement speed. Whenever the unit dies under these effects, it will infect up to 10 more units. Units that survived the plague, can''t be affected again.', 'Active', 'Unit', 'Q', 1, '8 seconds', '100', '25 seconds', '500', '100', 'Air, Ground, Enemy', '10 damage over 8s <br /> -11% movement speed', 1, ''),
(121, 7, 'Plague Infection', '', 'Active', 'Unit', 'Q', 2, '8 seconds', '125', '25 seconds', '500', '150', 'Air, Ground, Enemy', '20 damage over 8s <br /> -22% movement speed', 3, ''),
(122, 7, 'Plague Infection', '', 'Active', 'Unit', 'Q', 3, '8 seconds', '150', '25 seconds', '500', '200', 'Air, Ground, Enemy', '30 damage over 8s <br /> -33% movement speed', 5, ''),
(123, 7, 'Plague Infection', '', 'Active', 'Unit', 'Q', 4, '8 seconds', '175', '25 seconds', '500', '250', 'Air, Ground, Enemy', '40 damage over 8s <br /> -44% movement speed', 7, ''),
(124, 7, 'Plague Infection', '', 'Active', 'Unit', 'Q', 5, '8 seconds', '200', '25 seconds', '500', '300', 'Air, Ground, Enemy', '50 damage over 8s <br /> -55% movement speed', 9, ''),
(125, 7, 'Soul Extraction', 'Whenever Ukko or his minions kill an enemy unit, he will extract it''s soul as long as he is close enough. Each soul increases his damage and that of his zombies, and increases the damage and area of effect of Call of the Damned. Can store up to 10 souls.', 'Passive', 'Instant', '', 1, 'N/A', 'None', 'N/A', 'N/A', '500', 'Air, Ground, Enemy', 'increases damage by each soul', 1, ''),
(126, 7, 'Soul Extraction', '', 'Passive', 'Instant', '', 2, 'N/A', 'None', 'N/A', 'N/A', '600', 'Air, Ground, Enemy', 'increases damage by each soul', 3, ''),
(127, 7, 'Soul Extraction', '', 'Passive', 'Instant', '', 3, 'N/A', 'None', 'N/A', 'N/A', '700', 'Air, Ground, Enemy', 'increases damage by each soul', 5, ''),
(128, 7, 'Soul Extraction', '', 'Passive', 'Instant', '', 4, 'N/A', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Enemy', 'increases damage by each soul', 7, ''),
(129, 7, 'Soul Extraction', '', 'Passive', 'Instant', '', 5, 'N/A', 'None', 'N/A', 'N/A', '900', 'Air, Ground, Enemy', 'increases damage by each soul', 9, ''),
(130, 7, 'Spawn Zombie', 'The Traitor summons several zombies in a target area. Zombies will fight alongside him. They have an disease aura that deals damage over time to nearby enemies. Zombies are also valid targets for Call of the Damned, but they will die after they got affected by this ability.', 'Active', 'Area', 'E', 1, '15 seconds', '135', '35 seconds', '600', '400', 'N/A', '2 Zombies', 1, ''),
(131, 7, 'Spawn Zombie', '', 'Active', 'Area', 'E', 2, '20 seconds', '145', '35 seconds', '600', '400', 'N/A', '2 Zombies', 3, ''),
(132, 7, 'Spawn Zombie', '', 'Active', 'Area', 'E', 3, '25 seconds', '155', '35 seconds', '600', '400', 'N/A', '3 Zombies', 5, ''),
(133, 7, 'Spawn Zombie', '', 'Active', 'Area', 'E', 4, '30 seconds', '165', '35 seconds', '600', '400', 'N/A', '3 Zombies', 7, ''),
(134, 7, 'Spawn Zombie', '', 'Active', 'Area', 'E', 5, '35 seconds', '175', '35 seconds', '600', '400', 'N/A', '4 Zombies', 9, ''),
(135, 7, 'Call of the Damned', 'Ukko releases the souls of fallen units in a target area, which deal area of effect damage. A soul is released every 0.75 seconds but it takes 1.5 seconds till it finally is released. Zombies created with Spawn Zombies are also valid targets which will die after their soul gets released.', 'Active', 'Area', 'R', 1, '6 seconds', '200', '80 seconds', '500', '300', 'Dead', '3 souls of corpes <br /> 250 damage per soul', 6, ''),
(136, 7, 'Call of the Damned', '', 'Active', 'Area', 'R', 2, '7 seconds', '300', '80 seconds', '500', '300', 'Dead', '4 souls of corpes <br /> 500 damage per soul', 12, ''),
(137, 7, 'Call of the Damned', '', 'Active', 'Area', 'R', 3, '8 seconds', '400', '80 seconds', '500', '300', 'Dead', '5 souls of corpes <br /> 750 damage per soul', 18, ''),
(140, 8, 'Necromancy', 'The Master Necromancer raises a Skeleton from every corpse in the target area. The more skeletons raised, the weaker they are.', 'Active', 'Area', 'Q', 1, '60 seconds', '115', '45 seconds', '600', '250', 'Dead', 'raises Skeletons', 1, ''),
(347, 18, 'Crippling Arrow', '', 'Active', 'Point', 'W', 3, '60/10 seconds', '75', '8 seconds', '700', 'N/A', 'Air, Ground, Enemy', '225 damage <br /> +112 bonus damage <br />\r\n-70% movement speed <br /> -50% attack speed', 5, ''),
(141, 8, 'Necromancy', '', 'Active', 'Area', 'Q', 2, '60 seconds', '130', '45 seconds', '600', '250', 'Dead', 'raises Skeletons', 3, ''),
(142, 8, 'Necromancy', '', 'Active', 'Area', 'Q', 3, '60 seconds', '145', '45 seconds', '600', '250', 'Dead', 'raises Skeletons', 5, ''),
(143, 8, 'Necromancy', '', 'Active', 'Area', 'Q', 4, '60 seconds', '160', '45 seconds', '600', '250', 'Dead', 'raises Skeletons', 7, ''),
(144, 8, 'Necromancy', '', 'Active', 'Area', 'Q', 5, '60 seconds', '175', '45 seconds', '600', '250', 'Dead', 'raises Skeletons', 9, ''),
(145, 8, 'Malicious Curse', 'By the power of his black magic, Kakos is able to put a hex on an enemy unit. This unit will drain either the health or the mana of its nearby allies, but the unit itself is immune to this effect.', 'Active', 'Unit', 'W/X', 1, '10 seconds', '120', '12 seconds', '600', '350', 'Air, Ground, Enemy', 'drains 2% of HP or Mana', 1, ''),
(340, 18, 'Ghost Form', 'The Dark Ranger becomes etheral, increasing her movement speed. In this form, she''s able to walk through units.', 'Active', 'Instant', 'Q', 1, '15 seconds', '75', '5 seconds', 'N/A', 'N/A', 'Self', '+10% movement speed <br /> able to walk through units', 1, ''),
(341, 18, 'Ghost Form', '', 'Active', 'Instant', 'Q', 2, '20 seconds', '75', '5 seconds', 'N/A', 'N/A', 'Self', '+20% movement speed <br /> able to walk through units', 3, ''),
(342, 18, 'Ghost Form', '', 'Active', 'Instant', 'Q', 3, '25 seconds', '75', '5 seconds', 'N/A', 'N/A', 'Self', '+30% movement speed <br /> able to walk through units', 5, ''),
(343, 18, 'Ghost Form', '', 'Active', 'Instant', 'Q', 4, '30 seconds', '75', '5 seconds', 'N/A', 'N/A', 'Self', '+40% movement speed <br /> able to walk through units', 7, ''),
(146, 8, 'Malicious Curse', '', 'Active', 'Unit', 'W/X', 2, '9 seconds', '120', '12 seconds', '600', '350', 'Air, Ground, Enemy', 'drains 3% of HP or Mana', 3, ''),
(147, 8, 'Malicious Curse', '', 'Active', 'Unit', 'W/X', 3, '8 seconds', '120', '12 seconds', '600', '350', 'Air, Ground, Enemy', 'drains 4% of HP or Mana', 5, ''),
(148, 8, 'Malicious Curse', '', 'Active', 'Unit', 'W/X', 4, '7 seconds', '120', '12 seconds', '600', '350', 'Air, Ground, Enemy', 'drains 5% of HP or Mana', 7, ''),
(149, 8, 'Malicious Curse', '', 'Active', 'Unit', 'W/X', 5, '6 seconds', '120', '12 seconds', '600', '350', 'Air, Ground, Enemy', 'drains 6% of HP or Mana', 9, ''),
(150, 8, 'Despair', 'Kakos makes a unit enter a state crushing fear, reducing its attack speed. The penalty increases the more enemies the unit has to face.', 'Active', 'Unit', 'E', 1, '8 seconds', '80', '15 seconds', '600', '350', 'Air, Ground, Enemy', '10% attack speed reduction per enemy<br/> 10% start reduction', 1, ''),
(151, 8, 'Despair', '', 'Active', 'Unit', 'E', 2, '8.5 seconds', '90', '15 seconds', '600', '350', 'Air, Ground, Enemy', '10% attack speed reduction per enemy<br/> 20% start reduction', 3, ''),
(152, 8, 'Despair', '', 'Active', 'Unit', 'E', 3, '9 seconds', '100', '15 seconds', '600', '350', 'Air, Ground, Enemy', '10% attack speed reduction per enemy<br/> 30% start reduction', 5, ''),
(153, 8, 'Despair', '', 'Active', 'Unit', 'E', 4, '9.5 seconds', '110', '15 seconds', '600', '350', 'Air, Ground, Enemy', '10% attack speed reduction per enemy<br/> 40% start reduction', 7, ''),
(154, 8, 'Despair', '', 'Active', 'Unit', 'E', 5, '10 seconds', '120', '15 seconds', '600', '350', 'Air, Ground, Enemy', '10% attack speed reduction per enemy<br/> 50% start reduction', 9, ''),
(155, 8, 'Dead Souls', 'The Death Master calls forth vile souls to help him in his fight. He summons magical ghosts over 12 seconds, flying to enemies around him and dealing damage on impact.', 'Active', 'Area', 'R', 1, '12 seconds', '150', '150 seconds', '750', 'N/A', 'Air, Ground, Enemy', '60 damage per missile', 6, ''),
(156, 8, 'Dead Souls', '', 'Active', 'Area', 'R', 2, '12 seconds', '180', '150 seconds', '750', 'N/A', 'Air, Ground, Enemy', '120 damage per missile', 12, ''),
(157, 8, 'Dead Souls', '', 'Active', 'Area', 'R', 3, '12 seconds', '210', '150 seconds', '750', 'N/A', 'Air, Ground, Enemy', '180 damage per missile', 18, ''),
(160, 9, 'Burrow Strike', 'The Crypt Lord burrows himself below the earth, becoming invisible and magic immune. He digs with 650 speed to the target location, creating a dangerous spike when coming out from that deals damage to enemies and throws them in the air.', 'Active', 'Area', 'Q', 1, 'N/A', '90', '11 seconds', '700', '150', 'Air, Ground, Enemy', '80 damage <br />  150 area damage <br /> 1.5s stun', 1, ''),
(161, 9, 'Burrow Strike', '', 'Active', 'Area', 'Q', 2, 'N/A', '100', '11 seconds', '750', '175', 'Air, Ground, Enemy', '160 damage <br />  175 area damage <br /> 1.5s stun', 3, ''),
(162, 9, 'Burrow Strike', '', 'Active', 'Area', 'Q', 3, 'N/A', '110', '11 seconds', '800', '200', 'Air, Ground, Enemy', '240 damage <br />  200 area damage <br /> 1.5s stun', 5, ''),
(163, 9, 'Burrow Strike', '', 'Active', 'Area', 'Q', 4, 'N/A', '120', '11 seconds', '850', '225', 'Air, Ground, Enemy', '320 damage <br />  225 area damage <br /> 1.5s stun', 7, ''),
(164, 9, 'Burrow Strike', '', 'Active', 'Area', 'Q', 5, 'N/A', '130', '11 seconds', '900', '250', 'Air, Ground, Enemy', '400 damage <br />  250 area damage <br /> 1.5s stun', 9, ''),
(165, 9, 'Burrow Move', 'Dominus and all his minions burrow for a limited time, after which, if there is a unit in the target area, they will come out of the earth close to it, else they will unburrow at the Crypt Lord''s position.', 'Active', 'Area', 'W', 1, '6 seconds', '120', '35 seconds', 'N/A', '200', 'Self', 'become invisible', 1, ''),
(166, 9, 'Burrow Move', '', 'Active', 'Area', 'W', 2, '5 seconds', '120', '30 seconds', 'N/A', '200', 'Self', 'become invisible', 3, ''),
(167, 9, 'Burrow Move', '', 'Active', 'Area', 'W', 3, '4 seconds', '120', '25 seconds', 'N/A', '200', 'Self', 'become invisible', 5, ''),
(168, 9, 'Burrow Move', '', 'Active', 'Area', 'W', 4, '3 seconds', '120', '20 seconds', 'N/A', '200', 'Self', 'become invisible', 7, ''),
(169, 9, 'Burrow Move', '', 'Active', 'Area', 'W', 5, '2 seconds', '120', '15 seconds', 'N/A', '200', 'Self', 'become invisible', 9, ''),
(170, 9, 'Carrion Swarm', 'His giant horn allows Dominus to inject his spawn into a unit. If the unit dies within the next 5 seconds, a Grub will spawn out of the corpse. There only can be a limited amount of grubs and beetles at the same time.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'max. 3 grubs', 1, ''),
(171, 9, 'Carrion Swarm', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'max. 5 grubs', 3, ''),
(172, 9, 'Carrion Swarm', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'max. 7 grubs', 5, ''),
(173, 9, 'Carrion Swarm', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'max. 9 grubs', 7, ''),
(174, 9, 'Carrion Swarm', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', 'max. 11 grubs', 9, ''),
(175, 9, 'Metamorphosis', 'Gives your Grubs the ability to develop into the more powerful Carrion Beetles over 1 minute. They deal double damage and have more hp.', 'Passive', 'Unit', '', 1, '60 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Grubs', 'double damage<br /> 100 extra HP', 6, ''),
(176, 9, 'Metamorphosis', '', 'Passive', 'Unit', '', 2, '60 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Grubs', 'double damage<br /> 200 extra HP', 12, ''),
(177, 9, 'Metamorphosis', '', 'Passive', 'Unit', '', 3, '60 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Grubs', 'double damage<br /> 300 extra HP', 18, ''),
(200, 10, 'Cleave', 'The Abomination''s brutal strikes hit several units at once, a bonus percentage of the damage. There''s a small chance to stun or knockback weaker units.', 'Active', 'Unit / Area', 'Q', 1, '10 seconds', '80', '15 seconds', 'N/A', 'N/A', 'Ground, Enemy', '60% bonus damage <br /> 8% chance for stun or knockback', 1, ''),
(201, 10, 'Cleave', '', 'Active', 'Unit / Area', 'Q', 2, '10 seconds', '85', '15 seconds', 'N/A', 'N/A', 'Ground, Enemy', '55% bonus damage <br /> 10% chance for stun or knockback', 3, ''),
(202, 10, 'Cleave', '', 'Active', 'Unit / Area', 'Q', 3, '10 seconds', '90', '15 seconds', 'N/A', 'N/A', 'Ground, Enemy', '50% bonus damage <br /> 12% chance for stun or knockback', 5, ''),
(203, 10, 'Cleave', '', 'Active', 'Unit / Area', 'Q', 4, '10 seconds', '95', '15 seconds', 'N/A', 'N/A', 'Ground, Enemy', '45% bonus damage <br /> 14% chance for stun or knockback', 7, ''),
(204, 10, 'Cleave', '', 'Active', 'Unit / Area', 'Q', 5, '10 seconds', '100', '15 seconds', 'N/A', 'N/A', 'Ground, Enemy', '40% bonus damage <br /> 16% chance for stun or knockback', 9, ''),
(205, 10, 'Consume himself', 'The Abomination consumes a chunk of his body to regenerate some hitpoints over a few seconds.', 'Active', 'Unit', 'W', 1, '5 seconds', '60', '11 seconds', 'N/A', 'N/A', 'Self', '5% of max hp/s', 1, ''),
(206, 10, 'Consume himself', '', 'Active', 'Unit', 'W', 2, '5 seconds', '70', '11 seconds', 'N/A', 'N/A', 'Self', '6% of max hp/s', 3, ''),
(207, 10, 'Consume himself', '', 'Active', 'Unit', 'W', 3, '5 seconds', '80', '11 seconds', 'N/A', 'N/A', 'Self', '7% of max hp/s', 5, ''),
(208, 10, 'Consume himself', '', 'Active', 'Unit', 'W', 4, '5 seconds', '90', '11 seconds', 'N/A', 'N/A', 'Self', '8% of max hp/s', 7, ''),
(209, 10, 'Consume himself', '', 'Active', 'Unit', 'W', 5, '5 seconds', '100', '11 seconds', 'N/A', 'N/A', 'Self', '9% of max hp/s', 9, ''),
(210, 10, 'Plague Cloud', 'Each unit that comes in range of Blight Cleaver has a chance to get infected with the plague, taking damage over time. Each infected unit also has a low chance to infect others. The plague disappears after a few seconds if the unit is not reinfected.', 'Passive', 'Unit', '', 1, '3 seconds', 'None', 'N/A', '200', '200', 'Air, Ground, Enemy', '2 damage/sec <br /> -25% Movementspeed', 1, ''),
(211, 10, 'Plague Cloud', '', 'Passive', 'Unit', '', 2, '4 seconds', 'None', 'N/A', '225', '225', 'Air, Ground, Enemy', '4 damage/sec <br /> -25% Movementspeed', 3, ''),
(212, 10, 'Plague Cloud', '', 'Passive', 'Unit', '', 3, '5 seconds', 'None', 'N/A', '250', '250', 'Air, Ground, Enemy', '8 damage/sec <br /> -25% Movementspeed', 5, ''),
(213, 10, 'Plague Cloud', '', 'Passive', 'Unit', '', 4, '6 seconds', 'None', 'N/A', '275', '275', 'Air, Ground, Enemy', '16 damage/sec <br /> -25% Movementspeed', 7, ''),
(214, 10, 'Plague Cloud', '', 'Passive', 'Unit', '', 5, '7 seconds', 'None', 'N/A', '300', '300', 'Air, Ground, Enemy', '32 damage/sec <br /> -25% Movementspeed', 9, ''),
(215, 10, 'Snack', 'Blight Cleaver joyfully feasts on an enemy hero, damaging him and healing himself for an equal amount. The enemy cannot move while being eaten. If the victim dies in the process, Blight Cleaver will permanently gain 3 points in Strength.', 'Active', 'Unit', 'R', 1, '5 seconds', '100', '60 seconds', '175', 'N/A', 'Ground, Enemy Hero', '105 damage/heal per sec.', 6, ''),
(216, 10, 'Snack', '', 'Active', 'Unit', 'R', 2, '5 seconds', '120', '60 seconds', '175', 'N/A', 'Ground, Enemy Hero', '140 damage/heal per sec.', 12, ''),
(217, 10, 'Snack', '', 'Active', 'Unit', 'R', 3, '5 seconds', '140', '60 seconds', '175', 'N/A', 'Ground, Enemy Hero', '175 damage/heal per sec.', 18, ''),
(180, 11, 'Arcane Swap', 'Gundagar restores mana to an enemy but damages his health for the same amount. The target is damaged by half the spell cost if it has no mana.', 'Active', 'Unit', 'Q', 1, 'N/A', '120', '21 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'restrores 100 mana of an enemy<br /> 100 damage to the enemy or<br /> half of mana ability as damage', 1, ''),
(181, 11, 'Arcane Swap', '', 'Active', 'Unit', 'Q', 2, 'N/A', '150', '18 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'restrores 200 mana of an enemy<br /> 200 damage to the enemy or<br /> half of mana ability as damage', 3, ''),
(182, 11, 'Arcane Swap', '', 'Active', 'Unit', 'Q', 3, 'N/A', '180', '15 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'restrores 300 mana of an enemy<br /> 300 damage to the enemy or<br /> half of mana ability as damage', 5, ''),
(183, 11, 'Arcane Swap', '', 'Active', 'Unit', 'Q', 4, 'N/A', '210', '12 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'restrores 400 mana of an enemy<br /> 400 damage to the enemy or<br /> half of mana ability as damage', 7, ''),
(184, 11, 'Arcane Swap', '', 'Active', 'Unit', 'Q', 5, 'N/A', '240', '9 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'restrores 500 mana of an enemy<br /> 500 damage to the enemy or<br /> half of mana ability as damage', 9, ''),
(185, 11, 'Mind Burst', 'The Mana Eater casts out two magical bolts towards a target. They deal damage and leave a mana draining debuff. If the target has mana, some of it will be transfered to Gundagar.', 'Active', 'Unit / Point', 'W', 1, 'N/A', '80', '9 seconds', '700', 'N/A', 'Ground, Enemy', '50 damage<br /> 10 mana steal<br /> -55 mana lose over 8s', 1, ''),
(186, 11, 'Mind Burst', '', 'Active', 'Unit / Point', 'W', 2, 'N/A', '90', '9 seconds', '700', 'N/A', 'Ground, Enemy', '70 damage<br /> 15 mana steal<br /> -75 mana lose over 8s', 3, ''),
(187, 11, 'Mind Burst', '', 'Active', 'Unit / Point', 'W', 3, 'N/A', '100', '9 seconds', '700', 'N/A', 'Ground, Enemy', '90 damage<br /> 20 mana steal<br /> -95 mana lose over 8s', 5, ''),
(188, 11, 'Mind Burst', '', 'Active', 'Unit / Point', 'W', 4, 'N/A', '110', '9 seconds', '700', 'N/A', 'Ground, Enemy', '110 damage<br /> 25 mana steal<br /> -115 mana lose over 8s', 7, ''),
(189, 11, 'Mind Burst', '', 'Active', 'Unit / Point', 'W', 5, 'N/A', '120', '9 seconds', '700', 'N/A', 'Ground, Enemy', '130 damage<br /> 30 mana steal<br /> -135 mana lose over 8s', 9, ''),
(190, 11, 'Mana Steal', 'Everytime Gundagar attacks a unit, he has a 25% chance to absorbs it''s mana. But he cannot absorb more mana than what the target has.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Air, Ground, Enemy', 'absorbs 20 mana', 1, ''),
(191, 11, 'Mana Steal', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Air, Ground, Enemy', 'absorbs 40 mana', 3, ''),
(192, 11, 'Mana Steal', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Air, Ground, Enemy', 'absorbs 60 mana', 5, ''),
(193, 11, 'Mana Steal', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Air, Ground, Enemy', 'absorbs 80 mana', 7, ''),
(194, 11, 'Mana Steal', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Air, Ground, Enemy', 'absorbs 100 mana', 9, ''),
(195, 11, 'Release Mana', 'The Destroyer uses all of his mana to unleash an energy wave around him that damages and slows every enemy it hits. The AoE depends on the amount of mana used.', 'Active', 'Area', 'R', 1, 'N/A', 'None', 'N/A', 'N/A', 'Depends of the Mana', 'Ground, Enemy', '240 damage<br /> -25% attack speed over 2s<br /> -50% movementspeed over 2s', 6, ''),
(196, 11, 'Release Mana', '', 'Active', 'Area', 'R', 2, 'N/A', 'None', 'N/A', 'N/A', 'Depends of the Mana', 'Ground, Enemy', '480 damage<br /> -25% attack speed over 4s<br /> -50% movementspeed over 4s', 12, ''),
(197, 11, 'Release Mana', '', 'Active', 'A', 'R', 3, 'N/A', 'None', 'N/A', 'N/A', 'Depends of the Mana', 'Ground, Enemy', '720 damage<br /> -25% attack speed over 6s<br /> -50% movementspeed over 6s', 18, ''),
(220, 12, 'Vampire Blood', 'The Dread Lord spills his own blood into a target area, enchanting allied units with a life-draining attack.', 'Active', 'Area', 'Q', 1, '20 seconds', '75', '10 seconds', '900', '250', 'Ground, Ally', 'max. 3 Units <br /> 20 Life drained', 1, ''),
(221, 12, 'Vampire Blood', '', 'Active', 'Area', 'Q', 2, '30 seconds', '75', '9 seconds', '900', '250', 'Ground, Ally', 'max. 4 Units <br /> 20 Life drained', 3, ''),
(222, 12, 'Vampire Blood', '', 'Active', 'Area', 'Q', 3, '40 seconds', '75', '8 seconds', '900', '250', 'Ground, Ally', 'max. 5 Units <br /> 20 Life drained', 5, ''),
(223, 12, 'Vampire Blood', '', 'Active', 'Area', 'Q', 4, '50 seconds', '75', '7 seconds', '900', '250', 'Ground, Ally', 'max. 6 Units <br /> 20 Life drained', 7, ''),
(224, 12, 'Vampire Blood', '', 'Active', 'Area', 'Q', 5, '60 seconds', '75', '6 seconds', '900', '250', 'Ground, Ally', 'max. 7 Units <br /> 20 Life drained', 9, ''),
(225, 12, 'Purify', 'Tristan heals a friendly unit and removes negative buffs or, he damages an enemy unit and removes positive buffs. It deals bonus damage to summons.', 'Active', 'Unit', 'W', 1, 'N/A', '100', '5 seconds', '800', 'N/A', 'Organic, Ally', 'removes Buffs <br /> 140 heal <br /> 50 damage <br /> 150 bonus damage against summons', 1, ''),
(226, 12, 'Purify', '', 'Active', 'Unit', 'W', 2, 'N/A', '125', '4 seconds', '800', 'N/A', 'Organic, Ally', 'removes Buffs <br /> 280 heal <br /> 100 damage <br /> 300 bonus damage against summons', 3, ''),
(227, 12, 'Purify', '', 'Active', 'Unit', 'W', 3, 'N/A', '150', '3 seconds', '800', 'N/A', 'Organic, Ally', 'removes Buffs <br /> 420 heal <br /> 150 damage <br /> 450 bonus damage against summons', 5, ''),
(228, 12, 'Purify', '', 'Active', 'Unit', 'W', 4, 'N/A', '175', '2 seconds', '800', 'N/A', 'Organic, Ally', 'removes Buffs <br /> 560 heal <br /> 200 damage <br /> 600 bonus damage against summons', 7, ''),
(229, 12, 'Purify', '', 'Active', 'Unit', 'W', 5, 'N/A', '200', '1 second', '800', 'N/A', 'Organic, Ally', 'removes Buffs <br /> 700 heal <br /> 250 damage <br /> 750 bonus damage against summons', 9, ''),
(230, 12, 'Sleepy Dust', 'The Snake Tongue summons an invisible Dust Bag on the floor that releases Sleep Powder when an enemy steps on it, effectively putting the unit to sleep.', 'Active', 'Point', 'E', 1, '60 seconds', '100', '7 seconds', '500', '30', 'Ground, Enemy', 'unit put to sleep', 1, ''),
(231, 12, 'Sleepy Dust', '', 'Active', 'Point', 'E', 2, '80 seconds', '95', '7 seconds', '500', '30', 'Ground, Enemy', 'unit put to sleep', 3, ''),
(232, 12, 'Sleepy Dust', '', 'Active', 'Point', 'E', 3, '100 seconds', '90', '7 seconds', '500', '30', 'Ground, Enemy', 'unit put to sleep', 5, ''),
(233, 12, 'Sleepy Dust', '', 'Active', 'Point', 'E', 4, '120 seconds', '85', '7 seconds', '500', '30', 'Ground, Enemy', 'unit put to sleep', 7, ''),
(234, 12, 'Sleepy Dust', '', 'Active', 'Point', 'E', 5, '140 seconds', '80', '7 seconds', '500', '30', 'Ground, Enemy', 'unit put to sleep', 9, ''),
(235, 12, 'Night Dome', 'Snake Tongue Tristan increases the mana regeneration of friendly units by creating a great Dome around them. It absorbs mana everytime a unit inside it casts a spell, increasing its own output.', 'Active', 'Area', 'R', 1, '30 seconds', '400', '120 seconds', '900', '600', 'Ally', '1% Mana/sec. start output <br /> 100 Mana absorbed', 6, ''),
(236, 12, 'Night Dome', '', 'Active', 'Area', 'R', 2, '30 seconds', '400', '110 seconds', '900', '600', 'Ally', '2% Mana/sec. start output <br /> 100 Mana absorbed', 12, ''),
(237, 12, 'Night Dome', '', 'Active', 'Area', 'R', 3, '30 seconds', '400', '100 seconds', '900', '600', 'Ally', '3% Mana/sec. start output <br /> 100 Mana absorbed', 18, ''),
(240, 13, 'Fire Totem', 'The Tauren Chieftain creates a burning Totem at a target point which attacks nearby enemy units.', 'Active', 'Point', 'Q', 1, '15 seconds', '115', '10 seconds', '350', '650', 'Air, Ground, Enemy', '35 damage', 1, ''),
(241, 13, 'Fire Totem', '', 'Active', 'Point', 'Q', 2, '15 seconds', '115', '10 seconds', '350', '650', 'Air, Ground, Enemy', '55 damage', 3, ''),
(242, 13, 'Fire Totem', '', 'Active', 'Point', 'Q', 3, '15 seconds', '115', '10 seconds', '350', '650', 'Air, Ground, Enemy', '75 damage', 5, ''),
(243, 13, 'Fire Totem', '', 'Active', 'Point', 'Q', 4, '15 seconds', '115', '10 seconds', '350', '650', 'Air, Ground, Enemy', '95 damage', 7, ''),
(244, 13, 'Fire Totem', '', 'Active', 'Point', 'Q', 5, '15 seconds', '115', '10 seconds', '350', '650', 'Air, Ground, Enemy', '115 damage', 9, ''),
(245, 13, 'Stomp Blaster', 'The Tauren Chieftain stomp the area, damaging and knock back nearby enemy units.', 'Active', 'Instant', 'W', 1, 'N/A', '100', '7 seconds', 'N/A', '300', 'Ground, Enemy', '75 damage <br /> knock back', 1, ''),
(246, 13, 'Stomp Blaster', '', 'Active', 'Instant', 'W', 2, 'N/A', '100', '7 seconds', 'N/A', '300', 'Ground, Enemy', '100 damage <br /> knock back', 3, ''),
(247, 13, 'Stomp Blaster', '', 'Active', 'Instant', 'W', 3, 'N/A', '100', '7 seconds', 'N/A', '300', 'Ground, Enemy', '125 damage <br /> knock back', 5, ''),
(248, 13, 'Stomp Blaster', '', 'Active', 'Instant', 'W', 4, 'N/A', '100', '7 seconds', 'N/A', '300', 'Ground, Enemy', '150 damage <br /> knock back', 7, ''),
(249, 13, 'Stomp Blaster', '', 'Active', 'Instant', 'W', 5, 'N/A', '100', '7 seconds', 'N/A', '300', 'Ground, Enemy', '175 damage <br /> knock back', 9, ''),
(250, 13, 'Fervor', 'By using his mental power, the Tauren Chieftain increases the attack speed based on the number of allied units in the aura.', 'Active', 'Unit', 'E', 1, 'N/A', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Ally', 'max .10 % Attack Speed', 1, ''),
(251, 13, 'Fervor', '', 'Active', 'Unit', 'E', 2, 'N/A', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Ally', 'max .15 % Attack Speed', 3, ''),
(252, 13, 'Fervor', '', 'Active', 'Unit', 'E', 3, 'N/A', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Ally', 'max .20 % Attack Speed', 5, ''),
(253, 13, 'Fervor', '', 'Active', 'Unit', 'E', 4, 'N/A', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Ally', 'max .25 % Attack Speed', 7, ''),
(254, 13, 'Fervor', '', 'Active', 'Unit', 'E', 5, 'N/A', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Ally', 'max .30 % Attack Speed', 9, ''),
(255, 13, 'Shockwave', 'After 3 seconds, the Tauren Chieftain sends out a shockwave that knocks all enemies it hits back, dealing high damage to them and slowing them for 5 seconds. The closer an enemy is to the center of the wave, the higher is the damage it takes.', 'Active', 'Point', 'R', 1, '5 seconds', '200', '150 seconds', '800', '1000 x 200', 'Ground, Enemy', '350 damage <br /> knock back', 6, ''),
(256, 13, 'Shockwave', '', 'Active', 'Point', 'R', 2, '5 seconds', '250', '150 seconds', '800', '1000 x 200', 'Ground, Enemy', '550 damage <br /> knock back', 12, ''),
(257, 13, 'Shockwave', '', 'Active', 'Point', 'R', 3, '5 seconds', '300', '150 seconds', '800', '1000 x 200', 'Ground, Enemy', '750 damage <br /> knock back', 18, ''),
(260, 14, 'Holy Chains', 'The Archmage casts Holy Chains in the targeted direction, damaging every enemy unit in the spells''s path.', 'Active', 'Point', 'Q', 1, 'N/A', '140', '10 seconds', '600', 'N/A', 'Air, Ground, Enemy', '15 damage per chain', 1, ''),
(261, 14, 'Holy Chains', '', 'Active', 'Point', 'Q', 2, 'N/A', '150', '10 seconds', '600', 'N/A', 'Air, Ground, Enemy', '25 damage per chain', 3, ''),
(262, 14, 'Holy Chains', '', 'Active', 'Point', 'Q', 3, 'N/A', '160', '10 seconds', '600', 'N/A', 'Air, Ground, Enemy', '35 damage per chain', 5, ''),
(263, 14, 'Holy Chains', '', 'Active', 'Point', 'Q', 4, 'N/A', '170', '10 seconds', '600', 'N/A', 'Air, Ground, Enemy', '45 damage per chain', 7, ''),
(264, 14, 'Holy Chains', '', 'Active', 'Point', 'Q', 5, 'N/A', '180', '10 seconds', '600', 'N/A', 'Air, Ground, Enemy', '55 damage per chain', 9, ''),
(265, 14, 'Trappy Swap', 'Belenus uses his powerful magic to trick and enemy''s mind into attacking his peers, the Archmage''s foes.', 'Active', 'Unit', 'W', 1, '60 seconds', '115', '15 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'unit control', 1, ''),
(266, 14, 'Trappy Swap', '', 'Active', 'Unit', 'W', 2, '55 seconds', '130', '15 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'unit control', 3, ''),
(267, 14, 'Trappy Swap', '', 'Active', 'Unit', 'W', 3, '50 seconds', '145', '15 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'unit control', 5, ''),
(268, 14, 'Trappy Swap', '', 'Active', 'Unit', 'W', 4, '45 seconds', '160', '15 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'unit control', 7, ''),
(269, 14, 'Trappy Swap', '', 'Active', 'Unit', 'W', 5, '40 seconds', '175', '15 seconds', '600', 'N/A', 'Air, Ground, Enemy', 'unit control', 9, '');
INSERT INTO `spells` (`ID`, `hero_ID`, `name`, `description`, `ability_type`, `targeting_type`, `ability_hotkey`, `level`, `duration`, `mana_cost`, `cooldown`, `range`, `aoe`, `targets`, `effects`, `required_level`, `note`) VALUES
(270, 14, 'Refreshing Aura', 'The Aura gives all nearby friendly heroes a chance to fully replenish their mana when casting a spell.', 'Passive', 'Unit', 'N/A', 1, 'Unlimited', 'None', 'N/A', 'N/A', '900', 'Hero, Friend, Self', '3% chance to set the Mana to 100%', 1, ''),
(271, 14, 'Refreshing Aura', '', 'Passive', 'Unit', 'N/A', 2, 'Unlimited', 'None', 'N/A', 'N/A', '900', 'Hero, Friend, Self', '5% chance to set the Mana to 100%', 3, ''),
(272, 14, 'Refreshing Aura', '', 'Passive', 'Unit', 'N/A', 3, 'Unlimited', 'None', 'N/A', 'N/A', '900', 'Hero, Friend, Self', '7% chance to set the Mana to 100%', 5, ''),
(273, 14, 'Refreshing Aura', '', 'Passive', 'Unit', 'N/A', 4, 'Unlimited', 'None', 'N/A', 'N/A', '900', 'Hero, Friend, Self', '9% chance to set the Mana to 100%', 7, ''),
(274, 14, 'Refreshing Aura', '', 'Passive', 'Unit', 'N/A', 5, 'Unlimited', 'None', 'N/A', 'N/A', '900', 'Hero, Friend, Self', '11% chance to set the Mana to 100%', 9, ''),
(275, 14, 'Fireworks', 'The Last Archmage casts his ultimate spell, a massive explosion of colourful sparks that damage and blind his enemies.', 'Active', 'Area', 'R', 1, '13 seconds', '200', '105 seconds', 'N/A', '700', 'Air, Ground, Enemy', '100 damage <br /> 20% miss', 6, ''),
(276, 14, 'Fireworks', '', 'Active', 'Area', 'R', 2, '13 seconds', '300', '105 seconds', 'N/A', '700', 'Air, Ground, Enemy', '150 damage <br /> 30% miss', 12, ''),
(277, 14, 'Fireworks', '', 'Active', 'Area', 'R', 3, '13 seconds', '400', '105 seconds', 'N/A', '700', 'Air, Ground, Enemy', '200 damage <br /> 40% miss', 18, ''),
(280, 15, 'Life Vortex', 'The Priestess of the Moon summons a powerful vortex, that deals damage to units in a targeted area for a certain period of time.', 'Active', 'Area', 'Q', 1, '2.5 seconds', '100', '12 seconds', '700', '300', 'Air, Ground, Enemy', '55 damage over 2.5 sec.', 1, ''),
(281, 15, 'Life Vortex', '', 'Active', 'Area', 'Q', 2, '2.5 seconds', '120', '12 seconds', '700', '300', 'Air, Ground, Enemy', '75 damage over 2.5 sec.', 3, ''),
(282, 15, 'Life Vortex', '', 'Active', 'Area', 'Q', 3, '2.5 seconds', '140', '12 seconds', '700', '300', 'Air, Ground, Enemy', '95 damage over 2.5 sec.', 5, ''),
(283, 15, 'Life Vortex', '', 'Active', 'Area', 'Q', 4, '2.5 seconds', '160', '12 seconds', '700', '300', 'Air, Ground, Enemy', '115 damage over 2.5 sec.', 7, ''),
(284, 15, 'Life Vortex', '', 'Active', 'Area', 'Q', 5, '2.5 seconds', '180', '12 seconds', '700', '300', 'Air, Ground, Enemy', '135 damage over 2.5 sec.', 9, ''),
(285, 15, 'Moonlight', 'The PotM concentrates all her strenght to call the mystic might of the moon making friendly units invulnverable for a few seconds.', 'Active', 'Point', 'W', 1, '6 seconds', '160', '30 seconds', '600', '600', 'Air, Ground, Friend', 'complete invulnerabiliy', 1, ''),
(286, 15, 'Moonlight', '', 'Active', 'Point', 'W', 2, '7 seconds', '160', '30 seconds', '600', '600', 'Air, Ground, Friend', 'complete invulnerabiliy', 3, ''),
(287, 15, 'Moonlight', '', 'Active', 'Point', 'W', 3, '8 seconds', '160', '30 seconds', '600', '600', 'Air, Ground, Friend', 'complete invulnerabiliy', 5, ''),
(288, 15, 'Moonlight', '', 'Active', 'Point', 'W', 4, '9 seconds', '160', '30 seconds', '600', '600', 'Air, Ground, Friend', 'complete invulnerabiliy', 7, ''),
(289, 15, 'Moonlight', '', 'Active', 'Point', 'W', 5, '10 seconds', '160', '30 seconds', '600', '600', 'Air, Ground, Friend', 'complete invulnerabiliy', 9, ''),
(290, 15, 'Night Aura', 'The mighty aura of the Priestess of the Moon surrounds friendly units and gives a 20% chance to reflect a part of the damage back to the attacker. If the unit dies,  15% of it''s mana is released and fills up the mana of the attacker.', 'Passive', 'Unit', '', 1, 'Unlimited', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Friend, Self', 'Reflects 10% damage', 1, ''),
(291, 15, 'Night Aura', '', 'Passive', 'Unit', '', 2, 'Unlimited', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Friend, Self', 'Reflects 20% damage', 3, ''),
(292, 15, 'Night Aura', '', 'Passive', 'Unit', '', 3, 'Unlimited', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Friend, Self', 'Reflects 30% damage', 5, ''),
(293, 15, 'Night Aura', '', 'Passive', 'Unit', '', 4, 'Unlimited', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Friend, Self', 'Reflects 40% damage', 7, ''),
(294, 15, 'Night Aura', '', 'Passive', 'Unit', '', 5, 'Unlimited', 'None', 'N/A', 'N/A', '800', 'Air, Ground, Friend, Self', 'Reflects 50% damage', 9, ''),
(295, 15, 'Revenge Owl', 'The Owl of the Priestess flys over the enemy''s army calls down waves of falling stars that damage nearby enemy units. The Owl is invulnerable and can be controlled for a short moment.', 'Active', 'Area', 'R', 1, 'N/A', '200', '135 seconds', '700', '250', 'Ground, Enemy', '5 x 250 damage', 6, ''),
(296, 15, 'Revenge Owl', '', 'Active', 'Area', 'R', 2, 'N/A', '300', '145 seconds', '700', '250', 'Ground, Enemy', '6 x 250 damage', 12, ''),
(297, 15, 'Revenge Owl', '', 'Active', 'Area', 'R', 3, 'N/A', '400', '155 seconds', '700', '250', 'Ground, Enemy', '7 x 250 damage', 18, ''),
(300, 16, 'Tidal Shield', 'This shield makes the Naga immune to spells and boosts her life regeneration.', 'Active', 'Instant', 'Q', 1, '10 seconds', '50', '30 seconds', 'N/A', 'N/A', 'Self', 'magic Immunity <br /> 10 HP/s', 1, ''),
(301, 16, 'Tidal Shield', '', 'Active', 'Instant', 'Q', 2, '10 seconds', '60', '30 seconds', 'N/A', 'N/A', 'Self', 'magic Immunity <br /> 15 HP/s', 3, ''),
(302, 16, 'Tidal Shield', '', 'Active', 'Instant', 'Q', 3, '10 seconds', '70', '30 seconds', 'N/A', 'N/A', 'Self', 'magic Immunity <br /> 20 HP/s', 5, ''),
(303, 16, 'Tidal Shield', '', 'Active', 'Instant', 'Q', 4, '10 seconds', '80', '30 seconds', 'N/A', 'N/A', 'Self', 'magic Immunity <br /> 25 HP/s', 7, ''),
(304, 16, 'Tidal Shield', '', 'Active', 'Instant', 'Q', 5, '10 seconds', '90', '30 seconds', 'N/A', 'N/A', 'Self', 'magic Immunity <br /> 30 HP/s', 9, ''),
(305, 16, 'Impaling Spine', 'The Naga Matriarch throws a magical Spear, dealing damage, stunning the target and damaging it over 60 seconds.', 'Active', 'Unit', 'W', 1, 'N/A', '75', '9 seconds', '600', 'N/A', 'Air, Ground, Enemy', '20 initial damage <br /> 30 damage over time <br /> 1.5s stun (hero) <br /> 2.5s stun (normal)', 1, ''),
(306, 16, 'Impaling Spine', '', 'Active', 'Unit', 'W', 2, 'N/A', '75', '9 seconds', '600', 'N/A', 'Air, Ground, Enemy', '30 initial damage <br /> 60 damage over time  <br /> 1.5s stun (hero) <br /> 3.5s stun (normal)', 3, ''),
(307, 16, 'Impaling Spine', '', 'Active', 'Unit', 'W', 3, 'N/A', '75', '9 seconds', '600', 'N/A', 'Air, Ground, Enemy', '40 initial damage <br /> 90 damage over time  <br /> 1.5s stun (hero) <br /> 4.5s stun (normal)', 5, ''),
(308, 16, 'Impaling Spine', '', 'Active', 'Unit', 'W', 4, 'N/A', '75', '9 seconds', '600', 'N/A', 'Air, Ground, Enemy', '50 initial damage <br /> 120 damage over time  <br /> 1.5s stun (hero) <br /> 5.5s stun (normal)', 7, ''),
(309, 16, 'Impaling Spine', '', 'Active', 'Unit', 'W', 5, 'N/A', '75', '9 seconds', '600', 'N/A', 'Air, Ground, Enemy', '60 initial damage <br /> 150 damage over time <br /> 1.5s stun (hero) <br /> 6.5s stun (normal)', 9, ''),
(310, 16, 'Crushing Wave', 'The Naga Matriarch sends out a deadly gust of water wich will increase in size and damage with traveled distance. End damage is 4 times the start damage.', 'Active', 'Point', 'E', 1, 'N/A', '110', '10 seconds', '700', '50-300', 'Air, Ground, Enemy', '25 - 100 Damage <br /> 300 maximum Damage', 1, ''),
(311, 16, 'Crushing Wave', '', 'Active', 'Point', 'E', 2, 'N/A', '110', '10 seconds', '700', '50-300', 'Air, Ground, Enemy', '50 - 200 Damage <br /> 600 maximum Damage', 3, ''),
(312, 16, 'Crushing Wave', '', 'Active', 'Point', 'E', 3, 'N/A', '110', '10 seconds', '700', '50-300', 'Air, Ground, Enemy', '75 - 300 Damage <br /> 900 maximum Damage', 5, ''),
(313, 16, 'Crushing Wave', '', 'Active', 'Point', 'E', 4, 'N/A', '110', '10 seconds', '700', '50-300', 'Air, Ground, Enemy', '100 - 400 Damage <br /> 1200 maximum Damage^', 7, ''),
(314, 16, 'Crushing Wave', '', 'Active', 'Point', 'E', 5, 'N/A', '110', '10 seconds', '700', '50-300', 'Air, Ground, Enemy', '125 - 500 Damage <br /> 1500 maximum Damage', 9, ''),
(315, 16, 'Maelstrom', 'The Naga channels a deadly Maelstrom, turning all units slowly around her, dealing damage to all enemy units caught.', 'Active', 'Instant', 'R', 1, '15 seconds', '125', '120 seconds', 'N/A', '400', 'Air, Ground, Enemy, Friend', 'Moves Units <br /> 50 damage/s to enemies', 6, ''),
(316, 16, 'Maelstrom', '', 'Active', 'Instant', 'R', 2, '15 seconds', '125', '120 seconds', 'N/A', '400', 'Air, Ground, Enemy, Friend', 'Moves Units <br /> 100 damage/s to enemies', 12, ''),
(317, 16, 'Maelstrom', '', 'Active', 'Instant', 'R', 3, '15 seconds', '125', '120 seconds', 'N/A', '400', 'Air, Ground, Enemy, Friend', 'Moves Units <br /> 150 damage/s to enemies', 18, ''),
(320, 17, 'Thunderbolt', 'After channeling 1 second, a lightning strike comes down somewhere in an 200 AoE around the target point, damaging all units around it.', 'Active', 'Area', 'Q', 1, 'N/A', '100', '1 second', '500', '200', 'Air, Ground, Enemy, Ally', '100 damage', 1, ''),
(321, 17, 'Thunderbolt', '', 'Active', 'Area', 'Q', 2, 'N/A', '100', '1 second', '500', '200', 'Air, Ground, Enemy, Ally', '300 damage', 3, ''),
(322, 17, 'Thunderbolt', '', 'Active', 'Area', 'Q', 3, 'N/A', '100', '1 second', '500', '200', 'Air, Ground, Enemy, Ally', '500 damage', 5, ''),
(323, 17, 'Thunderbolt', '', 'Active', 'Area', 'Q', 4, 'N/A', '100', '1 second', '500', '200', 'Air, Ground, Enemy, Ally', '700 damage', 7, ''),
(324, 17, 'Thunderbolt', '', 'Active', 'Area', 'Q', 5, 'N/A', '100', '1 second', '500', '200', 'Air, Ground, Enemy, Ally', '900 damage', 9, ''),
(325, 17, 'Spirit Link', 'The Warlock connects his spirit with the target. Whenever the target receives damage and has less life than the Warlock, the damage will be blocked, by sacrificing the amount of damage with the Warlock''s own life.', 'Active', 'Unit', 'W', 1, '20 seconds', '125', '1 second', '500', 'N/A', 'Air, Ground, Ally, Not Self', 'shares damage with Warlock', 1, ''),
(326, 17, 'Spirit Link', '', 'Active', 'Unit', 'W', 2, '30 seconds', '100', '1 second', '500', 'N/A', 'Air, Ground, Ally, Not Self', 'shares damage with Warlock', 3, ''),
(327, 17, 'Spirit Link', '', 'Active', 'Unit', 'W', 3, '40 seconds', '75', '1 second', '500', 'N/A', 'Air, Ground, Ally, Not Self', 'shares damage with Warlock', 5, ''),
(328, 17, 'Spirit Link', '', 'Active', 'Unit', 'W', 4, '50 seconds', '50', '1 second', '500', 'N/A', 'Air, Ground, Ally, Not Self', 'shares damage with Warlock', 7, ''),
(329, 17, 'Spirit Link', '', 'Active', 'Unit', 'W', 5, '60 seconds', '25', '1 second', '500', 'N/A', 'Air, Ground, Ally, Not Self', 'shares damage with Warlock', 9, ''),
(330, 17, 'Mana Ward', 'The Orcish Warlock summons an immobile ward which replenishes the mana of nearby allied units.', 'Active', 'Point', 'E', 1, '40 seconds', '30', '6.5 seconds', '500', '700', 'Air, Ground, Ally', '3 Mana per second', 1, ''),
(331, 17, 'Mana Ward', '', 'Active', 'Point', 'E', 2, '40 seconds', '30', '6.5 seconds', '500', '700', 'Air, Ground, Ally', '4 Mana per second', 3, ''),
(332, 17, 'Mana Ward', '', 'Active', 'Point', 'E', 3, '40 seconds', '30', '6.5 seconds', '500', '700', 'Air, Ground, Ally', '5 Mana per second', 5, ''),
(333, 17, 'Mana Ward', '', 'Active', 'Point', 'E', 4, '40 seconds', '30', '6.5 seconds', '500', '700', 'Air, Ground, Ally', '6 Mana per second', 7, ''),
(334, 17, 'Mana Ward', '', 'Active', 'Point', 'E', 5, '40 seconds', '30', '6.5 seconds', '500', '700', 'Air, Ground, Ally', '7 Mana per second', 9, ''),
(335, 17, 'Dark Summoning', 'The Warlock summons demons that binds the target between them. While being trapped, the target cannot move, attack or cast spells and any damage or heal that would affect the target will be ignored. The demons will regenerate the target''s life over the duration, if it is an allied unit.', 'Active', 'Unit', 'R', 1, '30 seconds', '200', '180 seconds', '500', 'N/A', 'Air, Ground, Enemy, Ally', 'can''t move or attack <br /> has 0 Mana <br /> can''t be damaged', 6, ''),
(336, 17, 'Dark Summoning', '', 'Active', 'Unit', 'R', 2, '30 seconds', '175', '150 seconds', '500', 'N/A', 'Air, Ground, Enemy, Ally', 'can''t move or attack <br /> has 0 Mana <br /> can''t be damaged', 12, ''),
(337, 17, 'Dark Summoning', '', 'Active', 'Unit', 'R', 3, '30 seconds', '150', '130 seconds', '500', 'N/A', 'Air, Ground, Enemy, Ally', 'can''t move or attack <br /> has 0 Mana <br /> can''t be damaged', 18, ''),
(346, 18, 'Crippling Arrow', '', 'Active', 'Point', 'W', 2, '60/10 seconds', '75', '8 seconds', '700', 'N/A', 'Air, Ground, Enemy', '150 damage <br /> +150 bonus damage <br />\r\n-60% movement speed <br /> -50% attack speed', 3, ''),
(345, 18, 'Crippling Arrow', 'Gabrielle shoots a poisoned arrow that slows down the targeted unit. It deals bonus damage if the target is already affected by an arrow.', 'Active', 'Point', 'W', 1, '60/10 seconds', '75', '8 seconds', '700', 'N/A', 'Air, Ground, Enemy', '75 damage <br /> +37 bonus damage <br />\r\n-50% movement speed <br /> -50% attack speed', 1, ''),
(344, 18, 'Ghost Form', '', 'Active', 'Instant', 'Q', 5, '35 seconds', '75', '5 seconds', 'N/A', 'N/A', 'Self', '+50% movement speed <br /> able to walk through units', 9, ''),
(348, 18, 'Crippling Arrow', '', 'Active', 'Point', 'W', 4, '60/10 seconds', '75', '8 seconds', '700', 'N/A', 'Air, Ground, Enemy', '300 damage <br /> 150 bonus damage <br />\r\n-80% movement speed <br /> -50% attack speed', 7, ''),
(349, 18, 'Crippling Arrow', '', 'Active', 'Point', 'W', 5, '60/10 seconds', '75', '8 seconds', '700', 'N/A', 'Air, Ground, Enemy', '375 damage <br /> +187 bonus damage <br />\r\n-90% movement speed <br /> -50% attack speed', 9, ''),
(350, 18, 'Snipe', 'The Dark Ranger shoots an arrow at a target outside of her usual range. She takes 3 seconds to aim.', 'Active', 'Unit', 'E', 1, 'Instant', '60', '5 seconds', '1200', 'N/A', 'Air, Ground, Enemy', '75 damage', 1, ''),
(351, 18, 'Snipe', '', 'Active', 'Unit', 'E', 2, 'Instant', '70', '5 seconds', '1500', 'N/A', 'Air, Ground, Enemy', '125 damage', 3, ''),
(352, 18, 'Snipe', '', 'Active', 'Unit', 'E', 3, 'Instant', '80', '5 seconds', '1800', 'N/A', 'Air, Ground, Enemy', '175 damage', 5, ''),
(353, 18, 'Snipe', '', 'Active', 'Unit', 'E', 4, 'Instant', '90', '5 seconds', '2100', 'N/A', 'Air, Ground, Enemy', '225 damage', 7, ''),
(354, 18, 'Snipe', '', 'Active', 'Unit', 'E', 5, 'Instant', '100', '5 seconds', '2400', 'N/A', 'Air, Ground, Enemy', '275 damage', 9, ''),
(355, 18, 'Coup de Grace', 'Gabrielle fires an arrow at an allied hero and instantly kills it. The energy released creates a powerful explosion that deals heavy area of effect damage to all enemy units.', 'Active', 'Unit', 'R', 1, 'N/A', '180', '180 seconds', '600', '300', 'Ally, Hero', 'kills allied Hero <br /> deals 750 area damage', 6, ''),
(356, 18, 'Coup de Grace', '', 'Active', 'Unit', 'R', 2, 'N/A', '150', '150 seconds', '600', '300', 'Ally, Hero', 'kills allied Hero <br /> deals 1250 area damage', 12, ''),
(357, 18, 'Coup de Grace', '', 'Active', 'Unit', 'R', 3, 'N/A', '120', '120 seconds', '600', '300', 'Ally, Hero', 'kills allied Hero <br /> deals 1750 area damage', 18, ''),
(360, 19, 'Fire Blast', 'The Blood Mage launches a Fire Blast that spits smaller fireballs at the closest enemy unit. When the Blast lands, it fires one last wave of fireballs at all nearby enemies.', 'Active', 'Area', 'Q', 1, 'N/A', '100', '10 seconds', '600', '350', 'Air, Ground, Enemy', '40 damage per missile', 1, ''),
(361, 19, 'Fire Blast', '', 'Active', 'Area', 'Q', 2, 'N/A', '110', '10 seconds', '600', '350', 'Air, Ground, Enemy', '80 damage per missile', 3, ''),
(362, 19, 'Fire Blast', '', 'Active', 'Area', 'Q', 3, 'N/A', '120', '10 seconds', '600', '350', 'Air, Ground, Enemy', '120 damage per missile', 5, ''),
(363, 19, 'Fire Blast', '', 'Active', 'Area', 'Q', 4, 'N/A', '130', '10 seconds', '600', '350', 'Air, Ground, Enemy', '160 damage per missile', 7, ''),
(364, 19, 'Fire Blast', '', 'Active', 'Area', 'Q', 5, 'N/A', '140', '10 seconds', '600', '350', 'Air, Ground, Enemy', '200 damage per missile', 9, ''),
(365, 19, 'Boon and Bane', 'The Fire Master encourages an ally unit to increase it''s damage output by 35% and reduce it''s damage received by 50%. Alternatively, Joos intimidates an enemy unit to reduce it''s damage output by 20% and increase it''s damage received by 30%. The buff lasts for 15 seconds.', 'Active', 'Unit', 'W', 1, '15 seconds', '115', '9 seconds', '600', 'N/A', 'Air, Ground, Ally, Enemy', 'damage modification', 1, ''),
(366, 19, 'Boon and Bane', '', 'Active', 'Unit', 'W', 2, '15 seconds', '120', '9 seconds', '600', 'N/A', 'Air, Ground, Ally, Enemy', 'damage modification', 3, ''),
(367, 19, 'Boon and Bane', '', 'Passive', 'Area', '', 3, '15 seconds', '125', '9 seconds', '600', 'N/A', 'Air, Ground, Ally, Enemy', 'damage modification', 5, ''),
(368, 19, 'Boon and Bane', '', 'Active', 'Unit', 'W', 4, '15 seconds', '130', '9 seconds', '600', 'N/A', 'Air, Ground, Ally, Enemy', 'damage modification', 7, ''),
(369, 19, 'Boon and Bane', '', 'Active', 'Unit', 'W', 5, '15 seconds', '135', '9 seconds', '600', 'N/A', 'Air, Ground, Ally, Enemy', 'damage modification', 9, ''),
(370, 19, 'Burning Skin', 'FireLord Ignos covers himself with fire. Attacking enemies are hurt by a portion of the damage they deal to Ignos over a short period of time.', 'Passive', 'Unit', '', 1, '4.5 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Melee, Enemy', '15% chance <br /> 75% damage factor', 1, ''),
(371, 19, 'Burning Skin', '', 'Passive', 'Unit', '', 2, '4 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Melee, Enemy', '20% chance <br /> 90% damage factor', 3, ''),
(372, 19, 'Burning Skin', '', 'Passive', 'Unit', '', 3, '3.5 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Melee, Enemy', '25% chance <br /> 105% damage factor', 5, ''),
(373, 19, 'Burning Skin', '', 'Passive', 'Unit', '', 4, '3 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Melee, Enemy', '30% chance <br /> 120% damage factor', 7, ''),
(374, 19, 'Burning Skin', '', 'Passive', 'Unit', '', 5, '2.5 seconds', 'None', 'N/A', 'N/A', 'N/A', 'Melee, Enemy', '35% chance <br /> 135% damage factor', 9, ''),
(375, 19, 'Fire Storm', 'Joos Ignos proves he''s a master of magic by summoning a raging Storm of fire that damages his enemies. The Storm lasts for 6 seconds.', 'Active', 'Area', 'R', 1, '6 seconds', '200', '160 seconds', '600', '300', 'Air, Ground, Enemy', '150 damage per collision', 6, ''),
(376, 19, 'Fire Storm', '', 'Active', 'Area', 'R', 2, '6 seconds', '200', '160 seconds', '600', '300', 'Air, Ground, Enemy', '200 damage per collision', 12, ''),
(377, 19, 'Fire Storm', '', 'Active', 'Area', 'R', 3, '6 seconds', '200', '160 seconds', '600', '300', 'Air, Ground, Enemy', '250 damage per collision', 18, ''),
(380, 20, 'Battle Fury', 'Darius enters a state of fury and deals bonus hero damage on every hit. Bonus damage is reduced everytime he gets hit. If he reaches the maximum of bonus damage it hold on for the same period of time.', 'Active', 'Instant', 'Q', 1, '10 seconds', '45', '20 seconds', 'N/A', 'N/A', 'Self', 'max 8 bonus damage', 1, ''),
(381, 20, 'Battle Fury', '', 'Active', 'Instant', 'Q', 2, '15 seconds', '55', '20 seconds', 'N/A', 'N/A', 'Self', 'max 16 bonus damage', 3, ''),
(382, 20, 'Battle Fury', '', 'Active', 'Instant', 'Q', 3, '20 seconds', '65', '20 seconds', 'N/A', 'N/A', 'Self', 'max 24 bonus damage', 5, ''),
(383, 20, 'Battle Fury', '', 'Active', 'Instant', 'Q', 4, '25 seconds', '75', '20 seconds', 'N/A', 'N/A', 'Self', 'max 32 bonus damage', 7, ''),
(384, 20, 'Battle Fury', '', 'Active', 'Instant', 'Q', 5, '30 seconds', '85', '20 seconds', 'N/A', 'N/A', 'Self', 'max 40 bonus damage', 9, ''),
(385, 20, 'Shattering Javelin', 'The Royal Knight throws a Javelin that deals piercing damage and shatters on impact. The shattered fragmets hit the units behind the target.', 'Active', 'Area', 'W', 1, 'N/A', '50', '15 seconds', '800', '400', 'Air, Ground, Enemy', '100 damage <br /> max.4x75 Fragment damage', 1, ''),
(386, 20, 'Shattering Javelin', '', 'Active', 'Area', 'W', 2, 'N/A', '50', '15 seconds', '800', '400', 'Air, Ground, Enemy', '200 damage <br /> max.4x100 Fragment damage', 3, ''),
(387, 20, 'Shattering Javelin', '', 'Active', 'Area', 'W', 3, 'N/A', '50', '15 seconds', '800', '400', 'Air, Ground, Enemy', '300 damage <br /> max.4x125 Fragment damage', 5, ''),
(388, 20, 'Shattering Javelin', '', 'Active', 'Area', 'W', 4, 'N/A', '50', '15 seconds', '800', '400', 'Air, Ground, Enemy', '400 damage <br /> max.4x150 Fragment damage', 7, ''),
(389, 20, 'Shattering Javelin', '', 'Active', 'Area', 'W', 5, 'N/A', '50', '15 seconds', '800', '400', 'Air, Ground, Enemy', '500 damage <br /> max.4x175 Fragment damage', 9, ''),
(390, 20, 'Animal War Training', 'The Knight''s ride is a well trained horse, faster than the average and fearless. It improves his fighting abilities, granting bonus damage and improvements for all his skills.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'bonus damage <br /> improvements for all abilities', 1, ''),
(391, 20, 'Animal War Training', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'bonus damage <br /> improvements for all abilities', 3, ''),
(392, 20, 'Animal War Training', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'bonus damage <br /> improvements for all abilities', 5, ''),
(393, 20, 'Animal War Training', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'bonus damage <br /> improvements for all abilities', 7, ''),
(394, 20, 'Animal War Training', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'bonus damage <br /> improvements for all abilities', 9, ''),
(395, 20, 'Charge', 'Royal Knight Parthos launches himself into the enemy lines without fear. He gains bonus attack speed and deals damage to enemy units along the way.', 'Active', 'Point', 'R', 1, 'N/A', '100', '90 seconds', '600', 'N/A', 'Ground, Enemy', 'bonus attack speed <br /> 100 damage', 6, ''),
(396, 20, 'Charge', '', 'Active', 'Area', 'R', 2, 'N/A', '130', '110 seconds', '600', 'N/A', 'Ground, Enemy', 'bonus attack speed <br /> 150 damage', 12, ''),
(397, 20, 'Charge', '', 'Active', 'Area', 'R', 3, 'N/A', '150', '130 seconds', '600', 'N/A', 'Ground, Enemy', 'bonus attack speed <br /> 200 damage', 18, ''),
(400, 21, 'God''s Seal', 'Blesses an allied unit with the seal of the Sun, reducing any damage it receives and increasing its health regeneration. The seal breaks when after receiving a certain amount of damage, hurting enemy units around by the same amount of damage received. If the seal is not broken, it will heal all allied units around the target for 50% of the base regeneration. And if the target receives lethal damage, the seal will block it. It expires after 9 seconds or when broken.', 'Active', 'Unit', 'Q', 1, '9 seconds', '130', '17 seconds', '550', 'N/A', 'Air, Ground, Ally', 'Reduce Damage by 15% <br /> HP Reg. 10/sec.', 1, ''),
(401, 21, 'God''s Seal', '', 'Active', 'Unit', 'Q', 2, '9 seconds', '140', '17 seconds', '550', 'N/A', 'Air, Ground, Ally', 'Reduce Damage by 20% <br /> HP Reg. 20/sec.', 3, ''),
(402, 21, 'God''s Seal', '', 'Active', 'Unit', 'Q', 3, '9 seconds', '150', '17 seconds', '550', 'N/A', 'Air, Ground, Ally', 'Reduce Damage by 25% <br /> HP Reg. 30/sec.', 5, ''),
(403, 21, 'God''s Seal', '', 'Active', 'Unit', 'Q', 4, '9 seconds', '160', '17 seconds', '550', 'N/A', 'Air, Ground, Ally', 'Reduce Damage by 30% <br /> HP Reg. 40/sec.', 7, ''),
(404, 21, 'God''s Seal', '', 'Active', 'Unit', 'Q', 5, '9 seconds', '170', '17 seconds', '550', 'N/A', 'Air, Ground, Ally', 'Reduce Damage by 35% <br /> HP Reg. 50/sec.', 9, ''),
(405, 21, 'Star Impact', 'Edgar calls down a Falling Star that, on impact, damages and stuns all enemy units, and splits into several smaller stars that deal less damage. The Star takes 1.5 seconds to summon.', 'Active', 'Area', 'W', 1, 'N/A', '120', '15 seconds', '750', '300', 'Ground, Enemy', '50 damage <br /> 0.75s stun <br /> splitter deals 5 damage', 1, ''),
(406, 21, 'Star Impact', '', 'Active', 'Area', 'W', 2, 'N/A', '130', '15 seconds', '750', '300', 'Ground, Enemy', '100 damage <br /> 1.25s stun <br /> splitter deals 10 damage', 3, ''),
(407, 21, 'Star Impact', '', 'Active', 'Area', 'W', 3, 'N/A', '140', '15 seconds', '750', '300', 'Ground, Enemy', '150 damage <br /> 1.75s stun <br /> splitter deals 15 damage', 5, ''),
(408, 21, 'Star Impact', '', 'Active', 'Area', 'W', 4, 'N/A', '150', '15 seconds', '750', '300', 'Ground, Enemy', '200 damage <br /> 2.25s stun <br /> splitter deals 20 damage', 7, ''),
(409, 21, 'Star Impact', '', 'Active', 'Area', 'W', 5, 'N/A', '160', '15 seconds', '750', '300', 'Ground, Enemy', '250 damage <br /> 2.75s stun <br /> splitter deals 25 damage', 9, ''),
(410, 21, 'Holy Strike', 'The Paladin enchances his mace with holy power, causing his next attack to deal bonus percentage magic damage to enemies around the target. Holy Strike will be activated automatically once the cooldown is over.', 'Passive', 'Unit', '', 1, 'N/A', 'None', '15 seconds', 'N/A', '250', 'Ground, Enemy', '+150% magic damage to enemies in 250 range', 1, ''),
(411, 21, 'Holy Strike', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', '12 seconds', 'N/A', '300', 'Ground, Enemy', '+200% magic damage to enemies in 300 range', 3, ''),
(412, 21, 'Holy Strike', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', '9 seconds', 'N/A', '350', 'Ground, Enemy', '+250% magic damage to enemies in 350 range', 5, ''),
(413, 21, 'Holy Strike', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', '6 seconds', 'N/A', '400', 'Ground, Enemy', '+300% magic damage to enemies in 400 range', 7, ''),
(414, 21, 'Holy Strike', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', '3 seconds', 'N/A', '450', 'Ground, Enemy', '+350% magic damage to enemies in 450 range', 9, ''),
(415, 21, 'Holy Cross', 'The Paladin creates a Holy Cross at the target location. Enemies that enter the Cross will be silenced for 2 seconds and will receive damage over time if they stay too long. Allies will receive less damage and an increased life regeneration. The cross lasts 7.5 seconds.', 'Active', 'Area', 'R', 1, '7.5 seconds', '200', '90 seconds', '600', '325', 'Air, Ground, Enemy, Ally', 'enemy: 2s silence + 40 damage/s inside the cross <br />\r\nally: 10% less damage + 25 HP/s', 6, ''),
(416, 21, 'Holy Cross', '', 'Active', 'Area', 'R', 2, '7.5 seconds', '200', '85 seconds', '600', '425', 'Air, Ground, Enemy, Ally', 'enemy: 2s silence + 60 damage/s inside the cross <br />\r\nally: 20% less damage + 50 HP/s', 12, ''),
(417, 21, 'Holy Cross', '', 'Active', 'Area', 'R', 3, '7.5 seconds', '200', '80 seconds', '600', '525', 'Air, Ground, Enemy, Ally', 'enemy: 2s silence + 80 damage/s inside the cross <br />\r\nally: 30% less damage + 75 HP/s', 18, ''),
(420, 22, 'Surf', 'The Giant Turtle summons a mighty wave behind him, flowing in the target direction. Once the wave reaches the Turtle''s position, he will surf on it to the impact area dealing damage to enemies in there. Units on the way are slighty pushed back and receive a small amount of damage.', 'Active', 'Unit', 'Q', 1, 'N/A', '145', '17 seconds', '700', '275', 'Air, Ground, Enemy', '35 pushback damage <br /> 80 wave end damage', 1, ''),
(421, 22, 'Surf', '', 'Active', 'Unit', 'Q', 2, 'N/A', '145', '17 seconds', '800', '275', 'Air, Ground, Enemy', '55 pushback damage <br /> 120 wave end damage', 3, ''),
(422, 22, 'Surf', '', 'Active', 'Unit', 'Q', 3, 'N/A', '145', '17 seconds', '900', '275', 'Air, Ground, Enemy', '75 pushback damage <br /> 160 wave end damage', 5, ''),
(423, 22, 'Surf', '', 'Active', 'Unit', 'Q', 4, 'N/A', '145', '17 seconds', '1000', '275', 'Air, Ground, Enemy', '95 pushback damage <br /> 200 wave end damage', 7, ''),
(424, 22, 'Surf', '', 'Active', 'Unit', 'Q', 5, 'N/A', '145', '17 seconds', '1100', '275', 'Air, Ground, Enemy', '115 pushback damage <br /> 240 wave end damage', 9, ''),
(425, 22, 'Aqua Shield', 'The Giant Turtle summons a magic shield of water around the target unit, protecting it against physical damage. The shield increases the armor of the target and explodes after 10 seconds, dealing damage to enemies in an area around the target. The shield can be destroyed manually if it is cast on self.', 'Active', 'Unit', 'W', 1, '10 seconds', '90', '16 seconds', '550', 'N/A', 'Air, Ground, Ally', '+3 Armor <br /> 75 damage after expiring', 1, ''),
(426, 22, 'Aqua Shield', '', 'Active', 'Unit', 'W', 2, '10 seconds', '100', '16 seconds', '550', 'N/A', 'Air, Ground, Ally', '+5 Armor <br /> 125 damage after expiring', 3, ''),
(427, 22, 'Aqua Shield', '', 'Active', 'Unit', 'W', 3, '10 seconds', '110', '16 seconds', '550', 'N/A', 'Air, Ground, Ally', '+7 Armor <br /> 175 damage after expiring', 5, ''),
(428, 22, 'Aqua Shield', '', 'Active', 'Unit', 'W', 4, '10 seconds', '120', '16 seconds', '550', 'N/A', 'Air, Ground, Ally', '+9 Armor <br /> 225 damage after expiring', 7, ''),
(429, 22, 'Aqua Shield', '', 'Active', 'Unit', 'W', 5, '10 seconds', '130', '16 seconds', '550', 'N/A', 'Air, Ground, Ally', '+11 Armor <br /> 275 damage after expiring', 9, ''),
(430, 22, 'Scaled Shell', 'The Turtle''s shell is full of scales, reducing the damage of attacks from behind and reflects some part of that damage back to the attacker.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', '20% damage reflection <br /> 25% damage reduction', 1, ''),
(431, 22, 'Scaled Shell', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', '27.5% damage reflection <br /> 35% damage reduction', 3, ''),
(432, 22, 'Scaled Shell', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', '35% damage reflection <br /> 45% damage reduction', 5, ''),
(433, 22, 'Scaled Shell', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', '42.5% damage reflection <br /> 55% damage reduction', 7, ''),
(434, 22, 'Scaled Shell', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Ground, Enemy', '50% damage reflection <br /> 65% damage reduction', 9, ''),
(435, 22, 'Fountain Blast', 'The Giant Turtle summons magical water projectiles, flying around him. After 10 seconds, the projectiles start to grow and withdraw and then splash down over 1.75 seconds, exploding on impact, which results in mighty water explosions, that throw enemies in 200 range in the air, dealing damage and slow them after falling back on the ground for 5 seconds. The projectiles can also be fired at a target area, causing them to explode on impact.', 'Active', 'Area', 'R', 1, '10 seconds', '200', '85 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', '125 explosion damage', 6, ''),
(436, 22, 'Fountain Blast', '', 'Active', 'Area', 'R', 2, '10 seconds', '250', '85 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', '200 explosion damage', 12, ''),
(437, 22, 'Fountain Blast', '', 'Active', 'Area', 'R', 3, '10 seconds', '300', '85 seconds', 'N/A', 'N/A', 'Air, Ground, Enemy', '275 explosion damage', 18, ''),
(440, 23, 'Hack''n Slash', 'The Fire Panda starts multiple attacks to random enemies, dealing damage to each. After returning to the start point, his attackspeed is increased.', 'Active', 'Unit', 'Q', 1, 'N/A', '140', '20 seconds', '325', 'N/A', 'Air, Ground, Enemy', '50 damage to max. 3 random units <br /> 20% attackspeed for 5s', 1, ''),
(441, 23, 'Hack''n Slash', '', 'Active', 'Unit', 'Q', 2, 'N/A', '140', '20 seconds', '325', 'N/A', 'Air, Ground, Enemy', '80 damage to max. 4 random units <br /> 30% attackspeed for 6s', 3, ''),
(442, 23, 'Hack''n Slash', '', 'Active', 'Unit', 'Q', 3, 'N/A', '140', '20 seconds', '325', 'N/A', 'Air, Ground, Enemy', '110 damage to max. 5 random units <br /> 40% attackspeed for 7s', 5, ''),
(443, 23, 'Hack''n Slash', '', 'Active', 'Unit', 'Q', 4, 'N/A', '140', '20 seconds', '325', 'N/A', 'Air, Ground, Enemy', '140 damage to max. 6 random units <br /> 50% attackspeed for 8s', 7, ''),
(444, 23, 'Hack''n Slash', '', 'Active', 'Unit', 'Q', 5, 'N/A', '140', '20 seconds', '325', 'N/A', 'Air, Ground, Enemy', '170 damage to max. 7 random units <br /> 60% attackspeed for 9s', 9, ''),
(445, 23, 'High Jump', 'The Fire Panda quickly jumps in the air moving to the target area, dealing damage to enemies he lands on and stuns them.', 'Active', 'Area', 'W', 1, 'N/A', '120', '15 seconds', '550', '300', 'Ground, Enemy', '60 damage <br /> 1s stun', 1, ''),
(446, 23, 'High Jump', '', 'Active', 'Area', 'W', 2, 'N/A', '130', '15 seconds', '550', '300', 'Ground, Enemy', '110 damage <br /> 1s stun', 3, ''),
(447, 23, 'High Jump', '', 'Active', 'Area', 'W', 3, 'N/A', '140', '15 seconds', '550', '300', 'Ground, Enemy', '160 damage <br /> 1s stun', 5, ''),
(448, 23, 'High Jump', '', 'Active', 'Area', 'W', 4, 'N/A', '150', '15 seconds', '550', '300', 'Ground, Enemy', '210 damage <br /> 1s stun', 7, ''),
(449, 23, 'High Jump', '', 'Active', 'Area', 'W', 5, 'N/A', '160', '15 seconds', '550', '300', 'Ground, Enemy', '260 damage <br /> 1s stun', 9, ''),
(450, 23, 'Bladethrow', 'The Fire Panda throws his blades in the target direction, damaging all enemies they hit. Each blade can only hit an enemy once.', 'Active', 'Unit/Point', 'E', 1, 'N/A', '130', '15 seconds', '900', 'N/A', 'Air, Ground, Enemy', '70 damage', 1, ''),
(451, 23, 'Bladethrow', '', 'Active', 'Unit/Point', 'E', 2, 'N/A', '130', '15 seconds', '900', 'N/A', 'Air, Ground, Enemy', '90 damage', 3, ''),
(452, 23, 'Bladethrow', '', 'Active', 'Unit/Point', 'E', 3, 'N/A', '130', '15 seconds', '900', 'N/A', 'Air, Ground, Enemy', '110 damage', 5, ''),
(453, 23, 'Bladethrow', '', 'Active', 'Unit/Point', 'E', 4, 'N/A', '130', '15 seconds', '900', 'N/A', 'Air, Ground, Enemy', '130 damage', 7, ''),
(454, 23, 'Bladethrow', '', 'Active', 'Unit/Point', 'E', 5, 'N/A', '130', '15 seconds', '900', 'N/A', 'Air, Ground, Enemy', '150 damage', 9, ''),
(455, 23, 'Art of Fire', 'The Fire Panda enhances his weapons with fire and increases the effectiveness of his abilities. Each enemy he attacks, hits with Hack''n Slash or with Bladethrow, will be ignited, dealing damage over time for 3 seconds. High Jump will now also create a mighty fire nova on impact, dealing additional damage and knocks enemies away from the Fire Panda.', 'Passive', '', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'increases the effectiveness of his abilities', 6, ''),
(456, 23, 'Art of Fire', '', 'Passive', '', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'increases the effectiveness of his abilities', 12, ''),
(457, 23, 'Art of Fire', '', 'Passive', '', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', 'increases the effectiveness of his abilities', 18, ''),
(459, 24, 'Axe Throw', 'The Ogre Warrior throws his mighty axe at a target enemy, damaging and stunning anyone near where it lands.', 'Active', 'Unit / Area', 'Q', 1, 'N/A', '85', '12 seconds', '600', '300', 'Air, Ground, Enemy', '110 damage <br /> 2s stun', 1, ''),
(460, 24, 'Axe Throw', '', 'Active', 'Unit / Area', 'Q', 2, 'N/A', '95', '12 seconds', '600', '300', 'Air, Ground, Enemy', '220 damage <br /> 2s stun', 3, ''),
(461, 24, 'Axe Throw', '', 'Active', 'Unit / Area', 'Q', 3, 'N/A', '105', '12 seconds', '600', '300', 'Air, Ground, Enemy', '330 damage <br /> 2s stun', 5, ''),
(462, 24, 'Axe Throw', '', 'Active', 'Unit / Area', 'Q', 4, 'N/A', '115', '12 seconds', '600', '300', 'Air, Ground, Enemy', '440 damage <br /> 2s stun', 7, ''),
(463, 24, 'Axe Throw', '', 'Active', 'Unit / Area', 'Q', 5, 'N/A', '125', '12 seconds', '600', '300', 'Air, Ground, Enemy', '550 damage <br /> 2s stun', 9, ''),
(464, 24, 'Decapitate', 'The Ogre performs a mighty attack with his Battle Axe, attempting to decapitate a target enemy. If the target is low on Health, this attack will instantly kill the target. There''s a 50% chance to kill the target if it''s a hero.', 'Active', 'Unit', 'W', 1, 'N/A', '100', '12 seconds', '150', 'N/A', 'Ground, Enemy', 'instantly kills target if they are below 200 Health. otherwise deals 150 damage to target unit', 1, ''),
(465, 24, 'Decapitate', '', 'Active', 'Unit', 'W', 2, 'N/A', '115', '12 seconds', '150', 'N/A', 'Ground, Enemy', 'instantly kills target if they are below 300 Health. Otherwise deals 200 damage to target unit', 3, ''),
(466, 24, 'Decapitate', '', 'Active', 'Unit', 'W', 3, 'N/A', '130', '12 seconds', '150', 'N/A', 'Ground, Enemy', 'instantly kills target if they are below 400 Health. Otherwise deals 250 damage to target unit', 5, ''),
(467, 24, 'Decapitate', '', 'Active', 'Unit', 'W', 4, 'N/A', '145', '12 seconds', '150', 'N/A', 'Ground, Enemy', 'instantly kills target if they are below 500 Health. Otherwise deals 300 damage to target unit', 7, ''),
(468, 24, 'Decapitate', '', 'Active', 'Unit', 'W', 5, 'N/A', '160', '12 seconds', '150', 'N/A', 'Ground, Enemy', 'instantly kills target if they are below 600 Health. Otherwise deals 350 damage to target unit', 9, ''),
(469, 24, 'Mighty Swing', 'The Ogre Warrior attacks with great might, causing his attacks to damage nearby enemies in addition to his main target. The further the enemy is away from the Ogre the less damage it takes.', 'Passive', 'Unit / Area', '', 1, 'N/A', 'None', 'N/A', 'N/A', '150-250', 'Ground, Enemy', 'applies max. 15% splash damage in a radius of 150-250', 1, ''),
(470, 24, 'Mighty Swing', '', 'Passive', 'Unit / Area', '', 2, 'N/A', 'None', 'N/A', 'N/A', '150-250', 'Ground, Enemy', 'applies max. 30% splash damage in a radius of 150-250', 3, ''),
(471, 24, 'Mighty Swing', '', 'Passive', 'Unit / Area', '', 3, 'N/A', 'None', 'N/A', 'N/A', '150-250', 'Ground, Enemy', 'applies max. 45% splash damage in a radius of 150-250', 5, ''),
(472, 24, 'Mighty Swing', '', 'Passive', 'Unit / Area', '', 4, 'N/A', 'None', 'N/A', 'N/A', '150-250', 'Ground, Enemy', 'applies max. 60% splash damage in a radius of 150-250', 7, ''),
(473, 24, 'Mighty Swing', '', 'Passive', 'Unit / Area', '', 5, 'N/A', 'None', 'N/A', 'N/A', '150-250', 'Ground, Enemy', 'applies max. 75% splash damage in a radius of 150-250', 9, ''),
(474, 24, 'Consumption', 'The Ogre Warrior concentrates his power to consume the complete damage to regain his life. After a short period of time he releases the total consumed power for a last final attack.', 'Active', 'Unit', 'R', 1, '10 seconds', '200', '120 seconds', 'N/A', 'N/A', 'Self', 'consume incoming damage', 6, ''),
(475, 24, 'Consumption', '', 'Active', 'Unit', 'R', 2, '12 seconds', '300', '120 seconds', 'N/A', 'N/A', 'Self', 'consume incoming damage', 12, ''),
(476, 24, 'Consumption', '', 'Active', 'Unit', 'R', 3, '14 seconds', '400', '120 seconds', 'N/A', 'N/A', 'Self', 'consume incoming damage', 18, ''),
(477, 25, 'Lightning Balls', 'The Farseer fires a lightning ball into the sky which explodes and scatters at the center of the point target, showering the target area and deals damage to nearby enemy units.', 'Active', 'Area', 'Q', 1, 'N/A', '120', '20 seconds', '650', '275', 'Air, Ground, Enemy', '4 lightning balls <br /> 25 damage per ball', 1, ''),
(478, 25, 'Lightning Balls', '', 'Active', 'Area', 'Q', 2, 'N/A', '140', '20 seconds', '650', '300', 'Air, Ground, Enemy', '6 lightning balls <br /> 25 damage per ball', 3, ''),
(479, 25, 'Lightning Balls', '', 'Active', 'Area', 'Q', 3, 'N/A', '160', '20 seconds', '650', '325', 'Air, Ground, Enemy', '8 lightning balls <br /> 25 damage per ball', 5, ''),
(480, 25, 'Lightning Balls', '', 'Active', 'Area', 'Q', 4, 'N/A', '180', '20 seconds', '650', '350', 'Air, Ground, Enemy', '10 lightning balls <br /> 25 damage per ball', 7, ''),
(481, 25, 'Lightning Balls', '', 'Active', 'Area', 'Q', 5, 'N/A', '200', '20 seconds', '650', '375', 'Air, Ground, Enemy', '12 lightning balls <br /> 25 damage per ball', 9, ''),
(482, 25, 'Volty Crush', 'The Farseer casts a magical curse at the target unit which causes a powerful explosion after 2s/2.5s/3s/3.5s/4s and damaging nearby enemy units.', 'Active', 'Unit', 'W', 1, '2 seconds', '100', '10 seconds', '650', '250', 'Air, Ground, Enemy', '5 damage/s <br /> 75 target damage <br /> 40 AoE damage', 1, ''),
(483, 25, 'Volty Crush', '', 'Active', 'Unit', 'W', 2, '2.5 seconds', '100', '10 seconds', '650', '250', 'Air, Ground, Enemy', '10 damage/s <br />\r\n125 target damage <br />\r\n80 AoE damage', 3, ''),
(484, 25, 'Volty Crush', '', 'Active', 'Unit', 'W', 3, '3 seconds', '100', '10 seconds', '650', '250', 'Air, Ground, Enemy', '15 damage/s <br />\r\n175 target damage <br />\r\n120 AoE damage', 5, ''),
(485, 25, 'Volty Crush', '', 'Active', 'Unit', 'W', 4, '3.5 seconds', '100', '10 seconds', '650', '250', 'Air, Ground, Enemy', '20 damage/s <br />\r\n225 target damage <br />\r\n160 AoE damage', 7, ''),
(486, 25, 'Volty Crush', '', 'Active', 'Unit', 'W', 5, '4 seconds', '100', '10 seconds', '650', '250', 'Air, Ground, Enemy', '25 damage/s <br />\r\n275 target damage <br />\r\n200 AoE damage', 9, ''),
(487, 25, 'Reflective Shield', 'The Farseer creates an invisible shield of energy around himself, the shield has a chance to instantly reflect attacks against him.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '10% chance to reflect an attack', 1, ''),
(488, 25, 'Reflective Shield', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '14% chance to reflect an attack', 3, ''),
(489, 25, 'Reflective Shield', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '18% chance to reflect an attack', 5, ''),
(490, 25, 'Reflective Shield', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '22% chance to reflect an attack', 7, ''),
(491, 25, 'Reflective Shield', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '26% chance to reflect an attack', 9, ''),
(492, 25, 'Spirit Arrows', 'The Farseer sends out arrows of his spirit homing towards a target location and dealing damage enemy units on collision.The Arrows last for up to 7 seconds and will fly around near the target location until death.', 'Active', 'Point', 'R', 1, '7 seconds', '150', '135 seconds', '950', 'N/A', 'Air, Ground, Enemy', '100 damage per missile <br /> 8 missiles', 6, ''),
(493, 25, 'Spirit Arrows', '', 'Active', 'Point', 'R', 2, '7 seconds', '200', '135 seconds', '950', 'N/A', 'Air, Ground, Enemy', '100 damage per missile <br />\r\n11 missiles', 12, ''),
(494, 25, 'Spirit Arrows', '', 'Active', 'Point', 'R', 3, '7 seconds', '250', '135 seconds', '950', 'N/A', 'Air, Ground, Enemy', '100 damage per missile <br />\r\n14 missiles', 18, ''),
(495, 26, 'Crag', 'The Mountain Giant creates rocks which comes out of the earth in a line, knocking back every unit they hit, damaging enemies and be a barricade to block units for 5 seconds.', 'Active', 'Area', 'Q', 1, '5 seconds', '110', '23 seconds', '850', 'N/A', 'Ground, Enemy', '60 damage per hit <br /> knock back', 1, ''),
(496, 26, 'Crag', '', 'Active', 'Area', 'Q', 2, '5 seconds', '120', '22 seconds', '850', 'N/A', 'Ground, Enemy', '120 damage per hit <br />\r\nknock back', 3, ''),
(497, 26, 'Crag', '', 'Active', 'Area', 'Q', 3, '5 seconds', '140', '21 seconds', '850', 'N/A', 'Ground, Enemy', '180 damage per hit <br />\r\nknock back', 5, ''),
(498, 26, 'Crag', '', 'Active', 'Area', 'Q', 4, '5 seconds', '140', '20 seconds', '850', 'N/A', 'Ground, Enemy', '240 damage per hit <br />\r\nknock back', 7, ''),
(499, 26, 'Crag', '', 'Active', 'Area', 'Q', 5, '5 seconds', '150', '19 seconds', '850', 'N/A', 'Ground, Enemy', '300 damage per hit <br />\r\nknock back', 9, ''),
(500, 26, 'Hurl Boulder', 'The Mountain Giant throws a boulder in the target area, causing damage and stunning the target for 2 seconds.', 'Active', 'Area', 'W', 1, 'N/A', '70', '10 seconds', '700', 'N/A', 'Air, Ground, Enemy', '100 damage <br /> 2s stun', 1, ''),
(501, 26, 'Hurl Boulder', '', 'Active', 'Unit', 'W', 2, 'N/A', '80', '10 seconds', '700', 'N/A', 'Air, Ground, Enemy', '200 damage <br />\r\n2s stun', 3, ''),
(502, 26, 'Hurl Boulder', '', 'Active', 'Unit', 'W', 3, 'N/A', '90', '10 seconds', '700', 'N/A', 'Air, Ground, Enemy', '300 damage <br />\r\n2s stun', 5, ''),
(503, 26, 'Hurl Boulder', '', 'Active', 'Unit', 'W', 4, 'N/A', '100', '10 seconds', '700', 'N/A', 'Air, Ground, Enemy', '400 damage <br />\r\n2s stun', 7, ''),
(504, 26, 'Hurl Boulder', '', 'Active', 'Unit', 'W', 5, 'N/A', '110', '10 seconds', '700', 'N/A', 'Air, Ground, Enemy', '500 damage <br />\r\n2s stun', 9, ''),
(505, 26, 'Craggy Exterior', 'The skin of the Mountain Giant reduces all physical and magical damage.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '-10% physical damage <br /> -5% magic damage', 1, ''),
(506, 26, 'Craggy Exterior', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '-15% physical damage <br />\r\n-10% magic damage', 3, ''),
(507, 26, 'Craggy Exterior', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '-20% physical damage <br />\r\n-15% magic damage', 5, ''),
(508, 26, 'Craggy Exterior', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '-25% physical damage <br />\r\n-20% magic damage', 7, ''),
(509, 26, 'Craggy Exterior', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', 'N/A', 'Self', '-30% physical damage <br />\r\n-25% magic damage', 9, ''),
(510, 26, 'Endurance', 'The Mountain Giant uses his mental power to get stronger and stronger by every hit he take. This newly gained strength fails after a short time.', 'Active', 'Unit', 'R', 1, '25 seconds', '150', '90 seconds', 'N/A', 'N/A', 'Self', 'get stronger for a short time', 6, ''),
(511, 26, 'Endurance', '', 'Active', 'Unit', 'R', 2, '20 seconds', '150', '100 seconds', 'N/A', 'N/A', 'Self', 'get stronger for a short time', 12, ''),
(512, 26, 'Endurance', '', 'Active', 'Unit', 'R', 3, '15 seconds', '150', '110 seconds', 'N/A', 'N/A', 'Self', 'get stronger for a short time', 18, ''),
(513, 27, 'Natural Sphere', 'Cenarius summons a natural sphere flying in the target direction, dealing damage to enemies it passes through. Whenever the sphere hits an enemy, there is a chance of 20%, that the target gets entangled for a short time, which disables the target. If the target isn''t rooted, its movement speed is decreased by 30% for 5 seconds.', 'Active', 'Point', 'Q', 1, 'N/A', '90', '11 seconds', '550', 'N/A', 'Ground, Enemy', '50 damage <br />  20% entangle chance ( 1.5s ) <br /> 30% decreased ms for 5s', 1, ''),
(514, 27, 'Natural Sphere', '', 'Active', 'Point', 'Q', 2, 'N/A', '100', '11 seconds', '700', 'N/A', 'Ground, Enemy', '100 damage <br /> \r\n20% entangle chance ( 2.0s ) <br />\r\n30% decreased ms for 5s', 3, ''),
(515, 27, 'Natural Sphere', '', 'Active', 'Point', 'Q', 3, 'N/A', '110', '11 seconds', '850', 'N/A', 'Ground, Enemy', '150 damage <br /> \r\n20% entangle chance ( 2.5s ) <br />\r\n30% decreased ms for 5s', 5, ''),
(516, 27, 'Natural Sphere', '', 'Active', 'Point', 'Q', 4, 'N/A', '120', '11 seconds', '1000', 'N/A', 'Ground, Enemy', '200 damage <br /> \r\n20% entangle chance ( 3.0s ) <br />\r\n30% decreased ms for 5s', 7, ''),
(517, 27, 'Natural Sphere', '', 'Active', 'Point', 'Q', 5, 'N/A', '130', '11 seconds', '1150', 'N/A', 'Ground, Enemy', '250 damage <br /> \r\n20% entangle chance ( 3.5s ) <br />\r\n30% decreased ms for 5s', 9, ''),
(518, 27, 'Magic Seed', 'Cenarius throws a magic seed at the target unit, dealing damage. If the target is entangled, the target will receive additional damage and creates an explosion that damages other enemies around it.', 'Active', 'Unit', 'W', 1, 'N/A', '80', '9 seconds', '600', 'N/A', 'Ground, Enemy', '75 damage <br />  25 entangled damage <br /> 50 seed area damage', 1, ''),
(519, 27, 'Magic Seed', '', 'Active', 'Unit', 'W', 2, 'N/A', '85', '8.5 seconds', '600', 'N/A', 'Ground, Enemy', '125 damage <br /> \r\n50 entangled damage <br />\r\n75 seed area damage', 3, ''),
(520, 27, 'Magic Seed', '', 'Active', 'Unit', 'W', 3, 'N/A', '90', '8 seconds', '600', 'N/A', 'Ground, Enemy', '175 damage <br /> \r\n75 entangled damage <br />\r\n100 seed area damage', 5, ''),
(521, 27, 'Magic Seed', '', 'Active', 'Unit', 'W', 4, 'N/A', '95', '7.5 seconds', '600', 'N/A', 'Ground, Enemy', '225 damage <br /> \r\n100 entangled damage <br />\r\n125 seed area damage', 7, ''),
(522, 27, 'Magic Seed', '', 'Active', 'Unit', 'W', 5, 'N/A', '100', '7 seconds', '600', 'N/A', 'Ground, Enemy', '275 damage <br /> \r\n125 entangled damage <br />\r\n150 seed area damage', 9, ''),
(523, 27, 'Pollen Aura', 'Cenarius summons deathly pollen around his body, slowing enemies attack speed and movement speed in 700 range. The pollen also reduce the life regeneration of enemies depending on how close they are to Cenarius. The pollen can also negate the life regeneration of enemies causing them to lose life over time. However, these pollen cannot kill any units.', 'Passive', 'Unit', '', 1, 'N/A', 'None', 'N/A', 'N/A', '700', 'Air, Ground, Enemy', '-10% Attack Speed <br />  -10% Movementspeed <br /> max 8 Life Degeneration', 1, ''),
(524, 27, 'Pollen Aura', '', 'Passive', 'Unit', '', 2, 'N/A', 'None', 'N/A', 'N/A', '700', 'Air, Ground, Enemy', '-15% Attack Speed <br /> \r\n-15% Movementspeed <br />\r\nmax 16 Life Degeneration', 3, ''),
(525, 27, 'Pollen Aura', '', 'Passive', 'Unit', '', 3, 'N/A', 'None', 'N/A', 'N/A', '700', 'Air, Ground, Enemy', '-20% Attack Speed <br /> \r\n-20% Movementspeed <br />\r\nmax 24 Life Degeneration', 5, ''),
(526, 27, 'Pollen Aura', '', 'Passive', 'Unit', '', 4, 'N/A', 'None', 'N/A', 'N/A', '700', 'Air, Ground, Enemy', '-25% Attack Speed <br /> \r\n-25% Movementspeed <br />\r\nmax 32 Life Degeneration', 7, ''),
(527, 27, 'Pollen Aura', '', 'Passive', 'Unit', '', 5, 'N/A', 'None', 'N/A', 'N/A', '700', 'Air, Ground, Enemy', '-30% Attack Speed <br /> \r\n-30% Movementspeed <br />\r\nmax 40 Life Degeneration', 9, '');
INSERT INTO `spells` (`ID`, `hero_ID`, `name`, `description`, `ability_type`, `targeting_type`, `ability_hotkey`, `level`, `duration`, `mana_cost`, `cooldown`, `range`, `aoe`, `targets`, `effects`, `required_level`, `note`) VALUES
(528, 27, 'Leaf Storm', 'Cenarius starts to channel and creates a Leaf Storm moving from her in the target direction. The storm deals damage to every enemy that is trapped inside of it and slowly drags them in the target direction.', 'Active', 'Area', 'R', 1, '4 seconds', '250', '115 seconds', '450', '500', 'Air, Ground, Enemy', '100 damage/s', 6, ''),
(529, 27, 'Leaf Storm', '', 'Active', 'Area', 'R', 2, '5 seconds', '350', '145 seconds', '550', '600', 'Air, Ground, Enemy', '150 damage/s', 12, ''),
(530, 27, 'Leaf Storm', '', 'Active', 'Area', 'R', 3, '6 seconds', '450', '175 seconds', '650', '700', 'Air, Ground, Enemy', '200 damage/s', 18, '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `tower`
--

CREATE TABLE IF NOT EXISTS `tower` (
  `towerId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(511) NOT NULL,
  `type` enum('common','rare','unique') NOT NULL DEFAULT 'common',
  `level` tinyint(3) unsigned NOT NULL,
  `ordering` tinyint(3) unsigned DEFAULT NULL,
  `lumber` smallint(5) unsigned NOT NULL,
  `dps` decimal(10,2) unsigned NOT NULL,
  `damageMin` decimal(10,2) unsigned NOT NULL,
  `damageMax` decimal(10,2) unsigned NOT NULL,
  `cooldown` decimal(6,2) unsigned NOT NULL,
  `range` int(10) unsigned NOT NULL,
  `imagePath` varchar(127) NOT NULL,
  `iconPath` varchar(127) NOT NULL,
  `upgradeTo` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`towerId`),
  KEY `FK_tower_tower` (`upgradeTo`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=34 ;

--
-- Daten für Tabelle `tower`
--

INSERT INTO `tower` (`towerId`, `name`, `description`, `type`, `level`, `ordering`, `lumber`, `dps`, `damageMin`, `damageMax`, `cooldown`, `range`, `imagePath`, `iconPath`, `upgradeTo`) VALUES
(1, 'Shady Spire', 'The Shady Spire is a basic tower that deals mild damage to enemy units. Cheap and effective against low level creeps. It can be upgraded to the Dark Spire for more damage.', 'common', 1, 1, 45, 49.00, 56.00, 77.00, 1.10, 825, 'shady-spire.jpg', 'icon0.png', 2),
(2, 'Dark Spire', 'The Dark Spire is an upgrade to the Shady Spire. It deals mild damage. Cheap and effective against low level creeps.  Can be upgraded to the Black Spire for more damage.', 'common', 2, NULL, 45, 62.00, 69.00, 90.00, 1.10, 825, 'dark-spire.jpg', '', 3),
(3, 'Black Spire', 'The Black Spire is an upgrade to the Dark Spire. It deals mild damage. Cheap and effective against low level creeps. It can''t be upgraded.', 'common', 3, NULL, 70, 77.00, 84.00, 105.00, 1.10, 825, 'black-spire.jpg', '', NULL),
(4, 'Cold Obelisk', 'The Cold Obelisk is a common tower that slows it''s targets for a short duration. It can be upgraded to the Frosty Obelisk for greater damage and slow effect.', 'common', 1, 2, 95, 47.00, 52.00, 57.00, 1.50, 700, 'cold-obelisk.jpg', '', 5),
(5, 'Frosty Obelisk', 'The Frosty Obelisk is upgraded from the Cold Obelisk, with improved stats. It can be upgraded to the Glacial Obelisk for greater damage and slow effect.', 'common', 2, NULL, 119, 54.00, 59.00, 64.00, 1.50, 700, 'frosty-obelisk.jpg', '', 6),
(6, 'Glacial Obelisk', 'The Glacial Obelisk is upgraded from the Frosty Obelisk, with improved stats. It can ''t be upgraded further.', 'common', 3, NULL, 148, 63.00, 68.00, 73.00, 1.50, 700, 'glacial-obelisk.jpg', '', NULL),
(7, 'Flaming Rock', 'The Flaming Rock is a basic tower with an Area of Effect attack. It gains bonus critical chance upon killing a creep. Effective against big groups of weak enemies. It can be upgraded to the Blazing Rock.', 'common', 1, 3, 115, 173.00, 178.00, 188.00, 1.60, 900, 'flaming-rock.jpg', '', 8),
(8, 'Blazing Rock', 'The Blazing Rock is upgraded from the Flaming Rock, with an improved Area of Effect attack and bonus critical chance. Effective against big groups of weak enemies. It can be upgraded to the Magma Core.', 'common', 2, NULL, 144, 222.00, 227.00, 237.00, 1.80, 900, 'blazing-rock.jpg', '', 9),
(9, 'Magma Core', 'The Magma Core is upgraded from the Blazing Rock, with greater Area of Effect attack and bonus critical chance. Effective against big groups of enemies. It can''t be upgraded.', 'common', 3, NULL, 180, 276.00, 281.00, 291.00, 2.00, 900, 'magma-core.jpg', '', NULL),
(10, 'Cursed Gravestone', 'The Cursed Gravestone is a common tower with a tiny chance to instantly kill a target regardless of it''s remaining health. It can be upgraded to the Cursed Tombstone.', 'common', 1, 4, 160, 216.00, 219.00, 258.00, 1.50, 1000, 'cursed-gravestone.jpg', '', 11),
(11, 'Cursed Tombstone', 'The Cursed Tombstone is an upgraded tower with a minimal chance to instantly kill a target regardless of it''s remaining health. It can be upgraded to the Cursed Memento.', 'common', 2, NULL, 200, 252.00, 255.00, 294.00, 1.45, 1000, 'cursed-tombstone.jpg', '', 12),
(12, 'Cursed Memento', 'The Cursed Memento is an upgraded tower with a small chance to instantly kill a target regardless of it''s remaining health. It can''t be upgraded.', 'common', 3, NULL, 250, 294.00, 297.00, 336.00, 1.40, 1000, 'cursed-memento.jpg', '', NULL),
(13, 'Decayed Earth Tower', 'The Decayed Earth Tower is a rare structure that deals flat, direct damage to single targets. It compensates it''s lack of an ability for low building costs. It can be Upgraded into the Plagued Earth Tower.', 'rare', 1, 1, 169, 277.00, 286.00, 304.00, 1.40, 800, 'decayed-earth-tower.jpg', '', 14),
(14, 'Plagued Earth Tower', 'The Plagued Earth Tower is a stronger version of the Decayed E. Tower. It can be Upgraded into the Plagued Earth Tower.', 'rare', 2, NULL, 211, 346.00, 355.00, 373.00, 1.40, 800, 'plagued-earth-tower.jpg', '', 15),
(15, 'Blighted Earth Tower', 'The Blighted Earth Tower is a stronger version of the Plagued E. Tower. It has decent damage and low costs. It can''t be upgraded.', 'rare', 3, NULL, 264, 433.00, 442.00, 460.00, 1.40, 800, 'blighted-earth-tower.jpg', '', NULL),
(16, 'Ice Frenzy', 'The Ice Frenzy is a rare tower with a slowing attack and chance to shortly stun it''s target. It deals a 100 spell damage upon stunning. Great against slow enemies. It can be upgraded to the Ice Fury.', 'rare', 1, 2, 356, 147.00, 152.00, 167.00, 1.50, 1100, 'ice-frenzy.jpg', '', 17),
(17, 'Ice Fury', 'The Ice Fury is upgraded from the Ice Frenzy. It deals slightly more damage and 200 spell damage upon stunning. Slowing effects are the same. It can be upgraded to the Icy Rage.', 'rare', 2, NULL, 445, 157.00, 162.00, 177.00, 1.40, 1100, 'ice-fury.jpg', '', 18),
(18, 'Icy Rage', 'The Icy Rage is upgraded from the Ice Fury. It deals slightly more damage and 300 spell damage upon stunning. Slowing effects are the same. It can''t be upgraded.', 'rare', 3, NULL, 557, 166.00, 171.00, 186.00, 1.30, 1100, 'ice-rage.jpg', '', NULL),
(19, 'Putrid Pot', 'The Putrid Pot has an AoE attack with a 30% chance of dealing spell damage over time and reducing the target''s health regeneration. It can be upgraded to the Putrid Vat.', 'rare', 1, 3, 431, 1070.00, 1073.00, 1103.00, 3.00, 900, 'putrid-pot.jpg', '', 20),
(20, 'Putrid Vat', 'The Putrid Vat upgrades from the Putrid Pot with increased dps and AoE and abilities. It can be upgraded to the Putrid Cauldron.', 'rare', 2, NULL, 539, 1174.00, 1177.00, 1207.00, 2.80, 900, 'putrid-vat.jpg', '', 21),
(21, 'Putrid Cauldron', 'The Putrid Cauldron upgrades from the Putrid Vat with increased dps and AoE and abilities. It can''t be upgraded.', 'rare', 3, NULL, 674, 1278.00, 1281.00, 1311.00, 2.60, 900, 'putrid-cauldron.jpg', '', NULL),
(22, 'Gloom Orb', 'The Gloom Orb is a rare tower. It has the ''Corpse Explosion'' ability which creates an AoE attack and slows units close to a nearby corpse. It can be upgraded to the Ruin Orb.', 'rare', 1, 4, 600, 1505.00, 1512.00, 1540.00, 2.40, 800, 'gloom-orb.jpg', '', 23),
(23, 'Ruin Orb', 'The Ruin Orb is upgraded from the Gloom Orb. ''Corpse Explsion'' has more damage and slow effect. It can be upgraded to the Doom Orb.', 'rare', 2, NULL, 750, 1084.00, 1091.00, 1119.00, 1.60, 800, 'ruin-orb.jpg', '', 24),
(24, 'Doom Orb', 'The Doom Orb is upgraded from the Ruin Orb. ''Corpse Explsion'' has more damage and slow effect. It can''t be upgraded.', 'rare', 3, NULL, 938, 550.00, 557.00, 585.00, 0.80, 800, 'doom-orb.jpg', '', NULL),
(25, 'Monolith of Hatred', 'The Monolith of Hatred is a unique tower. It deals a great amount of damage and has a 20% chance to critically hit a target. It upgrades into the Monolith of Terror.', 'unique', 1, 1, 591, 562.00, 575.00, 666.00, 0.80, 750, 'monolith-of-hatred.jpg', '', 26),
(26, 'Monolith of Terror', 'The Monolith of Terror is a unique tower upgraded from the Monolith of Hatred. It deals more damage and upgrades into the Monolith of Destruction.', 'unique', 2, NULL, 738, 702.00, 715.00, 806.00, 0.80, 750, 'monolith-of-terror.jpg', '', 27),
(27, 'Monolith of Destruction', 'The Monolith of Destruction is a unique tower upgraded from the Monolith of Terror. It deals even more damage. I can''t be upgraded.', 'unique', 3, NULL, 923, 878.00, 891.00, 982.00, 0.80, 750, 'monolith-of-destruction.jpg', '', NULL),
(28, 'Glacier of Sorrow', 'The Glacier of Sorrow is a unique and powerful tower. It''s basic attack has an AoE slow and it can shoot an Ice Shard that can split up more than once to deal a great amount of damage. It can be upgraded into the Glacier of Misery.', 'unique', 1, 2, 1247, 403.00, 407.00, 451.00, 2.00, 1200, 'glacier-of-sorrow.jpg', '', 29),
(29, 'Glacier of Misery', 'The Glacier of Misery is a unique tower. Upgraded from the Glacier of Sorrow. It''s slow and ''Ice Shard'' ability are greatly improved. It can be upgraded into the Glacier of Dispair.', 'unique', 2, NULL, 1559, 403.00, 407.00, 451.00, 2.00, 1200, 'glacier-of-misery.jpg', '', 30),
(30, 'Glacier of Despair', 'The Glacier of Despair is a unique tower. Upgraded from the Glacier of Misery. It''s slow and ''Ice Shard'' ability are greatly improved. It can''t be upgraded.', 'unique', 3, NULL, 1948, 378.00, 382.00, 426.00, 2.00, 1200, 'glacier-of-despair.jpg', '', NULL),
(31, 'Totem of Infamy', 'The Totem of Infamy is a unique all-round specialist tower. It has the ''Ultimate Fighter'' ability which adds a critical hit, bonus damage, a stun and a permanent attack increase every number of hits. It can be upgraded to the Totem of Malice.', 'unique', 1, 3, 1509, 401.00, 408.00, 436.00, 0.50, 800, 'totem-of-infamy.jpg', '', 32),
(32, 'Totem of Malice', 'The Totem of Malice is a unique all-round specialist tower. It''s ''Ultimate Fighter'' ability has increased effects. It can be upgraded to the Totem of Corruption.', 'unique', 2, NULL, 1887, 501.00, 508.00, 536.00, 0.50, 800, 'totem-of-malice.jpg', '', 33),
(33, 'Totem of Corruption', 'The Totem of Corruption is a unique all-round specialist tower. It''s ''Ultimate Fighter'' ability has greatly increased effects. It can''t be upgraded.', 'unique', 3, NULL, 2358, 626.00, 633.00, 661.00, 0.50, 800, 'totem-of-corruption.jpg', '', NULL);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `towerSpells`
--

CREATE TABLE IF NOT EXISTS `towerSpells` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(55) NOT NULL,
  `level` tinyint(3) unsigned NOT NULL,
  `icon` varchar(127) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=31 ;

--
-- Daten für Tabelle `towerSpells`
--

INSERT INTO `towerSpells` (`id`, `name`, `level`, `icon`, `description`) VALUES
(1, 'Zero Point', 1, 'zero-point.jpg', 'The tower will slow the attacked creeps by 30% for 4 seconds.'),
(2, 'Zero Point', 2, 'zero-point.jpg', 'The tower will slow the attacked creeps by 40% for 4 seconds.'),
(3, 'Zero Point', 3, 'zero-point.jpg', 'The tower will slow the attacked creeps by 50% for 4 seconds.'),
(4, 'Hot Coals', 1, 'hot-coals.jpg', 'Whenever this tower kills a creep it gains 30% bonus crit chance for 8.5 seconds.<br/>\r\n<br/>\r\n<b class="special">Specials</b>\r\n<span>Splash attack:</span><br/>\r\n<span>150 AoE: 25% damage</span>'),
(5, 'Hot Coals', 2, 'hot-coals.jpg', 'Whenever this tower kills a creep it gains 40% bonus crit chance for 8.5 seconds.<br/>\r\n<br/>\r\n<b class="special">Specials</b>\r\n<span>Splash attack:</span><br/>\r\n<span>160 AoE: 25% damage</span>'),
(6, 'Hot Coals', 3, 'hot-coals.jpg', 'Whenever this tower kills a creep it gains 50% bonus crit chance for 8.5 seconds.<br/>\r\n<br/>\r\n<b class="special">Specials</b>\r\n<span>Splash attack:</span><br/>\r\n<span>170 AoE: 25% damage</span>'),
(7, 'Tomb''s Curse', 1, 'tombs-curse.jpg', 'This tower has a 0.6% chance on attack to kill a target immediately.'),
(8, 'Tomb''s Curse', 2, 'tombs-curse.jpg', 'This tower has a 0.8% chance on attack to kill a target immediately.'),
(9, 'Tomb''s Curse', 3, 'tombs-curse.jpg', 'This tower has a 1.0% chance on attack to kill a target immediately.'),
(10, 'Cold Wrath', 1, 'cold-wrath.jpg', 'Attacks of this tower slow the attacked creep by 7% for 3 seconds. Each attack has a 2% chance to stun the target for 0.8 seconds and to deal 100 spelldamage to the target. The chance to stun the target will increase by 2% per attack and resets after a target is stunned.'),
(11, 'Cold Wrath', 2, 'cold-wrath.jpg', 'Attacks of this tower slow the attacked creep by 7% for 3 seconds. Each attack has a 2% chance to stun the target for 0.8 seconds and to deal 200 spelldamage to the target. The chance to stun the target will increase by 2% per attack and resets after a target is stunned.'),
(12, 'Cold Wrath', 3, 'cold-wrath.jpg', 'Attacks of this tower slow the attacked creep by 7% for 3 seconds. Each attack has a 2% chance to stun the target for 0.8 seconds and to deal 300 spelldamage to the target. The chance to stun the target will increase by 2% per attack and resets after a target is stunned.'),
(13, 'Ignite', 1, 'ignite.jpg', 'The tower has a 30% chance on damaging a creep to ignite the target, dealing 15% of the tower '' s attack damage as spell damage per second \r\nand reducing the target '' s health regeneration by 25% for 8 seconds.<br/>\r\n<br/>\r\n<b class="special">Specials</b>\r\n<span>Splash attack:</span><br/>\r\n<span>150 AoE: 30% damage</span>'),
(14, 'Ignite', 2, 'ignite.jpg', 'The tower has a 30% chance on damaging a creep to ignite the target, dealing 20% of the tower '' s attack damage as spell damage per second \r\nand reducing the target '' s health regeneration by 30% for 8 seconds.<br/>\r\n<br/>\r\n<b class="special">Specials</b>\r\n<span>Splash attack:</span><br/>\r\n<span>160 AoE: 30% damage</span>'),
(15, 'Ignite', 3, 'ignite.jpg', 'The tower has a 30% chance on damaging a creep to ignite the target, dealing 25% of the tower '' s attack damage as spell damage per second \r\nand reducing the target '' s health regeneration by 35% for 8 seconds.<br/>\r\n<br/>\r\n<b class="special">Specials</b>\r\n<span>Splash attack:</span><br/>\r\n<span>170 AoE: 30% damage</span>'),
(16, 'Corpse Explosion', 1, 'corpse-explosion.jpg', 'Explodes a corpse within 1000 range of the tower, causing enemies in 300 range of the corpse to take 8% more damage \r\nand move 8% slower for 8 seconds. 5 second cooldown. Doesn '' t affect Air.'),
(17, 'Corpse Explosion', 2, 'corpse-explosion.jpg', 'Explodes a corpse within 1000 range of the tower, causing enemies in 300 range of the corpse to take 11% more damage \r\nand move 11% slower for 8 seconds. 5 second cooldown. Doesn '' t affect Air.'),
(18, 'Corpse Explosion', 3, 'corpse-explosion.jpg', 'Explodes a corpse within 1000 range of the tower, causing enemies in 300 range of the corpse to take 13% more damage \r\nand move 13% slower for 8 seconds. 5 second cooldown. Doesn '' t affect Air.'),
(19, '', 1, '', '<b class="special">Specials</b>\r\n<span>20% critical strike ( 2x )</span>'),
(20, '', 2, '', '<b class="special">Specials</b>\r\n<span>20% critical strike ( 2x )</span>'),
(21, '', 3, '', '<b class="special">Specials</b>\r\n<span>20% critical strike ( 2x )</span>'),
(22, 'Ice Shard', 1, 'ice-shard.jpg', 'This tower fires an ice shard towards an enemy. After a distance of 300 the ice shard splits into 2 new shards which will split again. \r\nIf a shard collides with an enemy it deals 1150 spell damage. There is a maximum of 3 splits.'),
(23, 'Ice Shard', 2, 'ice-shard.jpg', 'This tower fires an ice shard towards an enemy. After a distance of 300 the ice shard splits into 2 new shards which will split again. \r\nIf a shard collides with an enemy it deals 1500 spell damage. There is a maximum of 4 splits.'),
(24, 'Ice Shard', 3, 'ice-shard.jpg', 'This tower fires an ice shard towards an enemy. After a distance of 300 the ice shard splits into 2 new shards which will split again. \r\nIf a shard collides with an enemy it deals 1850 spell damage. There is a maximum of 5 splits.'),
(25, 'Frost Attack', 1, 'frost-attack.jpg', 'Attacks of this tower slows enemy units by 15% in range of 250 around the target for 5s.'),
(26, 'Frost Attack', 2, 'frost-attack.jpg', 'Attacks of this tower slows enemy units by 30% in range of 250 around the target for 5s.'),
(27, 'Frost Attack', 3, 'frost-attack.jpg', 'Attacks of this tower slows enemy units by 45% in range of 250 around the target for 5s.'),
(28, 'Ultimate Fighter', 1, 'ultimate-fighter.jpg', 'The tower uses his great power to specialize his attacks:<br />\r\n- Every 3th attack is a critical hit<br />\r\n- Every 7th attack deals 1000 bonus spell damage<br />\r\n- Every 12th attack stuns the target for 1 second<br />\r\n- Every 15th attack adds 0.5% attack damage permanently<br />'),
(29, 'Ultimate Fighter', 2, 'ultimate-fighter.jpg', 'The tower uses his great power to specialize his attacks:<br />\r\n- Every 4th attack is a critical hit<br />\r\n- Every 8th attack deals 1500 bonus spell damage<br />\r\n- Every 13th attack stuns the target for 1.25 seconds<br />\r\n- Every 16th attack adds 0.5% attack damage permanently<br />'),
(30, 'Ultimate Fighter', 3, 'ultimate-fighter.jpg', 'The tower uses his great power to specialize his attacks:<br />\r\n- Every 5th attack is a critical hit<br />\r\n- Every 9th attack deals 2000 bonus spell damage<br />\r\n- Every 14th attack stuns the target for 1.5 seconds<br />\r\n- Every 17th attack adds 0.5% attack damage permanently<br />');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `tower_x_changelog`
--

CREATE TABLE IF NOT EXISTS `tower_x_changelog` (
  `towerId` int(10) unsigned NOT NULL,
  `version` varchar(31) NOT NULL,
  `changelog` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `tower_x_changelog`
--

INSERT INTO `tower_x_changelog` (`towerId`, `version`, `changelog`) VALUES
(4, '0.2.1', 'increased the slow effect from 20% to 30%'),
(5, '0.2.1', 'increased the slow effect from 30% to 40%'),
(6, '0.2.1', 'increased the slow effect from 40% to 50%'),
(13, '0.2.4', 'lumber from 158 to 169|\r\nDPS from 259 to 277|\r\nDamage from 268 - 286 to 286 - 304'),
(14, '0.2.4', 'lumber from 197 to 211|\r\nDPS from 323 to 346|\r\nDamage from 332 - 350 to 355 - 373'),
(15, '0.2.4', 'lumber from 246 to 264|\r\nDPS from 404 to 433|\r\nDamage from 413 - 431 to 442 - 460'),
(16, '0.2.4', 'lumber from 333 to 356|\r\nDPS from 137 to 147|\r\nDamage from 142 - 157 to 152 - 167'),
(17, '0.2.4', 'lumber from 416 to 445|\r\nDPS from 147 to 157|\r\nDamage from 152 - 167 to 162 - 177'),
(18, '0.2.4', 'lumber from 520 to 557|\r\nDPS from 155 to 166|\r\nDamage from 160 - 175 to 171 - 186'),
(19, '0.2.4', 'lumber from 403 to 431|\r\nDPS from 999 to 1070|\r\nDamage from 1002 - 1032 to 1073 - 1103'),
(20, '0.2.4', 'lumber from 503 to 539|\r\nDPS from 1096 to 1174|\r\nDamage from 1099 - 1129 to 1177 - 1207'),
(21, '0.2.4', 'lumber from 629 to 674|\r\nDPS from 1193 to 1278|\r\nDamage from 1196 - 1226 to 1281 - 1311'),
(22, '0.2.4', 'lumber from 560 to 600|\r\nDPS from 1404 to 1505|\r\nDamage from 1411 - 1439 to 1512 - 1540'),
(23, '0.2.4', 'lumber from 700 to 750|\r\nDPS from 1012 to 1084|\r\nDamage from 1019 - 1047 to 1091 - 1119'),
(24, '0.2.4', 'lumber from 875 to 938|\r\nDPS from 514 to 550|\r\nDamage from 521 - 549 to 557 - 585'),
(25, '0.2.4', 'lumber from 1103 to 591|\r\nDPS from 1049 to 562|\r\nDamage from 1062 - 1153 to 575 - 666'),
(26, '0.2.4', 'lumber from 1378 to 738|\r\nDPS from 1311 to 702|\r\nDamage from 1324 - 1415 to 715 - 806'),
(27, '0.2.4', 'lumber from 1723 to 923|\r\nDPS from 1638 to 878|\r\nDamage from 1651 - 1742 to 891 - 982'),
(28, '0.2.4', 'lumber from 2328 to 1247|\r\nDPS from 3456 to 403|\r\nDamage from 3460 - 3504 to 407 - 451|\r\nCD from 4.0 to 2.0'),
(29, '0.2.4', 'lumber from 2909 to 1559|\r\nDPS from 3312 to 403|\r\nDamage from 3316 - 3360 to 407 - 451|\r\nCD from 4.0 to 2.0'),
(30, '0.2.4', 'lumber from 3637 to 1948|\r\nDPS from 2880 to 378|\r\nDamage from 2884 - 2928 to 382 - 426|\r\nCD from 4.0 to 2.0'),
(31, '0.2.4', 'lumber from 2818 to 1509|\r\nDPS from 659 to 401|\r\nDamage from 666 - 694 to 408 - 436|\r\nCD from 1.75 to 0.5'),
(32, '0.2.4', 'lumber from 3522 to 1887|\r\nDPS from 659 to 501|\r\nDamage from 666 - 694 to 508 - 536|\r\nCD from 1.75 to 0.5'),
(33, '0.2.4', 'lumber from 4402 to 2358|\r\nDPS from 618 to 626|\r\nDamage from 625 - 653 to 633 - 661|\r\nCD from 1.75 to 0.5');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `tower_x_towerSpell`
--

CREATE TABLE IF NOT EXISTS `tower_x_towerSpell` (
  `towerId` int(10) unsigned NOT NULL,
  `towerSpellId` int(10) unsigned NOT NULL,
  PRIMARY KEY (`towerId`,`towerSpellId`),
  KEY `FK__towerSpells` (`towerSpellId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Daten für Tabelle `tower_x_towerSpell`
--

INSERT INTO `tower_x_towerSpell` (`towerId`, `towerSpellId`) VALUES
(4, 1),
(5, 2),
(6, 3),
(7, 4),
(8, 5),
(9, 6),
(10, 7),
(11, 8),
(12, 9),
(16, 10),
(17, 11),
(18, 12),
(19, 13),
(20, 14),
(21, 15),
(22, 16),
(23, 17),
(24, 18),
(25, 19),
(26, 20),
(27, 21),
(28, 22),
(29, 23),
(30, 24),
(28, 25),
(29, 26),
(30, 27),
(31, 28),
(32, 29),
(33, 30);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `useronline`
--

CREATE TABLE IF NOT EXISTS `useronline` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ip` varchar(15) NOT NULL DEFAULT '',
  `timestamp` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=42349 ;

--
-- Daten für Tabelle `useronline`
--

INSERT INTO `useronline` (`id`, `ip`, `timestamp`) VALUES
(42348, '66.249.72.8', '1303423008');

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `heroes_x_items`
--
ALTER TABLE `heroes_x_items`
  ADD CONSTRAINT `FK_heroes_id` FOREIGN KEY (`heroId`) REFERENCES `heroes` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_items_id` FOREIGN KEY (`itemId`) REFERENCES `items` (`ID`) ON DELETE CASCADE;

--
-- Constraints der Tabelle `heroes_x_media`
--
ALTER TABLE `heroes_x_media`
  ADD CONSTRAINT `FK_heroes_x_media_heroes` FOREIGN KEY (`heroId`) REFERENCES `heroes` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_heroes_x_media_media` FOREIGN KEY (`mediaId`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `mediaPosition`
--
ALTER TABLE `mediaPosition`
  ADD CONSTRAINT `FK_mediaPosition_media` FOREIGN KEY (`mediaId`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `recipe_x_items`
--
ALTER TABLE `recipe_x_items`
  ADD CONSTRAINT `FK_itemId_items` FOREIGN KEY (`itemId`) REFERENCES `items` (`ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_recipeId_items` FOREIGN KEY (`recipeId`) REFERENCES `items` (`ID`) ON DELETE CASCADE;

--
-- Constraints der Tabelle `tower`
--
ALTER TABLE `tower`
  ADD CONSTRAINT `FK_tower_tower` FOREIGN KEY (`upgradeTo`) REFERENCES `tower` (`towerId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints der Tabelle `tower_x_towerSpell`
--
ALTER TABLE `tower_x_towerSpell`
  ADD CONSTRAINT `FK__tower` FOREIGN KEY (`towerId`) REFERENCES `tower` (`towerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK__towerSpells` FOREIGN KEY (`towerSpellId`) REFERENCES `towerSpells` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
