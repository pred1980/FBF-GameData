library PassiveSpellSystem requires ModuleListModule, AutoIndex

    module PassiveSpell
    
        /*Required Static Variables:
            - integer spellId
            
        Conditional Variables:
            - boolean isNoHeroSpell
                This boolean has to be inside of the struct and set to true if you have an ability that can't
                be learned and is active by default.
            
            
        This variables are only required, if you use one of those events:
            - boolean useDamageEvents
            - boolean useItemEvents
            - boolean useSpellEvents
            - boolean useDeadEvents
            
        */
        
        unit owner = null
        
        private static trigger onLearnTrig = null
        private static trigger onDeathTrig = null
        private static HandleTable t = 0
        
        method reset takes nothing returns nothing
            call t.flush(owner)
            call m_listRemove()
            call destroy()
        endmethod
        
        method operator lvl takes nothing returns integer
            return GetUnitAbilityLevel(owner, spellId)
        endmethod
    
        static method operator [] takes unit whichUnit returns thistype
            local thistype this = t[whichUnit]
            //Unit ist weder registriert noch hat sie den Spell, 0 returnen
            if this == 0 and GetUnitAbilityLevel(whichUnit, spellId) < 0 then
                return 0
            //Unit ist zwar nicht registriert, hat jedoch den Spell, Struct erzeugen
            elseif this == 0 and GetUnitAbilityLevel(whichUnit, spellId) > 0 then
                set this = allocate()
                set owner = whichUnit
                set t[owner] = this
                call m_listAdd()
                return this
            //Unit ist registriert und hat die Ability
            elseif this != 0 and GetUnitAbilityLevel(whichUnit, spellId) > 0 then
                return this
            //Unit ist registriert aber hat nicht die Ability, unit removen
            elseif this != 0 and GetUnitAbilityLevel(whichUnit, spellId) <= 0 then
                call reset()
                return 0
            endif
            return 0
        endmethod
        
        
        
        //Disabled, cause there is no configurated Damage-Datection System 
        private static method onDamageEvent takes unit damagedUnit, unit damageSource, real damage returns nothing
            local thistype this = 0
            
            //Execute onDamaged Event
            static if thistype.onDamaged.exists then
                set this = thistype[damagedUnit]
                if this != 0 then
                    call onDamaged(damageSource, damage)
                endif
            endif
            
            //Execute onDamage Event
            static if thistype.onDamage.exists then
                set this = thistype[damageSource]
                if this != 0 then
                    call onDamage(damagedUnit, damage)
                endif
            endif
            
        endmethod
        
        
        
        private static method onCastEvent takes nothing returns nothing
            local thistype this = 0
            
            //Execute onSpellCast Event for Owner
            static if thistype.onSpellCast.exists then
                set this = SpellEvent.CastingUnit:thistype
                if this != 0 then
                    call onSpellCast(SpellEvent.TargetUnit, SpellEvent.TargetX, SpellEvent.TargetY, SpellEvent.AbilityId)
                endif
            endif
            
            //Execute onSpellTargeted Event for Owner
            static if thistype.onSpellTargeted.exists then
                set this = SpellEvent.TargetUnit:thistype
                if this != 0 then
                    call onSpellTargeted(SpellEvent.CastingUnit, SpellEvent.AbilityId)
                endif
            endif
            
            //Execute onAnySpellCast (this method isn't called if the owner used the spell or is targeted by a spell or if the owner is dead)
            static if thistype.onAnySpellCast.exists then
                set this = m_first
                
                loop
                    exitwhen this == 0
                    if not IsUnitType(owner, UNIT_TYPE_DEAD) and SpellEvent.CastingUnit != owner and SpellEvent.TargetUnit != owner then
                        call onAnySpellCast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, SpellEvent.AbilityId)
                    endif
                    
                    set this = m_next
                endloop
            endif
        endmethod
        
        /*
        //Disabled, because no ItemUtils Library is in use
        private static method onItemUseEvent takes unit caster, item used, real x, real y, unit target, item targetItem, destructable targetDest returns nothing
            local thistype this = 0
            
            //Execute onItemUse Event for Owner
            static if thistype.onItemUse.exists then
                set this = caster:thistype
                if this != 0 then
                    call onSpellCast(target, x, y, used)
                endif
            endif
            
            //Execute onItemTargeted Event for Owner
            static if thistype.onItemTargeted.exists then
                set this = target:thistype
                if this != 0 then
                    call onItemTargeted(caster, used)
                endif
            endif
            
            //Execute onAnyItemUse (this method isn't called if the owner used the item or is targeted by a item or if the owner is dead)
            static if thistype.onAnyItemUse.exists then
                set this = m_first
                
                loop
                    exitwhen this == 0
                    if not IsUnitType(owner, UNIT_TYPE_DEAD) and caster != owner and target != owner then
                        call onAnyItemUse(caster, target, used)
                    endif
                    
                    set this = m_next
                endloop
            endif
        endmethod
        */
        
        
        private static method onLearnEvent takes nothing returns boolean
            local unit u = null
            local integer l = 0
            local thistype this = 0
            if GetLearnedSkill() == spellId then
                set u = GetLearningUnit()
                set l = GetLearnedSkillLevel()
                set this = u:thistype
                if l == 1 then
                    static if thistype.onLearn.exists then
                        if this != 0 then
                            call this.onLearn()
                        endif
                    endif
                else
                    static if thistype.onLevelUp.exists then
                        if this != 0 then
                            call this.onLevelUp()
                        endif
                    endif
                endif
                set u = null
            endif
            return false
        endmethod
        
        private static method onDeathEvent takes nothing returns boolean
            local unit killed = GetDyingUnit()
            local unit killer = GetKillingUnit()
            local integer i = 0
            local thistype this = 0
            
            //Execute (Owner) Killed Event
            static if thistype.onKilled.exists then
                set this = killed:thistype
                if this != 0 then
                    call onKilled(killer)
                    set killed = null
                    set killer = null
                    return false
                endif
            endif
            
            //Execute (Owner) Kill Event
            static if thistype.onKill.exists then
                set this = killer:thistype
                if this != 0 then
                    call onKill(killed)
                    set killed = null
                    set killer = null
                    return false
                endif
            endif
            
            //Execute General Unit Death Event (use the onKilled method for the owner, not this method!)
            static if thistype.onUnitDeath.exists then
                set this = m_first
                loop
                    exitwhen this == 0
                    if owner != killed then
                        call onUnitDeath(killer, killed)
                    endif
                    
                    set this = m_next
                endloop
            endif
            
            set killed = null
            set killer = null
            return false
            
        endmethod
        
        
        static if isNoHeroSpell then
            
            private static method onUnitEntersMap takes unit u returns nothing
                local thistype this = u:thistype
                if this != 0 then
                    call BJDebugMsg("Detected a passive spell!")
                    static if thistype.onPassiveSpellDetectionCreate.exists then
                        call onPassiveSpellDetectionCreate()
                    endif
                endif
            endmethod
            
        endif
        
        private static method onInit takes nothing returns nothing
        
            static if thistype.useDamageEvents then
                call RegisterDamageResponse(thistype.onDamageEvent)
            endif
            
            static if thistype.useItemEvents then
                call OnUnitUseItem(thistype.onItemUseEvent)
            endif
            
            static if thistype.useSpellEvents then
                call RegisterSpellEffectResponse(0, thistype.onCastEvent)
            endif
            
            set onLearnTrig = CreateTrigger()
            call TriggerRegisterAnyUnitEventBJ(onLearnTrig, EVENT_PLAYER_HERO_SKILL)
            call TriggerAddCondition(onLearnTrig, Condition(function thistype.onLearnEvent))
            
            static if thistype.useDeadEvents then
                set onDeathTrig = CreateTrigger()
                call TriggerRegisterAnyUnitEventBJ(onDeathTrig, EVENT_PLAYER_UNIT_DEATH)
                call TriggerAddCondition(onDeathTrig, Condition(function thistype.onDeathEvent))
            endif
            
            static if isNoHeroSpell then
                call OnUnitIndexed(onUnitEntersMap)
            endif
            
            set t = HandleTable.create()
        endmethod
    
        implement ModuleList
    
    endmodule
    
    
endlibrary