scope ReflectiveShield initializer init
    /*
     * Description: The Farseer creates an invisible shield of energy around himself, the shield has a chance 
                    to instantly reflect attacks against him.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A09G'
        
        //DOT
        private constant real DOT_TIME = 3.00
        private constant string EFFECT = "Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl"
        private constant string ATT_POINT = "origin"
        private constant attacktype ATT_TYPE = ATTACK_TYPE_HERO
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_LIGHTNING
        
        private integer array CHANCE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set CHANCE[1] = 10
        set CHANCE[2] = 14
        set CHANCE[3] = 18
        set CHANCE[4] = 22
        set CHANCE[5] = 26
    endfunction
    
    private function reflect takes unit attacked, unit attacker, real damage returns nothing
        call SetWidgetLife(attacked, (GetWidgetLife(attacked) + damage))
        set DamageType = SPELL
        call DOT.start(attacked, attacker, damage , DOT_TIME , ATT_TYPE , DMG_TYPE , EFFECT , ATT_POINT )
    endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damagedUnit, SPELL_ID) > 0 /*
        */  and DamageType == PHYSICAL /*
        */  and GetRandomInt(1, 100) < CHANCE[GetUnitAbilityLevel(damagedUnit, SPELL_ID)]) /*
        */  and not IsUnitHidden(damagedUnit) then
                call reflect(damagedUnit, damageSource, damage)
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call XE_PreloadAbility(SPELL_ID)
        call Preload(EFFECT)
        call MainSetup()
    endfunction
endscope