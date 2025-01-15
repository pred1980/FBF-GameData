scope StormBolt initializer init
	/*
	 * Item: Volcano Hammer
	 */ 
    globals
        private constant integer ITEM_ID = 'I01Z'
        private constant integer CHANCE = 40
        private constant string MODEL = "Models\\GreatLightning.mdl"
        private constant string SFX_EFFECT = ""
        private constant attacktype at = ATTACK_TYPE_MAGIC
        private constant damagetype dt = DAMAGE_TYPE_FIRE
    endglobals
    
    struct NewStorm extends array
        private static integer instanceCount = 0 
        private static integer recycleCount = 0 
        private static integer array recycle
        private static real baseDamage = 165
        private static real radius = 300
        private static real dradius = 150
        
        static method create takes unit attacker returns thistype
            local thistype this
            local real x
            local real y
            local integer level
         
            if (recycleCount > 0) then
                set recycleCount = recycleCount - 1 
                set this = recycle[recycleCount] 
            else
                set instanceCount = instanceCount + 1 
                set this = instanceCount
            endif
            
            set x = GetUnitX(attacker)
            set y = GetUnitY(attacker)
            set level = GetHeroLevel(attacker)
            call MSStart(attacker, 0.75, level * .baseDamage , x, y, .radius, .dradius, 500.00, .25, 500, .25 , MODEL, SFX_EFFECT, GetOwningPlayer(attacker), at, dt, true)
            
            call destroy()
            return this
        endmethod

        private method destroy takes nothing returns nothing
            set recycle[recycleCount] = this
            set recycleCount = recycleCount + 1
        endmethod
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local NewStorm storm = 0
         
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and GetRandomInt(1, 100) <= CHANCE and IsUnitType(damagedUnit, UNIT_TYPE_HERO) and DamageType == 0 and IsDead ) then
            call ResetIsDead()
            set storm = NewStorm.create(damageSource)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call Preload(MODEL)
    endfunction
    
endscope