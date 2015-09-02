scope HeroStatsSystem
    
    globals
        //Time for Displaying Hero Stats
        constant real TEXT_DURATION = 25.00
    endglobals
    
    struct HeroData extends array
        //Hero Name
        static string array name
        //Seperator
        static string array seperator
         //Hero Primary Attribute
        static string array primaryAttribute
        //Hero Attribute Values
        static string array attributeValues
        //Affilation
        static string array affiliation
        //Gender
        static string array gender
        //Race
        static string array unitRace
        //Hero Role
        static string array role
        //Movement Speed
        static string array ms
        //Cooldown
        static string array cooldown
        //Range
        static string array range
        //Hero Description
        static string array desc
        
        /*
         * This function defines all Hero Data
         */
        static method initialize takes nothing returns nothing
            
            /* 
             * Undead Heroes
             */
            set .name[0] = "Behemot"
            set .primaryAttribute[0] = "Strength"
            set .attributeValues[0] = "STR: |cffff00002.9|r   |cffffcc00INT:|r |cffff00002.3|r   |cffffcc00AGI:|r |cffff00001.2|r"
            set .seperator[0] = "---------------"
            set .affiliation[0] = "Undead"
            set .gender[0] = "Male"
            set .unitRace[0] = "Undead"
            set .role[0] = "Slayer"
            set .ms[0] = "305"
            set .cooldown[0] = "1.8"
            set .range[0] = "Melee"
            set .desc[0] = "An uncanny rider of legends old. Mundzuk's sole name would terrorize the travelling merchants, his favorite kind of prey. He and his pet have been brought back to life by the Wizard to fight alongside his minions and lead them into victory. Merciless and brutal, few consider him to even be a man."
            
            set .name[1] = "Nerubian Widow"
            set .primaryAttribute[1] = "Agility"
            set .attributeValues[1] = "STR: |cffff00001.7|r   |cffffcc00INT:|r |cffff00001.90|r   |cffffcc00AGI:|r |cffff00002.4|r"
            set .seperator[1] = "---------------"
            set .affiliation[1] = "Undead"
            set .gender[1] = "Female"
            set .unitRace[1] = "Nerubian"
            set .role[1] = "Hunter"
            set .ms[1] = "295"
            set .cooldown[1] = "1.7"
            set .range[1] = "500"
            set .desc[1] = "Crawling forth from underground, the Widow catches her preys in silence and slowly poisons them to death. She kills to feed herrself and her kin, but most times she just does it for fun."
            
            set .name[2] = "Ice Avatar"
            set .primaryAttribute[2] = "Strength"
            set .attributeValues[2] = "STR: |cffff00001.4|r   |cffffcc00INT:|r |cffff00003.3|r   |cffffcc00AGI:|r |cffff00001.3|r"
            set .seperator[2] = "---------------"
            set .affiliation[2] = "Undead"
            set .gender[2] = "Male"
            set .unitRace[2] = "Elementar"
            set .role[2] = "Magician"
            set .ms[2] = "300"
            set .cooldown[2] = "1.7"
            set .range[2] = "600"
            set .desc[2] = "A court buffon sacrificed by his lord for his dull and embarrassing jokes. Forced to die frozen under the snow, magic and fate brought him back to crack fewer smiles than skulls. A master of Ice knows better that, as they say, revenge is a dish best served cold."
            
            set .name[3] = "Ghoul"
            set .primaryAttribute[3] = "Agility"
            set .attributeValues[3] = "STR: |cffff00002.0|r   |cffffcc00INT:|r |cffff00000.7|r   |cffffcc00AGI:|r |cffff00002.6|r"
            set .seperator[3] = "---------------"
            set .affiliation[3] = "Undead"
            set .gender[3] = "Male"
            set .unitRace[3] = "Undead"
            set .role[3] = "Hunter"
            set .ms[3] = "360"
            set .cooldown[3] = "1.65"
            set .range[3] = "Melee"
            set .desc[3] = "Edmund Shieldbearer, former General of the Regnum's army and an example of grace, honor and military cunning to friend and foe alike. His departure wasn't as painful to his brethren as his rebirth at the hands of the Wizard. He fights fearless and crazed, breaking the bones and souls of his old comrades before they can even gasp."
            
            set .name[4] = "Master Banshee"
            set .primaryAttribute[4] = "Intelligence"
            set .attributeValues[4] = "STR: |cffff00001.7|r   |cffffcc00INT:|r |cffff00002.8|r   |cffffcc00AGI:|r |cffff00001.6|r"
            set .seperator[4] = "---------------"
            set .affiliation[4] = "Undead"
            set .gender[4] = "Female"
            set .unitRace[4] = "Ghost"
            set .role[4] = "Magician"
            set .ms[4] = "270"
            set .cooldown[4] = "1.8"
            set .range[4] = "600"
            set .desc[4] = "Beware of old Lady Venefica, wielder of dark magic and profane curses. Should you find yourself alone in the night, amongst the cry of a thousand childs, rest assure she's around, and your death is certain to come. Hush, hush, baby. Go to sleep and let momma drain away your soul."
            
            set .name[5] = "Death Marcher"
            set .primaryAttribute[5] = "Strength"
            set .attributeValues[5] = "STR: |cffff00003.0|r   |cffffcc00INT:|r |cffff00001.9|r   |cffffcc00AGI:|r |cffff00001.6|r"
            set .seperator[5] = "---------------"
            set .affiliation[5] = "Undead"
            set .gender[5] = "Male"
            set .unitRace[5] = "Ghost"
            set .role[5] = "Defender"
            set .ms[5] = "270"
            set .cooldown[5] = "2.2"
            set .range[5] = "100"
            set .desc[5] = "The General of the Knights d'Or, the smallest yet strongest army ever to have marched on the fields of battle. His noble heart was stabbed by the Wizard disguised as King Mithas, his closest friend. What was left became the Death Marcher, a wall of steel and black magic. The Bastion's Gatekeeper."
            
            set .name[6] = "Skeleton Mage"
            set .seperator[6] = "---------------"
            set .primaryAttribute[6] = "Intelligence"
            set .attributeValues[6] = "STR: |cffff00001.3|r   |cffffcc00INT:|r |cffff00003.8|r   |cffffcc00AGI:|r |cffff00000.9|r"
            set .affiliation[6] = "Undead"
            set .gender[6] = "Male"
            set .unitRace[6] = "Undead"
            set .role[6] = "Magician"
            set .ms[6] = "295"
            set .cooldown[6] = "1.5"
            set .range[6] = "600"
            set .desc[6] = "This dark magician and soul devouring creature is what remains of the leader of the Magi's Guild, nemesis to the Wizard for having vanquished his clan. A 'treason' for which he has been punished with servitude in eternal undeath. Not without first making his flesh rot and peel off his very bones."
            
            set .name[7] = "Master Necromancer"
            set .seperator[7] = "---------------"
            set .primaryAttribute[7] = "Intelligence"
            set .attributeValues[7] = "STR: |cffff00001.3|r   |cffffcc00INT:|r |cffff00003.8|r   |cffffcc00AGI:|r |cffff00001.1|r"
            set .affiliation[7] = "Undead"
            set .gender[7] = "Male"
            set .unitRace[7] = "Undead"
            set .role[7] = "Magician"
            set .ms[7] = "240"
            set .cooldown[7] = "1.7"
            set .range[7] = "600"
            set .desc[7] = "Necromancy is the Wizard's specialty, but Kakos is the best in the field. A dedicated conjurer that walks the line between life and death without the need to actually 'die'. A powerful summoner very well deserving of the title of Master Necromancer."
            
            set .name[8] = "Crypt Lord"
            set .seperator[8] = "---------------"
            set .primaryAttribute[8] = "Intelligence"
            set .attributeValues[8] = "STR: |cffff00002.7|r   |cffffcc00INT:|r |cffff00001.4|r   |cffffcc00AGI:|r |cffff00001.8|r"
            set .affiliation[8] = "Undead"
            set .gender[8] = "Male"
            set .unitRace[8] = "Nerubian"
            set .role[8] = "Slayer"
            set .ms[8] = "285"
            set .cooldown[8] = "1.85"
            set .range[8] = "Melee"
            set .desc[8] = "It is thought to have been a subject of worship in ancient times because of the luxurious Tomb he was found in. Most likely the last of his kind, he's the Wizard's latest pet. With a carapace stronger than steel, quicker than a fleeing rat and the ability to burrow and attack from below. Not to mention the swarm of beetles that march with it."
            
            set .name[9] = "Abomination"
            set .seperator[9] = "---------------"
            set .primaryAttribute[9] = "Strength"
            set .attributeValues[9] = "STR: |cffff00002.9|r   |cffffcc00INT:|r |cffff00001.5|r   |cffffcc00AGI:|r |cffff00001.5|r"
            set .affiliation[9] = "Undead"
            set .gender[9] = "Male"
            set .unitRace[9] = "Undead"
            set .role[9] = "Slayer"
            set .ms[9] = "285"
            set .cooldown[9] = "1.95"
            set .range[9] = "Melee"
            set .desc[9] = "There's a steam machine, deep within the Bastion that creates creatures out 'parts' en masse. Blight Cleaver, is one of them. Able to march, cleave and eat his way through a whole batallion. Unlike his peers, he's smart. Not only he has the brawns; he's got the brains."
            
            set .name[10] = "Destroyer"
            set .seperator[10] = "---------------"
            set .primaryAttribute[10] = "Intelligence"
            set .attributeValues[10] = "STR: |cffff00002.1|r   |cffffcc00INT:|r |cffff00002.0|r   |cffffcc00AGI:|r |cffff00002.0|r"
            set .affiliation[10] = "Undead"
            set .gender[10] = "Male"
            set .unitRace[10] = "Undead"
            set .role[10] = "Slayer"
            set .ms[10] = "320"
            set .cooldown[10] = "1.35"
            set .range[10] = "500"
            set .desc[10] = "A renegade mage and archaelogist, an expert in forbidden spells and tombs. His essence has been imprisoned in an ancient obsidian statue that, with the promise of a new body has become the Wizard's official executioner. With  psionic power and magic he, quite literally, takes the life out of his foes."
            
            set .name[11] = "Dread Lord"
            set .seperator[11] = "---------------"
            set .primaryAttribute[11] = "Intelligence"
            set .attributeValues[11] = "STR: |cffff00002.0|r   |cffffcc00INT:|r |cffff00003.4|r   |cffffcc00AGI:|r |cffff00001.0|r"
            set .affiliation[11] = "Undead"
            set .gender[11] = "Male"
            set .unitRace[11] = "Undead"
            set .role[11] = "Supporter"
            set .ms[11] = "270"
            set .cooldown[11] = "1.9"
            set .range[11] = "Melee"
            set .desc[11] = "Tristan was nothing but snake in life and even in death. Betraying King Mithas for a position in the Forsaken's realm. He marches into battle making good use of his abilities to disrupt his enemies plans and leave them open for his undead brethren to take the win. He's a snake, but the good kind of snake."
            
            set .name[23] = "Dark Ranger"
            set .seperator[23] = "---------------"
            set .primaryAttribute[23] = "Intelligence"
            set .attributeValues[23] = "STR: |cffff00001.9|r   |cffffcc00INT:|r |cffff00002.6|r   |cffffcc00AGI:|r |cffff00001.7|r"
            set .affiliation[23] = "Undead"
            set .gender[23] = "Female"
            set .unitRace[23] = "Undead"
            set .role[23] = "Hunter"
            set .ms[23] = "320"
            set .cooldown[23] = "2.35"
            set .range[23] = "700"
            set .desc[23] = "The deadliest woman to hold a bow. Many rumours have been spread about her but none is as terrifying as reality. Once she's fixed on a prey she doesn't give up until blood is spilled. She's a mercenary used to work alone, but her skills, when correctly applied, can be the key to a major battle."
            
            /* 
             * Coalition Heroes
             */
             
            set .name[24] = "Blood Mage"
            set .seperator[24] = "---------------"
            set .primaryAttribute[24] = "Intelligence"
            set .attributeValues[24] = "STR: |cffff00001.9|r   |cffffcc00INT:|r |cffff00002.8|r   |cffffcc00AGI:|r |cffff00001.2|r"
            set .affiliation[24] = "Coalition"
            set .gender[24] = "Male"
            set .unitRace[24] = "Blood Elf"
            set .role[24] = "Magician"
            set .ms[24] = "300"
            set .cooldown[24] = "2.00"
            set .range[24] = "600"
            set .desc[24] = "A Mage that turned to politics long ago. Driven to war by true love and the promise of a sizeable inheritance. Despite having lost the habit of practice he's one of the best mages the Regnum has to offer. He specializes in Fire control and burning his foes to ashes."
            
            set .name[12] = "Archmage"
            set .seperator[12] = "---------------"
            set .primaryAttribute[12] = "Intelligence"
            set .attributeValues[12] = "STR: |cffff00001.7|r   |cffffcc00INT:|r |cffff00002.7|r   |cffffcc00AGI:|r |cffff00001.6|r"
            set .affiliation[12] = "Coalition"
            set .gender[12] = "Male"
            set .unitRace[12] = "Human"
            set .role[12] = "Magician"
            set .ms[12] = "320"
            set .cooldown[12] = "1.95"
            set .range[12] = "600"
            set .desc[12] = "Former Archmage of the Magi's Guild and the only one to survive the masacre that disbanded his order. A powerful caster, capable of raining fire on his enemies, or even taking control of their minds. He's out for revenge, but secretly he seeks power and control: Black Magic and the Forsaken's army."
            
            set .name[21] = "Paladin"
            set .seperator[21] = "---------------"
            set .primaryAttribute[21] = "Strength"
            set .attributeValues[21] = "STR: |cffff00002.5|r   |cffffcc00INT:|r |cffff00001.6|r   |cffffcc00AGI:|r |cffff00001.3|r"
            set .affiliation[21] = "Coalition"
            set .gender[21] = "Male"
            set .unitRace[21] = "Human"
            set .role[21] = "Defender"
            set .ms[21] = "270"
            set .cooldown[21] = "1.90"
            set .range[21] = "Melee"
            set .desc[21] = "Edgar Shieldbearer, Master Paladin of the Order of the Sun is a devout defender of the common men and the Church of the Twin Suns' teachings. As so, he wields not only a great warhammer but the defensive skills of a true champion. He's come to fight the last battle to vanquish the darkness and to fulfill the grim task of killing his own undead brother, Edmund."
            
            set .name[22] = "Royal Knight"
            set .seperator[22] = "---------------"
            set .primaryAttribute[22] = "Strength"
            set .attributeValues[22] = "STR: |cffff00002.9|r   |cffffcc00INT:|r |cffff00001.8|r   |cffffcc00AGI:|r |cffff00001.6|r"
            set .affiliation[22] = "Coalition"
            set .gender[22] = "Male"
            set .unitRace[22] = "Human"
            set .role[22] = "Slayer"
            set .ms[22] = "280"
            set .cooldown[22] = "1.95"
            set .range[22] = "Melee"
            set .desc[22] = "The Royal Knight Darius is one of an elite batallion of heavilly armored riders. Smart and strong, he uses his fast horse and simple tactics combined with raw power to surprise and destroy his enemies. For as strong and fearless as he may be, the war against the undead has changed him. He feels doom approaching, a feeling of dread. Of his own death? Or of your own defeat?"
            
            set .name[13] = "Tauren Chieftain"
            set .seperator[13] = "---------------"
            set .primaryAttribute[13] = "Strength"
            set .attributeValues[13] = "STR: |cffff00002.6|r   |cffffcc00INT:|r |cffff00001.5|r   |cffffcc00AGI:|r |cffff00001.7|r"
            set .affiliation[13] = "Coalition"
            set .gender[13] = "Male"
            set .unitRace[13] = "Orc"
            set .role[13] = "Slayer"
            set .ms[13] = "285"
            set .cooldown[13] = "2.10"
            set .range[13] = "Melee"
            set .desc[13] = "The 'Tau Nabi' or 'Prophet of the Tau' is on a quest to lead his enslaved people to the freedom they've long forgotten. Exiled from their own land, the Tau fight the Forsaken for survival. They say Baccar's every blow is fuel by the Shams, the Sun God."
            
            set .name[16] = "Orcish Warlock"
            set .seperator[16] = "---------------"
            set .primaryAttribute[16] = "Agility"
            set .attributeValues[16] = "STR: |cffff00001.7|r   |cffffcc00INT:|r |cffff00002.1|r   |cffffcc00AGI:|r |cffff00002.5|r"
            set .affiliation[16] = "Coalition"
            set .gender[16] = "Male"
            set .unitRace[16] = "Orc"
            set .role[16] = "Supporter"
            set .ms[16] = "290"
            set .cooldown[16] = "1.8"
            set .range[16] = "600"
            set .desc[16] = "The leader of the Ajdar Tribe, the strongest among the Bel'Trama, Sahkra is as proud as he is cunning and a powerful sorcerer. His honor has been shamed when captured by the Tau and forced out of his land to fight the Forsaken. To regain his pride he must first prove his men he can stomp the undead like roaches."
            
            set .name[20] = "Cenarius"
            set .seperator[20] = "----------"
            set .primaryAttribute[20] = "Intelligence"
            set .attributeValues[20] = "STR: |cffff00002.8|r   |cffffcc00INT:|r |cffff00003.6|r   |cffffcc00AGI:|r |cffff00000.9|r"
            set .affiliation[20] = "Coalition"
            set .gender[20] = "Male"
            set .unitRace[20] = "Night Elf"
            set .role[20] = "Magician"
            set .ms[20] = "350"
            set .cooldown[20] = "2.01"
            set .range[20] = "650"
            set .desc[20] = "An age old mage that became one with nature. He's Anahi's mentor and guide. Through his teachings, she and the Order of the Moon, became one of the gratest powers in the region. He's a legend come true, but he fears this battle will be his last service to his Goddess. A vital one, yet one that may require a great sacrifice."
            
            set .name[14] = "Priestess of the Moon"
            set .seperator[14] = "-------------------------"
            set .primaryAttribute[14] = "Intelligence"
            set .attributeValues[14] = "STR: |cffff00001.7|r   |cffffcc00INT:|r |cffff00001.9|r   |cffffcc00AGI:|r |cffff00002.4|r"
            set .affiliation[14] = "Coalition"
            set .gender[14] = "Female"
            set .unitRace[14] = "Night Elf"
            set .role[14] = "Supporter"
            set .ms[14] = "325"
            set .cooldown[14] = "2.10"
            set .range[14] = "650"
            set .desc[14] = "A young girl devoted to her Goddess that leads the Order against the Forsaken. Her accomplishments are many but the truth behind her prophecies is about to be put to a test."
            
            set .name[18] = "Fire Panda"
            set .seperator[18] = "---------------"
            set .primaryAttribute[18] = "Agility"
            set .attributeValues[18] = "STR: |cffff00001.8|r   |cffffcc00INT:|r |cffff00002.0|r   |cffffcc00AGI:|r |cffff00002.0|r"
            set .affiliation[18] = "Coalition"
            set .gender[18] = "Male"
            set .unitRace[18] = "Pandaren"
            set .role[18] = "Slayer"
            set .ms[18] = "310"
            set .cooldown[18] = "1.90"
            set .range[18] = "Melee"
            set .desc[18] = "A Master of alchemy, Pan'Chou brewed a potion that granted him control over fire, and made him into a furry panda! He was banned from the Magi's Guild, his only true love, and now that it's been destroyed by the Forsaken, Master Pan'Chou is out for revenge."
            
            set .name[15] = "Naga Matriarch"
            set .seperator[15] = "------------------"
            set .primaryAttribute[15] = "Agility"
            set .attributeValues[15] = "STR: |cffff00002.9|r   |cffffcc00INT:|r |cffff00001.8|r   |cffffcc00AGI:|r |cffff00002.3|r"
            set .affiliation[15] = "Coalition"
            set .gender[15] = "Female"
            set .unitRace[15] = "Naga"
            set .role[15] = "Defender"
            set .ms[15] = "285"
            set .cooldown[15] = "1.6"
            set .range[15] = "600"
            set .desc[15] = "The Witch from ancient tales. Sa'gara can control the waves and struck her enemies with the sea's might. She's never seen the land nor men's civilization but she's learned about them from a king lost in the sea. Upon reaching men's shores she find the War and must now choose a side."
            
            set .name[26] = "Giant Turtle"
            set .seperator[26] = "---------------"
            set .primaryAttribute[26] = "Agility"
            set .attributeValues[26] = "STR: |cffff00002.3|r   |cffffcc00INT:|r |cffff00001.9|r   |cffffcc00AGI:|r |cffff00000.9|r"
            set .affiliation[26] = "Coalition"
            set .gender[26] = "Male"
            set .unitRace[26] = "Tortoise"
            set .role[26] = "Defender"
            set .ms[26] = "265"
            set .cooldown[26] = "1.90"
            set .range[26] = "Melee"
            set .desc[26] = "coming soon..."
            
            set .name[17] = "Farseer"
            set .seperator[17] = "---------"
            set .primaryAttribute[17] = "Intelligence"
            set .attributeValues[17] = "STR: |cffff00002.0|r   |cffffcc00INT:|r |cffff00002.9|r   |cffffcc00AGI:|r |cffff00001.2|r"
            set .affiliation[17] = "Coalition"
            set .gender[17] = "Male"
            set .unitRace[17] = "Orc"
            set .role[17] = "Magician"
            set .ms[17] = "320"
            set .cooldown[17] = "2.10"
            set .range[17] = "600"
            set .desc[17] = "A lone and peaceful hermit, yet, the most powerful mage among the Bel'Trama. Some consider him to be a demigod for how tuned in he is with the Other Realm. He has accompanied his friend, Sahkra, to what he believes will be his last moments in this plane..."
            
            set .name[19] = "Mountain Giant"
            set .seperator[19] = "------------------"
            set .primaryAttribute[19] = "Strength"
            set .attributeValues[19] = "STR: |cffff00004.5|r   |cffffcc00INT:|r |cffff00001.0|r   |cffffcc00AGI:|r |cffff00001.0|r"
            set .affiliation[19] = "Coalition"
            set .gender[19] = "Male"
            set .unitRace[19] = "Night Elf"
            set .role[19] = "Defender"
            set .ms[19] = "270"
            set .cooldown[19] = "4.00"
            set .range[19] = "Melee"
            set .desc[19] = "From the time of his amazing appearance -falling from the skies and saving Anahi and Ta'Ta- he has safeguarded his young master of all dangers. A walking wall of mysterious yet divine origin, he serves the Oracle and the Order fearing nothing. Not even the Forsaken."
            
            set .name[25] = "Ogre Warrior"
            set .seperator[25] = "---------------"
            set .primaryAttribute[25] = "Strength"
            set .attributeValues[25] = "STR: |cffff00003.0|r   |cffffcc00INT:|r |cffff00001.3|r   |cffffcc00AGI:|r |cffff00002.1|r"
            set .affiliation[25] = "Coalition"
            set .gender[25] = "Male"
            set .unitRace[25] = "Ogre"
            set .role[25] = "Slayer"
            set .ms[25] = "295"
            set .cooldown[25] = "2.1"
            set .range[25] = "Melee"
            set .desc[25] = "The last of a Bel'trama clan called the Abbari. He's a giant blob of fat and pure brawns, a tank with a skin hard as stone. He seeks to avenge his people, killed by the Aj'dar, but in the middle of the war he must choose a side carefully to survive."
        
        endmethod
    endstruct
    
    struct HeroStats
    
        static method show takes integer pid, integer index returns nothing
            if (GetLocalPlayer() == Player(pid)) then
                call ClearTextMessages()
            endif
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "|cffffff00" + HeroData.name[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "|cffffcc00" + HeroData.seperator[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Primary Attribute: |cffffcc00" + HeroData.primaryAttribute[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Attribute Values: |cffffcc00" + HeroData.attributeValues[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Affiliation: |cffffcc00" + HeroData.affiliation[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Gender: |cffffcc00" + HeroData.gender[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Race: |cffffcc00" + HeroData.unitRace[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Role: |cffffcc00" + HeroData.role[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Movement Speed: |cffffcc00" + HeroData.ms[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Cooldown: |cffffcc00" + HeroData.cooldown[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Range: |cffffcc00" + HeroData.range[index] + "|r")
            call DisplayTimedTextToPlayer(Player(pid), 0.00, 0.00, TEXT_DURATION, "Description: |cffffcc00" + HeroData.desc[index] + "|r")
        endmethod
        
        static method onSelection takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer pid = GetConvertedPlayerId(p)
            local integer selectedUnitId = GetUnitTypeId(GetTriggerUnit())
            local integer i = 0
            local race r = GetPlayerRace(p)
            local race h
            local boolean b = false
            
            loop
                exitwhen i >= GET_MAX_HEROES()
                if GET_HERO(i) == selectedUnitId and /*
                */ IsUnitOwnedByPlayer(GetTriggerUnit(), Player(PLAYER_NEUTRAL_PASSIVE)) then
                    set h = GetUnitRace(FirstOfGroup(GetUnitsOfPlayerAndTypeId(Player(PLAYER_NEUTRAL_PASSIVE), GET_HERO(i))))
                    if ( r == RACE_UNDEAD ) then
                        if ( h == r ) then
                            call show(pid-1, i)
                        endif
                    else
                        if ( (h == r) or (h == RACE_OTHER) ) then
                            call show(pid-1, i)
                        else
                            if (GetLocalPlayer() == p) then
                                call ClearTextMessages()
                            endif
                            call Usability.getTextMessage(0, 6, true, p, true, 0.1)
                        endif
                    endif 
                    set i = GET_MAX_HEROES()
                endif
                set i = i + 1
            endloop
        endmethod
        
        static method initialize takes nothing returns nothing
            local trigger t = CreateTrigger()
            local integer i = 0
            
			loop
                exitwhen i >= bj_MAX_PLAYERS
                //Checking for Players and Bots
                if ( Game.isPlayerInGame(i) ) then
                    call RegisterPlayerUnitEventForPlayer(EVENT_PLAYER_UNIT_SELECTED, null, function thistype.onSelection, Player(i))
                endif
                set i = i + 1
            endloop
       
            //Cleanup
            set t = null
        endmethod
        
    endstruct
    
endscope