SET FOREIGN_KEY_CHECKS = 0;
--  this breaks `my family` query for some reason, which causes a cascade of DCs failing
-- LOCK TABLES `SITE_USER` WRITE;
-- UPDATE `SITE_USER`
-- SET `email` = 'admin@email.com'
-- WHERE `username` = 'admin';
-- UNLOCK TABLES;

LOCK TABLES `AB_ExampleApp_Movies` WRITE;
INSERT IGNORE INTO `AB_ExampleApp_Movies` (uuid,created_at,updated_at,properties,Titles,`Date Released`,Films) VALUES
	 ('aec6c065-3cb0-463d-abcf-133e1b681cc3','2025-02-16 03:59:35.000','2025-02-16 03:59:35.000',NULL,'Citizen Kane','1969-12-23','0579be25-48ff-4ceb-85b6-bfe88b0ce04c');
UNLOCK TABLES; 
LOCK TABLES `AB_MoviesApp_Actors` WRITE;
INSERT IGNORE INTO `AB_MoviesApp_Actors` (uuid,created_at,updated_at,properties,Name) VALUES
	 ('47c81f4d-7265-4210-b801-c0b12c72d8ee','2025-02-16 04:10:48.000','2025-02-16 04:10:48.000',NULL,'Bob');	
	 UNLOCK TABLES; 
LOCK TABLES `AB_MoviesApp_Directors` WRITE;
INSERT IGNORE INTO `AB_MoviesApp_Directors` (uuid,created_at,updated_at,properties,Name) VALUES
	 ('0579be25-48ff-4ceb-85b6-bfe88b0ce04c','2025-02-16 04:11:56.000','2025-02-16 04:11:56.000',NULL,'Alice'),
	 ('ae9f7fe5-63e8-428d-9a7b-c4c2c4d72561','2025-02-16 04:11:46.000','2025-02-16 04:11:46.000',NULL,'Quintin');
UNLOCK TABLES; 
LOCK TABLES `AB_JOINMN_Actors_Movies_Films` WRITE;
INSERT IGNORE INTO `AB_JOINMN_Actors_Movies_Films` (created_at,updated_at,Actors,Movies) VALUES
	 (NULL,NULL,'47c81f4d-7265-4210-b801-c0b12c72d8ee','aec6c065-3cb0-463d-abcf-133e1b681cc3');
UNLOCK TABLES; 
SET FOREIGN_KEY_CHECKS = 1;