library Eggshack initializer init requires xefx, TimerUtils
//*************************************************************
//* Configuration Constants
    globals 
        private constant integer SPELL_ID='A006' //eggshack ability rawcode
        private constant integer BUFF_ID='B004' //eggshack buff
        private constant integer BEETLE='ucs1' //beetle unit rawcode
        private constant integer DUMMY_ID='e000' //dummy unit rawcode
        private constant string FX="Doodads\\Dungeon\\Terrain\\EggSack\\EggSack1.mdl" //eggshack fx
        private constant integer NUM=3 //how many beetle spawns
        private constant real EGG_DISTANCE=-35.0 //egg distance from caster
        private constant real EGG_HEIGHT=100. //egg height
        private constant real PATROL_RADIUS=500. //beetle spawns patrol radius
        private integer array B_ABILITY[3]
    endglobals
    
    //beetle spawn abilities
    private function InitBSpells takes nothing returns nothing
        //set B_ABILITY[0]='ACct'
        set B_ABILITY[1]='ACct' //critical strike
        set B_ABILITY[2]='ACbh' //bash
        //...and so on
    endfunction
    
    private constant function Duration takes integer lvl returns real
        return 30.+0.*lvl //beetle spawns duration
    endfunction
    
    private constant function LifeCost takes integer lvl returns real
        return 5.*lvl //life cost per second
    endfunction
//* Configuration End
//*****************************************************************
    private struct data
        unit caster
        timer t
        unit Egg
        unit array Beetle[NUM]
        boolean patrol=false
        real counter=0.
        real hpcost=0.
        integer lvl
        xefx fx
        
        static method create takes unit c, timer t returns data
            local data d=data.allocate()
            local integer lvl=GetUnitAbilityLevel(c,SPELL_ID)
            
            set d.caster=c
            set d.t=t
            set d.counter=Duration(lvl)
            set d.hpcost=LifeCost(lvl)
            set d.lvl=lvl
            set d.fx=xefx.create(GetUnitX(c),GetUnitY(c),GetUnitFacing(c))
            set d.fx.z=EGG_HEIGHT
            set d.fx.fxpath=FX
            
            return d
        endmethod
        
        private method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
        endmethod
    endstruct

    //distance between X cord
    private function PolarProjectionX takes real x, real distance, real angle returns real
        return x+distance*Cos(angle * bj_DEGTORAD)
    endfunction
    //distance between Y cord
    private function PolarProjectionY takes real y, real distance, real angle returns real
        return y+distance*Sin(angle * bj_DEGTORAD)
    endfunction

    private function Check takes nothing returns nothing
        local timer t=GetExpiredTimer()
        local data d=data(GetTimerData(t))
        local real x=PolarProjectionX(GetUnitX(d.caster),EGG_DISTANCE,GetUnitFacing(d.caster))
        local real y=PolarProjectionY(GetUnitY(d.caster),EGG_DISTANCE,GetUnitFacing(d.caster))
        local rect r
        local integer i=0
        
        if (GetUnitAbilityLevel(d.caster,BUFF_ID)>0) then
            set d.fx.x=x
            set d.fx.y=y
            set d.fx.z=EGG_HEIGHT+GetUnitFlyHeight(d.caster)
            call SetUnitState(d.caster,UNIT_STATE_LIFE,GetUnitState(d.caster,UNIT_STATE_LIFE)-d.hpcost*.035)
            call TimerStart(t,XE_ANIMATION_PERIOD,false,function Check)
        elseif (d.patrol==false) then
            call d.fx.destroy()
            set d.patrol=true
            loop
            exitwhen i>NUM-1
                set d.Beetle[i]=CreateUnit(GetOwningPlayer(d.caster),BEETLE,GetUnitX(d.caster),GetUnitY(d.caster),0)
                call UnitApplyTimedLife(d.Beetle[i],'BTLF',d.counter)
                //--add ability--
                if (d.lvl==2) then
                    call UnitAddAbility(d.Beetle[i],B_ABILITY[1])
                elseif (d.lvl==3) then
                    call UnitAddAbility(d.Beetle[i],B_ABILITY[1])
                    call UnitAddAbility(d.Beetle[i],B_ABILITY[2])
                endif
                //--------------
                set i=i+1
            endloop
            call TimerStart(t,XE_ANIMATION_PERIOD,false,function Check)
        elseif (d.patrol==true and GetWidgetLife(d.caster)>0.405) then 
            set r = Rect(GetUnitX(d.caster)-PATROL_RADIUS, GetUnitY(d.caster)-PATROL_RADIUS, GetUnitX(d.caster)+PATROL_RADIUS, GetUnitY(d.caster)+PATROL_RADIUS)
        
            set i=0
            loop
            exitwhen i>NUM-1
            
                set x=GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
                set y=GetRandomReal(GetRectMinY(r), GetRectMaxY(r))
            
                call IssuePointOrder(d.Beetle[i],"patrol",x,y)
            
                set i=i+1
            
            endloop
        
            if (d.counter>0.) then
                call TimerStart(t,1.0,false,function Check)
                set d.counter=d.counter-1.0
            else 
                call d.destroy()
            endif
        
            call RemoveRect(r)
        elseif (GetWidgetLife(d.caster)<=0.405) then
            call d.destroy()
        endif
        
        set r=null
    endfunction
    
    private function Actions takes nothing returns nothing
        local timer t
        local unit u
        local data d
        
        if GetSpellAbilityId() == SPELL_ID then
            set t=NewTimer()
            set u=GetSpellAbilityUnit()
            set d=data.create(u,t)
            call SetTimerData(t,integer(d))
            call TimerStart(t,XE_ANIMATION_PERIOD,false,function Check)
        endif
        
        set u=null
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger(  )
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction(t, function Actions )
        call InitBSpells()
    endfunction

endlibrary