-- DualSpec module: uninstall / rollback for the characters DB.
--
-- NOT auto-applied by docker/db-import.sh. Run manually only if
-- you need to revert the M1 schema changes. Drops the module's
-- table outright and unwinds all column additions.
--
-- Inverse of 001_dualspec_schema.sql:

DROP TABLE IF EXISTS `character_talent`;

ALTER TABLE `character_spell`
  DROP COLUMN `specMask`;

ALTER TABLE `character_action`
  DROP PRIMARY KEY,
  DROP COLUMN `spec`,
  ADD PRIMARY KEY (`guid`, `button`);

ALTER TABLE `characters`
  DROP COLUMN `activeTalentGroup`,
  DROP COLUMN `talentGroupsCount`;
