scope TalismanOfTranslocation initializer Init
	
	globals
		private constant integer SPELL_ID = 'A05E'
		private constant integer ITEM_ID = 'I00K'
		private constant real MAX_DIST = 1000
	
	endglobals
	
	private function UnitMoveItemToSlot takes unit hero, item it, integer slot returns boolean
		if(slot > 5 or slot < 0 )then
			return false
		endif
		
		return IssueTargetOrderById(hero, 852002 + slot, it)
	endfunction
	
	private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
		local real casterX = GetUnitX(caster)
		local real casterY = GetUnitY(caster)
		local real targetX = GetSpellTargetX()
		local real targetY = GetSpellTargetY()
		local real dist = DistanceBetweenCords(casterX, casterY, targetX, targetY)
		local real maxDistance = MAX_DIST
		
		loop
            exitwhen IsTerrainWalkable(targetX, targetY)
			set maxDistance = maxDistance - 25
            set targetX = casterX + (targetX - casterX) * maxDistance/dist
            set targetY = casterY + (targetY - casterY) * maxDistance/dist
        endloop
				
		if (dist < maxDistance) then
            call SetUnitX(caster, targetX)
            call SetUnitY(caster, targetY)
        else
            call SetUnitX(caster, casterX + (targetX - casterX) * maxDistance/dist)
            call SetUnitY(caster, casterY + (targetY - casterY) * maxDistance/dist)
        endif
		
		set caster = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		local integer i = 0
		local boolean b = false
		local unit u = GetTriggerUnit()
		local item it 
		
		if (GetSpellAbilityId() == SPELL_ID) then
			if not DamageLog.isUnitDamaged(u) then
				set b = true
			else
				set it = CreateItem(ITEM_ID, GetUnitX(u), GetUnitY(u))
				loop
					exitwhen i == 6
						if (GetItemTypeId(it) == GetItemTypeId(UnitItemInSlot(u, i))) then
							call RemoveItem(UnitItemInSlot(u, i))
							call UnitAddItem(u, it)
							call UnitMoveItemToSlot(u, it, i)
						endif
					set i = i + 1
				endloop
			endif
		endif
		
		set u = null
		return b
    endfunction

	private function Init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
	endfunction
endscope