scope RocketBoots initializer init
	/*
	 * Item: Druid Boots
	 */ 
    globals
        private constant integer ITEM_ID = 'I040'
        private constant real DOUBLEKLICK_TIME = 0.3
    
        private constant real TIME_OUT = 1./32.
        private constant real SPEED = 25
        //Manavalue in %:
        private constant integer STEPS_PER_MANA = 8 //if this would be <1 increase MANA_AMOUNT instead
        private constant integer MANA_AMOUNT = 1
        private constant string SLIDE_EFFECT = "Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdl"
    
        private real targetX
        private real targetY
        private boolean ordered
        
        private boolean sliding
        private integer manaSteps
        private boolean anySliding = false
        private timer t = CreateTimer()
    endglobals
    
    struct Data
        unit u
    endstruct

    private function callback takes nothing returns nothing
        local Data data = GetTimerData(GetExpiredTimer())
        local integer i=0
        local real oldX
        local real oldY
        local real newX
        local real newY
        local real angle
        set anySliding = false
        if sliding then
            set anySliding = true
            set angle = GetUnitFacing(data.u)
            set oldX = GetUnitX(data.u)
            set oldY = GetUnitY(data.u)
            call ec(oldX, oldY, SLIDE_EFFECT)
            set newX = PolarProjectionX(oldX, SPEED, angle)
            set newY = PolarProjectionY(oldY, SPEED, angle)
            call SetUnitPosition(data.u, newX, newY)
            set manaSteps = manaSteps + 1
            if manaSteps == STEPS_PER_MANA then
                set manaSteps = 0
                call SetUnitState(data.u,UNIT_STATE_MANA,GetUnitState(data.u,UNIT_STATE_MANA)-GetUnitState(data.u,UNIT_STATE_MAX_MANA) * MANA_AMOUNT/100)
            endif
            if GetUnitState(data.u, UNIT_STATE_MANA) < MANA_AMOUNT or RAbsBJ(GetUnitX(data.u)-newX) > 1 or RAbsBJ(GetUnitY(data.u)-newY) > 1 then
                set sliding = false
            endif
        endif
        if not(anySliding) then
            call PauseTimer(t)
        endif
    endfunction
    
    private function StartSlide takes integer id, unit u returns nothing
        local Data data = Data.create()
        if GetUnitState(u,UNIT_STATE_MANA) <10 * MANA_AMOUNT then
            return
        endif
        set sliding = true
        if not(anySliding) then
            set anySliding = true
            set manaSteps = 0
            set data.u = u
            call SetTimerData(t, data)
            call TimerStart(t, TIME_OUT, true, function callback)
        endif
    endfunction
    
    private function Reset takes nothing returns nothing
        set ordered = false
    endfunction

    private function Conditions takes nothing returns boolean
        return GetIssuedOrderId()==String2OrderIdBJ("smart") and UnitHasItemOfTypeBJ(GetTriggerUnit(), ITEM_ID)
    endfunction

    private function Actions takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local real x = GetOrderPointX()
        local real y = GetOrderPointY()
        local integer id = GetPlayerId(GetOwningPlayer(u))
        if ordered and RAbsBJ(targetX - x)<50 and RAbsBJ(targetY - y) < 50 and GetAngleDifferenceDegree(GetUnitFacing(u), AngleBetweenCords(GetUnitX(u), GetUnitY(u), x, y)) < 100 then
            set ordered = false
            call StartSlide(id, u)
        else
            set targetX = x
            set targetY = y
            set ordered = true
            call TimerStart(CreateTimer(), DOUBLEKLICK_TIME, false, function Reset)
        endif
    endfunction

    private function Order_Conditions takes nothing returns boolean
        return GetIssuedOrderId()==String2OrderIdBJ("smart")
    endfunction

    private function Order_Actions takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer id = GetPlayerId(GetOwningPlayer(u))
        if sliding then
            call SetUnitFacing(u, AngleBetweenCords(GetUnitX(u), GetUnitY(u), GetOrderPointX(),GetOrderPointY()))
        endif
        set u = null
    endfunction
    
    private function init takes nothing returns nothing
        local trigger orderTrig = CreateTrigger()
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(orderTrig,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        call TriggerAddCondition(orderTrig,Condition(function Order_Conditions))
        call TriggerAddAction(orderTrig,function Order_Actions)
        
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER )
        call TriggerAddCondition( t, Condition( function Conditions ) )
        call TriggerAddAction( t, function Actions )
        
        set targetX = 0
        set targetY = 0
        set ordered = false
        set sliding = false
        
        call Preload(SLIDE_EFFECT)
    endfunction

endscope