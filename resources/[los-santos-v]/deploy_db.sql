START TRANSACTION;
SET AUTOCOMMIT = 0;

CREATE TABLE Players (
	PlayerID varchar(50) NOT NULL,
	PlayerName varchar(50) NOT NULL,
	DiscordID varchar(50) DEFAULT NULL,
	TimePlayed INT UNSIGNED NOT NULL DEFAULT 0,
	Banned TINYINT(1) NOT NULL DEFAULT 0,
	BanExpiresDate INT DEFAULT NULL,
	Moderator INT UNSIGNED DEFAULT NULL,
	PatreonTier INT UNSIGNED DEFAULT NULL,
	LoginTime INT UNSIGNED DEFAULT NULL,
	Cash INT UNSIGNED NOT NULL DEFAULT 50000,
	Experience INT UNSIGNED NOT NULL DEFAULT 0,
	Prestige INT UNSIGNED NOT NULL DEFAULT 0,
	Kills INT UNSIGNED NOT NULL DEFAULT 0,
	Deaths INT UNSIGNED NOT NULL DEFAULT 0,
	MoneyWasted INT UNSIGNED NOT NULL DEFAULT 0,
	Headshots INT UNSIGNED NOT NULL DEFAULT 0,
	VehicleKills INT UNSIGNED NOT NULL DEFAULT 0,
	MaxKillstreak INT UNSIGNED NOT NULL DEFAULT 0,
	MissionsDone INT UNSIGNED NOT NULL DEFAULT 0,
	EventsWon INT UNSIGNED NOT NULL DEFAULT 0,
	LongestKillDistance INT UNSIGNED NOT NULL DEFAULT 0,
	SkinModel MEDIUMTEXT DEFAULT NULL,
	Weapons MEDIUMTEXT DEFAULT NULL,
	WeaponStats MEDIUMTEXT DEFAULT NULL,
	Garages MEDIUMTEXT DEFAULT NULL,
	Vehicles LONGTEXT DEFAULT NULL,
	DrugBusiness MEDIUMTEXT DEFAULT NULL,
	Records MEDIUMTEXT DEFAULT NULL,
	Settings MEDIUMTEXT DEFAULT NULL,
	PRIMARY KEY (PlayerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE TimeTrialRecords (
	TrialID varchar(50) NOT NULL,
	PlayerName varchar(50) NOT NULL,
	Time INT UNSIGNED NOT NULL,
	PRIMARY KEY (TrialID)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE SurvivalRecords (
	SurvivalID varchar(50) NOT NULL,
	PlayerName varchar(50) NOT NULL,
	Waves INT UNSIGNED NOT NULL,
	PRIMARY KEY (SurvivalID)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

COMMIT;
