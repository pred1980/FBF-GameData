library SkeletonMageSpells initializer onInit requires xedamage, xemissile, GroupUtils, ListModule, SpellSystem, PassiveSpellSystem, Table, AutoIndex, UnitBonus
    //Basic Zombie-Globals
    
    globals
        private integer ZOMBIE_TYPE_COUNT = 0
        private integer array ZOMBIE_TYPE
        
        //Variable required to hook in this Scope from SpawnZombie (Index = Unit-Id from AutoIndex)
        private integer array TEMP_ZOMBIE_DAMAGE_NEW
    endglobals

        
    private function AddZombieType takes integer unitId returns nothing
        set ZOMBIE_TYPE[ZOMBIE_TYPE_COUNT] = unitId
        set ZOMBIE_TYPE_COUNT = ZOMBIE_TYPE_COUNT + 1
    endfunction
    
    function IsUnitZombie takes unit u returns boolean
        local integer i = 0
        local integer id = GetUnitTypeId(u)
        loop
            exitwhen i >= ZOMBIE_TYPE_COUNT
            if id == ZOMBIE_TYPE[i] then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction
    
    scope SpawnZombies
        /*
         * Description: The Traitor summons several zombies in a target area. Zombies will fight alongside him. 
                        They have an disease aura that deals damage over time to nearby enemies. 
                        Zombies are also valid targets for Call of the Damned, but they will die after they got affected by 
                        this ability.
         * Changelog: 
         *     	03.11.2013: Abgleich mit OE und der Exceltabelle
		 *     	23.03.2014: Zombie HP um 50% fuer alle erhoeht
		 *                 Zombie Damage um 20% fuer alle erhoeht
		 *                 Duration um 5s pro Level erhoeht
		 *     	26.03.2014: Anzahl der Zombies von 2/3/4/5/6 auf 2/2/3/3/4 
		 *		29.04.2015: Integrated SpellHelper for filtering
         *
         */
        globals
            private constant integer SPELL_ID = 'A058'
            private integer array ZOMBIE_ID
            private integer array ZOMBIE_SUMMON_AMOUNT
            private integer array ZOMBIE_DURATION
			private integer array ZOMBIE_HP
			private integer array ZOMBIE_DAMAGE
    		
			//New Constants of Version 1.17b
            private real array ZOMBIE_AURA_DAMAGE
            private constant integer ZOMBIE_AURA_ABILITY = 'A059'
            private constant integer ZOMBIE_AURA_EFFECT = 'A05A'
            private constant real ZOMBIE_AURA_RADIUS = 175.00
            private constant real ZOMBIE_AURA_DAMAGE_INTERVAL = 0.50

            //End of New Constants
            private constant real ZOMBIE_SPAWN_AREA = 400.00
            private constant integer ZOMBIE_TIMED_LIFE_BUFF = 'B00L'
            private constant string ZOMBIE_SPAWN_EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
        
			// Dealt damage configuration
			private constant attacktype ZOMBIE_AURA_ATTACK_TYPE = ATTACK_TYPE_MAGIC
			private constant damagetype ZOMBIE_AURA_DAMAGE_TYPE = DAMAGE_TYPE_DEATH
			private constant weapontype ZOMBIE_AURA_WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		endglobals
        
        private function MainSetup takes nothing returns nothing
            set ZOMBIE_ID[0] = 'zom0'
            set ZOMBIE_ID[1] = 'zom1'
            set ZOMBIE_ID[2] = 'zom2'
            set ZOMBIE_ID[3] = 'zom3'
            set ZOMBIE_ID[4] = 'zom4'
            
            set ZOMBIE_SUMMON_AMOUNT[0] = 2
            set ZOMBIE_SUMMON_AMOUNT[1] = 2//3
            set ZOMBIE_SUMMON_AMOUNT[2] = 3//4
            set ZOMBIE_SUMMON_AMOUNT[3] = 3//5
            set ZOMBIE_SUMMON_AMOUNT[4] = 4//6
			
			set ZOMBIE_HP[0] = 225
            set ZOMBIE_HP[1] = 450
            set ZOMBIE_HP[2] = 675
            set ZOMBIE_HP[3] = 900
            set ZOMBIE_HP[4] = 1125
			
			set ZOMBIE_DAMAGE[0] = 11
            set ZOMBIE_DAMAGE[1] = 22
            set ZOMBIE_DAMAGE[2] = 32
            set ZOMBIE_DAMAGE[3] = 43
            set ZOMBIE_DAMAGE[4] = 54
            
            set ZOMBIE_DURATION[0] = 15
            set ZOMBIE_DURATION[1] = 20
            set ZOMBIE_DURATION[2] = 25
            set ZOMBIE_DURATION[3] = 30
            set ZOMBIE_DURATION[4] = 35
			
			set ZOMBIE_AURA_DAMAGE[0] = 7.5
            set ZOMBIE_AURA_DAMAGE[1] = 12.5
            set ZOMBIE_AURA_DAMAGE[2] = 17.5
            set ZOMBIE_AURA_DAMAGE[3] = 22.5
			set ZOMBIE_AURA_DAMAGE[4] = 27.5
			
        endfunction
        
        struct Zombie
            unit zombie = null
            unit summoner = null
            integer lvl = 0
            DamageBonus dmgBoni = 0
            
            static trigger onDeath = null
            
            static timer ticker = null
            static thistype temp = 0
            static boolexpr damageFilter = null
            static delegate xedamage dmg = 0
            
            implement List
            
            private static HandleTable t = 0
            
            static method operator [] takes unit u returns thistype
                return thistype(t[u])
            endmethod
            
            method onDestroy takes nothing returns nothing
                call dmgBoni.remove(true)
                call t.flush(zombie)
                call listRemove()
                if count <= 0 then
                    call PauseTimer(ticker)
                endif

            endmethod
            
            static method updateDamage takes unit zombieOwner returns nothing
                local thistype this = first
                loop
                    exitwhen this == 0
                    if summoner == zombieOwner then
                        call dmgBoni.remove(false)
                        call dmgBoni.add(TEMP_ZOMBIE_DAMAGE_NEW[GetUnitId(summoner)])
                    endif
                    set this = next
                endloop
            endmethod
            
			static method dealAuraDamage takes nothing returns boolean
                local unit u = GetFilterUnit()
				
				if (SpellHelper.isValidEnemy(u, temp.zombie)) then
                    set DamageType = SPELL
                    call damageTarget(temp.zombie, u, ZOMBIE_AURA_DAMAGE[temp.lvl]*ZOMBIE_AURA_DAMAGE_INTERVAL)
                endif
				
                set u = null
				
                return false
            endmethod
            
            static method doAuraDamage takes nothing returns nothing
                local thistype this = first
                loop
                    exitwhen this == 0
                    set temp = this
                    call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(zombie), GetUnitY(zombie), ZOMBIE_AURA_RADIUS, damageFilter)
                    set this = next
                endloop
            endmethod

            static method create takes unit u, integer level, real x, real y returns thistype
                local thistype this = allocate()
                set lvl = level - 1
                
                if ZOMBIE_SPAWN_EFFECT != "" then
                    call DestroyEffect(AddSpecialEffect(ZOMBIE_SPAWN_EFFECT, x, y))
                endif
                
                set zombie = CreateUnit(GetOwningPlayer(u), ZOMBIE_ID[lvl], x, y, GetRandomReal(0.00, 360.00))
                call SetUnitMaxState(zombie, UNIT_STATE_MAX_LIFE, ZOMBIE_HP[lvl])
				call SetUnitState(zombie, UNIT_STATE_LIFE, GetUnitState(zombie, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
				call TDS.addDamage(zombie, ZOMBIE_DAMAGE[lvl])
				call UnitApplyTimedLife(zombie, ZOMBIE_TIMED_LIFE_BUFF, ZOMBIE_DURATION[lvl])
                call UnitAddAbility(zombie, ZOMBIE_AURA_ABILITY)
                call UnitAddAbility(zombie, ZOMBIE_AURA_EFFECT)
                call SetUnitAbilityLevel(zombie, ZOMBIE_AURA_ABILITY, lvl + 1)
                call SetUnitAnimation(zombie, "birth")
                set t[zombie] = integer(this)
                
                set summoner = u
                set dmgBoni = DamageBonus.create(zombie)
                call dmgBoni.add(TEMP_ZOMBIE_DAMAGE_NEW[GetUnitId(summoner)])
                call TriggerRegisterUnitEvent(onDeath, zombie, EVENT_UNIT_DEATH)
                call listAdd()
                if count == 1 then
                    call TimerStart(ticker, ZOMBIE_AURA_DAMAGE_INTERVAL, true, function thistype.doAuraDamage)
                endif
                return this
            endmethod
            
            private static method onUnitDeath takes nothing returns boolean
                local unit u = GetDyingUnit()
                local thistype this = u:thistype
                
				if this != 0 then
                    call destroy()
                endif
				
                set u = null
				
                return false
            endmethod
            
            private static method onInit takes nothing returns nothing
                set onDeath = CreateTrigger()
                call TriggerAddCondition(onDeath, Condition(function thistype.onUnitDeath))
                call XE_PreloadAbility(ZOMBIE_AURA_ABILITY)
                call XE_PreloadAbility(ZOMBIE_AURA_EFFECT)
                call XE_PreloadAbility(ZOMBIE_TIMED_LIFE_BUFF)
                set t = HandleTable.create()
                set ticker = CreateTimer()
                set dmg = xedamage.create()
                set dtype = ZOMBIE_AURA_DAMAGE_TYPE
                set atype = ZOMBIE_AURA_ATTACK_TYPE
				set wtype = ZOMBIE_AURA_WEAPON_TYPE
                set damageFilter = Condition(function thistype.dealAuraDamage)
            endmethod
        endstruct
    
        struct Main
            private static constant integer spellId = SPELL_ID
            private static constant integer spellType = SPELL_TYPE_TARGET_GROUND
            private static constant boolean autoDestroy = false
            
            private method onCast takes nothing returns nothing
                local integer i = 0
                local real zx = 0.00
                local real zy = 0.00

                loop
                    exitwhen i >= ZOMBIE_SUMMON_AMOUNT[lvl - 1]
                    set zx = x + GetRandomReal(0.00, ZOMBIE_SPAWN_AREA) * Cos(GetRandomReal(0.00, 2 * bj_PI))
                    set zy = y + GetRandomReal(0.00, ZOMBIE_SPAWN_AREA) * Sin(GetRandomReal(0.00, 2 * bj_PI))
                    call Zombie.create(caster, lvl, zx, zy)
                    set i = i + 1
                endloop
            endmethod
            
            private static method onInit takes nothing returns nothing
                call MainSetup()
                call Preload(ZOMBIE_SPAWN_EFFECT)
            endmethod
        
            implement Spell        
        
        endstruct
    
        public function UpdateZombieDamage takes unit owner returns nothing
            call Zombie.updateDamage(owner)
        endfunction
    endscope
    
    
    scope SoulExtraction
        /*
         * Description: Whenever Ukko or his minions kill an enemy unit, he will extract its soul as long as he is close enough. 
                        Each soul increases his damage and that of his zombies, and increases the damage and area of effect of 
                        Call of the Damned. Can store up to 10 souls.
         * Changelog: 
         *     	03.11.2013: Abgleich mit OE und der Exceltabelle
		 *		29.04.2015: Integrated SpellHelper for filtering
         *
         */
        globals
            private constant integer SPELL_ID = 'A056'
            private constant integer BUFF_PLACER_ID = 'A057'
            private real array EXTRACTED_SOUL_RANGE
            //Soul Options
            private integer array DAMAGE_BONUS
            private integer array ZOMBIE_DAMAGE_BONUS
            private integer array MAX_SOULS
            private real array SOUL_DURATION
            private real array ULTI_BONUS_DAMAGE
            private real array ULTI_BONUS_RANGE
            //Extracted Soul Missile Options
            private constant string EXTRACTED_SOUL_MISSILE_MODEL = "Models\\SoulExtractionMissile.mdl"
            private constant real EXTRACTED_SOUL_MISSILE_HEIGHT = 10.00
            private constant real EXTRACTED_SOUL_MISSILE_SIZE = 0.75
            private constant real EXTRACTED_SOUL_MISSILE_SPEED = 350.00
            
            private constant real TIMER_INTERVAL = 0.10
        endglobals
  
        private function MainSetup takes nothing returns nothing
            set EXTRACTED_SOUL_RANGE[0] = 500
            set EXTRACTED_SOUL_RANGE[1] = 600
            set EXTRACTED_SOUL_RANGE[2] = 700
            set EXTRACTED_SOUL_RANGE[3] = 800
            set EXTRACTED_SOUL_RANGE[4] = 900
            
            set DAMAGE_BONUS[0] = 1
            set DAMAGE_BONUS[1] = 2
            set DAMAGE_BONUS[2] = 3
            set DAMAGE_BONUS[3] = 4
            set DAMAGE_BONUS[4] = 5
            
            set ZOMBIE_DAMAGE_BONUS[0] = 1
            set ZOMBIE_DAMAGE_BONUS[1] = 2
            set ZOMBIE_DAMAGE_BONUS[2] = 3
            set ZOMBIE_DAMAGE_BONUS[3] = 4
            set ZOMBIE_DAMAGE_BONUS[4] = 5
            
            set MAX_SOULS[0] = 10
            set MAX_SOULS[1] = 10
            set MAX_SOULS[2] = 10
            set MAX_SOULS[3] = 10
            set MAX_SOULS[4] = 10
            
            set SOUL_DURATION[0] = 5.00
            set SOUL_DURATION[1] = 10.00
            set SOUL_DURATION[2] = 15.00
            set SOUL_DURATION[3] = 20.00
            set SOUL_DURATION[4] = 25.00
            
            set ULTI_BONUS_DAMAGE[0] = 2.50
            set ULTI_BONUS_DAMAGE[1] = 5.00
            set ULTI_BONUS_DAMAGE[2] = 7.50
            set ULTI_BONUS_DAMAGE[3] = 10.00
            set ULTI_BONUS_DAMAGE[4] = 12.50
            
            set ULTI_BONUS_RANGE[0] = 3.00
            set ULTI_BONUS_RANGE[1] = 4.50
            set ULTI_BONUS_RANGE[2] = 6.00
            set ULTI_BONUS_RANGE[3] = 7.50
            set ULTI_BONUS_RANGE[4] = 9.00
            
        endfunction
        
        private keyword Main
        
        
        private struct Soul
        
            unit owner = null
            integer lvl = 0
            real counter = 0.00
            
            DamageBonus dmgBoni = 0
            
            private static timer ticker = null
            
            implement List
            
            static method getStoredSouls takes unit u returns integer
                local integer c = 0
                local thistype this = first
                
                loop
                    exitwhen this == 0
                    if owner == u then
                        set c = c + 1
                    endif
                    set this = next
                endloop
                return c
            endmethod
            
            static method checkZombieDamage takes unit u returns nothing
                set TEMP_ZOMBIE_DAMAGE_NEW[GetUnitId(u)] = getStoredSouls(u) * ZOMBIE_DAMAGE_BONUS[u:Main.lvl - 1]
            endmethod
            
            method onDestroy takes nothing returns nothing
                call dmgBoni.remove(true)
                call listRemove()
                call checkZombieDamage(owner)
                call SpawnZombies_UpdateZombieDamage(owner)
                if count <= 0 then
                    call PauseTimer(ticker)
                endif
            endmethod
            
            static method onExpire takes nothing returns nothing
                local thistype this = first
                loop
                    exitwhen this == 0
                    set counter = counter + TIMER_INTERVAL
                    if counter >= SOUL_DURATION[lvl] or IsUnitType(owner, UNIT_TYPE_DEAD) then
                        call destroy()
                    endif
                    set this = next
                endloop
            endmethod
        
        
            static method create takes unit u, integer lv returns thistype
                local thistype this = 0
                if getStoredSouls(u) < MAX_SOULS[lv - 1] then
                    set this = allocate()
                    set owner = u
                    set lvl = lv - 1
                    set dmgBoni = DamageBonus.create(u)
                    call dmgBoni.add(DAMAGE_BONUS[lvl])
                    call listAdd()
                    if count == 1 then
                        call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.onExpire)
                    endif
                endif
                return this
            endmethod
            
            private static method onInit takes nothing returns nothing
                set ticker = CreateTimer()
            endmethod
        endstruct
        
        private struct ExtractedSoulMissile extends xehomingmissile
        
            unit owner = null
            integer lvl = 0
            
            static method create takes unit from, unit to, integer lv returns thistype
                local thistype this = allocate(GetUnitX(from), GetUnitY(from), GetUnitFlyHeight(from), to, EXTRACTED_SOUL_MISSILE_HEIGHT)
                set fxpath = EXTRACTED_SOUL_MISSILE_MODEL
                set scale = EXTRACTED_SOUL_MISSILE_SIZE
                set owner = to
                set lvl = lv
                call launch(EXTRACTED_SOUL_MISSILE_SPEED, GetRandomReal(0.0, 0.25))
                return this
            endmethod
            
            method loopControl takes nothing returns nothing
				if (SpellHelper.isUnitDead(owner)) then
                    call terminate()
                endif
            endmethod
            
            method onHit takes nothing returns nothing
                call terminate()
                call Soul.create(owner, lvl)
                call Soul.checkZombieDamage(owner)
                call SpawnZombies_UpdateZombieDamage(owner)
            endmethod
        endstruct
        
        
        private struct Main
        
            implement List
            
            static constant integer spellId = SPELL_ID
            static constant boolean useDeadEvents = true
            
            method onLearn takes nothing returns nothing
                call UnitAddAbility(owner, BUFF_PLACER_ID)
                call UnitMakeAbilityPermanent(owner, true, BUFF_PLACER_ID)
            endmethod
            
            method onKill takes unit killed returns nothing
				if (SpellHelper.isValidEnemy(killed, owner)) then
                    call ExtractedSoulMissile.create(killed, owner, lvl)
                endif
            endmethod
                
            method onUnitDeath takes unit killer, unit killed returns nothing
                local real dx = GetUnitX(owner) - GetUnitX(killed)
                local real dy = GetUnitY(owner) - GetUnitY(killed)
                local real dist = SquareRoot(dx * dx + dy * dy)

                if (killer != owner and dist <= EXTRACTED_SOUL_RANGE[lvl - 1] and not /*
				*/	SpellHelper.isUnitDead(owner)) then
					if (SpellHelper.isValidEnemy(killed, owner) and /*
					*/	SpellHelper.isValidEnemy(killed, killer) and /*
					*/	GetOwningPlayer(killer) != null) then
                        call ExtractedSoulMissile.create(killed, owner, lvl)
                    endif
                endif
            endmethod
                    
            implement PassiveSpell
            
            private static method onInit takes nothing returns nothing
                call MainSetup()
                call Preload(EXTRACTED_SOUL_MISSILE_MODEL)
                call XE_PreloadAbility(BUFF_PLACER_ID)
            endmethod
        endstruct
        
        public function GetUltiBonusDamage takes unit caster returns real
            return Soul.getStoredSouls(caster) * ULTI_BONUS_DAMAGE[caster:Main.lvl - 1]
        endfunction
        
        public function GetUltiBonusArea takes unit caster returns real
            return Soul.getStoredSouls(caster) * ULTI_BONUS_RANGE[caster:Main.lvl - 1]
        endfunction
        
    endscope
        

    scope CallOfTheDamned
        /*
         * Description: Ukko releases the souls of fallen units in a target area, which deal area of effect damage. 
                        A soul is released every 0.75 seconds but it takes 1.5 seconds till it finally is released. 
                        Zombies created with Spawn Zombies are also valid targets which will die after their soul gets released.
         * Changelog: 
         *     	03.11.2013: Abgleich mit OE und der Exceltabelle
		 *		29.04.2015: Integrated SpellHelper for filtering
         *
         */
        globals
            private constant integer SPELL_ID = 'A05B'
            private constant real TIMER_INTERVAL = 0.05
            private real array SPELL_DURATION
            private real array SPELL_AOE
            
            private constant string GROUND_EFFECT_MODEL = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl"
            private real array GROUND_EFFECT_SCALE
            private constant string GRAVE_STONE_MODEL = "Abilities\\Spells\\Undead\\Graveyard\\GraveMarker.mdl"
            private constant real GRAVE_STONE_SIZE = 0.75
            private constant integer GRAVE_STONE_COUNT = 7
                    
            private constant real SOUL_RELEASE_INTERVAL = 0.75
            private constant string SOUL_RELEASE_TARGET_EFFECT = "Models\\SoulReleaseTarget.mdl"
            private constant real SOUL_RELEASE_TARGET_EFFECT_SCALE  = 0.75
            private constant real SOUL_RELEASE_TARGET_EFFECT_HEIGHT = 0.00
            private constant string SOUL_RELEASE_FINAL_EFFECT = "Models\\SoulRelease.mdl"
            private constant real SOUL_RELEASE_FINAL_EFFECT_SCALE = 0.50
            private constant real SOUL_RELEASE_FINAL_EFFECT_HEIGHT = 0.00
            private constant real SOUL_RELEASE_DAMAGE_AOE = 150.00 
            private real array SOUL_RELEASE_DAMAGE
			
			// Dealt damage configuration
			private constant attacktype SOUL_RELEASE_ATTACK_TYPE = ATTACK_TYPE_MAGIC
            private constant damagetype SOUL_RELEASE_DAMAGE_TYPE = DAMAGE_TYPE_DEATH
            private constant weapontype SOUL_RELEASE_WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        endglobals
        
        private function MainSetup takes nothing returns nothing
            
            set SPELL_DURATION[0] = 6.00
            set SPELL_DURATION[1] = 7.00
            set SPELL_DURATION[2] = 8.00
            
            set SPELL_AOE[0] = 300.00
            set SPELL_AOE[1] = 350.00
            set SPELL_AOE[2] = 400.00
            
            set GROUND_EFFECT_SCALE[0] = 1.10
            set GROUND_EFFECT_SCALE[1] = 1.25
            set GROUND_EFFECT_SCALE[2] = 1.40
            
            set SOUL_RELEASE_DAMAGE[0] = 250
            set SOUL_RELEASE_DAMAGE[1] = 500
            set SOUL_RELEASE_DAMAGE[2] = 750
            
        endfunction
        
        private keyword Soul
        private keyword Main
        
        private struct Soul
        
            delegate Main root = 0
            unit corpse = null
            xefx corpsefx = 0
            boolean isZombie = false
            real counter = 0.00
            
            static HandleTable t  = 0
            static timer ticker = null
            static delegate xedamage dmg = 0
            static boolexpr corpseFilter = null
            static thistype temp = 0
            
            implement List
            
            private static method corpseFilterMethod takes nothing returns boolean
                local unit u = GetFilterUnit()
				local boolean b = false
				
				if (SpellHelper.isUnitDead(u) or /*
				*/	IsUnitZombie(u) and /*
				*/	SpellHelper.isValidAlly(u, temp.caster)	and /*
				*/	t[u] == 0) then
                    set b = true
                endif
				
                set u = null
				
                return b
            endmethod
            
            private method onDestroy takes nothing returns nothing
                call listRemove()
                call SpawnZombies_UpdateZombieDamage(caster)
                if count <= 0 then
                    call PauseTimer(ticker)
                endif
            endmethod
            
            static method onExpire takes nothing returns nothing
                local thistype this = first
                loop
                    exitwhen this == 0
                    set counter = counter + TIMER_INTERVAL
                    if counter >= SOUL_RELEASE_INTERVAL then
                        if isZombie then
                            if not IsUnitType(corpse, UNIT_TYPE_DEAD) then
                                set damageAllies = true
                                set DamageType = SPELL
                                call damageTarget(caster, corpse, GetWidgetLife(corpse) + 100)
                                set damageAllies = false
                            endif
                        endif
                        set corpsefx.z = SOUL_RELEASE_FINAL_EFFECT_HEIGHT
                        set corpsefx.scale = SOUL_RELEASE_FINAL_EFFECT_SCALE
                        call corpsefx.flash(SOUL_RELEASE_FINAL_EFFECT)
                        set DamageType = SPELL
                        call damageAOE(caster, corpsefx.x, corpsefx.y, SOUL_RELEASE_DAMAGE_AOE + SoulExtraction_GetUltiBonusArea(caster), SOUL_RELEASE_DAMAGE[lvl] + SoulExtraction_GetUltiBonusDamage(caster))
                        call corpsefx.destroy()
                        call destroy()
                    else
                        set corpsefx.x = GetUnitX(corpse)
                        set corpsefx.y = GetUnitY(corpse)
                    endif
                    set this = next
                endloop
            endmethod
            
            static method release takes Main which returns boolean
                local thistype this = allocate()
                set root = which
                set temp = this
                call GroupRefresh(ENUM_GROUP)
                call GroupEnumUnitsInRange(ENUM_GROUP, x, y, SPELL_AOE[lvl], corpseFilter)
                set corpse = GroupPickRandomUnit(ENUM_GROUP)
                if corpse != null then
                    if IsUnitZombie(corpse) then
                        set isZombie = true
                    endif
                    set t[corpse] = 1
                    set corpsefx = xefx.create(GetUnitX(corpse), GetUnitY(corpse), GetUnitFacing(corpse) * bj_DEGTORAD)
                    set corpsefx.z = SOUL_RELEASE_TARGET_EFFECT_HEIGHT
                    set corpsefx.scale = SOUL_RELEASE_TARGET_EFFECT_SCALE 
                    set corpsefx.fxpath = SOUL_RELEASE_TARGET_EFFECT
                    call listAdd()
                    if count == 1 then
                        call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.onExpire)
                    endif
                    return true
                endif
                return false
            endmethod
            
            static method onInit takes nothing returns nothing
                set ticker = CreateTimer()
                set t = HandleTable.create()
                set corpseFilter = Condition(function thistype.corpseFilterMethod)
                set dmg = xedamage.create()
                set dtype = SOUL_RELEASE_DAMAGE_TYPE
                set atype = SOUL_RELEASE_ATTACK_TYPE
				set wtype = SOUL_RELEASE_WEAPON_TYPE
            endmethod
            
        endstruct
            
        private struct Main
        
            private static constant integer spellId = SPELL_ID
            private static constant integer spellType = SPELL_TYPE_NO_TARGET
            private static constant boolean autoDestroy = false
            
            private xefx groundfx = 0
            private xefx array stone[GRAVE_STONE_COUNT]
            
            private real counter = 0.00
            private real totalTime = 0.00
            
            private static timer ticker = null
            
            implement List
            
            method onDestroy takes nothing returns nothing
                local integer i = 0
                call listRemove()
                
                loop
                    exitwhen i > GRAVE_STONE_COUNT
                    call stone[i].destroy()
                    set i = i + 1
                endloop
                
                call groundfx.destroy()
                
                if count == 0 then
                    call PauseTimer(ticker)
                endif
            endmethod
            
            static method onExpire takes nothing returns nothing
                local thistype this = first
                
                loop
                    exitwhen this == 0
                    
                    set totalTime = totalTime + TIMER_INTERVAL
                    set counter = counter + TIMER_INTERVAL
                    
                    if counter >= SOUL_RELEASE_INTERVAL then
                        if Soul.release(this) then
                            set counter = 0.00
                        endif
                    endif
                    
                    if totalTime == SPELL_DURATION[lvl] then
                        call destroy()
                    endif
                    
                    set this = next
                endloop
            endmethod
            
            method onCast takes nothing returns nothing
                local real ang = 0.00
                local integer i = 0
                local real dx = 0.00
                local real dy = 0.00
                
                //Da ich immer das Level-1 als Index nehme passt dies so
                set lvl = lvl - 1 
            
                set groundfx = xefx.create(x, y, 0.0)
                set groundfx.fxpath = GROUND_EFFECT_MODEL
                set groundfx.scale = GROUND_EFFECT_SCALE[lvl]
                
                //Create the Gravestones...
                loop
                    exitwhen i > GRAVE_STONE_COUNT
                    set ang = 2 * bj_PI * i / GRAVE_STONE_COUNT
                    set dx = x + SPELL_AOE[lvl] * Cos(ang)
                    set dy = y + SPELL_AOE[lvl] * Sin(ang)
                    set ang = Atan2(y - dy, x - dx)
                    set stone[i] = xefx.create(dx, dy, ang)
                    set stone[i].xyangle = ang
                    set stone[i].fxpath = GRAVE_STONE_MODEL
                    set stone[i].scale = GRAVE_STONE_SIZE
                    set i = i + 1
                endloop
                
                call listAdd()
                
                if count == 1 then
                    call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.onExpire)
                endif
            endmethod
            
            implement Spell
            
            private static method onInit takes nothing returns nothing
                set ticker = CreateTimer()
                call MainSetup()
                call Preload(GROUND_EFFECT_MODEL)
                call Preload(GRAVE_STONE_MODEL)
                call Preload(SOUL_RELEASE_TARGET_EFFECT)
                call Preload(SOUL_RELEASE_FINAL_EFFECT)
            endmethod
        endstruct
    endscope
    
    
    private function onInit takes nothing returns nothing
        call AddZombieType('zom0')
        call AddZombieType('zom1')
        call AddZombieType('zom2')
        call AddZombieType('zom3')
        call AddZombieType('zom4')
    endfunction

endlibrary
