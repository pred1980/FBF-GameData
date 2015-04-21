scope Endurance initializer init
    /*
     * Description: The Mountain Giant uses his mental power to get stronger and stronger by every hit he take. 
                    This newly gained strength fails after a short time.
     * Changelog: 
     *     	09.01.2014: Abgleich mit OE und der Exceltabelle
	 *		21.04.2015: Integrated SpellHelper for filtering
						Removed xedamage
	 *
	 * Info:
	       BONUS_ATTACK_SPEED |-512|+511 
     */
    globals
        private constant integer SPELL_ID = 'A09B'
        private constant integer BUFF_PLACER_ID = 'A09A'
        private constant integer BUFF_ID = 'B01W'
        private constant integer DAMAGE_MODIFIER_PRIORITY = 50
        private constant real TIMER_INTERVAL = 0.10
        private constant real REMOVE_BONUS_TIMER_INTERVAL = 5.0
        private constant integer array STR_BONUS
        private constant integer array AGI_BONUS
        private constant integer array ATTACK_SPEED_BONUS
        private constant integer MAX_ATTACK_SPEED_BONUS = 511
		
		private real array SPELL_DURATION
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set STR_BONUS[0] = 2
        set STR_BONUS[1] = 4
        set STR_BONUS[2] = 6
        
        set AGI_BONUS[0] = 1
        set AGI_BONUS[1] = 2
        set AGI_BONUS[2] = 3
        
        set ATTACK_SPEED_BONUS[0] = 5
        set ATTACK_SPEED_BONUS[1] = 10
        set ATTACK_SPEED_BONUS[2] = 15
        
        set SPELL_DURATION[0] = 25.0
        set SPELL_DURATION[1] = 20.0
        set SPELL_DURATION[2] = 15.0
    endfunction
    
    private keyword Main
    private keyword DamageModificator

    struct DamageModificator extends DamageModifier
        static constant integer prio = DAMAGE_MODIFIER_PRIORITY
        
        Main root = 0
            
        static method create takes Main from returns thistype
            local thistype this = allocate(from.target, prio)
            set root = from
            return this
        endmethod
        
        method onDamageTaken takes unit source, real damage returns real
            if DamageType == PHYSICAL then
			    set root.hits = root.hits + 1
                call SetHeroStr( root.target, GetHeroStr(root.target, false) + STR_BONUS[root.lvl], false )
                set root.strength = root.strength + STR_BONUS[root.lvl]
			    call SetHeroAgi( root.target, GetHeroAgi(root.target, false) + AGI_BONUS[root.lvl], false )
                set root.agility = root.agility + AGI_BONUS[root.lvl]
            	
                if (root.attackSpeed + ATTACK_SPEED_BONUS[root.lvl]) <= MAX_ATTACK_SPEED_BONUS then
                    call AddUnitBonus(root.target, BONUS_ATTACK_SPEED, ATTACK_SPEED_BONUS[root.lvl])
                    set root.attackSpeed = root.attackSpeed + ATTACK_SPEED_BONUS[root.lvl]
                endif
            endif
            
            return 0.00
        endmethod
    
    endstruct

    private struct Main
        static constant integer spellId = SPELL_ID
        static constant boolean autoDestroy = false
        static constant integer spellType = SPELL_TYPE_TARGET_UNIT
    
        DamageModificator dmgModi = 0
        real damageBlocked = 0.00
        dbuff buff = 0
        
        static thistype temp = 0
        static integer buffType = 0
        
        integer hits = 0
        integer strength = 0
        integer agility = 0
        integer attackSpeed = 0
        timer ticker
        
        implement List
        
        method onDestroy takes nothing returns nothing
            call dmgModi.destroy()
        endmethod
        
        static method onRemoveBonus takes nothing returns nothing
            local timer t = GetExpiredTimer()
            
            call SetHeroStr(.temp.target, GetHeroStr(.temp.target, false) - STR_BONUS[.temp.lvl], false )
            call SetHeroAgi(.temp.target, GetHeroAgi(.temp.target, false) - AGI_BONUS[.temp.lvl], false )
            
            if .temp.attackSpeed > 0 then
                call SetUnitBonus(.temp.target, BONUS_ATTACK_SPEED, GetUnitBonus(.temp.target, BONUS_ATTACK_SPEED) - ATTACK_SPEED_BONUS[.temp.lvl])
                set .temp.attackSpeed = .temp.attackSpeed - ATTACK_SPEED_BONUS[.temp.lvl]
            endif
            
            set .temp.hits = .temp.hits - 1
            set .temp.strength = .temp.strength - STR_BONUS[.temp.lvl]
            set .temp.agility = .temp.agility - AGI_BONUS[.temp.lvl]
            
            if .temp.hits == 0 then
                call ReleaseTimer(t)
                set t = null
            endif
        endmethod
        
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local timer t = NewTimer()
            
            if (SpellHelper.isUnitDead(b.target)) then
                call TimerStart(t, 1.00/I2R(.temp.hits), true, function thistype.onRemoveBonus)
            else
                call TimerStart(t, REMOVE_BONUS_TIMER_INTERVAL/I2R(.temp.hits), true, function thistype.onRemoveBonus)
            endif
            call thistype(b.data).destroy()
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            if b.isRefreshed then
                //Destroying old data
                call thistype(b.data).destroy()
            endif
            
            set this = temp
            set b.data = integer(this)
            set buff = b
            set dmgModi = DamageModificator.create(this)
        endmethod
        
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            set temp = this
            call UnitAddBuff(caster, target, buffType, SPELL_DURATION[lvl], lvl + 1)
        endmethod
    
        implement Spell
        
        private static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, TIMER_INTERVAL, true, false, thistype.onBuffAdd, 0, thistype.onBuffEnd)
        endmethod
    
    endstruct

    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(BUFF_PLACER_ID)
    endfunction

endscope