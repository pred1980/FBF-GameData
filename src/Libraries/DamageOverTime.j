library DamageOverTime initializer Init requires DamageEvent

    globals
        // This is how many times the struct loop will run in a single second. 30-40 is recomended
        private constant integer FPS = 40 
        // DO NOT TUCH! =)
        private constant real Interval = (1.0 / FPS)
    endglobals
    
    struct DOT
        unit Attacker
        unit Target

        real Damage
        integer EndCount

        attacktype Attack_Type
        damagetype Damage_Type
        
        effect Effect
        
        static integer array Index
        static integer Total = 0
        
        static timer Tim = null
        
        static integer Count = -2147483648 // Just a random low number, it is needed
        
        static method Loop takes nothing returns nothing
            local DOT dat
            local integer i = 0

            set DOT.Count = DOT.Count + 1
            
            loop
                exitwhen i >= DOT.Total
                set dat = DOT.Index[i]
                
                if DOT.Count > dat.EndCount or SpellHelper.isUnitDead(dat.Target) then
                    call DestroyEffect(dat.Effect)

                    set dat.Effect     = null
                    set dat.Attacker   = null
                    set dat.Target     = null
                    set dat.Attack_Type = null
                    set dat.Damage_Type = null
                    
                    call dat.destroy()
                    
                    set DOT.Total = DOT.Total - 1
                    set DOT.Index[i] = DOT.Index[DOT.Total]

                    set i = i - 1
                else
					if (DamageType == PHYSICAL) then
						call SpellHelper.damageTarget(dat.Attacker, dat.Target, dat.Damage, true, false, dat.Attack_Type, dat.Damage_Type, null)
					else
						call SpellHelper.damageTarget(dat.Attacker, dat.Target, dat.Damage, false, false, dat.Attack_Type, dat.Damage_Type, null)
					endif
                endif
                
                set i = i + 1
            endloop
            
            if DOT.Total == 0 then
                call PauseTimer(DOT.Tim)
            endif
        endmethod
        
        static method start takes unit Attacker, unit Target, real Damage, real Time, attacktype AttackType, damagetype DamageType, string Effect, string EffectAttach returns DOT
            local DOT dat = DOT.allocate()
            
            set dat.Attacker   = Attacker
            set dat.Target     = Target
            set dat.Attack_Type = AttackType
            set dat.Damage_Type = DamageType
            
            if Effect != "" and Effect != null then
                if EffectAttach != "" and EffectAttach != null then
                    set dat.Effect = AddSpecialEffectTarget(Effect, Target, EffectAttach)
                endif
            endif
            
            set dat.Damage   = Damage * Interval / Time
            set dat.EndCount = DOT.Count + R2I(Time / Interval)
            
            if DOT.Total == 0 then
                call TimerStart(DOT.Tim, Interval, true, function DOT.Loop)
            endif
            
            set DOT.Index[DOT.Total] = dat
            set DOT.Total = DOT.Total + 1
            
            return dat
        endmethod
    endstruct
    
//=========================================================================================
    
  //  function DamageOverTimeEx takes unit Attacker, widget Target, real Damage, real Time, attacktype AttackType, damagetype DamageType, string Effect, string EffectAttach returns DOT
  //      return DOT.Start(Attacker, Target, Damage, Time, AttackType, DamageType, Effect, EffectAttach)
  //  endfunction
    
  //  function DamageOverTime takes unit Attacker, widget Target, real Damage, real Time, attacktype AttackType, damagetype DamageType returns DOT
  //      return DOT.Start(Attacker, Target, Damage, Time, AttackType, DamageType, "", "")
  //  endfunction
    
  //  function EndDamageOverTime takes DOT dat returns nothing
  //      set dat.EndCount = DOT.Count + 1
  //  endfunction
    
  //  function IsDamageRunning takes DOT dat returns unit
  //      return dat.Target
  //  endfunction
    
//=========================================================================================*/

    private function Init takes nothing returns nothing
        set DOT.Tim = CreateTimer()
    endfunction

endlibrary