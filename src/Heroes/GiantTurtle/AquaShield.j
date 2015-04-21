scope AquaShield initializer init
    /*
     * Description: The Giant Turtle summons a magic shield of water around the target unit, protecting it 
                    against physical damage. The shield increases the armor of the target and explodes after expiring, 
                    dealing damage to enemies in an area around the target. The shield can be destroyed manually if 
                    it is cast on self.
     * Changelog: 
     *      10.01.2014: Abgleich mit OE und der Exceltabelle
	 *		17.04.2015: Integrated RegisterPlayerUnitEvent
     */
    globals
        private constant integer SPELL_ID = 'A083'
        private constant integer AQUA_SHIELD_RELEASE_SPELL_ID = 'A084'
        private constant integer AQUA_SHIELD_BUFF_PLACER_ID = 'A085'
        private constant integer AQUA_SHIELD_BUFF_ID = 'B01K'
        private constant real AQUA_SHIELD_DAMAGE_AREA = 250.00
        private constant string AQUA_SHIELD_DAMAGE_EFFECT = "Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl"
        private constant string AQUA_SHIELD_DAMAGE_EFFECT_ATTACH = "chest"
        private constant string AQUA_SHIELD_EXPLOSION_EFFECT = "Models\\AquaShieldExplosion.mdx"
        private constant real AQUA_SHIELD_EXPLOSION_SIZE = 1.0 //0.35
        private constant real AQUA_SHIELD_DURATION = 10.00
        private real array AQUA_SHIELD_DAMAGE
        private integer array AQUA_SHIELD_ARMOR_BONUS
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    private function MainSetup takes nothing returns nothing
        set AQUA_SHIELD_DAMAGE[0] = 75.00
        set AQUA_SHIELD_DAMAGE[1] = 125.00
        set AQUA_SHIELD_DAMAGE[2] = 175.00
        set AQUA_SHIELD_DAMAGE[3] = 225.00
        set AQUA_SHIELD_DAMAGE[4] = 275.00
        
        set AQUA_SHIELD_ARMOR_BONUS[0] = 3
        set AQUA_SHIELD_ARMOR_BONUS[1] = 5
        set AQUA_SHIELD_ARMOR_BONUS[2] = 7
        set AQUA_SHIELD_ARMOR_BONUS[3] = 9
        set AQUA_SHIELD_ARMOR_BONUS[4] = 11
    endfunction
    
    private keyword Main

    private struct AquaShield

    static delegate xedamage dmg = 0
    static thistype temp = 0
    static integer buffType = 0
    static boolean array registred
    static trigger onDeathTrig = null

    unit caster = null
    unit target = null
    integer lvl = -1
    boolean selfCast = false

    dbuff buff = 0
    ArmorBonus armorBonus = 0

    method onDestroy takes nothing returns nothing
        call armorBonus.remove(true) 
    endmethod

    method releaseShield takes boolean destroyBuff returns nothing
        local xefx explosion = 0
        set DamageType = SPELL
        call damageAOE(caster, GetUnitX(target), GetUnitY(target), AQUA_SHIELD_DAMAGE_AREA, AQUA_SHIELD_DAMAGE[lvl])
        if destroyBuff then
            call buff.destroy()
        endif
        if AQUA_SHIELD_EXPLOSION_EFFECT != "" then
            set explosion = xefx.create(GetUnitX(caster), GetUnitY(caster), GetRandomReal(0, bj_PI * 2))
            set explosion.fxpath = AQUA_SHIELD_EXPLOSION_EFFECT
            set explosion.scale = AQUA_SHIELD_EXPLOSION_SIZE
            call explosion.destroy()
        endif
        if selfCast then
            call SetPlayerAbilityAvailable(GetOwningPlayer(caster), AQUA_SHIELD_RELEASE_SPELL_ID, false)
            call SetPlayerAbilityAvailable(GetOwningPlayer(caster), SPELL_ID, true)
        endif 
        call destroy()
    endmethod

    static method onBuffEnd takes nothing returns nothing
        local dbuff b = GetEventBuff()
        if b.isExpired or b.isRemoved then
            call thistype(b.data).releaseShield(false)
        endif
    endmethod

    static method onBuffAdd takes nothing returns nothing
        local dbuff b = GetEventBuff()
        local thistype this = 0

        if b.isRefreshed then
            call thistype(b.data).destroy()
        endif

        set this = allocate()
        set b.data = integer(this)
        set caster = b.source
        set target = b.target
        if caster == target then
            set selfCast = true
            call SetPlayerAbilityAvailable(GetOwningPlayer(caster), SPELL_ID, false)
            call SetPlayerAbilityAvailable(GetOwningPlayer(caster), AQUA_SHIELD_RELEASE_SPELL_ID, true)
            if GetUnitAbilityLevel(caster, AQUA_SHIELD_RELEASE_SPELL_ID) == 0 then
                call UnitAddAbility(caster, AQUA_SHIELD_RELEASE_SPELL_ID)
            endif
        endif
        set lvl = b.level - 1
        set armorBonus = ArmorBonus.create(target)
        call armorBonus.add(AQUA_SHIELD_ARMOR_BONUS[lvl])
        set buff = b
        endmethod

    static method add takes Main from returns nothing
        call UnitAddBuff(from.caster, from.target, buffType, AQUA_SHIELD_DURATION, from.lvl)
    endmethod

    static method onSpellCast takes nothing returns boolean
        local thistype this = 0
        
        if GetUnitTypeId(GetTriggerUnit()) != XE_DUMMY_UNITID then
            set this =  thistype(GetUnitBuff(GetTriggerUnit(), buffType).data)
            if this != 0 and selfCast and GetSpellAbilityId() == AQUA_SHIELD_RELEASE_SPELL_ID then
                call releaseShield(true)
            endif
        endif
        return false 
    endmethod

    static method onInit takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CAST, function thistype.onSpellCast, null)

        set buffType = DefineBuffType(AQUA_SHIELD_BUFF_PLACER_ID, AQUA_SHIELD_BUFF_ID, 0, false, false, thistype.onBuffAdd, 0, thistype.onBuffEnd)
        set dmg = xedamage.create()
        set dtype = DAMAGE_TYPE
        set atype = ATTACK_TYPE
		set wtype = WEAPON_TYPE
        call useSpecialEffect(AQUA_SHIELD_DAMAGE_EFFECT, AQUA_SHIELD_DAMAGE_EFFECT_ATTACH)
    endmethod

    endstruct

    private struct Main
    static constant integer spellId = SPELL_ID
    static constant boolean autoDestroy = true
    static constant integer spellType = SPELL_TYPE_TARGET_UNIT

    static boolean array learned

    method onCast takes nothing returns nothing
        call AquaShield.add(this)
    endmethod

    static method onLearn takes unit u returns nothing
        local integer i = GetPlayerId(GetOwningPlayer(u))
        //THIS METHOD IS FASTER, BUT SO THE SPELL ONLY IS MPI, NOT MUI!!!
        if not learned[i] then
            call UnitAddAbility(u, AQUA_SHIELD_RELEASE_SPELL_ID)
            call SetPlayerAbilityAvailable(GetOwningPlayer(u), AQUA_SHIELD_RELEASE_SPELL_ID, false)
            set learned[i] = true
        endif
    endmethod

    implement Spell

    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(AQUA_SHIELD_RELEASE_SPELL_ID)
        call XE_PreloadAbility(AQUA_SHIELD_BUFF_PLACER_ID)
        call Preload(AQUA_SHIELD_DAMAGE_EFFECT)
        call Preload(AQUA_SHIELD_EXPLOSION_EFFECT)
    endfunction

endscope