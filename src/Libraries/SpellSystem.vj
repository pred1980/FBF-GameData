//! zinc
library SpellSystem requires SpellEvent, optional AbilityPreload{

    public constant integer SPELL_TYPE_TARGET_UNIT = 1;
    public constant integer SPELL_TYPE_TARGET_GROUND = 2;
    public constant integer SPELL_TYPE_NO_TARGET = 3;
    public constant integer SPELL_TYPE_SELF_CAST = 4;
    
    /*Required Variables:
        - integer spellId
        - integer spellType
        - boolean autoDestroy
        
      Optional Variables:
        - hasSubSkill
        - integer subSkillId
        - boolean adjustSubSkillLevel
    */
    
    public module Spell {
        public {
            unit caster, target;
            integer lvl;
            real x, y, cx, cy, dist, angle;
            boolean usedSubSkill = false;
            string order = "";
            static trigger learn = null;
        }

        private static method create(boolean subSkill, integer usedSkill) -> thistype{
            thistype this = allocate();
            real dx = 0.00, dy = 0.00; 
            caster = SpellEvent.CastingUnit;
            target = SpellEvent.TargetUnit;
            x = SpellEvent.TargetX;
            y = SpellEvent.TargetY;
            cx = GetUnitX(caster);
            cy = GetUnitY(caster);
            order = OrderId2String(GetIssuedOrderId());
            usedSubSkill = subSkill;
            lvl = GetUnitAbilityLevel(caster, usedSkill);
            
            if(thistype.spellType != SPELL_TYPE_NO_TARGET && target != caster){
                    dx = x - GetUnitX(caster);
                    dy = y - GetUnitY(caster);
                dist = SquareRoot(dx * dx + dy * dy);
                angle = Atan2(dy, dx);
            }
            
            static if(thistype.onCast.exists){
                onCast();
                static if(thistype.autoDestroy){
                    destroy();
                }
            }
            return this;
        }
        
        private static method castResponse(){
            static if(thistype.hasSubSkill){
                if(SpellEvent.AbilityId == subSkillId){
                    create(true, subSkillId);
                    return;
                }
            }
            if(SpellEvent.AbilityId == spellId){ create(false, spellId); }
        }
        
        private static method onAbilityLearn()->boolean{
            unit u = GetLearningUnit();
            integer l = GetLearnedSkillLevel();
			
			if(GetLearnedSkill() == spellId){
                static if(thistype.onLearn.exists){
                    if(l == 1){
                        thistype.onLearn(u);
                    }
                }
                static if(thistype.onSkill.exists){
                    if(l > 1){
                        thistype.onSkill(u);
                    }
                }
                static if(thistype.hasSubSkill){
                    static if(thistype.adjustSubSkill){
                        if(l == 1){
                            UnitAddAbility(u, thistype.subSkillId);
                        }
                        SetUnitAbilityLevel(u, thistype.subSkillId, l);
                    }
                }
            }
            u = null;
            return false;
        }
        
        public static method preload(){
            static if(LIBRARY_AbilityPreload){
                static if(thistype.hasSubSkill){
                    AbilityPreload(subSkillId);
                }
                AbilityPreload(spellId);
            }
        }
        
        private static method onInit(){
            RegisterSpellEffectResponse(0, castResponse);
            learn = CreateTrigger();
            TriggerRegisterAnyUnitEventBJ(learn, EVENT_PLAYER_HERO_SKILL);
            TriggerAddCondition(learn, Condition(static method thistype.onAbilityLearn));
        }
    }
}    
//! endzinc
            
            