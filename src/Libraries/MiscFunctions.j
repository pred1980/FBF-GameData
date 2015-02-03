library MiscFunctions requires GroupUtils
    
    globals
        constant integer SPELL_DUMMY = 'e00E'
        private group g = CreateGroup()
    endglobals
    
    //Diese Funktion ermittelt ob ein Schaden von vorne oder von hinten ist
    //Beispiel: Scale Armor Spell
    function Backstab_GetAngleDifference takes real a1, real a2 returns real
     local real x
        // The Modulo will get the co-terminal angle if the angle is less than -360 or greater than 360.
        set a1=ModuloReal(a1,360)
        set a2=ModuloReal(a2,360)
        // makes sure angle 1 is the smaller angle.  If it isn't it switches them.
        if a1>a2 then
            set x=a1
            set a1=a2
            set a2=x
        endif
        // Subtracts 360, to get the first negative co-terminal angle, this is then used in a comparison to check if the angle is greater than 180
        set x=a2-360
        if a2-a1 > a1-x then
            //  If it is, use the negative angle instead
            set a2=x
        endif
        //  Now, get the difference between the 2 angles.
        set x=a1-a2
        //  If the difference is negative, make it positive and return it.  If its positive, return it.
        if (x<0) then
            return -x
        endif
     return x
    endfunction

    
    function UnitTargetable takes unit source, unit target returns boolean
        return IsUnitEnemy(target,GetOwningPlayer(source)) and not(IsUnitType(target,UNIT_TYPE_DEAD))
    endfunction

    function DamageUnitMagic takes unit source, unit target, real damage returns nothing
        call UnitDamageTarget(source,target,damage,true,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,WEAPON_TYPE_WHOKNOWS)        
    endfunction

    function DamageUnitPhysical takes unit source, unit target, real damage returns nothing
        call UnitDamageTarget(source,target,damage,true,false,ATTACK_TYPE_CHAOS,DAMAGE_TYPE_NORMAL,WEAPON_TYPE_WHOKNOWS)        
    endfunction

    function DamageUnitPure takes unit source, unit target, real damage returns nothing
        call UnitDamageTarget(source,target,damage,true,false,ATTACK_TYPE_CHAOS,DAMAGE_TYPE_UNIVERSAL,WEAPON_TYPE_WHOKNOWS)        
    endfunction

    function TextOnUnit takes string whichText, unit whichUnit, real zOffset, real size, real red, real green, real blue, real transparency returns texttag
        set bj_lastCreatedTextTag = CreateTextTag()
        call SetTextTagTextBJ(bj_lastCreatedTextTag, whichText, size)
        call SetTextTagPosUnitBJ(bj_lastCreatedTextTag, whichUnit, zOffset)
        call SetTextTagColorBJ(bj_lastCreatedTextTag, red, green, blue, transparency)
        call SetTextTagColorBJ( bj_lastCreatedTextTag, 100, 0.00, 0.00, 0 )
        call SetTextTagLifespanBJ( bj_lastCreatedTextTag, 1.60 )
        call SetTextTagPermanentBJ( bj_lastCreatedTextTag, false )
        call SetTextTagVelocityBJ( bj_lastCreatedTextTag, 50.00, 90.00 )

        return bj_lastCreatedTextTag
    endfunction
    
    function DamageText takes unit u, real damage returns nothing
        call TextOnUnit(I2S(R2I(damage)),u,25,10,255,0,0,0)
    endfunction
    
    function CountItemsOfTypeFromUnit takes unit whichUnit, integer whatItemtype returns integer
        local integer index = 0
        local integer count = 0
        loop
            exitwhen index >= bj_MAX_INVENTORY
            if ( GetItemTypeId ( UnitItemInSlot ( whichUnit, index ) ) == whatItemtype ) then
                set count = count + 1
            endif
            set index = index + 1
        endloop
        return count
    endfunction


    function CountItemChargesOfTypeFromUnit takes unit whichUnit, integer whichItemtype returns integer
        local integer index = 0
        local integer count = 0
        local item    indexItem
        local integer charges
        loop
            exitwhen index >= bj_MAX_INVENTORY
            set indexItem = UnitItemInSlot ( whichUnit, index )
            if ( GetItemTypeId ( indexItem ) == whichItemtype ) then
                set charges = GetItemCharges ( indexItem )
                if ( charges == 0 ) then
                    set count = count + 1
                else
                    set count = count + charges
                endif
            endif
            set index = index + 1
        endloop
        return count
    endfunction


    function Int2Hex takes integer int returns string
        local string charMap = "0123456789ABCDEF"
        local string hex = ""
        local integer index = 0
        if ((int < 0) or (int > 0x7FFFFFFF)) then
            return "|cffff0000Invalid argument in function Int2Hex()!|r"
        endif
        loop
            set index = ModuloInteger(int, 0x10) + 1
            set int = int / 0x10
            set hex = SubStringBJ(charMap, index, index) + hex
            exitwhen (int == 0)
        endloop
        return hex
    endfunction


    function Per2Clr takes string text, integer r, integer g, integer b, integer alpha returns string
        local string array str 
        if ((r >= 0) and (r <= 100) and (g >= 0) and (g <= 100) and (b >= 0) and (b <= 100) and (alpha >= 0) and (alpha <= 100)) then
            set r = R2I(0xFF / 100.000 * r)
            set g = R2I(0xFF / 100.000 * g)
            set b = R2I(0xFF / 100.000 * b)
            set alpha = R2I(0xFF / 100.000 * alpha)
            if (alpha <= 0xF) then
                set str[0] = "0" + Int2Hex(alpha)
            else
                set str[0] = Int2Hex(alpha)
            endif
            if (r <= 0xF) then
                set str[1] = "0" + Int2Hex(r)
            else
                set str[1] = Int2Hex(r)
            endif
            if (g <= 0xF) then
                set str[2] = "0" + Int2Hex(g)
            else
                set str[2] = Int2Hex(g)
            endif
            if (b <= 0xF) then
                set str[3] = "0" + Int2Hex(b)
            else
                set str[3] = Int2Hex(b)
            endif 
            return "|c" + str[0] + str[1] + str[2] + str[3] + text + "|r"
        else
            return "|cffff0000Invalid arguments in function Per2Clr()!|r"
        endif        
    endfunction


    function indexOf takes string text, string searchtext returns integer
        local integer i = 0
        if ( StringLength(text) >= StringLength ( searchtext ) ) then
            loop
                exitwhen i > ( StringLength ( text ) - StringLength ( searchtext ) )
                if ( SubString (text, i, i + StringLength ( searchtext ) ) == searchtext ) then
                    return i
                endif
                set i = i + 1
            endloop
        endif
        return -1
    endfunction


    function ConvertNumber takes string number, string base_alphabet_from, string base_alphabet_to returns string
        local integer base_from = StringLength ( base_alphabet_from )
        local integer base_to = StringLength ( base_alphabet_to )
        local string null_from = SubString ( base_alphabet_from, 0, 1 )
        local string new_number = ""
        local string result_division
        local integer result_modulo
        local integer result_div
        local integer index
        loop
            set index = 0
            set result_modulo = indexOf ( base_alphabet_from, SubString ( number, 0, 1 ) )
            set result_division = ""
            loop
                if ( result_modulo >= base_to ) then
                    set result_div = result_modulo / base_to
                    set result_division = result_division + SubString ( base_alphabet_from, result_div, result_div + 1 )
                    set result_modulo = result_modulo - ( result_div * base_to )
                else
                    set result_division = result_division + null_from
                endif
                set index = index + 1
                exitwhen index >= StringLength ( number )
                set result_modulo = ( result_modulo * base_from ) + indexOf ( base_alphabet_from, SubString ( number, index, index + 1 ) )
            endloop
            set index = 0
            loop
                exitwhen index >= StringLength ( result_division )
                exitwhen SubString ( result_division, index, index + 1 ) != null_from
                set index = index + 1
            endloop
            set result_division = SubString ( result_division, index, StringLength ( result_division ) )
            set new_number = SubString ( base_alphabet_to, result_modulo, result_modulo + 1 ) + new_number
            set number = result_division
            exitwhen number == ""
        endloop
        return new_number
    endfunction

    function Dec2Hex takes integer i returns string
        local string charMap="0123456789ABCDEF"
        local string hex
        if i>255 then
            return "|cffff0000This function is NOT designed to convert values above 255!|r"
        elseif i<0 then
            return "|cffff0000 The value is to small!|r"
        endif
        if i<16 then
            return "0"+SubString(charMap, i, i+1)
        else
            set hex=SubString(charMap, i/16, i/16+1)
            set i=ModuloInteger(i, 16)
            set hex=hex+SubString(charMap, i, i+1)
            return hex
        endif
    endfunction

    function MakeGradientText takes string toColor, integer r1, integer g1, integer b1, integer r2, integer g2, integer b2 returns string
        local integer length=StringLength(toColor)
        local integer rDif=(r1-r2)/length
        local integer gDif=(g1-g2)/length
        local integer bDif=(b1-b2)/length
        local integer rN=r1
        local integer gN=g1
        local integer bN=b1
        local integer i=0
        local string rS=""
        loop
        exitwhen i>length
            set rS=rS+"|cff"+Dec2Hex(rN)+Dec2Hex(gN)+Dec2Hex(bN)+SubString(toColor, i, i+1)
            set rN=rN-rDif
            set gN=gN-gDif
            set bN=bN-bDif
            set i=i+1
        endloop
        return rS+"|r"
    endfunction

    function IsXPrime takes integer x returns boolean
        local integer i = 3
        local integer end_index = R2I(SquareRoot(I2R(x))) + 1
        if (ModuloInteger(x, 2) == 0) then
            return false
        endif
        loop
            exitwhen i >= end_index
            if (ModuloInteger(x, i) == 0) then
                return false
            endif
            set i = i + 2
        endloop
        return true
    endfunction

    function GetAngleDifferenceDegree takes real a, real b returns real
        local real result
        set a = ModuloReal( a, 360 )
        set b = ModuloReal( b, 360 )
        set result = RAbsBJ( a - b )
        if ( result > 180 ) then
            return ( 360 - result )
        endif
        return result
    endfunction

    function ggT takes integer zahl1, integer zahl2 returns integer
        local integer a=IAbsBJ(zahl1)
        local integer b=IAbsBJ(zahl2)
        local integer rest
        if a*b==0 then
           return a+b
        endif
        loop
           set rest = ModuloInteger( a, b)
           exitwhen rest==0
           set a = b
           set b = rest
        endloop
        return b
    endfunction

    function kgV takes integer zahl1, integer zahl2 returns integer
        local integer a=IAbsBJ(zahl1)
        local integer b=IAbsBJ(zahl2)
        if a*b==0 then
           return a+b
        endif
        return (a/ggT(a,b))*b
    endfunction

    function Runden takes real r returns integer
        return R2I(r+.5)
    endfunction

    function IsRealInt takes real r returns boolean
        return r - I2R(R2I(r)) == 0
    endfunction

    function IsBetween takes integer tocheck, integer i2, integer i3 returns boolean
        return ((tocheck < i2) and (i3 < tocheck)) or ((tocheck > i2) and (tocheck < i3))
    endfunction

    function Chance takes real percentage returns boolean
        return percentage>GetRandomReal(0,100)
    endfunction

    function MultiboardDisplayForPlayer takes integer playerid, multiboard mb, boolean flag returns nothing    
        local player cplayer = ConvertedPlayer(playerid)
        if( cplayer == GetLocalPlayer() ) then
            call MultiboardDisplay( mb, flag )
        endif
    endfunction
    
    function RefreshSingleCooldown takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local integer spellid = GetSpellAbilityId()
        local integer level = GetUnitAbilityLevel( caster, spellid )

        call UnitRemoveAbility( caster, spellid )
        call UnitAddAbility( caster, spellid )
        call SetUnitAbilityLevel( caster, spellid, level )
    endfunction

    function CinematicFilterForPlayer takes player whichPlayer, real duration, string tex, real red0, real green0, real blue0, real trans0, real red1, real green1, real blue1, real trans1 returns nothing
        //if ( GetLocalPlayer() == whichPlayer ) then
            call SetCineFilterTexture(tex)
            call SetCineFilterBlendMode(BLEND_MODE_BLEND)
            call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
            call SetCineFilterStartUV(0, 0, 1, 1)
            call SetCineFilterEndUV(0, 0, 1, 1)
            call SetCineFilterStartColor(PercentTo255(red0), PercentTo255(green0), PercentTo255(blue0), PercentTo255(100-trans0))
            call SetCineFilterEndColor(PercentTo255(red1), PercentTo255(green1), PercentTo255(blue1), PercentTo255(100-trans1))
            call SetCineFilterDuration(duration)
            call DisplayCineFilter(true)
        //endif
    endfunction
    
    function Wait takes real duration returns nothing
        local timer t
        local real timeRemaining

        if (duration > 0) then
            set t = CreateTimer()
            call TimerStart(t, duration, false, null)
            loop
                set timeRemaining = TimerGetRemaining(t)
                exitwhen timeRemaining <= 0
                call TriggerSleepAction(0.0325)
            endloop
            call DestroyTimer(t)
            set t=null
        endif
    endfunction
    
    function ef takes unit u, string path returns nothing
        call DestroyEffect(AddSpecialEffectTarget(path, u , "chest"))
    endfunction

    function eh takes unit u, string path returns nothing
        call DestroyEffect(AddSpecialEffectTarget(path,u,"overhead"))
    endfunction

    function er takes unit u, string path returns nothing
        call DestroyEffect(AddSpecialEffectTarget(path,u,"origin"))
    endfunction

    function ec takes real x, real y, string path returns nothing
        call DestroyEffect(AddSpecialEffect(path,x,y))
    endfunction
    
    private function dummyRemoval takes unit dummy, real duration returns nothing
        call PolledWait(duration+1)
        call UnitApplyTimedLife(dummy,'BTLF',30)
        call ShowUnit(dummy,false)
    endfunction
    
    function CastDummySpellTarget takes unit source, unit target, integer spellID, integer level, string orderString, real duration returns nothing
        local unit dummy=CreateUnit(GetOwningPlayer(source), SPELL_DUMMY, GetUnitX(target),GetUnitY(target),0)
        call UnitAddAbility(dummy,spellID)
        call SetUnitAbilityLevel(dummy,spellID,level)
        call IssueTargetOrder(dummy,orderString,target)
        call dummyRemoval.execute(dummy,duration)
        set dummy=null
    endfunction

    function CastDummySpellPoint takes unit source, real targetX, real targetY, integer spellID, integer level, string orderString, real duration returns nothing
        local unit dummy=CreateUnit(GetOwningPlayer(source), SPELL_DUMMY, targetX,targetY,0)
        call UnitAddAbility(dummy,spellID)
        call SetUnitAbilityLevel(dummy,spellID,level)
        call IssuePointOrder(dummy,orderString,targetX,targetY)
        call dummyRemoval.execute(dummy,duration)
        set dummy=null
    endfunction

    function CastDummySpellImmediate takes unit source, real targetX, real targetY, integer spellID, integer level, string orderString, real duration returns nothing
        local unit dummy=CreateUnit(GetOwningPlayer(source), SPELL_DUMMY, targetX,targetY,0)
        call UnitAddAbility(dummy,spellID)
        call SetUnitAbilityLevel(dummy,spellID,level)
        call IssueImmediateOrder(dummy,orderString)
        call dummyRemoval.execute(dummy,duration)
        set dummy=null
    endfunction
    
    function TerrainDeformationRipple takes real duration, boolean limitNeg, real x, real y, real startRadius, real endRadius, real depth, real wavePeriod, real waveWidth returns terraindeformation
        local real spaceWave
        local real timeWave
        local real radiusRatio

        if (endRadius <= 0 or waveWidth <= 0 or wavePeriod <= 0) then
            return null
        endif

        set timeWave = 2.0 * duration / wavePeriod
        set spaceWave = 2.0 * endRadius / waveWidth
        set radiusRatio = startRadius / endRadius

        set bj_lastCreatedTerrainDeformation = TerrainDeformRipple(x, y, endRadius, depth, R2I(duration * 1000), 1, spaceWave, timeWave, radiusRatio, limitNeg)
        return bj_lastCreatedTerrainDeformation
    endfunction
    
    // Zwei Funktionen, die ermitteln, welches Aura Level am h?chsten ist
    // Beispiel: 2x Archmage, beide haben die Aura aktiv und der eine ist lvl 3 und der andere auf lvl 1
    // dann wird der mit dem level 3 mit diesen 2 Funktionen ermittelt
    private function AuraEnumFilter takes nothing returns boolean
        return true // GetUnitAbilityLevel(GetFilterUnit(), SPELL_ID) > 0
    endfunction
    
    function GetHighestAuraLevel takes unit u, integer radius, integer spellId returns integer
        local group g = NewGroup()
        local integer level = 0
        
        call GroupEnumUnitsInRange( g, GetUnitX(u), GetUnitY(u), radius, Filter(function AuraEnumFilter) )
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            if level < GetUnitAbilityLevel(u, spellId) then
                set level = GetUnitAbilityLevel(u, spellId)
            endif
            call GroupRemoveUnit(g, u)
        endloop
        call ReleaseGroup(g)
        set g = null
        
        return level
    endfunction
    
    //Heuschrecke sauber entfernen
    function UnitRemoveAloc takes unit u returns nothing
        local boolean backup = not IsUnitHidden(u)
        call ShowUnit(u, false)
        call UnitRemoveAbility(u, 'Aloc')
        call ShowUnit(u, backup)
    endfunction
    
    function DamageUnit takes unit source, unit target, real damage, boolean magic returns nothing
        set DamageType = SPELL
        if magic then
            call UnitDamageTarget(source,target,damage,true,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,WEAPON_TYPE_WHOKNOWS)        
        else
            call UnitDamageTarget(source,target,damage,true,false,ATTACK_TYPE_CHAOS,DAMAGE_TYPE_UNIVERSAL,WEAPON_TYPE_WHOKNOWS)        
        endif
    endfunction
    
    /*Mit der Funktion l?sst sich ein String, der Werte mit Komma getrennt enth?lt, auseinaderklam?sern ^^*/
    function getDataFromString takes string list, integer index returns string
        local string result = ""
        local string char
        local integer currentPos = 0
        local integer i = 0
        local integer len = StringLength(list)
        loop
            exitwhen i >= len
            set char = SubString(list, i, i + 1)
            if char == "," then
                set currentPos = currentPos + 1
                exitwhen currentPos > index
            else
                if currentPos == index then
                    set result = result + char
                endif
            endif
            set i = i + 1
        endloop
        return result
    endfunction
    
    //http://wc3jass.com/wiki/page/selectunit
    function SelectUnitByPlayer takes unit u, boolean b, player p returns nothing
        if GetLocalPlayer() == p then
            call ClearSelection()
            call SelectUnit(u, b)
        endif
    endfunction
    
    function IsUnitInRect takes unit whichUnit, rect whichRect returns boolean
        local region rectRegion = CreateRegion()
        local boolean flag
        
        call RegionAddRect(rectRegion, whichRect)
        set flag = IsUnitInRegion(rectRegion, whichUnit)
        call RemoveRegion(rectRegion)
        set rectRegion = null
        
        return flag
    endfunction
    
    function IsUnitDead takes unit u returns boolean
        return IsUnitType(u, UNIT_TYPE_DEAD) or GetUnitTypeId(u) == 0
    endfunction
    
    function RectFromCenterSize takes real tx, real ty, real width, real height returns rect
        return Rect( tx - width * 0.5, ty - height * 0.5, tx + width * 0.5, ty + height * 0.5 )
    endfunction
    
    function XE_Dummy_Conditions takes unit u returns boolean
        return GetUnitTypeId(u) != XE_DUMMY_UNITID
    endfunction
	
	globals
		private constant real ALPHA = 1.0
		private constant real BETA = 0.1
	endglobals
    
	function GetGameStartRatioValue takes integer value, real factor returns integer
		if not (Game.isOneSidedGame()) then
			return R2I(I2R(value) * I2R(Game.getCoalitionPlayers()) / I2R(6) * (I2R(1) + factor * (I2R(6) - I2R(Game.getForsakenPlayers()))))
		//Wenn nur auf der Forsaken Seite Spieler sind...
		elseif (Game.getCoalitionPlayers() == 0 and Game.getForsakenPlayers() > 0) then
			return R2I(I2R(value) * I2R(Game.getForsakenPlayers()) / I2R(6))
		//Wenn nur auf der Coalition Seite Spieler sind...
		else
			return R2I(I2R(value) * I2R(Game.getCoalitionPlayers()) / I2R(6) * (I2R(1) + factor))
		endif
	endfunction
	
    function GetDynamicRatioValue takes integer value, real factor returns integer
		if not (Game.isOneSidedGame()) then
			return R2I(I2R(value) * I2R(Game.getCoalitionPlayers()) / I2R(6) * (I2R(1) + factor * (I2R(6) - I2R(Game.getForsakenPlayers()))))
		//Wenn nur auf der Forsaken Seite Spieler sind...
		elseif (Game.getCoalitionPlayers() == 0 and Game.getForsakenPlayers() > 0) then
			return R2I(I2R(value) * I2R(Game.getForsakenPlayers()) / I2R(6))
		//Wenn nur auf der Coalition Seite Spieler sind...
		else
			return R2I(I2R(value) * BETA * Game.getCoalitionHeroLevelSumPow(ALPHA))
		endif
    endfunction
    
    //Zeige/Versteck des Timer Dialogs
    function TimerDialogDisplayForPlayer takes player p, timerdialog tm, boolean show returns nothing
        if (GetLocalPlayer() == p) then
            call TimerDialogDisplay(tm, show)
        endif
    endfunction
    
    function cinematicOn takes player p returns nothing
        if (GetLocalPlayer() == p) then
            call ClearTextMessages()
            call ShowInterface(false, 1.5)
            call EnableUserControl(false)
            call EnableOcclusion(false)
            call FogMaskEnable(false)
            call FogEnable(false)
            call EnableWorldFogBoundary(false)
        endif
    endfunction
        
    function cinematicOff takes player p returns nothing
        if (GetLocalPlayer() == p) then
            //call ClearTextMessages()
            call ShowInterface(true, 1.5)
            call EnableUserControl(true)
            call EnableOcclusion(true)
            call FogMaskEnable(true)
            call FogEnable(true)
            call EnableWorldFogBoundary(true)
        endif
    endfunction
    
    function CountItemInInventar takes unit u returns integer
        local integer i = 0
        local integer count = 0
        
        loop
          exitwhen i > 5
          set count = GetItemTypeId(UnitItemInSlot(u,i))
          set i = i + 1
        endloop
        
        return count
    endfunction
	
	
	function StopUnitsOfPlayer takes player p returns nothing
		local group g = NewGroup()
		local unit u
		
		call GroupEnumUnitsOfPlayer(g, p, null)
		loop
			set u = FirstOfGroup(g)
			exitwhen u == null
			call IssueImmediateOrder(u, "holdposition")
			call GroupRemoveUnit(g, u)
		endloop
		
		set u = null
		call ReleaseGroup(g)
	endfunction

endlibrary