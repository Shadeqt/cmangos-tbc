-- ============================================================================
-- Uninstall counterpart for 001_revert_2.3.0_creature_rank_and_hp_world.sql
--
-- Restores TBC 2.4.3 stock values (cm_world truth) on creature_template for
-- the same 297 creatures the install file modifies, in `Rank` and
-- `HealthMultiplier` columns. Use to undo the vanilla revert if the module
-- is removed.
--
-- Grouped by (tbc_rank, tbc_HealthMultiplier) histogram desc: the largest
-- group (rank=0, HM=1.0 — creatures TBC demoted to Normal with 1.0 HP
-- scaling) comes first, then progressively smaller groups. Each inline
-- comment records the vanilla → TBC transition for that entry.
--
-- Source: zzDocumentation/Research/TBC/data/creature_rank_changes.csv
--         (plus a cross-DB query against wow-dbc cm_world for the TBC
--         HealthMultiplier values, which the CSV does not record)
-- ============================================================================

-- Restored to TBC Normal -- HealthMultiplier 1  (104 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1 WHERE entry IN (
     314,  -- Eliza                          (Rank 1 -> 0, HM 3 -> 1)
     397,  -- Morganth                       (Rank 1 -> 0, HM 3 -> 1)
     436,  -- Blackrock Shadowcaster         (Rank 1 -> 0, HM 3 -> 1)
     594,  -- Defias Henchman                (Rank 1 -> 0, HM 3 -> 1)
     619,  -- Defias Conjurer                (Rank 1 -> 0, HM 3 -> 1)
     623,  -- Skeletal Miner                 (Rank 1 -> 0, HM 3 -> 1)
     624,  -- Undead Excavator               (Rank 1 -> 0, HM 3 -> 1)
     625,  -- Undead Dynamiter               (Rank 1 -> 0, HM 3 -> 1)
    1051,  -- Dark Iron Dwarf                (Rank 1 -> 0, HM 3 -> 1)
    1052,  -- Dark Iron Saboteur             (Rank 1 -> 0, HM 3 -> 1)
    1053,  -- Dark Iron Tunneler             (Rank 1 -> 0, HM 3 -> 1)
    1054,  -- Dark Iron Demolitionist        (Rank 1 -> 0, HM 3 -> 1)
    1178,  -- Mo'grosh Ogre                  (Rank 1 -> 0, HM 3 -> 1)
    1179,  -- Mo'grosh Enforcer              (Rank 1 -> 0, HM 3 -> 1)
    1180,  -- Mo'grosh Brute                 (Rank 1 -> 0, HM 3 -> 1)
    1181,  -- Mo'grosh Shaman                (Rank 1 -> 0, HM 3 -> 1)
    1183,  -- Mo'grosh Mystic                (Rank 1 -> 0, HM 3 -> 1)
    1225,  -- Ol' Sooty                      (Rank 1 -> 0, HM 3 -> 1)
    1364,  -- Balgaras the Foul              (Rank 1 -> 0, HM 5 -> 1)
    1388,  -- Vagash                         (Rank 1 -> 0, HM 3 -> 1)
    1725,  -- Defias Watchman                (Rank 1 -> 0, HM 3 -> 1)
    1726,  -- Defias Magician                (Rank 1 -> 0, HM 3 -> 1)
    1891,  -- Pyrewood Watcher               (Rank 1 -> 0, HM 3 -> 1)
    1892,  -- Moonrage Watcher               (Rank 1 -> 0, HM 3 -> 1)
    1893,  -- Moonrage Sentry                (Rank 1 -> 0, HM 3 -> 1)
    1894,  -- Pyrewood Sentry                (Rank 1 -> 0, HM 3 -> 1)
    1895,  -- Pyrewood Elder                 (Rank 1 -> 0, HM 3 -> 1)
    1896,  -- Moonrage Elder                 (Rank 1 -> 0, HM 3 -> 1)
    1947,  -- Thule Ravenclaw                (Rank 1 -> 0, HM 3 -> 1)
    2060,  -- Councilman Smithers            (Rank 1 -> 0, HM 3 -> 1)
    2061,  -- Councilman Thatcher            (Rank 1 -> 0, HM 3 -> 1)
    2062,  -- Councilman Hendricks           (Rank 1 -> 0, HM 3 -> 1)
    2063,  -- Councilman Wilhelm             (Rank 1 -> 0, HM 3 -> 1)
    2064,  -- Councilman Hartin              (Rank 1 -> 0, HM 3 -> 1)
    2065,  -- Councilman Cooper              (Rank 1 -> 0, HM 3 -> 1)
    2066,  -- Councilman Higarth             (Rank 1 -> 0, HM 3 -> 1)
    2067,  -- Councilman Brunswick           (Rank 1 -> 0, HM 3 -> 1)
    2068,  -- Lord Mayor Morrison            (Rank 1 -> 0, HM 3 -> 1)
    2091,  -- Chieftain Nek'rosh             (Rank 1 -> 0, HM 3 -> 1)
    2106,  -- Apothecary Berard              (Rank 1 -> 0, HM 3 -> 1)
    2166,  -- Oakenscowl                     (Rank 1 -> 0, HM 3 -> 1)
    2254,  -- Crushridge Mauler              (Rank 1 -> 0, HM 3 -> 1)
    2255,  -- Crushridge Mage                (Rank 1 -> 0, HM 3 -> 1)
    2256,  -- Crushridge Enforcer            (Rank 1 -> 0, HM 3 -> 1)
    2257,  -- Mug'thol                       (Rank 1 -> 0, HM 3 -> 1)
    2287,  -- Crushridge Warmonger           (Rank 1 -> 0, HM 3 -> 1)
    2304,  -- Captain Ironhill               (Rank 1 -> 0, HM 3 -> 1)
    2344,  -- Dun Garok Mountaineer          (Rank 1 -> 0, HM 3 -> 1)
    2345,  -- Dun Garok Rifleman             (Rank 1 -> 0, HM 3 -> 1)
    2346,  -- Dun Garok Priest               (Rank 1 -> 0, HM 3 -> 1)
    2416,  -- Crushridge Plunderer           (Rank 1 -> 0, HM 3 -> 1)
    2420,  -- Targ                           (Rank 1 -> 0, HM 5 -> 1)
    2421,  -- Muckrake                       (Rank 1 -> 0, HM 3 -> 1)
    2422,  -- Glommus                        (Rank 1 -> 0, HM 3 -> 1)
    2588,  -- Syndicate Prowler              (Rank 1 -> 0, HM 3 -> 1)
    2612,  -- Lieutenant Valorcall           (Rank 1 -> 0, HM 3 -> 1)
    2645,  -- Vilebranch Shadow Hunter       (Rank 1 -> 0, HM 3 -> 1)
    2646,  -- Vilebranch Blood Drinker       (Rank 1 -> 0, HM 3 -> 1)
    2681,  -- Vilebranch Raiding Wolf        (Rank 1 -> 0, HM 3 -> 1)
    2726,  -- Scorched Guardian              (Rank 1 -> 0, HM 3 -> 1)
    2757,  -- Blacklash                      (Rank 1 -> 0, HM 5 -> 1)
    2759,  -- Hematus                        (Rank 1 -> 0, HM 6 -> 1)
    2763,  -- Thenan                         (Rank 1 -> 0, HM 3 -> 1)
    2773,  -- Or'Kalar                       (Rank 1 -> 0, HM 3.25 -> 1)
    3528,  -- Pyrewood Armorer               (Rank 1 -> 0, HM 3 -> 1)
    3529,  -- Moonrage Armorer               (Rank 1 -> 0, HM 3 -> 1)
    3530,  -- Pyrewood Tailor                (Rank 1 -> 0, HM 3 -> 1)
    3531,  -- Moonrage Tailor                (Rank 1 -> 0, HM 3 -> 1)
    3532,  -- Pyrewood Leatherworker         (Rank 1 -> 0, HM 3 -> 1)
    3533,  -- Moonrage Leatherworker         (Rank 1 -> 0, HM 3 -> 1)
    3630,  -- Deviate Coiler                 (Rank 1 -> 0, HM 3 -> 1)
    3631,  -- Deviate Stinglash              (Rank 1 -> 0, HM 3 -> 1)
    3632,  -- Deviate Creeper                (Rank 1 -> 0, HM 3 -> 1)
    3633,  -- Deviate Slayer                 (Rank 1 -> 0, HM 3 -> 1)
    3634,  -- Deviate Stalker                (Rank 1 -> 0, HM 3 -> 1)
    3638,  -- Devouring Ectoplasm            (Rank 1 -> 0, HM 3 -> 1)
    3641,  -- Deviate Lurker                 (Rank 1 -> 0, HM 3 -> 1)
    3655,  -- Mad Magglish                   (Rank 1 -> 0, HM 3 -> 1)
    4050,  -- Cenarion Caretaker             (Rank 1 -> 0, HM 3 -> 1)
    4052,  -- Cenarion Druid                 (Rank 1 -> 0, HM 3 -> 1)
    4061,  -- Mirkfallon Dryad               (Rank 1 -> 0, HM 3 -> 1)
    4064,  -- Blackrock Scout                (Rank 1 -> 0, HM 3 -> 1)
    4065,  -- Blackrock Sentry               (Rank 1 -> 0, HM 3 -> 1)
    4394,  -- Bubbling Swamp Ooze            (Rank 1 -> 0, HM 3 -> 1)
    4409,  -- Gatekeeper Kordurus            (Rank 1 -> 0, HM 3 -> 1)
    4462,  -- Blackrock Hunter               (Rank 1 -> 0, HM 3 -> 1)
    4464,  -- Blackrock Gladiator            (Rank 1 -> 0, HM 3 -> 1)
    4468,  -- Jade Sludge                    (Rank 1 -> 0, HM 3 -> 1)
    4469,  -- Emerald Ooze                   (Rank 1 -> 0, HM 3 -> 1)
    4788,  -- Fallenroot Satyr               (Rank 1 -> 0, HM 3 -> 1)
    4789,  -- Fallenroot Rogue               (Rank 1 -> 0, HM 3 -> 1)
    4802,  -- Blackfathom Tide Priestess     (Rank 1 -> 0, HM 3 -> 1)
    4803,  -- Blackfathom Oracle             (Rank 1 -> 0, HM 3 -> 1)
    5780,  -- Cloned Ectoplasm               (Rank 1 -> 0, HM 3 -> 1)
    6523,  -- Dark Iron Rifleman             (Rank 1 -> 0, HM 3 -> 1)
    6669,  -- The Threshwackonator 4100      (Rank 1 -> 0, HM 2 -> 1)
    7053,  -- Klaven Mortwake                (Rank 1 -> 0, HM 4 -> 1)
    7734,  -- Ilifar                         (Rank 1 -> 0, HM 2 -> 1)
    7735,  -- Felcular                       (Rank 1 -> 0, HM 1.5 -> 1)
    8075,  -- Edana Hatetalon                (Rank 1 -> 0, HM 3 -> 1)
    8447,  -- Clunk                          (Rank 1 -> 0, HM 3 -> 1)
   11721,  -- Hive'Ashi Worker               (Rank 1 -> 0, HM 3 -> 1)
   11921,  -- Besseleth                      (Rank 1 -> 0, HM 3 -> 1)
   12579   -- Bloodfury Ripper               (Rank 1 -> 0, HM 3 -> 1)
);

-- Restored to TBC Normal -- HealthMultiplier 1.15  (34 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.15 WHERE entry IN (
     678,  -- Mosh'Ogg Mauler                (Rank 1 -> 0, HM 3 -> 1.15)
     679,  -- Mosh'Ogg Shaman                (Rank 1 -> 0, HM 3 -> 1.15)
     680,  -- Mosh'Ogg Lord                  (Rank 1 -> 0, HM 3 -> 1.15)
     709,  -- Mosh'Ogg Warmonger             (Rank 1 -> 0, HM 3 -> 1.15)
     710,  -- Mosh'Ogg Spellcrafter          (Rank 1 -> 0, HM 3 -> 1.15)
     723,  -- Mosh'Ogg Butcher               (Rank 2 -> 0, HM 3 -> 1.15)
     728,  -- Bhag'thera                     (Rank 1 -> 0, HM 3.15 -> 1.15)
     730,  -- Tethis                         (Rank 1 -> 0, HM 3.1 -> 1.15)
     871,  -- Saltscale Warrior              (Rank 1 -> 0, HM 3 -> 1.15)
     873,  -- Saltscale Oracle               (Rank 1 -> 0, HM 3 -> 1.15)
     875,  -- Saltscale Tide Lord            (Rank 1 -> 0, HM 3 -> 1.15)
     877,  -- Saltscale Forager              (Rank 1 -> 0, HM 3 -> 1.15)
     879,  -- Saltscale Hunter               (Rank 1 -> 0, HM 3 -> 1.15)
    2558,  -- Witherbark Berserker           (Rank 1 -> 0, HM 3 -> 1.15)
    2583,  -- Stromgarde Troll Hunter        (Rank 1 -> 0, HM 3 -> 1.15)
    2584,  -- Stromgarde Defender            (Rank 1 -> 0, HM 3 -> 1.15)
    2585,  -- Stromgarde Vindicator          (Rank 1 -> 0, HM 3 -> 1.15)
    2607,  -- Prince Galen Trollbane         (Rank 1 -> 0, HM 3 -> 1.15)
    2635,  -- Elder Saltwater Crocolisk      (Rank 1 -> 0, HM 3 -> 1.15)
    2780,  -- Caretaker Nevlin               (Rank 1 -> 0, HM 3 -> 1.15)
    2781,  -- Caretaker Weston               (Rank 1 -> 0, HM 3 -> 1.15)
    2782,  -- Caretaker Alaric               (Rank 1 -> 0, HM 3 -> 1.15)
    2794,  -- Summoned Guardian              (Rank 1 -> 0, HM 3 -> 1.15)
    2892,  -- Stonevault Seer                (Rank 1 -> 0, HM 3 -> 1.15)
    2932,  -- Magregan Deepshadow            (Rank 1 -> 0, HM 3 -> 1.15)
    4844,  -- Shadowforge Surveyor           (Rank 1 -> 0, HM 3 -> 1.15)
    4845,  -- Shadowforge Ruffian            (Rank 1 -> 0, HM 3 -> 1.15)
    4846,  -- Shadowforge Digger             (Rank 1 -> 0, HM 3 -> 1.15)
    4851,  -- Stonevault Rockchewer          (Rank 1 -> 0, HM 3 -> 1.15)
    4872,  -- Obsidian Golem                 (Rank 1 -> 0, HM 3 -> 1.15)
    6733,  -- Stonevault Basher              (Rank 1 -> 0, HM 3 -> 1.15)
    7872,  -- Death's Head Cultist           (Rank 1 -> 0, HM 3 -> 1.15)
    7977,  -- Gammerita                      (Rank 1 -> 0, HM 3.25 -> 1.15)
   10882   -- Arikara                        (Rank 1 -> 0, HM 3 -> 1.15)
);

-- Restored to TBC Normal -- HealthMultiplier 1.25  (30 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.25 WHERE entry IN (
    1788,  -- Skeletal Warlord               (Rank 1 -> 0, HM 3 -> 1.25)
    1827,  -- Scarlet Sentinel               (Rank 1 -> 0, HM 3 -> 1.25)
    1832,  -- Scarlet Magus                  (Rank 1 -> 0, HM 3 -> 1.25)
    1834,  -- Scarlet Paladin                (Rank 1 -> 0, HM 3 -> 1.25)
    4856,  -- Stonevault Cave Hunter         (Rank 1 -> 0, HM 3 -> 1.25)
    5224,  -- Murk Slitherer                 (Rank 1 -> 0, HM 3 -> 1.25)
    5225,  -- Murk Spitter                   (Rank 1 -> 0, HM 3 -> 1.25)
    5235,  -- Fungal Ooze                    (Rank 1 -> 0, HM 3 -> 1.25)
    5243,  -- Cursed Atal'ai                 (Rank 1 -> 0, HM 3 -> 1.25)
    5261,  -- Enthralled Atal'ai             (Rank 1 -> 0, HM 3 -> 1.25)
    5263,  -- Mummified Atal'ai              (Rank 1 -> 0, HM 3 -> 1.25)
    5269,  -- Atal'ai Priest                 (Rank 1 -> 0, HM 3 -> 1.25)
    7041,  -- Black Wyrmkin                  (Rank 1 -> 0, HM 3 -> 1.25)
    7042,  -- Flamescale Dragonspawn         (Rank 1 -> 0, HM 3 -> 1.25)
    7043,  -- Flamescale Wyrmkin             (Rank 1 -> 0, HM 3 -> 1.25)
    7044,  -- Black Drake                    (Rank 1 -> 0, HM 3 -> 1.25)
    7045,  -- Scalding Drake                 (Rank 1 -> 0, HM 3 -> 1.25)
    7046,  -- Searscale Drake                (Rank 1 -> 0, HM 3 -> 1.25)
    7135,  -- Infernal Bodyguard             (Rank 1 -> 0, HM 3 -> 1.25)
    7136,  -- Infernal Sentry                (Rank 1 -> 0, HM 3 -> 1.25)
    7728,  -- Kirith the Damned              (Rank 1 -> 0, HM 4 -> 1.25)
   10608,  -- Scarlet Priest                 (Rank 1 -> 0, HM 3 -> 1.25)
   10737,  -- Shy-Rotam                      (Rank 1 -> 0, HM 4.5 -> 1.25)
   10741,  -- Sian-Rotam                     (Rank 1 -> 0, HM 4.5 -> 1.25)
   10806,  -- Ursius                         (Rank 1 -> 0, HM 4.5 -> 1.25)
   10807,  -- Brumeran                       (Rank 1 -> 0, HM 4 -> 1.25)
   12262,  -- Ziggurat Protector             (Rank 1 -> 0, HM 6 -> 1.25)
   12263,  -- Slaughterhouse Protector       (Rank 1 -> 0, HM 6 -> 1.25)
   12865,  -- Ambassador Malcin              (Rank 1 -> 0, HM 3 -> 1.25)
   14467   -- Kroshius                       (Rank 1 -> 0, HM 6 -> 1.25)
);

-- Restored to TBC Normal -- HealthMultiplier 1.2  (28 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.2 WHERE entry IN (
     626,  -- Foreman Thistlenettle          (Rank 1 -> 0, HM 3 -> 1.2)
    2641,  -- Vilebranch Headhunter          (Rank 1 -> 0, HM 3 -> 1.2)
    2642,  -- Vilebranch Shadowcaster        (Rank 1 -> 0, HM 3 -> 1.2)
    2643,  -- Vilebranch Berserker           (Rank 1 -> 0, HM 3 -> 1.2)
    2644,  -- Vilebranch Hideskinner         (Rank 1 -> 0, HM 3 -> 1.2)
    2647,  -- Vilebranch Soul Eater          (Rank 1 -> 0, HM 3 -> 1.2)
    2648,  -- Vilebranch Aman'zasi Guard     (Rank 1 -> 0, HM 3 -> 1.2)
    4465,  -- Vilebranch Warrior             (Rank 1 -> 0, HM 3 -> 1.2)
    4499,  -- Rok'Alim the Pounder           (Rank 1 -> 0, HM 3 -> 1.2)
    5402,  -- Khan Hratha                    (Rank 1 -> 0, HM 3 -> 1.2)
    5645,  -- Sandfury Hideskinner           (Rank 1 -> 0, HM 3 -> 1.2)
    5646,  -- Sandfury Axe Thrower           (Rank 1 -> 0, HM 3 -> 1.2)
    5647,  -- Sandfury Firecaller            (Rank 1 -> 0, HM 3 -> 1.2)
    5833,  -- Margol the Rager               (Rank 1 -> 0, HM 3 -> 1.2)
    5860,  -- Twilight Dark Shaman           (Rank 1 -> 0, HM 3 -> 1.2)
    5861,  -- Twilight Fire Guard            (Rank 1 -> 0, HM 3 -> 1.2)
    5862,  -- Twilight Geomancer             (Rank 1 -> 0, HM 3 -> 1.2)
    8419,  -- Twilight Idolater              (Rank 1 -> 0, HM 3 -> 1.2)
    9461,  -- Frenzied Black Drake           (Rank 1 -> 0, HM 3 -> 1.2)
   11141,  -- Spirit of Trey Lightforge      (Rank 1 -> 0, HM 3 -> 1.2)
   11777,  -- Shadowshard Rumbler            (Rank 1 -> 0, HM 3 -> 1.2)
   11778,  -- Shadowshard Smasher            (Rank 1 -> 0, HM 3 -> 1.2)
   11781,  -- Ambershard Crusher             (Rank 1 -> 0, HM 3 -> 1.2)
   11782,  -- Ambershard Destroyer           (Rank 1 -> 0, HM 3 -> 1.2)
   11785,  -- Ambereye Basilisk              (Rank 1 -> 0, HM 3 -> 1.2)
   11786,  -- Ambereye Reaver                (Rank 1 -> 0, HM 3 -> 1.2)
   11787,  -- Rock Borer                     (Rank 1 -> 0, HM 3 -> 1.2)
   11788   -- Rock Worm                      (Rank 1 -> 0, HM 3 -> 1.2)
);

-- Restored to TBC Normal -- HealthMultiplier 1.5  (23 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.5 WHERE entry IN (
     813,  -- Colonel Kurzen                 (Rank 1 -> 0, HM 3 -> 1.5)
     818,  -- Mai'Zoth                       (Rank 1 -> 0, HM 3 -> 1.5)
    2597,  -- Lord Falconcrest               (Rank 1 -> 0, HM 7 -> 1.5)
    2611,  -- Fozruk                         (Rank 1 -> 0, HM 3 -> 1.5)
    4056,  -- Mirkfallon Keeper              (Rank 1 -> 0, HM 3 -> 1.5)
    5401,  -- Kazkaz the Unholy              (Rank 1 -> 0, HM 3 -> 1.5)
    6140,  -- Hetaera                        (Rank 1 -> 0, HM 5 -> 1.5)
    7040,  -- Black Dragonspawn              (Rank 1 -> 0, HM 3 -> 1.5)
    7995,  -- Vile Priestess Hexx            (Rank 1 -> 0, HM 5 -> 1.5)
    7996,  -- Qiaga the Keeper               (Rank 1 -> 0, HM 5 -> 1.5)
    8391,  -- Lathoric the Black             (Rank 1 -> 0, HM 5 -> 1.5)
    8400,  -- Obsidion                       (Rank 1 -> 0, HM 7 -> 1.5)
    8636,  -- Morta'gya the Keeper           (Rank 1 -> 0, HM 5 -> 1.5)
   10738,  -- High Chief Winterfall          (Rank 1 -> 0, HM 3 -> 1.5)
   10802,  -- Hitah'ya the Keeper            (Rank 1 -> 0, HM 5 -> 1.5)
   10953,  -- Servant of Horgus              (Rank 1 -> 0, HM 3 -> 1.5)
   11897,  -- Duskwing                       (Rank 1 -> 0, HM 6 -> 1.5)
   14388,  -- Rogue Black Drake              (Rank 1 -> 0, HM 3 -> 1.5)
   14621,  -- Overseer Maltorius             (Rank 1 -> 0, HM 8 -> 1.5)
   15209,  -- Crimson Templar                (Rank 1 -> 0, HM 2.7 -> 1.5)
   15211,  -- Azure Templar                  (Rank 1 -> 0, HM 2.7 -> 1.5)
   15212,  -- Hoary Templar                  (Rank 1 -> 0, HM 2.7 -> 1.5)
   15307   -- Earthen Templar                (Rank 1 -> 0, HM 2.7 -> 1.5)
);

-- Restored to TBC Normal -- HealthMultiplier 1.3  (21 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.3 WHERE entry IN (
    9043,  -- Scarshield Grunt               (Rank 1 -> 0, HM 3 -> 1.3)
    9044,  -- Scarshield Sentry              (Rank 1 -> 0, HM 3 -> 1.3)
   11440,  -- Gordok Enforcer                (Rank 1 -> 0, HM 3 -> 1.3)
   11442,  -- Gordok Mauler                  (Rank 1 -> 0, HM 3 -> 1.3)
   11443,  -- Gordok Ogre-Mage               (Rank 1 -> 0, HM 3 -> 1.3)
   11698,  -- Hive'Ashi Stinger              (Rank 1 -> 0, HM 3 -> 1.3)
   11722,  -- Hive'Ashi Defender             (Rank 1 -> 0, HM 3 -> 1.3)
   11723,  -- Hive'Ashi Sandstalker          (Rank 1 -> 0, HM 2.85 -> 1.3)
   11724,  -- Hive'Ashi Swarmer              (Rank 1 -> 0, HM 3 -> 1.3)
   11725,  -- Hive'Zora Waywatcher           (Rank 1 -> 0, HM 3 -> 1.3)
   11726,  -- Hive'Zora Tunneler             (Rank 1 -> 0, HM 3 -> 1.3)
   11728,  -- Hive'Zora Reaver               (Rank 1 -> 0, HM 3 -> 1.3)
   11729,  -- Hive'Zora Hive Sister          (Rank 1 -> 0, HM 3 -> 1.3)
   11730,  -- Hive'Regal Ambusher            (Rank 1 -> 0, HM 2.85 -> 1.3)
   11731,  -- Hive'Regal Burrower            (Rank 1 -> 0, HM 3 -> 1.3)
   11732,  -- Hive'Regal Spitfire            (Rank 1 -> 0, HM 3 -> 1.3)
   11733,  -- Hive'Regal Slavemaker          (Rank 1 -> 0, HM 3 -> 1.3)
   11734,  -- Hive'Regal Hive Lord           (Rank 1 -> 0, HM 4 -> 1.3)
   15286,  -- Xil'xix                        (Rank 1 -> 0, HM 45 -> 1.3)
   15288,  -- Aluntir                        (Rank 1 -> 0, HM 30 -> 1.3)
   15290   -- Arakis                         (Rank 1 -> 0, HM 30 -> 1.3)
);

-- Restored to TBC Normal -- HealthMultiplier 1.1  (12 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.1 WHERE entry IN (
    2569,  -- Boulderfist Mauler             (Rank 1 -> 0, HM 3 -> 1.1)
    2570,  -- Boulderfist Shaman             (Rank 1 -> 0, HM 3 -> 1.1)
    2571,  -- Boulderfist Lord               (Rank 1 -> 0, HM 3 -> 1.1)
    2590,  -- Syndicate Conjuror             (Rank 1 -> 0, HM 3 -> 1.1)
    2591,  -- Syndicate Magus                (Rank 1 -> 0, HM 3 -> 1.1)
    2783,  -- Marez Cowl                     (Rank 1 -> 0, HM 3 -> 1.1)
    4283,  -- Scarlet Sentry                 (Rank 1 -> 0, HM 3 -> 1.1)
    4284,  -- Scarlet Augur                  (Rank 1 -> 0, HM 3 -> 1.1)
    4285,  -- Scarlet Disciple               (Rank 1 -> 0, HM 3 -> 1.1)
    7873,  -- Razorfen Battleguard           (Rank 1 -> 0, HM 3 -> 1.1)
    7874,  -- Razorfen Thornweaver           (Rank 1 -> 0, HM 3 -> 1.1)
   11920   -- Goggeroc                       (Rank 1 -> 0, HM 3 -> 1.1)
);

-- Restored to TBC Rare -- HealthMultiplier 1.5  (7 creatures)
UPDATE `creature_template` SET `Rank` = 4, HealthMultiplier = 1.5 WHERE entry IN (
     596,  -- Brainwashed Noble              (Rank 2 -> 4, HM 3 -> 1.5)
     599,  -- Marisa du'Paige                (Rank 2 -> 4, HM 3 -> 1.5)
    1063,  -- Jade                           (Rank 2 -> 4, HM 3.25 -> 1.5)
    3672,  -- Boahn                          (Rank 2 -> 4, HM 3 -> 1.5)
    5400,  -- Zekkis                         (Rank 2 -> 4, HM 3 -> 1.5)
    8924,  -- The Behemoth                   (Rank 2 -> 4, HM 5 -> 1.5)
    9046   -- Scarshield Quartermaster       (Rank 2 -> 4, HM 3 -> 1.5)
);

-- Restored to TBC Normal -- HealthMultiplier 1.05  (4 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.05 WHERE entry IN (
    4280,  -- Scarlet Preserver              (Rank 1 -> 0, HM 3 -> 1.05)
    4281,  -- Scarlet Scout                  (Rank 1 -> 0, HM 3 -> 1.05)
    4282,  -- Scarlet Magician               (Rank 1 -> 0, HM 3 -> 1.05)
    6231   -- Techbot                        (Rank 1 -> 0, HM 6 -> 1.05)
);

-- Restored to TBC Normal -- HealthMultiplier 3  (4 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 3 WHERE entry IN (
    2835,  -- Cedrik Prose                   (Rank 1 -> 0, HM 3 -> 3)
    6208,  -- Caverndeep Invader             (Rank 1 -> 0, HM 3 -> 3)
    6210,  -- Caverndeep Pillager            (Rank 1 -> 0, HM 3 -> 3)
    6213   -- Irradiated Invader             (Rank 1 -> 0, HM 3 -> 3)
);

-- Restored to TBC Elite -- HealthMultiplier 8  (4 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 8 WHERE entry IN (
     639,  -- Edwin VanCleef                 (Rank 2 -> 1, HM 8 -> 8)
    9736,  -- Quartermaster Zigris           (Rank 2 -> 1, HM 8 -> 8)
   10584,  -- Urok Doomhowl                  (Rank 2 -> 1, HM 8 -> 8)
   10808   -- Timmy the Cruel                (Rank 2 -> 1, HM 8 -> 8)
);

-- Restored to TBC Elite -- HealthMultiplier 3  (3 creatures)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 3 WHERE entry IN (
    9297,  -- Enraged Wyvern                 (Rank 0 -> 1, HM 3 -> 3)
    9527,  -- Enraged Hippogryph             (Rank 0 -> 1, HM 3 -> 3)
   10917   -- Aurius                         (Rank 0 -> 1, HM 3 -> 3)
);

-- Restored to TBC Normal -- HealthMultiplier 0.75  (2 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 0.75 WHERE entry IN (
    2599,  -- Otto                           (Rank 1 -> 0, HM 3 -> 0.75)
    2738   -- Stromgarde Cavalryman          (Rank 1 -> 0, HM 3 -> 0.75)
);

-- Restored to TBC Normal -- HealthMultiplier 2  (2 creatures)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 2 WHERE entry IN (
    1559,  -- King Mukla                     (Rank 1 -> 0, HM 5 -> 2)
   11896   -- Borelgore                      (Rank 1 -> 0, HM 15 -> 2)
);

-- Restored to TBC Rare Elite -- HealthMultiplier 4  (2 creatures)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 4 WHERE entry IN (
   10899,  -- Goraluk Anvilcrack             (Rank 1 -> 2, HM 4 -> 4)
   15796   -- Christmas Goraluk Anvilcrack   (Rank 1 -> 2, HM 4 -> 4)
);

-- Restored to TBC Rare Elite -- HealthMultiplier 6  (2 creatures)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 6 WHERE entry IN (
   11467,  -- Tsu'zee                        (Rank 1 -> 2, HM 6 -> 6)
   16184   -- Nerubian Overseer              (Rank 1 -> 2, HM 6 -> 6)
);

-- Restored to TBC Boss -- HealthMultiplier 27.5  (2 creatures)
UPDATE `creature_template` SET `Rank` = 3, HealthMultiplier = 27.5 WHERE entry IN (
   11946,  -- Drek'Thar                      (Rank 1 -> 3, HM 50 -> 27.5)
   11948   -- Vanndar Stormpike              (Rank 1 -> 3, HM 50 -> 27.5)
);

-- Restored to TBC Normal -- HealthMultiplier 1.02  (1 creature)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 1.02 WHERE entry IN (
    6132   -- Razorfen Servitor              (Rank 1 -> 0, HM 3 -> 1.02)
);

-- Restored to TBC Normal -- HealthMultiplier 5  (1 creature)
UPDATE `creature_template` SET `Rank` = 0, HealthMultiplier = 5 WHERE entry IN (
   15215   -- Mistress Natalia Mar'alith     (Rank 1 -> 0, HM 10 -> 5)
);

-- Restored to TBC Elite -- HealthMultiplier 3.5  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 3.5 WHERE entry IN (
    3580   -- Crafticus Rabbitus             (Rank 0 -> 1, HM 0.05 -> 3.5)
);

-- Restored to TBC Elite -- HealthMultiplier 5  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 5 WHERE entry IN (
    9025   -- Lord Roccor                    (Rank 2 -> 1, HM 5 -> 5)
);

-- Restored to TBC Elite -- HealthMultiplier 20  (1 creature)
UPDATE `creature_template` SET `Rank` = 1, HealthMultiplier = 20 WHERE entry IN (
   11980   -- Zuluhed the Whacked            (Rank 3 -> 1, HM 5 -> 20)
);

-- Restored to TBC Rare Elite -- HealthMultiplier 3  (1 creature)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 3 WHERE entry IN (
   14346   -- Captain Greshkil               (Rank 1 -> 2, HM 3 -> 3)
);

-- Restored to TBC Rare Elite -- HealthMultiplier 4.5  (1 creature)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 4.5 WHERE entry IN (
   11383   -- High Priestess Hai'watna       (Rank 1 -> 2, HM 4.5 -> 4.5)
);

-- Restored to TBC Rare Elite -- HealthMultiplier 12  (1 creature)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 12 WHERE entry IN (
   14506   -- Lord Hel'nurath                (Rank 1 -> 2, HM 12 -> 12)
);

-- Restored to TBC Rare Elite -- HealthMultiplier 25  (1 creature)
UPDATE `creature_template` SET `Rank` = 2, HealthMultiplier = 25 WHERE entry IN (
   11676   -- Fjordune the Greater           (Rank 1 -> 2, HM 25 -> 25)
);

-- Restored to TBC Boss -- HealthMultiplier 25  (1 creature)
UPDATE `creature_template` SET `Rank` = 3, HealthMultiplier = 25 WHERE entry IN (
   11947   -- Captain Galvangar              (Rank 1 -> 3, HM 40 -> 25)
);

-- Restored to TBC Rare -- HealthMultiplier 0.75  (1 creature)
UPDATE `creature_template` SET `Rank` = 4, HealthMultiplier = 0.75 WHERE entry IN (
    2753   -- Barnabus                       (Rank 0 -> 4, HM 0.75 -> 0.75)
);

-- Restored to TBC Rare -- HealthMultiplier 1.1  (1 creature)
UPDATE `creature_template` SET `Rank` = 4, HealthMultiplier = 1.1 WHERE entry IN (
    7895   -- Ambassador Bloodrage           (Rank 2 -> 4, HM 3 -> 1.1)
);

-- Restored to TBC Rare -- HealthMultiplier 1.25  (1 creature)
UPDATE `creature_template` SET `Rank` = 4, HealthMultiplier = 1.25 WHERE entry IN (
    3652   -- Trigore the Lasher             (Rank 2 -> 4, HM 3 -> 1.25)
);

