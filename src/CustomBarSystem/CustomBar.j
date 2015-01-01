//******************************************************************************
//*
//* CustomBar 1.0 (Initial Release)
//* ====
//*  For your CustomBar needs. / Thanks Vex for this sentence <3
//*
//* This library is used to give a fully functional Bar System
//* that provides you interfaces for setting the bar state and
//* for letting you fade the bar, and even let you decide which
//* fade Condition to use. 
//*
//* If a Bar is fading (out) and its condition becomes false, its
//* changing its fading (to in).
//*
//* You can also disable fading, if you want.
//*
//* PLEASE NOTE: MY FADING OF MY SYSTEM DOES !NOT! USE
//* WC3S FADE SYSTEM! IT SIMPLY CHANGES THE COLOR OF THE 
//* TEXTTAG WITH LESS ALPHA! YOU CAN USE BOTH TOGETHER, 
//* BUT I DOUBT ITS A GOOD IDEA!
//*
//*
//* by dhk_undead_lord / aka Anachron
//*
//******************************************************************************
library CustomBar initializer init requires ARGB

    //=!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#
    //: Change anything below to what you need!
    //=!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#

    //: The customizeable constants.
    //: I hope the names are self-explaining.
    //: (If not, check the CustomBar Documentation!
    globals
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //: Texttag defaults. 
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        public  constant string  FADE_TYPE_IN               = "IN"
        public  constant string  FADE_TYPE_OUT              = "OUT"
        private constant real    FADE_MIN                   = 0.
        private constant real    FADE_MAX                   = 1.00
        private constant real    TT_DEFAULT_AGE             = 0.
        private          ARGB    TT_DEFAULT_COLOR
        private constant real    TT_DEFAULT_FADEPOINT       = 0.
        private constant boolean TT_DEFAULT_FADES           = true
        private constant real    TT_DEFAULT_FADE_STATE      = FADE_MIN
        private constant real    TT_DEFAULT_FADE_STRENGH    = 0.75
        private constant string  TT_DEFAULT_FADE_TYPE       = FADE_TYPE_OUT
        private constant boolean TT_DEFAULT_FADING          = false
        private constant texttag TT_DEFAULT_HANDLE          = null
        private constant real    TT_DEFAULT_LIFESPAN        = 0.
        private constant boolean TT_DEFAULT_PERMANENT       = true
        private constant real    TT_DEFAULT_OFFSETX        = 0.
        private constant real    TT_DEFAULT_OFFSETY        = 0.
        private constant real    TT_DEFAULT_OFFSETZ        = 0.
        private constant real    TT_DEFAULT_POSX            = 0.
        private constant real    TT_DEFAULT_POSY            = 0.
        private constant real    TT_DEFAULT_POSZ            = 0.
        private constant real    TT_DEFAULT_SIZE            = 7.5 * 0.023 / 10
        private constant boolean TT_DEFAULT_SUSPENDED       = false
        private constant string  TT_DEFAULT_TEXT            = ""
        private constant real    TT_DEFAULT_VELX            = 0.
        private constant real    TT_DEFAULT_VELY            = 0.
        private constant boolean TT_DEFAULT_VISIBILITY      = true
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //: TextBar defaults.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        private constant string     TB_DEFAULT_CHAR                 = "I"
        private constant integer    TB_DEFAULT_CHAR_AMOUNT          = 25
        private constant string     TB_DEFAULT_CHAR_EMPTY           = " "
        private          ARGB       TB_DEFAULT_CHAR_COLOR
        private constant string     TB_DEFAULT_FINISHEDBAR          = ""
        private          ARGB       TB_DEFAULT_LIMITER_COLOR
        private constant string     TB_DEFAULT_LIMITER_SYMBOL_LEFT  = "["
        private constant string     TB_DEFAULT_LIMITER_SYMBOL_RIGHT = "]"
        private constant boolean    TB_DEFAULT_LIMITER_VISIBLE      = true
        private constant real       TB_DEFAULT_PERCENTAGE           = 100.
        private constant integer    TB_MAX_CHAR_AMOUNT              = 100
    
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //: CustomBar defaults.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        private constant boolean    CB_DEFAULT_LOCKED           = true
        private constant unit       CB_DEFAULT_TARGET           = null
        private constant force      CB_DEFAULT_SHOW_FORCE       = bj_FORCE_ALL_PLAYERS
    
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //: TextBarStack defaults.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        private constant timer  CBS_TIMER   = CreateTimer()
        private constant real   CBS_TICK    = 0.0375
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //: Information.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //: For the ARGB declaration check the function init,
        //: at the total bottom of this library.
    endglobals
    
    //: The interfaces for the system
    public function interface iChange takes CustomBar cb returns nothing
    public function interface iFade takes CustomBar cb returns boolean
    public function interface iShow takes player owner, player cur returns boolean
    
    //: Default functions for this system
    public function defaultFadeCondition takes CustomBar cb returns boolean
        return GetUnitState(cb.target, UNIT_STATE_LIFE) == 0.
    endfunction
    
    public function defaultShowCondition takes player owner, player cur returns boolean
        return true
    endfunction
    
    //=!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#
    //: I don't recommend changing code below this!
    //=!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#
    
    //==-=-=-=-=-=-=-
    //: Textmacros
    //==-=-=-=-=-=-=-
    //! textmacro varOp takes name, fname, type, method
    method operator $fname$ takes nothing returns $type$
        return .$name$
    endmethod
    
    method operator $fname$= takes $type$ val returns nothing
        set .$name$ = val
        $method$
    endmethod
    //! endtextmacro
    //==-=-=-=-=-=-=-
        
    //: A struct which contains all 
    //: TextTag methods and members
    private struct TextTag
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: TextTag members. Sorted by name.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private real    Age         = TT_DEFAULT_AGE
        private ARGB    Color       = TT_DEFAULT_COLOR
        private boolean Fades       = TT_DEFAULT_FADES
        private real    FadeState   = TT_DEFAULT_FADE_STATE
        private real    FadeStrengh = TT_DEFAULT_FADE_STRENGH
        private string  FadeType    = TT_DEFAULT_FADE_TYPE
        private real    Fadepoint   = TT_DEFAULT_FADEPOINT
        private boolean Fading      = TT_DEFAULT_FADING
        private iFade   FadeCond    = defaultFadeCondition
        private real    Lifespan    = TT_DEFAULT_LIFESPAN
        private texttag Handle      = TT_DEFAULT_HANDLE
        private boolean Permanent   = TT_DEFAULT_PERMANENT
        private real    OffsetX     = TT_DEFAULT_OFFSETX
        private real    OffsetY     = TT_DEFAULT_OFFSETY
        private real    OffsetZ     = TT_DEFAULT_OFFSETZ
        private real    PosX        = TT_DEFAULT_POSX
        private real    PosY        = TT_DEFAULT_POSY
        private real    PosZ        = TT_DEFAULT_POSZ
        private boolean Suspended   = TT_DEFAULT_SUSPENDED
        private string  Text        = TT_DEFAULT_TEXT
        private real    Size        = TT_DEFAULT_SIZE
        private real    VelX        = TT_DEFAULT_VELX
        private real    VelY        = TT_DEFAULT_VELY
        private boolean Visibility  = TT_DEFAULT_VISIBILITY
    
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: TextTag methods. 
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            
            set .Handle = CreateTextTag()
            call .updAge()
            call .updColor()
            call .updFadepoint()
            call .updLifespan()
            call .updPermanent()
            call .updPos()
            call .updSuspended()
            call .updText()
            call .updVelocity()
            
            return this
        endmethod
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Update Methods.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private method updAge takes nothing returns nothing
            call SetTextTagAge(.Handle, .Age)    
        endmethod
        
        private method updColor takes nothing returns nothing
            if not .fading then
                call SetTextTagColor(.Handle, .Color.red, .Color.green, .Color.blue, .Color.alpha)
            endif
        endmethod
        
        private method updFadepoint takes nothing returns nothing
            call SetTextTagFadepoint(.Handle, .Fadepoint)
        endmethod
        
        private method updLifespan takes nothing returns nothing
            call SetTextTagLifespan(.Handle, .Lifespan)    
        endmethod
        
        private method updPermanent takes nothing returns nothing
            call SetTextTagPermanent(.Handle, .Permanent)   
        endmethod
        
        private method updPos takes nothing returns nothing
            call SetTextTagPos(.Handle, .PosX, .PosY, .PosZ)  
        endmethod
        
        private method updSuspended takes nothing returns nothing
            call SetTextTagSuspended(.Handle, .Suspended) 
        endmethod
        
        private method updText takes nothing returns nothing
            call SetTextTagText(.Handle, .Text, .Size)
        endmethod
        
        private method updVelocity takes nothing returns nothing
            call SetTextTagVelocity(.Handle, .VelX, .VelY)  
        endmethod
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Member setting / getting
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Variables that should update the texttag
        //==----------------------------------------
        //! runtextmacro varOp("Age",        "age",          "real",     "call .updAge()")
        //! runtextmacro varOp("Color",      "color",        "ARGB",     "call .updColor()")
        //! runtextmacro varOp("Fadepoint",  "fadepoint",    "real",     "call .updFadepoint()")
        //! runtextmacro varOp("Lifespan",   "lifespan",     "real",     "call .updLifespan()")
        //! runtextmacro varOp("Permanent",  "permanent",    "boolean",  "call .updPermanent()")
        //! runtextmacro varOp("Suspended",  "suspended",    "boolean",  "call .updSuspended()")
        //! runtextmacro varOp("Visibility", "visiblity",    "boolean",  "")
        
        //==--------------------------------------------
        //: Variables that shouldn't update the texttag
        //==--------------------------------------------
        //! runtextmacro varOp("Fades",         "fades",        "boolean",  "")
        //! runtextmacro varOp("FadeCond",      "fadeCond",     "iFade",    "")
        //! runtextmacro varOp("FadeState",     "fadeState",    "real",     "")
        //! runtextmacro varOp("FadeStrengh",   "fadeStrengh",  "real",     "")
        //! runtextmacro varOp("FadeType",      "fadeType",     "string",   "")
        //! runtextmacro varOp("Fading",        "fading",       "boolean",  "")
        //! runtextmacro varOp("Handle",        "handle",       "texttag",  "")
        //! runtextmacro varOp("OffsetX",       "offsetX",      "real",     "")
        //! runtextmacro varOp("OffsetY",       "offsetY",      "real",     "")
        //! runtextmacro varOp("OffsetZ",       "offsetZ",      "real",     "")
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Advanced members and their settings.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public method pos takes real x, real y, real z returns nothing
            set .PosX = x + .OffsetX
            set .PosY = y + .OffsetY
            set .PosZ = z + .OffsetZ
            call .updPos()
        endmethod
        
        public method posUnit takes unit u, real z returns nothing
            call .pos(GetUnitX(u), GetUnitY(u), z)
        endmethod
        
        public method text takes string t, real s returns nothing
            set .Text = t
            set .Size = s * 0.023 / 10
            call .updText()
        endmethod
        
        method operator textText takes nothing returns string
            return .Text
        endmethod
        
        method operator textText= takes string t returns nothing
            set .Text = t
            call .updText()
        endmethod
        
        method operator textSize takes nothing returns real
            return .Size
        endmethod
        
        method operator textSize= takes real s returns nothing
            set .Size = s
            call .updText()
        endmethod
        
        public method velocity takes real s, real angle returns nothing
            local real vel = s * 0.071 / 128
            set .VelX = vel * Cos(angle * bj_DEGTORAD)
            set .VelY = vel * Sin(angle * bj_DEGTORAD)
            call .updVelocity()
        endmethod
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Advanced Methods
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public method showPlayer takes player p returns nothing
            if GetLocalPlayer() == p then
                call SetTextTagVisibility(.Handle, .Visibility)
            endif 
        endmethod
        
        public method fade takes CustomBar cb returns nothing
            local boolean c = false
            local boolean r = false
            local ARGB color = 0
            
            if .Fades then
                set c = .fadeCond.evaluate(cb)
                
                if c and .FadeState < FADE_MAX then
                    set .FadeType = FADE_TYPE_OUT
                    set .Fading = true
                    set r = true
                elseif not(c) and .FadeState > FADE_MIN then
                    set .FadeType = FADE_TYPE_IN
                    set .Fading = true
                    set r = true
                endif
                
                if .Fading then
                    //: Lets calculate the fading!
                    if .FadeType == FADE_TYPE_OUT then
                        set .FadeState = .FadeState + .FadeStrengh * CBS_TICK
                        if .FadeState >= FADE_MAX then
                            set .FadeState = FADE_MAX
                            set .Fading = false
                        endif
                    elseif .FadeType == FADE_TYPE_IN then
                        set .FadeState = .FadeState - .FadeStrengh * CBS_TICK
                        if .FadeState <= FADE_MIN then
                            set .FadeState = FADE_MIN
                            set .Fading = false
                        endif
                    endif
                    
                    if .Fading then
                        call SetTextTagAge(.Handle, .FadeState)
                    endif
                endif
                
                if r then
                    if .Fading then
                        call SetTextTagAge(.Handle, .FadeState)
                        call SetTextTagFadepoint(.Handle, 0.)
                        call SetTextTagLifespan(.Handle, FADE_MAX + CBS_TICK * 2)
                        call SetTextTagPermanent(.Handle, false)
                        call cb.showCB()
                    else
                        call SetTextTagAge(.Handle, .Age)
                        call SetTextTagLifespan(.Handle, .Lifespan)
                        call SetTextTagFadepoint(.Handle, .Fadepoint)
                        call SetTextTagPermanent(.Handle, .Permanent)
                        
                        if  .FadeType == FADE_TYPE_OUT then
                            call SetTextTagVisibility(.Handle, false)
                        endif
                    endif
                endif
            endif
        endmethod
        
        private method onDestroy takes nothing returns nothing
            call DestroyTextTag(.Handle)
        endmethod
    endstruct
    
    //: A struct which contains all 
    //: Textbar methods and members
    private struct TextBar
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: TextBar members. Sorted by name.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private string          Char                = TB_DEFAULT_CHAR
        private integer         CharAmount          = TB_DEFAULT_CHAR_AMOUNT
        private ARGB            CharColor           = TB_DEFAULT_CHAR_COLOR
        private ARGB    array   CharColors          [TB_MAX_CHAR_AMOUNT]
        private string          CharEmpty           = TB_DEFAULT_CHAR_EMPTY   
        private string          FinishedBar         = TB_DEFAULT_FINISHEDBAR
        private ARGB            LimiterColor        = TB_DEFAULT_LIMITER_COLOR
        private string          LimiterSymbolLeft   = TB_DEFAULT_LIMITER_SYMBOL_LEFT
        private string          LimiterSymbolRight  = TB_DEFAULT_LIMITER_SYMBOL_RIGHT
        private boolean         LimiterVisible      = TB_DEFAULT_LIMITER_VISIBLE
        private real            Percentage          = TB_DEFAULT_PERCENTAGE
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: TextBar methods
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            
            return this
        endmethod
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Member setting / getting
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Variables that should'nt update the texttag
        //==--------------------------------------------
        //! runtextmacro varOp("Char",                  "char",                 "string",   "")
        //! runtextmacro varOp("CharAmount",            "charAmount",           "integer",  "")
        //! runtextmacro varOp("CharEmpty",             "charEmpty",            "string",   "")
        //! runtextmacro varOp("FinishedBar",           "finishedBar",          "string",   "")
        //! runtextmacro varOp("LimiterColor",          "limiterColor",         "ARGB",     "")
        //! runtextmacro varOp("LimiterSymbolLeft",     "limiterSymbolLeft",    "string",   "")
        //! runtextmacro varOp("LimiterSymbolRight",    "limiterSymbolRight",   "string",   "")
        //! runtextmacro varOp("LimiterVisible",        "limiterVisible",       "boolean",  "")
        //! runtextmacro varOp("Percentage",            "percentage",           "real",     "")
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Advanced Methods
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public method addGradient takes ARGB left, ARGB right, integer start, integer end returns nothing
            local integer i = start - 1
            local boolean e = false
            local real s = 0.
            local string test = ""
            local real m = 100 / .CharAmount
            set m = m / 100
            
            loop
                exitwhen e
                
                if i < end then
                    set s = i * m
                    set test = "i :" + I2S(i) + "\n" + " 1 / " + I2S(.CharAmount) + " = " + R2S(s)
                    set .CharColors[i] = ARGB.mix(left, right, s)
                    
                    set i = i + 1
                else
                    set e = true
                endif
            endloop
        endmethod
        
        public method generateBar takes nothing returns nothing
            local integer i = 0
            local string char = ""
            
            set .FinishedBar = ""
            
            loop
                exitwhen i >= .CharAmount
                
                if i < (.Percentage / 100) * .CharAmount then
                    if .CharColors[i] != 0 then
                        set char = .CharColors[i].str(.Char)
                    else
                        set char = .CharColor.str(.Char)
                    endif
                else
                    set char = .CharEmpty
                endif
                
                set .FinishedBar = .FinishedBar + char
                
                set i = i + 1
            endloop
            
            if .LimiterVisible then
                set .FinishedBar = .LimiterColor.str(.LimiterSymbolLeft) + .FinishedBar + .LimiterColor.str(.LimiterSymbolRight)
            endif
        endmethod
    endstruct
    
    //: A struct which contains all 
    //: Custom methods and members
    struct CustomBar
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: CustomBar members
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private unit    Target      = CB_DEFAULT_TARGET
        private boolean Locked      = CB_DEFAULT_LOCKED
        private iChange UpdateMethod
        
        private iShow   ShowCond    = defaultShowCondition
        private force   ShowForce   = CB_DEFAULT_SHOW_FORCE
        
        private TextBar TxtBar
        private TextTag TxtTag
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: CustomBar methods
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public static method create takes unit target, iChange updMeth returns thistype
            local thistype this = thistype.allocate()
            
            set .Target = target
            set .TxtBar = TextBar.create()
            set .TxtTag = TextTag.create()
            set .UpdateMethod = updMeth
            
            call CBStack.addCustomBar(this)
            
            return this   
        endmethod
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Member setting / getting
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Variables that should'nt update the texttag
        //==--------------------------------------------
        //! runtextmacro varOp("Locked",        "locked",       "boolean",  "")
        //! runtextmacro varOp("ShowCond",      "showCond",     "iShow",    "")
        //! runtextmacro varOp("ShowForce",     "showForce",    "force",    "")
        //! runtextmacro varOp("Target",        "target",       "unit",     "")
        //! runtextmacro varOp("TxtTag",        "txtTag",       "TextTag",  "")
        //! runtextmacro varOp("TxtBar",        "txtBar",       "TextBar",  "")
        //! runtextmacro varOp("UpdateMethod",  "updateMethod", "iChange",  "")
        
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        //: Advanced methods.
        //==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        public method Show takes force f, iShow c returns nothing
            set .ShowForce = f
            set .ShowCond = c
        endmethod
        
        public method checkP takes player p returns nothing
            if .ShowCond.evaluate(GetOwningPlayer(.Target), p) then
                call .TxtTag.showPlayer(p)    
            endif   
        endmethod
        
        public method showCB takes nothing returns nothing
            local integer i = 0
            local boolean e = false
            
            loop
                exitwhen e
                
                if i < 15 then
                    if IsPlayerInForce(Player(i), .ShowForce) then
                        call .checkP(Player(i))
                    endif
                
                    set i = i + 1
                else
                    set e = true
                endif
            endloop
        endmethod
        
        public method updateBar takes nothing returns nothing
            if .Locked then
                call .TxtTag.posUnit(.Target, 0.)
            endif
            
            call .UpdateMethod.execute(this)
            call .TxtBar.generateBar()
            set .TxtTag.textText = .TxtBar.finishedBar
        endmethod
        
        public method update takes nothing returns nothing
            call .updateBar()
            call .TxtTag.fade(this)
        endmethod
        
        private method onDestroy takes nothing returns nothing
            call CBStack.remCustomBar(this)
            call .TxtTag.destroy()
            call .TxtBar.destroy()
        endmethod
    endstruct
    
    //: A struct which is used to
    //: update CustomBars
    struct CBStack
        static CustomBar array CBars
        static integer index = 0
        
        public static method addCustomBar takes CustomBar cb returns nothing
            set thistype.CBars[thistype.index] = cb
            set thistype.index = thistype.index + 1
            
            if thistype.index == 1 then
                call TimerStart(CBS_TIMER, CBS_TICK, true, function thistype.updateBars)
            endif 
        endmethod
        
        public static method remCBByIndex takes integer i returns nothing
            set thistype.CBars[i] = thistype.CBars[thistype.index]
            set thistype.index = thistype.index - 1
            
            if thistype.index <= 0 then
                call PauseTimer(CBS_TIMER)
            endif    
        endmethod
        
        public static method remCustomBar takes CustomBar cb returns nothing
            local integer i = 0
            local boolean e = false
            
            loop
                exitwhen e
                
                if i < thistype.index then
                    if thistype.CBars[i] == cb then
                        call .remCBByIndex(i)
                        set e = true
                    else
                        set i = i + 1
                    endif
                else
                    set e = true
                endif
            endloop
        endmethod
        
        public static method updateBars takes nothing returns nothing
            local integer i = 0
            local boolean e = false
        
            loop
                exitwhen e
                
                if i < thistype.index then
                
                    if thistype.CBars[i] == 0 then
                        call thistype.remCBByIndex(i)
                        set i = i - 1
                    else
                        call thistype.CBars[i].update()
                    endif
                    
                    set i = i + 1
                else
                    set e = true
                endif
            endloop
        endmethod
    endstruct

    //: The init method, initialisates
    //: a few default objects
    private function init takes nothing returns nothing
        set TB_DEFAULT_CHAR_COLOR       = ARGB.create(255,  255,    255,    255)
        set TB_DEFAULT_LIMITER_COLOR    = ARGB.create(255,  255,    255,    255)  
        set TT_DEFAULT_COLOR            = ARGB.create(255,  255,    255,    255)
    endfunction
endlibrary