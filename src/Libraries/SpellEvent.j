library SpellEvent requires Table

//*****************************************************************
//*  SPELL EVENT LIBRARY 1.2
//*
//*  written by: Anitarf
//*  requires: -Table
//*
//*  Maps with many triggered spells require many triggers that run
//*  on spell events. Whenever a spell is cast, all those triggers
//*  need to be evaluated by the game even though only one actually
//*  needs to run. This library has been written to reduce the
//*  number of triggers in such maps; instead of having a trigger
//*  per spell, this library contains a single trigger which then
//*  runs only the code associated with the spell that's actually
//*  being cast.
//*
//*  Perhaps more significant than the marginal speed gain is the
//*  feature that allows you to access all the spell event
//*  responses from all spell events, something that the native
//*  functions senselessly do not support. With this system you can
//*  for example easily get the target unit of the spell on the
//*  casting finish event.
//*
//*  All functions following the Response function interface that
//*  is defined at the start of this library can be used to respond
//*  to spell events. You can register a response with one of the
//*  following functions, each for a different spell event:
//*
//*    function RegisterSpellChannelResponse takes integer spellId, Response r returns nothing
//*    function RegisterSpellCastResponse takes integer spellId, Response r returns nothing
//*    function RegisterSpellEffectResponse takes integer spellId, Response r returns nothing
//*    function RegisterSpellFinishResponse takes integer spellId, Response r returns nothing
//*    function RegisterSpellEndCastResponse takes integer spellId, Response r returns nothing
//*
//*  The first event occurs at the very start of the spell, when
//*  the spell's casting time begins; most spells have 0 casting
//*  time, so in most cases this first event occurs at the same
//*  time as the second one, which runs when the unit actually
//*  begins casting a spell by starting its spell animation. The
//*  third event occurs when the spell effect actually takes place,
//*  which happens sometime into the unit's spell animation
//*  depending on the unit's "Animation - Cast Point" property.
//*  The fourth event runs if the unit finishes casting the spell
//*  uninterrupted, which might be important for channeling spells.
//*  The last event runs when the unit stops casting the spell,
//*  regardless of whether it finished casting or was interrupted.
//*
//*  If you specify a spell id when registering a response then
//*  that response will only run when that ability is cast; only
//*  one function per ability per event is supported, if you
//*  register more responses then only the last one registered will
//*  be called. If, however, you pass 0 as the ability id parameter
//*  then the registered function will run for all spells. Up to
//*  8190 functions can be registered this way for each event.
//*  These functions will be called before the ability's specific
//*  function in the order they were registered.
//*
//*  This library provides its own event responses that work
//*  better than the Blizzard's bugged native cast event responses.
//*  They still won't work after a wait, but unlike Blizzard's
//*  natives they will work on all spell events.
//*
//*  Here are usage examples for all event responses:
//*
//*    local integer a = SpellEvent.AbilityId
//*    local unit u = SpellEvent.CastingUnit
//*    local unit t = SpellEvent.TargetUnit
//*    local item i = SpellEvent.TargetItem
//*    local destructable d = SpellEvent.TargetDestructable
//*    local location l = SpellEvent.TargetLoc
//*    local real x = SpellEvent.TargetX
//*    local real y = SpellEvent.TargetY
//*    local boolean b = SpellEvent.CastFinished
//*
//*  SpellEvent.TargetLoc is provided for odd people who insist on
//*  using locations, note that if you use it you have to cleanup
//*  the returned location yourself.
//*
//*  SpellEvent.CastFinished boolean is intended only for the
//*  EndCast event as it tells you whether the spell finished or
//*  was interrupted.
//*
//*  Note that a few spells such as Berserk and Wind Walk behave
//*  somewhat differently from regular spells: they are cast
//*  instantly without regard for cast animation times, they do not
//*  interrupt the unit's current order, as well as any spell it
//*  may be casting. SpellEvent 1.1 now handles such spells without
//*  errors provided they are truly instant (without casting time).
//*
//*  It also turned out that a few rare abilities like Charge Gold
//*  & Lumber trigger a spell effect event, but not any other.
//*  SpellEvent 1.2 no longer ignores these lone effect events.
//*****************************************************************

    // use the RegisterSpell*Response functions to add spell event responses to the library
    public function interface Response takes nothing returns nothing

