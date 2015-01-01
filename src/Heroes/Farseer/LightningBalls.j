library LightningBalls initializer init uses RegisterPlayerUnitEvent, TimerUtils, SimError, xemissile, xecast, xedamage optional BoundSentinel
    /*
     * Description: The Farseer fires a lightning ball into the sky which explodes and scatters at the center 
                    of the point target, showering the target area and deals damage to nearby enemy units.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A09D' //spell raw code 
        private constant integer DUMMY_SPELL_ID = 'A09C' //dummy spell id
        private constant string  DUMMY_ORDER = "frostnova" //dummy order
        private constant string MODEL = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl" //missile fx path
        private constant string EFFECT = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdl" //explode sfx
        private constant string CHILD_MODEL = "Models\\OrbOfLightning.mdx" //missile fx path
        private constant real SCALE = 2. //ball scale
        private constant real CHILD_SCALE = 1.2 //ball scale
        private constant real MAX_HEIGHT = 525. // explode height 
        private constant real SPEED = 600.
        private constant real CHILD_SPEED = 350.
        private constant real ARC = 0.10 
        private constant real MIN_DIST = 300. // min cast range 
        private constant string ERROR_MSG = "The Farseer is inside the minimum range."  
    endglobals

    private function GetAoE takes integer lvl returns real
        return 250. + (lvl * 25) // spell aoe, must match the object editor field
    endfunction

    private function GetDamage takes integer lvl returns real
        return 25. //* lvl // deals damage each ball
    endfunction

    private function GetBallCount takes integer lvl returns integer 
        return 2 + (lvl * 2)  //how many balls
    endfunction
        
    private function GetBallAoE takes integer lvl returns real
        return 125. // collision size each ball
    endfunction
    
    //xedamage options:
    private function DamageOptions takes xedamage spellDamage returns nothing
        set spellDamage.dtype = DAMAGE_TYPE_MAGIC
        set spellDamage.atype = ATTACK_TYPE_NORMAL
        set spellDamage.exception = UNIT_TYPE_STRUCTURE
        set spellDamage.visibleOnly = false
        set spellDamage.damageAllies = false
        set spellDamage.damageTrees = false
    endfunction
        
   globals
        xedamage xed
        xecast xec
    endglobals
    
    struct Ball extends xemissile
        unit caster 
        real tx 
        real ty 
        integer lvl
            
        private method onHit takes nothing returns nothing
            call xed.damageAOE(.caster,.tx, .ty, GetBallAoE(.lvl), GetDamage(.lvl))
                
            set  xec.owningplayer = GetOwningPlayer(.caster)
            call xec.castOnAOE(.tx,.ty, GetBallAoE(.lvl))
        endmethod
            
        static method start takes unit c, real x, real y, real tx, real ty, integer lvl returns nothing
            local thistype this = thistype.allocate(x,y,MAX_HEIGHT,tx,ty,45.)
            local real dist = SquareRoot((x - tx) * (x - tx) + (y - ty) * (y - ty))
            local real speed = dist * (CHILD_SPEED / GetAoE(.lvl))
                
            set .fxpath = CHILD_MODEL
            set .scale  = CHILD_SCALE
                
            set .lvl = lvl
            set .caster = c
            set .tx = tx
            set .ty = ty
               
            call .launch(speed,ARC)
        endmethod
            
    endstruct
        
    private struct MainBalls extends xemissile
        unit    caster
        integer lvl
        real    sx
        real    sy
        real    tx
        real    ty
        xefx    sfx
            
        private method onHit takes nothing returns nothing
            local integer i
            local real angle
            local real dis
            local real tx
            local real ty
                
            //sfx:
            set .sfx = xefx.create(.sx, .sy, 0.)
            set .sfx.z = MAX_HEIGHT
            set .sfx.fxpath = EFFECT
            set .sfx.alpha = 0
            call .sfx.destroy()

            set i = GetBallCount(.lvl)
                
            loop
                    
                exitwhen i == 0
                set angle = GetRandomReal(0., 2. * bj_PI)
                set dis = GetRandomReal(1., GetAoE(.lvl))
                set tx = .tx + dis * Cos (angle)
                set ty = .ty + dis * Sin (angle)
                call Ball.start(.caster, .sx, .sy, tx, ty, .lvl)
                    
                set i = i - 1
            endloop
                
        endmethod
            
        private static method start takes unit u, real x, real y, integer lvl returns nothing
            local real unitX = GetUnitX(u)
            local real unitY = GetUnitY(u)
            local real dx    = x - unitX
            local real dy    = y - unitY
            local real a     = Atan2(dy, dx)
            local real dist  = SquareRoot(dx*dx + dy*dy)/2
            local real tx    = unitX + dist * Cos(a)
            local real ty    = unitY + dist * Sin(a)

            local thistype this = thistype.allocate(unitX, unitY, 45, tx, ty, MAX_HEIGHT)

            set this.fxpath = MODEL
            set this.scale  = SCALE

            set this.lvl = lvl
            set this.caster = u
            set this.sx = tx
            set this.sy = ty
            set this.tx = x
            set this.ty = y

            call this.launch(SPEED, ARC)
        endmethod
            
        private static method SpellEffect takes nothing returns nothing
            if GetSpellAbilityId() == SPELL_ID then
                call thistype.start(GetTriggerUnit(),GetSpellTargetX(), GetSpellTargetY(), GetUnitAbilityLevel(GetTriggerUnit(),SPELL_ID))
            endif
        endmethod
            
        private static method Check takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local real dx = GetUnitX(u) - GetSpellTargetX()
            local real dy = GetUnitY(u) - GetSpellTargetY()
            
            if GetSpellAbilityId() == SPELL_ID and dx * dx + dy * dy < MIN_DIST * MIN_DIST then
                call SimError(GetOwningPlayer(u), ERROR_MSG)
                call PauseUnit(u, true)
                call IssueImmediateOrder(u, "stop")
                call PauseUnit(u, false)
            endif
            
            set u = null
        endmethod
            
        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent( EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.SpellEffect )
            call RegisterPlayerUnitEvent( EVENT_PLAYER_UNIT_SPELL_CHANNEL, function thistype.Check )
            
            //xecast options:
            set xec = xecast.create()
            set xec.abilityid = DUMMY_SPELL_ID
            set xec.orderstring = DUMMY_ORDER
            //xe damage init:    
            set xed = xedamage.create()
            call DamageOptions(xed)
        endmethod
            
    endstruct
    
    private function init takes nothing returns nothing
        call Preload(MODEL)
        call Preload(CHILD_MODEL)
        call Preload(EFFECT)
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction
        
endlibrary