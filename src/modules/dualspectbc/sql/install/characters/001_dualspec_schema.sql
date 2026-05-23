-- DualSpec module: characters-DB schema additions.
--
-- Applied by docker/db-import.sh, sentinel-gated on `character_talent`.
-- Plain (non-idempotent) DDL: the sentinel guarantees one-shot application;
-- MySQL 5.7 (cmangos-tbc's container) does not support
-- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`, so we rely on the gate.
--
-- Schema mirrors AzerothCore (3.3.5a) naming for portability:
--   character_talent           - new
--   character_spell.specMask   - new column (1 = spec0 only by default)
--   character_action.spec      - new column + widened PK to (guid, spec, button)
--   characters.activeTalentGroup, .talentGroupsCount - new columns

CREATE TABLE `character_talent` (
  `guid` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Global Unique Identifier',
  `spell` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Talent spell rank id',
  `specMask` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Bitmask: bit0=spec0, bit1=spec1',
  PRIMARY KEY (`guid`, `spell`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Player System';

ALTER TABLE `character_spell`
  ADD COLUMN `specMask` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Bitmask: bit0=spec0, bit1=spec1';

ALTER TABLE `character_action`
  DROP PRIMARY KEY,
  ADD COLUMN `spec` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Talent group index (0 or 1)',
  ADD PRIMARY KEY (`guid`, `spec`, `button`);

ALTER TABLE `characters`
  ADD COLUMN `activeTalentGroup` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Active spec index (0 or 1)',
  ADD COLUMN `talentGroupsCount` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Number of unlocked specs (1 or 2)';
