-- ============================================================================
-- 001_revert_2.3.0_creature_rank_and_hp_world.sql
--
-- Reverts both `Rank` and `HealthMultiplier` for the 297 creatures whose rank
-- was changed between vanilla 1.12.1 (vmangos truth) and TBC 2.4.3 (cmangos
-- truth). Restores each affected creature's vanilla rank tag AND vanilla
-- per-creature HP multiplier in a single coordinated update.
--
-- Why combine the two columns:
--   - Rank alone is cosmetic in cmangos (gold elite-dragon ring on nameplate,
--     corpse decay timer, a few AI flags). Server `Rate.Creature.<tier>.HP`
--     defaults to 1.0 for ALL ranks (src/game/World/World.cpp:439-443), so
--     rank does NOT scale HP at runtime. The actual elite-vs-normal HP gap is
--     baked per-creature into `HealthMultiplier`.
--   - 276 of these 297 creatures also had their `HealthMultiplier` changed in
--     TBC (typically from vanilla's 3.0 for elite-tier mobs down to TBC's 1.0
--     for the demoted-to-normal set). Reverting only rank leaves them with
--     the elite badge but normal-mob HP. This file reverts both.
--
-- Calibration caveat:
--   The HP formula is `cCLS.BaseHealth × HealthMultiplier × Rate.Creature.<r>.HP`
--   where `cCLS` (creature_template_classlevelstats) differs between vmangos
--   and cmangos. Setting `HealthMultiplier` to the vanilla value applies it
--   against TBC's cCLS base, NOT vanilla's. Result is "close to vanilla feel"
--   on the cmangos side, not literal-vanilla absolute HP. Damage and armor
--   multipliers are intentionally NOT touched here -- those are a separate
--   research dimension (see creature_rank_changes.md for context).
--
-- This file is consumed by docker/db-import.sh; the trailing `_world.sql`
-- suffix routes it to DB_WORLD (tbcmangos). It runs on every `docker compose
-- up` after upstream base + updates load. All UPDATEs are idempotent.
--
-- DO NOT apply to wow-dbc/cm_world -- that container holds the 2.4.3 reference
-- snapshot used to *find* these changes. Mutating it corrupts the source of
-- truth. This file only belongs against the runtime DB (tbcmangos).
--
-- Source: zzDocumentation/zzResearch/2.3.0/creature_rank_changes.md
--         zzDocumentation/zzResearch/2.3.0/data/creature_rank_changes.csv
-- Generated via the methodology query with HealthMultiplier added to the
-- projection. Grouped by (vanilla_rank, vanilla_HealthMultiplier) into 30
-- distinct UPDATEs, covering 297 creatures total. Each entry carries an
-- inline comment showing the rank transition and HM transition being applied.
-- ============================================================================

