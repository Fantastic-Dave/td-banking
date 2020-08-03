-- teamDemo


ALTER TABLE `users` ADD COLUMN `creditcardnumber` varchar(10) COLLATE utf8mb4_bin NOT NULL;
ALTER TABLE `users` ADD COLUMN `accounts` longtext COLLATE utf8mb4_bin DEFAULT NULL;
ALTER TABLE `users` ADD COLUMN `creditpassword` varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '3162';