// ================================================================

    private keyword effectDone
    private keyword init
    private keyword get

    private struct spellEvent
        private static HandleTable casterTable
        boolean effectDone=false

        integer AbilityId
        unit CastingUnit
        unit TargetUnit
        item TargetItem=null
        destructable TargetDestructable=null
        real TargetX=0.0
        real TargetY=0.0
        boolean CastFinished=false
        
        // Some abilities like Berserk can be cast instantly without interrupting
        // the caster's current order, which includes any spells the caster may
        // already be casting. The following member allows the system to recover
        // the original spellEvent when such an instant spell overwrites it.
        private spellEvent interrupt

        method operator TargetLoc takes nothing returns location
            return Location(.TargetX, .TargetY)
        endmethod
        
        private static method create takes nothing returns spellEvent
            return spellEvent.allocate()
        endmethod
        static method init takes nothing returns spellEvent
            local spellEvent s=spellEvent.allocate()
            set s.AbilityId = GetSpellAbilityId()
            set s.CastingUnit = GetTriggerUnit()
            set s.TargetUnit = GetSpellTargetUnit()
            if s.TargetUnit != null then
                set s.TargetX = GetUnitX(s.TargetUnit)
                set s.TargetY = GetUnitY(s.TargetUnit)
            else
                set s.TargetDestructable = GetSpellTargetDestructable()
                if s.TargetDestructable != null then
                    set s.TargetX = GetDestructableX(s.TargetDestructable)
                    set s.TargetY = GetDestructableY(s.TargetDestructable)
                else
                    set s.TargetItem = GetSpellTargetItem()
                    if s.TargetItem != null then
                        set s.TargetX = GetItemX(s.TargetItem)
                        set s.TargetY = GetItemY(s.TargetItem)
                    else
                        set s.TargetX = GetSpellTargetX()
                        set s.TargetY = GetSpellTargetY()
                    endif
                endif
            endif
            set s.interrupt=spellEvent.casterTable[s.CastingUnit]
            set spellEvent.casterTable[s.CastingUnit]=integer(s)
            return s
        endmethod
        method onDestroy takes nothing returns nothing
            if .interrupt==0 then
                call spellEvent.casterTable.flush(.CastingUnit)
            else
                set spellEvent.casterTable[.CastingUnit]=.interrupt
            endif
            set .CastingUnit=null
        endmethod

        static method get takes unit caster returns spellEvent
            return spellEvent(spellEvent.casterTable[caster])
        endmethod
        static method onInit takes nothing returns nothing
            set .casterTable=HandleTable.create()
        endmethod
    endstruct
    
    globals
        spellEvent SpellEvent=0
    endglobals
    
// ================================================================

    //! textmacro spellEvent_make takes name
    globals
        private Response array $name$CallList
        private integer $name$CallCount=0
        private Table $name$Table
    endglobals

    private function $name$Calls takes integer id returns nothing
        local integer i=0
        local spellEvent previous=SpellEvent
        set SpellEvent=spellEvent.get(GetTriggerUnit())
        loop
            exitwhen i>=$name$CallCount
            call $name$CallList[i].evaluate()
            set i=i+1
        endloop
        if $name$Table.exists(id) then
            call Response($name$Table[id]).evaluate()
        endif
        set SpellEvent=previous
    endfunction

    function RegisterSpell$name$Response takes integer spellId, Response r returns nothing
        if spellId==0 then
            set $name$CallList[$name$CallCount]=r
            set $name$CallCount=$name$CallCount+1
        else
            set $name$Table[spellId]=integer(r)
        endif
    endfunction
    //! endtextmacro

    //! runtextmacro spellEvent_make("Channel")
    //! runtextmacro spellEvent_make("Cast")
    //! runtextmacro spellEvent_make("Effect")
    //! runtextmacro spellEvent_make("Finish")
    //! runtextmacro spellEvent_make("EndCast")

// ================================================================

    globals
        // Morph abilities like Metamorphosis will cause an additional spell effect
        // event to run when the caster morphs back to its original form. To avoid
        // such duplicates, SpellEvent is designed to ignore any effect event that
        // does not have a matching channel event preceding it.
        // However, there are also rare abilities, like Charge Gold&Lumber, which
        // only cause an effect event to run, so these events must not be ignored
        // even though they occur without a matching channel event. This Table
        // tracks ability IDs of spells that did cause a channel event so that when
        // a spell is cast that doesn't cause one, its effect event is not ignored.
        private Table CastAfterChannel
    endglobals

    private function Channel takes nothing returns nothing
        call spellEvent.init()
        call ChannelCalls(GetSpellAbilityId())
    endfunction

    private function Cast takes nothing returns nothing
        call CastCalls(GetSpellAbilityId())
    endfunction

    private function Effect takes nothing returns nothing
        local spellEvent s=spellEvent.get(GetTriggerUnit())
        local integer id=GetSpellAbilityId()
        if s!=0 and not s.effectDone then
            set s.effectDone=true
            call EffectCalls(id)
            if not CastAfterChannel.exists(id) then
                set CastAfterChannel[id]=1
            endif
        elseif not CastAfterChannel.exists(id) then
            set s = spellEvent.init()
            call EffectCalls(id)
            call s.destroy()
        endif
    endfunction

    private function Finish takes nothing returns nothing
        set spellEvent.get(GetTriggerUnit()).CastFinished=true
        call FinishCalls(GetSpellAbilityId())
    endfunction

    private function EndCast takes nothing returns nothing
        call EndCastCalls(GetSpellAbilityId())
        call spellEvent.get(GetTriggerUnit()).destroy()
    endfunction

// ================================================================

    private function InitTrigger takes playerunitevent e, code c returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, e )
        call TriggerAddAction(t, c)
        set t=null
    endfunction
    
    private module Init
        
        static method onInit takes nothing returns nothing
            set ChannelTable=Table.create()
            set CastTable=Table.create()
            set EffectTable=Table.create()
            set FinishTable=Table.create()
            set EndCastTable=Table.create()
            call InitTrigger(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function Channel)
            call InitTrigger(EVENT_PLAYER_UNIT_SPELL_CAST, function Cast)
            call InitTrigger(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Effect)
            call InitTrigger(EVENT_PLAYER_UNIT_SPELL_FINISH, function Finish)
            call InitTrigger(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function EndCast)
            set CastAfterChannel=Table.create()
        endmethod
        
    endmodule
    
    private struct SpellEventInit
        implement Init
    endstruct

endlibrary