-- Restored to Elite -- HealthMultiplier 3  (222 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 3 WHERE entry IN (
  314,   -- Eliza                          (Normal -> Elite, HM 1 -> 3)
  397,   -- Morganth                       (Normal -> Elite, HM 1 -> 3)
  436,   -- Blackrock Shadowcaster         (Normal -> Elite, HM 1 -> 3)
  594,   -- Defias Henchman                (Normal -> Elite, HM 1 -> 3)
  619,   -- Defias Conjurer                (Normal -> Elite, HM 1 -> 3)
  623,   -- Skeletal Miner                 (Normal -> Elite, HM 1 -> 3)
  624,   -- Undead Excavator               (Normal -> Elite, HM 1 -> 3)
  625,   -- Undead Dynamiter               (Normal -> Elite, HM 1 -> 3)
  626,   -- Foreman Thistlenettle          (Normal -> Elite, HM 1.2 -> 3)
  678,   -- Mosh'Ogg Mauler                (Normal -> Elite, HM 1.15 -> 3)
  679,   -- Mosh'Ogg Shaman                (Normal -> Elite, HM 1.15 -> 3)
  680,   -- Mosh'Ogg Lord                  (Normal -> Elite, HM 1.15 -> 3)
  709,   -- Mosh'Ogg Warmonger             (Normal -> Elite, HM 1.15 -> 3)
  710,   -- Mosh'Ogg Spellcrafter          (Normal -> Elite, HM 1.15 -> 3)
  813,   -- Colonel Kurzen                 (Normal -> Elite, HM 1.5 -> 3)
  818,   -- Mai'Zoth                       (Normal -> Elite, HM 1.5 -> 3)
  871,   -- Saltscale Warrior              (Normal -> Elite, HM 1.15 -> 3)
  873,   -- Saltscale Oracle               (Normal -> Elite, HM 1.15 -> 3)
  875,   -- Saltscale Tide Lord            (Normal -> Elite, HM 1.15 -> 3)
  877,   -- Saltscale Forager              (Normal -> Elite, HM 1.15 -> 3)
  879,   -- Saltscale Hunter               (Normal -> Elite, HM 1.15 -> 3)
  1051,  -- Dark Iron Dwarf                (Normal -> Elite, HM 1 -> 3)
  1052,  -- Dark Iron Saboteur             (Normal -> Elite, HM 1 -> 3)
  1053,  -- Dark Iron Tunneler             (Normal -> Elite, HM 1 -> 3)
  1054,  -- Dark Iron Demolitionist        (Normal -> Elite, HM 1 -> 3)
  1178,  -- Mo'grosh Ogre                  (Normal -> Elite, HM 1 -> 3)
  1179,  -- Mo'grosh Enforcer              (Normal -> Elite, HM 1 -> 3)
  1180,  -- Mo'grosh Brute                 (Normal -> Elite, HM 1 -> 3)
  1181,  -- Mo'grosh Shaman                (Normal -> Elite, HM 1 -> 3)
  1183,  -- Mo'grosh Mystic                (Normal -> Elite, HM 1 -> 3)
  1225,  -- Ol' Sooty                      (Normal -> Elite, HM 1 -> 3)
  1388,  -- Vagash                         (Normal -> Elite, HM 1 -> 3)
  1725,  -- Defias Watchman                (Normal -> Elite, HM 1 -> 3)
  1726,  -- Defias Magician                (Normal -> Elite, HM 1 -> 3)
  1788,  -- Skeletal Warlord               (Normal -> Elite, HM 1.25 -> 3)
  1827,  -- Scarlet Sentinel               (Normal -> Elite, HM 1.25 -> 3)
  1832,  -- Scarlet Magus                  (Normal -> Elite, HM 1.25 -> 3)
  1834,  -- Scarlet Paladin                (Normal -> Elite, HM 1.25 -> 3)
  1891,  -- Pyrewood Watcher               (Normal -> Elite, HM 1 -> 3)
  1892,  -- Moonrage Watcher               (Normal -> Elite, HM 1 -> 3)
  1893,  -- Moonrage Sentry                (Normal -> Elite, HM 1 -> 3)
  1894,  -- Pyrewood Sentry                (Normal -> Elite, HM 1 -> 3)
  1895,  -- Pyrewood Elder                 (Normal -> Elite, HM 1 -> 3)
  1896,  -- Moonrage Elder                 (Normal -> Elite, HM 1 -> 3)
  1947,  -- Thule Ravenclaw                (Normal -> Elite, HM 1 -> 3)
  2060,  -- Councilman Smithers            (Normal -> Elite, HM 1 -> 3)
  2061,  -- Councilman Thatcher            (Normal -> Elite, HM 1 -> 3)
  2062,  -- Councilman Hendricks           (Normal -> Elite, HM 1 -> 3)
  2063,  -- Councilman Wilhelm             (Normal -> Elite, HM 1 -> 3)
  2064,  -- Councilman Hartin              (Normal -> Elite, HM 1 -> 3)
  2065,  -- Councilman Cooper              (Normal -> Elite, HM 1 -> 3)
  2066,  -- Councilman Higarth             (Normal -> Elite, HM 1 -> 3)
  2067,  -- Councilman Brunswick           (Normal -> Elite, HM 1 -> 3)
  2068,  -- Lord Mayor Morrison            (Normal -> Elite, HM 1 -> 3)
  2091,  -- Chieftain Nek'rosh             (Normal -> Elite, HM 1 -> 3)
  2106,  -- Apothecary Berard              (Normal -> Elite, HM 1 -> 3)
  2166,  -- Oakenscowl                     (Normal -> Elite, HM 1 -> 3)
  2254,  -- Crushridge Mauler              (Normal -> Elite, HM 1 -> 3)
  2255,  -- Crushridge Mage                (Normal -> Elite, HM 1 -> 3)
  2256,  -- Crushridge Enforcer            (Normal -> Elite, HM 1 -> 3)
  2257,  -- Mug'thol                       (Normal -> Elite, HM 1 -> 3)
  2287,  -- Crushridge Warmonger           (Normal -> Elite, HM 1 -> 3)
  2304,  -- Captain Ironhill               (Normal -> Elite, HM 1 -> 3)
  2344,  -- Dun Garok Mountaineer          (Normal -> Elite, HM 1 -> 3)
  2345,  -- Dun Garok Rifleman             (Normal -> Elite, HM 1 -> 3)
  2346,  -- Dun Garok Priest               (Normal -> Elite, HM 1 -> 3)
  2416,  -- Crushridge Plunderer           (Normal -> Elite, HM 1 -> 3)
  2421,  -- Muckrake                       (Normal -> Elite, HM 1 -> 3)
  2422,  -- Glommus                        (Normal -> Elite, HM 1 -> 3)
  2558,  -- Witherbark Berserker           (Normal -> Elite, HM 1.15 -> 3)
  2569,  -- Boulderfist Mauler             (Normal -> Elite, HM 1.1 -> 3)
  2570,  -- Boulderfist Shaman             (Normal -> Elite, HM 1.1 -> 3)
  2571,  -- Boulderfist Lord               (Normal -> Elite, HM 1.1 -> 3)
  2583,  -- Stromgarde Troll Hunter        (Normal -> Elite, HM 1.15 -> 3)
  2584,  -- Stromgarde Defender            (Normal -> Elite, HM 1.15 -> 3)
  2585,  -- Stromgarde Vindicator          (Normal -> Elite, HM 1.15 -> 3)
  2588,  -- Syndicate Prowler              (Normal -> Elite, HM 1 -> 3)
  2590,  -- Syndicate Conjuror             (Normal -> Elite, HM 1.1 -> 3)
  2591,  -- Syndicate Magus                (Normal -> Elite, HM 1.1 -> 3)
  2599,  -- Otto                           (Normal -> Elite, HM 0.75 -> 3)
  2607,  -- Prince Galen Trollbane         (Normal -> Elite, HM 1.15 -> 3)
  2611,  -- Fozruk                         (Normal -> Elite, HM 1.5 -> 3)
  2612,  -- Lieutenant Valorcall           (Normal -> Elite, HM 1 -> 3)
  2635,  -- Elder Saltwater Crocolisk      (Normal -> Elite, HM 1.15 -> 3)
  2641,  -- Vilebranch Headhunter          (Normal -> Elite, HM 1.2 -> 3)
  2642,  -- Vilebranch Shadowcaster        (Normal -> Elite, HM 1.2 -> 3)
  2643,  -- Vilebranch Berserker           (Normal -> Elite, HM 1.2 -> 3)
  2644,  -- Vilebranch Hideskinner         (Normal -> Elite, HM 1.2 -> 3)
  2645,  -- Vilebranch Shadow Hunter       (Normal -> Elite, HM 1 -> 3)
  2646,  -- Vilebranch Blood Drinker       (Normal -> Elite, HM 1 -> 3)
  2647,  -- Vilebranch Soul Eater          (Normal -> Elite, HM 1.2 -> 3)
  2648,  -- Vilebranch Aman'zasi Guard     (Normal -> Elite, HM 1.2 -> 3)
  2681,  -- Vilebranch Raiding Wolf        (Normal -> Elite, HM 1 -> 3)
  2726,  -- Scorched Guardian              (Normal -> Elite, HM 1 -> 3)
  2738,  -- Stromgarde Cavalryman          (Normal -> Elite, HM 0.75 -> 3)
  2763,  -- Thenan                         (Normal -> Elite, HM 1 -> 3)
  2780,  -- Caretaker Nevlin               (Normal -> Elite, HM 1.15 -> 3)
  2781,  -- Caretaker Weston               (Normal -> Elite, HM 1.15 -> 3)
  2782,  -- Caretaker Alaric               (Normal -> Elite, HM 1.15 -> 3)
  2783,  -- Marez Cowl                     (Normal -> Elite, HM 1.1 -> 3)
  2794,  -- Summoned Guardian              (Normal -> Elite, HM 1.15 -> 3)
  2835,  -- Cedrik Prose                   (Normal -> Elite, HM 3 -> 3)
  2892,  -- Stonevault Seer                (Normal -> Elite, HM 1.15 -> 3)
  2932,  -- Magregan Deepshadow            (Normal -> Elite, HM 1.15 -> 3)
  3528,  -- Pyrewood Armorer               (Normal -> Elite, HM 1 -> 3)
  3529,  -- Moonrage Armorer               (Normal -> Elite, HM 1 -> 3)
  3530,  -- Pyrewood Tailor                (Normal -> Elite, HM 1 -> 3)
  3531,  -- Moonrage Tailor                (Normal -> Elite, HM 1 -> 3)
  3532,  -- Pyrewood Leatherworker         (Normal -> Elite, HM 1 -> 3)
  3533,  -- Moonrage Leatherworker         (Normal -> Elite, HM 1 -> 3)
  3630,  -- Deviate Coiler                 (Normal -> Elite, HM 1 -> 3)
  3631,  -- Deviate Stinglash              (Normal -> Elite, HM 1 -> 3)
  3632,  -- Deviate Creeper                (Normal -> Elite, HM 1 -> 3)
  3633,  -- Deviate Slayer                 (Normal -> Elite, HM 1 -> 3)
  3634,  -- Deviate Stalker                (Normal -> Elite, HM 1 -> 3)
  3638,  -- Devouring Ectoplasm            (Normal -> Elite, HM 1 -> 3)
  3641,  -- Deviate Lurker                 (Normal -> Elite, HM 1 -> 3)
  3655,  -- Mad Magglish                   (Normal -> Elite, HM 1 -> 3)
  4050,  -- Cenarion Caretaker             (Normal -> Elite, HM 1 -> 3)
  4052,  -- Cenarion Druid                 (Normal -> Elite, HM 1 -> 3)
  4056,  -- Mirkfallon Keeper              (Normal -> Elite, HM 1.5 -> 3)
  4061,  -- Mirkfallon Dryad               (Normal -> Elite, HM 1 -> 3)
  4064,  -- Blackrock Scout                (Normal -> Elite, HM 1 -> 3)
  4065,  -- Blackrock Sentry               (Normal -> Elite, HM 1 -> 3)
  4280,  -- Scarlet Preserver              (Normal -> Elite, HM 1.05 -> 3)
  4281,  -- Scarlet Scout                  (Normal -> Elite, HM 1.05 -> 3)
  4282,  -- Scarlet Magician               (Normal -> Elite, HM 1.05 -> 3)
  4283,  -- Scarlet Sentry                 (Normal -> Elite, HM 1.1 -> 3)
  4284,  -- Scarlet Augur                  (Normal -> Elite, HM 1.1 -> 3)
  4285,  -- Scarlet Disciple               (Normal -> Elite, HM 1.1 -> 3)
  4394,  -- Bubbling Swamp Ooze            (Normal -> Elite, HM 1 -> 3)
  4409,  -- Gatekeeper Kordurus            (Normal -> Elite, HM 1 -> 3)
  4462,  -- Blackrock Hunter               (Normal -> Elite, HM 1 -> 3)
  4464,  -- Blackrock Gladiator            (Normal -> Elite, HM 1 -> 3)
  4465,  -- Vilebranch Warrior             (Normal -> Elite, HM 1.2 -> 3)
  4468,  -- Jade Sludge                    (Normal -> Elite, HM 1 -> 3)
  4469,  -- Emerald Ooze                   (Normal -> Elite, HM 1 -> 3)
  4499,  -- Rok'Alim the Pounder           (Normal -> Elite, HM 1.2 -> 3)
  4788,  -- Fallenroot Satyr               (Normal -> Elite, HM 1 -> 3)
  4789,  -- Fallenroot Rogue               (Normal -> Elite, HM 1 -> 3)
  4802,  -- Blackfathom Tide Priestess     (Normal -> Elite, HM 1 -> 3)
  4803,  -- Blackfathom Oracle             (Normal -> Elite, HM 1 -> 3)
  4844,  -- Shadowforge Surveyor           (Normal -> Elite, HM 1.15 -> 3)
  4845,  -- Shadowforge Ruffian            (Normal -> Elite, HM 1.15 -> 3)
  4846,  -- Shadowforge Digger             (Normal -> Elite, HM 1.15 -> 3)
  4851,  -- Stonevault Rockchewer          (Normal -> Elite, HM 1.15 -> 3)
  4856,  -- Stonevault Cave Hunter         (Normal -> Elite, HM 1.25 -> 3)
  4872,  -- Obsidian Golem                 (Normal -> Elite, HM 1.15 -> 3)
  5224,  -- Murk Slitherer                 (Normal -> Elite, HM 1.25 -> 3)
  5225,  -- Murk Spitter                   (Normal -> Elite, HM 1.25 -> 3)
  5235,  -- Fungal Ooze                    (Normal -> Elite, HM 1.25 -> 3)
  5243,  -- Cursed Atal'ai                 (Normal -> Elite, HM 1.25 -> 3)
  5261,  -- Enthralled Atal'ai             (Normal -> Elite, HM 1.25 -> 3)
  5263,  -- Mummified Atal'ai              (Normal -> Elite, HM 1.25 -> 3)
  5269,  -- Atal'ai Priest                 (Normal -> Elite, HM 1.25 -> 3)
  5401,  -- Kazkaz the Unholy              (Normal -> Elite, HM 1.5 -> 3)
  5402,  -- Khan Hratha                    (Normal -> Elite, HM 1.2 -> 3)
  5645,  -- Sandfury Hideskinner           (Normal -> Elite, HM 1.2 -> 3)
  5646,  -- Sandfury Axe Thrower           (Normal -> Elite, HM 1.2 -> 3)
  5647,  -- Sandfury Firecaller            (Normal -> Elite, HM 1.2 -> 3)
  5780,  -- Cloned Ectoplasm               (Normal -> Elite, HM 1 -> 3)
  5833,  -- Margol the Rager               (Normal -> Elite, HM 1.2 -> 3)
  5860,  -- Twilight Dark Shaman           (Normal -> Elite, HM 1.2 -> 3)
  5861,  -- Twilight Fire Guard            (Normal -> Elite, HM 1.2 -> 3)
  5862,  -- Twilight Geomancer             (Normal -> Elite, HM 1.2 -> 3)
  6132,  -- Razorfen Servitor              (Normal -> Elite, HM 1.02 -> 3)
  6208,  -- Caverndeep Invader             (Normal -> Elite, HM 3 -> 3)
  6210,  -- Caverndeep Pillager            (Normal -> Elite, HM 3 -> 3)
  6213,  -- Irradiated Invader             (Normal -> Elite, HM 3 -> 3)
  6523,  -- Dark Iron Rifleman             (Normal -> Elite, HM 1 -> 3)
  6733,  -- Stonevault Basher              (Normal -> Elite, HM 1.15 -> 3)
  7040,  -- Black Dragonspawn              (Normal -> Elite, HM 1.5 -> 3)
  7041,  -- Black Wyrmkin                  (Normal -> Elite, HM 1.25 -> 3)
  7042,  -- Flamescale Dragonspawn         (Normal -> Elite, HM 1.25 -> 3)
  7043,  -- Flamescale Wyrmkin             (Normal -> Elite, HM 1.25 -> 3)
  7044,  -- Black Drake                    (Normal -> Elite, HM 1.25 -> 3)
  7045,  -- Scalding Drake                 (Normal -> Elite, HM 1.25 -> 3)
  7046,  -- Searscale Drake                (Normal -> Elite, HM 1.25 -> 3)
  7135,  -- Infernal Bodyguard             (Normal -> Elite, HM 1.25 -> 3)
  7136,  -- Infernal Sentry                (Normal -> Elite, HM 1.25 -> 3)
  7872,  -- Death's Head Cultist           (Normal -> Elite, HM 1.15 -> 3)
  7873,  -- Razorfen Battleguard           (Normal -> Elite, HM 1.1 -> 3)
  7874,  -- Razorfen Thornweaver           (Normal -> Elite, HM 1.1 -> 3)
  8075,  -- Edana Hatetalon                (Normal -> Elite, HM 1 -> 3)
  8419,  -- Twilight Idolater              (Normal -> Elite, HM 1.2 -> 3)
  8447,  -- Clunk                          (Normal -> Elite, HM 1 -> 3)
  9043,  -- Scarshield Grunt               (Normal -> Elite, HM 1.3 -> 3)
  9044,  -- Scarshield Sentry              (Normal -> Elite, HM 1.3 -> 3)
  9461,  -- Frenzied Black Drake           (Normal -> Elite, HM 1.2 -> 3)
  10608, -- Scarlet Priest                 (Normal -> Elite, HM 1.25 -> 3)
  10738, -- High Chief Winterfall          (Normal -> Elite, HM 1.5 -> 3)
  10882, -- Arikara                        (Normal -> Elite, HM 1.15 -> 3)
  10953, -- Servant of Horgus              (Normal -> Elite, HM 1.5 -> 3)
  11141, -- Spirit of Trey Lightforge      (Normal -> Elite, HM 1.2 -> 3)
  11440, -- Gordok Enforcer                (Normal -> Elite, HM 1.3 -> 3)
  11442, -- Gordok Mauler                  (Normal -> Elite, HM 1.3 -> 3)
  11443, -- Gordok Ogre-Mage               (Normal -> Elite, HM 1.3 -> 3)
  11698, -- Hive'Ashi Stinger              (Normal -> Elite, HM 1.3 -> 3)
  11721, -- Hive'Ashi Worker               (Normal -> Elite, HM 1 -> 3)
  11722, -- Hive'Ashi Defender             (Normal -> Elite, HM 1.3 -> 3)
  11724, -- Hive'Ashi Swarmer              (Normal -> Elite, HM 1.3 -> 3)
  11725, -- Hive'Zora Waywatcher           (Normal -> Elite, HM 1.3 -> 3)
  11726, -- Hive'Zora Tunneler             (Normal -> Elite, HM 1.3 -> 3)
  11728, -- Hive'Zora Reaver               (Normal -> Elite, HM 1.3 -> 3)
  11729, -- Hive'Zora Hive Sister          (Normal -> Elite, HM 1.3 -> 3)
  11731, -- Hive'Regal Burrower            (Normal -> Elite, HM 1.3 -> 3)
  11732, -- Hive'Regal Spitfire            (Normal -> Elite, HM 1.3 -> 3)
  11733, -- Hive'Regal Slavemaker          (Normal -> Elite, HM 1.3 -> 3)
  11777, -- Shadowshard Rumbler            (Normal -> Elite, HM 1.2 -> 3)
  11778, -- Shadowshard Smasher            (Normal -> Elite, HM 1.2 -> 3)
  11781, -- Ambershard Crusher             (Normal -> Elite, HM 1.2 -> 3)
  11782, -- Ambershard Destroyer           (Normal -> Elite, HM 1.2 -> 3)
  11785, -- Ambereye Basilisk              (Normal -> Elite, HM 1.2 -> 3)
  11786, -- Ambereye Reaver                (Normal -> Elite, HM 1.2 -> 3)
  11787, -- Rock Borer                     (Normal -> Elite, HM 1.2 -> 3)
  11788, -- Rock Worm                      (Normal -> Elite, HM 1.2 -> 3)
  11920, -- Goggeroc                       (Normal -> Elite, HM 1.1 -> 3)
  11921, -- Besseleth                      (Normal -> Elite, HM 1 -> 3)
  12579, -- Bloodfury Ripper               (Normal -> Elite, HM 1 -> 3)
  12865, -- Ambassador Malcin              (Normal -> Elite, HM 1.25 -> 3)
  14346, -- Captain Greshkil               (Rare-Elite -> Elite, HM 3 -> 3)
  14388  -- Rogue Black Drake              (Normal -> Elite, HM 1.5 -> 3)
);

-- Restored to Elite -- HealthMultiplier 5  (10 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 5 WHERE entry IN (
  1364,  -- Balgaras the Foul              (Normal -> Elite, HM 1 -> 5)
  1559,  -- King Mukla                     (Normal -> Elite, HM 2 -> 5)
  2420,  -- Targ                           (Normal -> Elite, HM 1 -> 5)
  2757,  -- Blacklash                      (Normal -> Elite, HM 1 -> 5)
  6140,  -- Hetaera                        (Normal -> Elite, HM 1.5 -> 5)
  7995,  -- Vile Priestess Hexx            (Normal -> Elite, HM 1.5 -> 5)
  7996,  -- Qiaga the Keeper               (Normal -> Elite, HM 1.5 -> 5)
  8391,  -- Lathoric the Black             (Normal -> Elite, HM 1.5 -> 5)
  8636,  -- Morta'gya the Keeper           (Normal -> Elite, HM 1.5 -> 5)
  10802  -- Hitah'ya the Keeper            (Normal -> Elite, HM 1.5 -> 5)
);

-- Restored to Elite -- HealthMultiplier 6  (8 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 6 WHERE entry IN (
  2759,  -- Hematus                        (Normal -> Elite, HM 1 -> 6)
  6231,  -- Techbot                        (Normal -> Elite, HM 1.05 -> 6)
  11467, -- Tsu'zee                        (Rare-Elite -> Elite, HM 6 -> 6)
  11897, -- Duskwing                       (Normal -> Elite, HM 1.5 -> 6)
  12262, -- Ziggurat Protector             (Normal -> Elite, HM 1.25 -> 6)
  12263, -- Slaughterhouse Protector       (Normal -> Elite, HM 1.25 -> 6)
  14467, -- Kroshius                       (Normal -> Elite, HM 1.25 -> 6)
  16184  -- Nerubian Overseer              (Rare-Elite -> Elite, HM 6 -> 6)
);

-- Restored to Rare-Elite -- HealthMultiplier 3  (8 creatures)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 3 WHERE entry IN (
  596,   -- Brainwashed Noble              (Rare -> Rare-Elite, HM 1.5 -> 3)
  599,   -- Marisa du'Paige                (Rare -> Rare-Elite, HM 1.5 -> 3)
  723,   -- Mosh'Ogg Butcher               (Normal -> Rare-Elite, HM 1.15 -> 3)
  3652,  -- Trigore the Lasher             (Rare -> Rare-Elite, HM 1.25 -> 3)
  3672,  -- Boahn                          (Rare -> Rare-Elite, HM 1.5 -> 3)
  5400,  -- Zekkis                         (Rare -> Rare-Elite, HM 1.5 -> 3)
  7895,  -- Ambassador Bloodrage           (Rare -> Rare-Elite, HM 1.1 -> 3)
  9046   -- Scarshield Quartermaster       (Rare -> Rare-Elite, HM 1.5 -> 3)
);

-- Restored to Elite -- HealthMultiplier 4  (6 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 4 WHERE entry IN (
  7053,  -- Klaven Mortwake                (Normal -> Elite, HM 1 -> 4)
  7728,  -- Kirith the Damned              (Normal -> Elite, HM 1.25 -> 4)
  10807, -- Brumeran                       (Normal -> Elite, HM 1.25 -> 4)
  10899, -- Goraluk Anvilcrack             (Rare-Elite -> Elite, HM 4 -> 4)
  11734, -- Hive'Regal Hive Lord           (Normal -> Elite, HM 1.3 -> 4)
  15796  -- Christmas Goraluk Anvilcrack   (Rare-Elite -> Elite, HM 4 -> 4)
);

-- Restored to Elite -- HealthMultiplier 4.5  (4 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 4.5 WHERE entry IN (
  10737, -- Shy-Rotam                      (Normal -> Elite, HM 1.25 -> 4.5)
  10741, -- Sian-Rotam                     (Normal -> Elite, HM 1.25 -> 4.5)
  10806, -- Ursius                         (Normal -> Elite, HM 1.25 -> 4.5)
  11383  -- High Priestess Hai'watna       (Rare-Elite -> Elite, HM 4.5 -> 4.5)
);

-- Restored to Elite -- HealthMultiplier 2.7  (4 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 2.7 WHERE entry IN (
  15209, -- Crimson Templar                (Normal -> Elite, HM 1.5 -> 2.7)
  15211, -- Azure Templar                  (Normal -> Elite, HM 1.5 -> 2.7)
  15212, -- Hoary Templar                  (Normal -> Elite, HM 1.5 -> 2.7)
  15307  -- Earthen Templar                (Normal -> Elite, HM 1.5 -> 2.7)
);

-- Restored to Rare-Elite -- HealthMultiplier 8  (4 creatures)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 8 WHERE entry IN (
  639,   -- Edwin VanCleef                 (Elite -> Rare-Elite, HM 8 -> 8)
  9736,  -- Quartermaster Zigris           (Elite -> Rare-Elite, HM 8 -> 8)
  10584, -- Urok Doomhowl                  (Elite -> Rare-Elite, HM 8 -> 8)
  10808  -- Timmy the Cruel                (Elite -> Rare-Elite, HM 8 -> 8)
);

-- Restored to Normal -- HealthMultiplier 3  (3 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 3 WHERE entry IN (
  9297,  -- Enraged Wyvern                 (Elite -> Normal, HM 3 -> 3)
  9527,  -- Enraged Hippogryph             (Elite -> Normal, HM 3 -> 3)
  10917  -- Aurius                         (Elite -> Normal, HM 3 -> 3)
);

-- Restored to Elite -- HealthMultiplier 3.25  (2 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 3.25 WHERE entry IN (
  2773,  -- Or'Kalar                       (Normal -> Elite, HM 1 -> 3.25)
  7977   -- Gammerita                      (Normal -> Elite, HM 1.15 -> 3.25)
);

-- Restored to Elite -- HealthMultiplier 7  (2 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 7 WHERE entry IN (
  2597,  -- Lord Falconcrest               (Normal -> Elite, HM 1.5 -> 7)
  8400   -- Obsidion                       (Normal -> Elite, HM 1.5 -> 7)
);

-- Restored to Rare-Elite -- HealthMultiplier 5  (2 creatures)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 5 WHERE entry IN (
  8924,  -- The Behemoth                   (Rare -> Rare-Elite, HM 1.5 -> 5)
  9025   -- Lord Roccor                    (Elite -> Rare-Elite, HM 5 -> 5)
);

-- Restored to Elite -- HealthMultiplier 50  (2 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 50 WHERE entry IN (
  11946, -- Drek'Thar                      (Boss -> Elite, HM 27.5 -> 50)
  11948  -- Vanndar Stormpike              (Boss -> Elite, HM 27.5 -> 50)
);

-- Restored to Elite -- HealthMultiplier 2  (2 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 2 WHERE entry IN (
  6669,  -- The Threshwackonator 4100      (Normal -> Elite, HM 1 -> 2)
  7734   -- Ilifar                         (Normal -> Elite, HM 1 -> 2)
);

-- Restored to Elite -- HealthMultiplier 2.85  (2 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 2.85 WHERE entry IN (
  11723, -- Hive'Ashi Sandstalker          (Normal -> Elite, HM 1.3 -> 2.85)
  11730  -- Hive'Regal Ambusher            (Normal -> Elite, HM 1.3 -> 2.85)
);

-- Restored to Elite -- HealthMultiplier 30  (2 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 30 WHERE entry IN (
  15288, -- Aluntir                        (Normal -> Elite, HM 1.3 -> 30)
  15290  -- Arakis                         (Normal -> Elite, HM 1.3 -> 30)
);

-- Restored to Elite -- HealthMultiplier 8  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 8 WHERE entry IN (
  14621  -- Overseer Maltorius             (Normal -> Elite, HM 1.5 -> 8)
);

-- Restored to Boss -- HealthMultiplier 5  (1 creature)
UPDATE `creature_template` SET `Rank` = 3, HealthMultiplier = 5 WHERE entry IN (
  11980  -- [NOT USED] Zuluhed the Whacked (Elite -> Boss, HM 20 -> 5)
);

-- Restored to Normal -- HealthMultiplier 0.05  (1 creature)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 0.05 WHERE entry IN (
  3580   -- Invisibility Totem             (Elite -> Normal, HM 3.5 -> 0.05)
);

-- Restored to Elite -- HealthMultiplier 40  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 40 WHERE entry IN (
  11947  -- Captain Galvangar              (Boss -> Elite, HM 25 -> 40)
);

-- Restored to Normal -- HealthMultiplier 0.75  (1 creature)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 0.75 WHERE entry IN (
  2753   -- Barnabus                       (Rare -> Normal, HM 0.75 -> 0.75)
);

-- Restored to Elite -- HealthMultiplier 3.15  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 3.15 WHERE entry IN (
  728    -- Bhag'thera                     (Normal -> Elite, HM 1.15 -> 3.15)
);

-- Restored to Elite -- HealthMultiplier 3.1  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 3.1 WHERE entry IN (
  730    -- Tethis                         (Normal -> Elite, HM 1.15 -> 3.1)
);

-- Restored to Elite -- HealthMultiplier 15  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 15 WHERE entry IN (
  11896  -- Borelgore                      (Normal -> Elite, HM 2 -> 15)
);

-- Restored to Rare-Elite -- HealthMultiplier 3.25  (1 creature)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 3.25 WHERE entry IN (
  1063   -- Jade                           (Rare -> Rare-Elite, HM 1.5 -> 3.25)
);

-- Restored to Elite -- HealthMultiplier 25  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 25 WHERE entry IN (
  11676  -- Fjordune the Greater           (Rare-Elite -> Elite, HM 25 -> 25)
);

-- Restored to Elite -- HealthMultiplier 10  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 10 WHERE entry IN (
  15215  -- Mistress Natalia Mar'alith     (Normal -> Elite, HM 5 -> 10)
);

-- Restored to Elite -- HealthMultiplier 12  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 12 WHERE entry IN (
  14506  -- Lord Hel'nurath                (Rare-Elite -> Elite, HM 12 -> 12)
);

-- Restored to Elite -- HealthMultiplier 45  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 45 WHERE entry IN (
  15286  -- Xil'xix                        (Normal -> Elite, HM 1.3 -> 45)
);

-- Restored to Elite -- HealthMultiplier 1.5  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 1.5 WHERE entry IN (
  7735   -- Felcular                       (Normal -> Elite, HM 1 -> 1.5)
);

-- ============================================================================
-- Verification -- after apply, this should report 0 deviations from vanilla
-- on BOTH columns (cross-check against wow-dbc/vm_world via the methodology
-- query):
--
--   SELECT v.entry, v.name, v.rank AS van_rank, c.Rank AS tbc_rank,
--          v.health_multiplier AS van_hm, c.HealthMultiplier AS tbc_hm
--   FROM vm_world.creature_template v
--   JOIN (SELECT entry, MAX(patch) mp FROM vm_world.creature_template
--         GROUP BY entry) m ON m.entry=v.entry AND m.mp=v.patch
--   JOIN cm_world.creature_template c ON c.Entry = v.entry
--   WHERE v.rank <> c.Rank;
--   -- (cm_world is the unchanged reference; runtime tbcmangos should match
--   -- vm_world after this file applies.)
-- ============================================================================
