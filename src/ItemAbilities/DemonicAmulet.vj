scope DemonicAmulet initializer init
	/*
	 * Item: Demonic Amulet
	 */ 
    globals
        private constant integer ITEM_ID = 'I00P'
        private constant integer CHANCE = 35
        private constant string MODEL = "Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl"
        private constant string SFX_EFFECT = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"
        private constant attacktype at = ATTACK_TYPE_MAGIC
        private constant damagetype dt = DAMAGE_TYPE_FIRE
    endglobals
    
    private struct NewMeteor extends array
        private static integer instanceCount = 0 
        private static integer recycleCount = 0 
        private static integer array recycle
        private static real baseDamage = 12.5
        private static real radius = 350
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
            call MSStart(attacker, 1.0, level * .baseDamage , x, y, .radius, .dradius, 20.00, .5, 2000, 0 , MODEL, SFX_EFFECT, GetOwningPlayer(attacker), at, dt, true)
            
            call destroy()
            return this
        endmethod

        private method destroy takes nothing returns nothing
            set recycle[recycleCount] = this
            set recycleCount = recycleCount + 1
        endmethod
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local NewMeteor meteor = 0
         
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and GetRandomInt(1, 100) <= CHANCE and IsUnitType(damagedUnit, UNIT_TYPE_HERO) and DamageType == 0 and IsDead ) then
            call ResetIsDead()
            set meteor = NewMeteor.create(damageSource)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call Preload(MODEL)
        call Preload(SFX_EFFECT)
    endfunction
    
endscope