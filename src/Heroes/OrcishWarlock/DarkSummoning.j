scope DarkSummoning
	/*
     * Description: The Warlock summons demons that binds the target between them. While being trapped, 
                    the target cannot move, attack or cast spells and any damage or heal that would affect the target 
                    will be ignored. The demons will regenerate the targets life over the duration, if it is an allied unit.
     * Last Update: 08.01.2014
     * Changelog: 
     *      08.01.2014: Abgleich mit OE und der Exceltabelle
	 *      02.03.2014: Original Code von Kricz genommen. Aus unerklärlichen Gründen gab es große
	                   Unterschiede im Code. Dadurch konnte ein Bug behoben werden, der bestimmte 
					   Einheiten nicht bewegungsunfähig gemacht hat
					   
	 * Info:
	 *      3.334 Animation Duration of Spell
			Wenn ihr die maximale Duration des Spells ändert, müsst ihr in Zeile < x > folgendes hinzufügen:
			Für jede 3.334 Sekunden, die größer als 6,668 ist, müsst ihr folgende Zeile hinzufügen:

			call QueueUnitAnimation(demon[i], "spell")

			Beispiel:
			Ihr wollt, dass der Spell auf Level 1 bei Freunden doch 15 Sekunden dauert, dann müsst ihr:
			(15.000 - 6.688) = 8,332 / 3.334 = 2 Zeilen adden

			Grund ist, dass die Spell Animation immer gequeued werden muss und ich nicht weitere Variablen und Timer benutzen muss um die Animation neu zu starten.
     */
    globals
        
        private constant integer SPELL_ID = 'A07Y'
        private constant integer BUFF_PLACER_ID = 'A07Z'
        private constant integer BUFF_ID = 'B01I'
        private constant real TIMER_INTERVAL                    = 0.05
        private constant integer DAMAGE_MODIFIER_PRIORITY       = 85
        private constant string TARGET_EFFECT                   = "Abilities\\Spells\\Undead\\Possession\\PossessionTarget.mdl"
        private constant string TARGET_EFFECT_ATTACH            = "overhead"
        //If true, the effect will be recreated each interval chosen below
        private constant boolean TARGET_EFFECT_REFRESH          = true
        private constant real TARGET_EFFECT_REFRESH_INTERVAL    = 1.50
        
		private real array ALLY_SPELL_DURATION
        private real array ENEMY_SPELL_DURATION
        private real array ALLY_HEAL_VALUE
        private real array ALLY_MAX_HEAL_VALUE
    endglobals
    
    
    //Channeling Demon Options
    globals
        private constant integer CHANNELING_DEMON_ID            = 'n000'
        private constant integer CHANNELING_DEMON_AMOUNT        = 3
        private constant real CHANNELING_DEMON_SIZE             = 0.85
        private constant real CHANNELING_DEMON_DISTANCE         = 115.00
        private constant string CHANNELING_DEMON_EFFECT         = "Abilities\\Spells\\Undead\\Possession\\PossessionCaster.mdl"
        private constant string CHANNELING_DEMON_EFFECT_ATTACH  = "overhead"
    endglobals
    
    private keyword Main
    private keyword DamageModificator
    
    private function MainSetup takes nothing returns nothing
        set ALLY_SPELL_DURATION[0] = 10.00
        set ALLY_SPELL_DURATION[1] = 7.50
        set ALLY_SPELL_DURATION[2] = 5.00
        
        set ENEMY_SPELL_DURATION[0] = 5.00
        set ENEMY_SPELL_DURATION[1] = 7.50
        set ENEMY_SPELL_DURATION[2] = 10.00
        
        set ALLY_HEAL_VALUE[0] = 0.20
        set ALLY_HEAL_VALUE[1] = 0.35
        set ALLY_HEAL_VALUE[2] = 0.50
        
        set ALLY_MAX_HEAL_VALUE[0] = 0.50
        set ALLY_MAX_HEAL_VALUE[1] = 0.65
        set ALLY_MAX_HEAL_VALUE[2] = 0.80
    endfunction
    
    //The reason, a damage modifier is required is, that there could be damage, that would kill the unit, which has to be prevented...
    struct DamageModificator extends DamageModifier
        Main root = 0
            
        static method create takes Main from returns thistype
            local thistype this = allocate(from.target, DAMAGE_MODIFIER_PRIORITY)
            set root = from
            return this
        endmethod
        
        method onDamageTaken takes unit source, real damage returns real
            return -damage
        endmethod
    
    endstruct

    struct Main
    
        static constant integer spellId = SPELL_ID
        static constant boolean autoDestroy = false
        static constant integer spellType = SPELL_TYPE_TARGET_UNIT
        
        DamageModificator dmgModi = 0
        dbuff buff = 0
        boolean allied = false
        real life = 0.00
        real mana = 0.00
        real fxtime = 0.00
        effect targetfx = null
        boolean spawned = false
        unit array demon[CHANNELING_DEMON_AMOUNT]
        effect array demonfx[CHANNELING_DEMON_AMOUNT]
        real array cos[CHANNELING_DEMON_AMOUNT]
        real array sin[CHANNELING_DEMON_AMOUNT]
        
        static integer buffType = 0
        static thistype temp = 0
        
        method onDestroy takes nothing returns nothing
            local integer i = 0
            call dmgModi.destroy()
            
            loop
                exitwhen i >= CHANNELING_DEMON_AMOUNT
                if CHANNELING_DEMON_EFFECT != "" then
                    call DestroyEffect(demonfx[i])
                endif
                call KillUnit(demon[i])
                set i = i + 1
            endloop
            
            if TARGET_EFFECT != "" then
                call DestroyEffect(targetfx)
            endif
        endmethod
        
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
        
        static method periodicActions takes nothing returns nothing
            local thistype this = thistype(GetEventBuff().data)
            local integer i = 0
            local real ang = GetRandomReal(0.00, bj_PI * 2)
            local real facing = 0.00
            local real dx = 0.00
            local real dy = 0.00
            
            call SetUnitState(target, UNIT_STATE_LIFE, life)
            call SetUnitState(target, UNIT_STATE_MANA, mana)
            
            if allied then
                if (GetUnitState(target, UNIT_STATE_LIFE) / GetUnitState(target, UNIT_STATE_MAX_LIFE)) < ALLY_MAX_HEAL_VALUE[lvl] then
                    call SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + ((GetUnitState(target, UNIT_STATE_MAX_LIFE) * ALLY_HEAL_VALUE[lvl] * TIMER_INTERVAL) / ALLY_SPELL_DURATION[lvl]))
                    set life = GetUnitState(target, UNIT_STATE_LIFE)
                endif
            endif
            
            if not spawned then
                loop
                    exitwhen i >= CHANNELING_DEMON_AMOUNT
                    set x = GetUnitX(target)
                    set y = GetUnitY(target)
                    set dx = x + CHANNELING_DEMON_DISTANCE * Cos(ang)
                    set dy = y + CHANNELING_DEMON_DISTANCE * Sin(ang)
                    set facing = Atan2(dy - y, dx - x) - bj_PI
                    set demon[i] = CreateUnit(GetOwningPlayer(caster), CHANNELING_DEMON_ID, dx, dy, facing * bj_RADTODEG)
                    call UnitAddAbility(demon[i], 'Aloc')
                    if CHANNELING_DEMON_EFFECT != "" then
                        set demonfx[i] = AddSpecialEffectTarget(CHANNELING_DEMON_EFFECT, demon[i], CHANNELING_DEMON_EFFECT_ATTACH)
                    endif
                    call SetUnitScale(demon[i], CHANNELING_DEMON_SIZE, CHANNELING_DEMON_SIZE, CHANNELING_DEMON_SIZE)

                    set cos[i] = Cos(ang)
                    set sin[i] = Sin(ang)
                    
                    call SetUnitAnimation(demon[i], "spell")
                    call QueueUnitAnimation(demon[i], "spell")
                    call QueueUnitAnimation(demon[i], "spell")

                    set ang = ang + (bj_PI * 2 / CHANNELING_DEMON_AMOUNT)
                    set i = i + 1
                endloop
                
                set spawned = true
            else
                loop
                    exitwhen i >= CHANNELING_DEMON_AMOUNT
                    call SetUnitX(demon[i], GetUnitX(target) + CHANNELING_DEMON_DISTANCE * cos[i])
                    call SetUnitY(demon[i], GetUnitY(target) + CHANNELING_DEMON_DISTANCE * sin[i])
                    set i = i + 1
                endloop
                
            endif
            
            static if TARGET_EFFECT_REFRESH then
                if TARGET_EFFECT != "" then
                    set fxtime = fxtime + TIMER_INTERVAL
                    if fxtime >= TARGET_EFFECT_REFRESH_INTERVAL then
                        call DestroyEffect(targetfx)
                        set targetfx = AddSpecialEffectTarget(TARGET_EFFECT, target, TARGET_EFFECT_ATTACH)
                        set fxtime = 0.00
                    endif
                endif
            endif
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            if b.isRefreshed then
                //Destroying old damage modifier
                call thistype(b.data).destroy()
            endif
            
            set this = temp
            set b.data = integer(this)
            set buff = b
            
            if TARGET_EFFECT != "" then
                set targetfx = AddSpecialEffectTarget(TARGET_EFFECT, target, TARGET_EFFECT_ATTACH)
            endif
            
            set mana = GetUnitState(target, UNIT_STATE_MANA)
            set life = GetUnitState(target, UNIT_STATE_LIFE)
            
            set dmgModi = DamageModificator.create(this)
        endmethod
        
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            set temp = this
            set allied = IsUnitAlly(caster, GetOwningPlayer(target))
            if allied then
                call UnitAddBuff(caster, target, buffType, ALLY_SPELL_DURATION[lvl], lvl + 1)
                call DisableUnitTimed(target, ALLY_SPELL_DURATION[lvl])
            else
                call UnitAddBuff(caster, target, buffType, ENEMY_SPELL_DURATION[lvl], lvl + 1)
                call DisableUnitTimed(target, ENEMY_SPELL_DURATION[lvl])
            endif
        endmethod
    
        implement Spell
        
        private static method onInit takes nothing returns nothing
            call MainSetup()
            set buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, TIMER_INTERVAL, true, false, thistype.onBuffAdd, thistype.periodicActions, thistype.onBuffEnd)
        endmethod
    
    endstruct

endscope