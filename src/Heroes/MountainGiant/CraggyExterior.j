scope CraggyExterior initializer init
    /*
     * Description: The skin of the Mountain Giant reduces all physical and magical damage.
     * Changelog: 
     *     	09.01.2014: Abgleich mit OE und der Exceltabelle
	 *     	21.04.2015: Integrated RegisterPlayerUnitEvent
     */
    private keyword CraggyExterior

    globals
        private constant integer SPELL_ID = 'A099'
        private constant integer DAMAGE_MODIFIER_PRIORITY = 25
        
		private real array PHYSICAL_DAMAGE_RED
        private real array SPELL_DAMAGE_RED
        private CraggyExterior array spellForUnit
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set PHYSICAL_DAMAGE_RED[1] = -0.10
        set PHYSICAL_DAMAGE_RED[2] = -0.15
        set PHYSICAL_DAMAGE_RED[3] = -0.20
        set PHYSICAL_DAMAGE_RED[4] = -0.25
        set PHYSICAL_DAMAGE_RED[5] = -0.30
        
        set SPELL_DAMAGE_RED[1] = -0.05
        set SPELL_DAMAGE_RED[2] = -0.10
        set SPELL_DAMAGE_RED[3] = -0.15
        set SPELL_DAMAGE_RED[4] = -0.20
        set SPELL_DAMAGE_RED[5] = -0.25
    endfunction
    
    //Die Keywords werden benoetigt, um Struct oberhalb ihrer Deklarierung zu benutzen
	private keyword DamageManipulator
	private keyword CraggyExterior
    
	struct DamageManipulator extends DamageModifier
        CraggyExterior root = 0
            
        static method create takes CraggyExterior from returns thistype
            local thistype this = allocate(from.caster, DAMAGE_MODIFIER_PRIORITY)
            
			set root = from
            
			return this
        endmethod
        
        method onDamageTaken takes unit source, real damage returns real
            if not IsUnitHidden(root.caster) then
                if DamageType == SPELL then
					return damage * SPELL_DAMAGE_RED[root.level]
                else
					return damage * PHYSICAL_DAMAGE_RED[root.level]
                endif
            endif
                
            return 0.00
        endmethod
    
    endstruct
	
    private struct CraggyExterior
        unit caster
        integer level
        DamageManipulator manipulator = 0
        
        static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
		endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set spellForUnit[GetUnitId(.caster)] = this
            //Den DamageModificator erzeugen
            set .manipulator = DamageManipulator.create(this)
            
			return this
        endmethod
        
        method onLevelUp takes unit caster returns nothing
            set .level = GetUnitAbilityLevel(caster, SPELL_ID)
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local CraggyExterior ce = 0
		local unit u = GetTriggerUnit()
        
        set ce = CraggyExterior.getForUnit(u)
        if( GetLearnedSkill() == SPELL_ID )then
            if ce == null then
                set ce = CraggyExterior.create(u)
            else
                call ce.onLevelUp(u)
            endif
        endif
		
		set u = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetLearnedSkill() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function Conditions, function Actions)
        call MainSetup()
    endfunction

endscope