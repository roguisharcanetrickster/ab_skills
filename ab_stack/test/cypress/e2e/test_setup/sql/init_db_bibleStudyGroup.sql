SET FOREIGN_KEY_CHECKS = 0;

LOCK TABLES `AB_bibleStudyGroup_Mothers` WRITE;
INSERT IGNORE INTO `AB_bibleStudyGroup_Mothers` (uuid,created_at,updated_at,properties,Name,Description) VALUES
	 ('b1110001-0001-4001-8001-000000000001','2026-04-16 10:00:00.000','2026-04-16 10:00:00.000',NULL,'Seed Mother','Cypress seed mother');
UNLOCK TABLES;

LOCK TABLES `AB_bibleStudyGroup_Groups` WRITE;
INSERT IGNORE INTO `AB_bibleStudyGroup_Groups` (uuid,created_at,updated_at,properties,Name,Description) VALUES
	 ('b1110002-0002-4002-8002-000000000002','2026-04-16 10:00:00.000','2026-04-16 10:00:00.000',NULL,'Seed Group','Cypress seed group');
UNLOCK TABLES;

LOCK TABLES `AB_bibleStudyGroup_GroupMeetings` WRITE;
INSERT IGNORE INTO `AB_bibleStudyGroup_GroupMeetings` (uuid,created_at,updated_at,properties,Name,Description,scheduledAt,`Group`) VALUES
	 ('b1110003-0003-4003-8003-000000000003','2026-04-16 10:00:00.000','2026-04-16 10:00:00.000',NULL,'Seed Meeting','First meeting','2026-04-20 19:00:00.000','b1110002-0002-4002-8002-000000000002');
UNLOCK TABLES;

LOCK TABLES `AB_bibleStudyGroup_GroupMemberships` WRITE;
INSERT IGNORE INTO `AB_bibleStudyGroup_GroupMemberships` (uuid,created_at,updated_at,properties,Name,Description,Mother,`Group`) VALUES
	 ('b1110004-0004-4004-8004-000000000004','2026-04-16 10:00:00.000','2026-04-16 10:00:00.000',NULL,'Seed Membership','','b1110001-0001-4001-8001-000000000001','b1110002-0002-4002-8002-000000000002');
UNLOCK TABLES;

LOCK TABLES `AB_bibleStudyGroup_Applications` WRITE;
INSERT IGNORE INTO `AB_bibleStudyGroup_Applications` (uuid,created_at,updated_at,properties,Name,Description,Mother,`Group`) VALUES
	 ('b1110005-0005-4005-8005-000000000005','2026-04-16 10:00:00.000','2026-04-16 10:00:00.000',NULL,'Seed Application','Cypress seed application','b1110001-0001-4001-8001-000000000001','b1110002-0002-4002-8002-000000000002');
UNLOCK TABLES;

SET FOREIGN_KEY_CHECKS = 1;
