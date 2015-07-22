//==============================================================================
//  TEXT TAG - Floating text system by Cohadar - v5.0
//==============================================================================
//
//  PURPOUSE:
//       * Displaying floating text - the easy way
//       * Has a set of useful and commonly needed texttag functions
//  
//  CREDITS:
//       * DioD - for extracting proper color, fadepoint and lifespan parameters
//         for default warcraft texttags (from miscdata.txt)
//
//  HOW TO IMPORT:
//       * Just create a trigger named TextTag
//         convert it to text and replace the whole trigger text with this one
//==============================================================================

library TextTag

    globals    
        // for custom centered texttags
        private constant real MEAN_CHAR_WIDTH = 5.5
        private constant real MAX_TEXT_SHIFT = 200.0
        private constant real DEFAULT_HEIGHT = 16.0

        // for default texttags
        private constant real   SIGN_SHIFT = 16.0
        private constant real   FONT_SIZE = 0.024
        private constant string MISS = "miss"
    endglobals

    //===========================================================================
    //   Custom centered texttag on (x,y) position
    //   color is in default wc3 format, for example "|cFFFFCC00"
    //===========================================================================
    public function TextTagXY takes real x, real y, string text, string color returns nothing
        local texttag tt = CreateTextTag()
        local real shift = RMinBJ(StringLength(text)*MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
        call SetTextTagText(tt, color+text, FONT_SIZE)
        call SetTextTagPos(tt, x-shift, y, DEFAULT_HEIGHT)
        call SetTextTagVelocity(tt, 0.0, 0.04)
        call SetTextTagVisibility(tt, true)
        call SetTextTagFadepoint(tt, 2.5)
        call SetTextTagLifespan(tt, 4.0)
        call SetTextTagPermanent(tt, false)
        set tt = null
    endfunction

    //===========================================================================
    //   Custom centered texttag above unit
    //===========================================================================
    function TextTagUnit takes unit whichUnit, string text, string color returns nothing
        local texttag tt = CreateTextTag()
        local real shift = RMinBJ(StringLength(text)*MEAN_CHAR_WIDTH, MAX_TEXT_SHIFT)
        call SetTextTagText(tt, color+text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-shift, GetUnitY(whichUnit), DEFAULT_HEIGHT)
        call SetTextTagVelocity(tt, 0.0, 0.04)
        call SetTextTagVisibility(tt, true)
        call SetTextTagFadepoint(tt, 2.5)
        call SetTextTagLifespan(tt, 4.0)
        call SetTextTagPermanent(tt, false)    
        set tt = null
    endfunction

    //===========================================================================
    //  Standard wc3 gold bounty texttag, displayed only to killing player 
    //===========================================================================
    function TextTagGoldBounty takes unit whichUnit, integer bounty, player killer returns nothing
        local texttag tt = CreateTextTag()
        local string text = "+" + I2S(bounty)
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
        call SetTextTagColor(tt, 255, 220, 0, 255)
        call SetTextTagVelocity(tt, 0.0, 0.03)
        call SetTextTagVisibility(tt, GetLocalPlayer()==killer)
        call SetTextTagFadepoint(tt, 2.0)
        call SetTextTagLifespan(tt, 3.0)
        call SetTextTagPermanent(tt, false)
        set text = null
        set tt = null
    endfunction

    //==============================================================================
    function TextTagLumberBounty takes unit whichUnit, integer bounty, player killer returns nothing
        local texttag tt = CreateTextTag()
        local string text = "+" + I2S(bounty)
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
        call SetTextTagColor(tt, 0, 200, 80, 255)
        call SetTextTagVelocity(tt, 0.0, 0.03)
        call SetTextTagVisibility(tt, GetLocalPlayer()==killer)
        call SetTextTagFadepoint(tt, 2.0)
        call SetTextTagLifespan(tt, 3.0)
        call SetTextTagPermanent(tt, false)
        set text = null
        set tt = null
    endfunction

    //===========================================================================
    function TextTagManaburn takes unit whichUnit, integer dmg returns nothing
        local texttag tt = CreateTextTag()
        local string text = "-" + I2S(dmg)
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit)-SIGN_SHIFT, GetUnitY(whichUnit), 0.0)
        call SetTextTagColor(tt, 82, 82 ,255 ,255)
        call SetTextTagVelocity(tt, 0.0, 0.04)
        call SetTextTagVisibility(tt, true)
        call SetTextTagFadepoint(tt, 2.0)
        call SetTextTagLifespan(tt, 5.0)
        call SetTextTagPermanent(tt, false)    
        set text = null
        set tt = null
    endfunction

    //===========================================================================
    function TextTagMiss takes unit whichUnit returns nothing
        local texttag tt = CreateTextTag()
        call SetTextTagText(tt, MISS, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
        call SetTextTagColor(tt, 255, 0, 0, 255)
        call SetTextTagVelocity(tt, 0.0, 0.03)
        call SetTextTagVisibility(tt, true)
        call SetTextTagFadepoint(tt, 1.0)
        call SetTextTagLifespan(tt, 3.0)
        call SetTextTagPermanent(tt, false)
        set tt = null
    endfunction

    //===========================================================================
    function TextTagCriticalStrike takes unit whichUnit, integer dmg returns nothing
        local texttag tt = CreateTextTag()
        local string text = I2S(dmg) + "!"
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
        call SetTextTagColor(tt, 255, 0, 0, 255)
        call SetTextTagVelocity(tt, 0.0, 0.04)
        call SetTextTagVisibility(tt, true)
        call SetTextTagFadepoint(tt, 2.0)
        call SetTextTagLifespan(tt, 5.0)
        call SetTextTagPermanent(tt, false)
        set text = null
        set tt = null    
    endfunction

    //===========================================================================
    function TextTagShadowStrike takes unit whichUnit, integer dmg, boolean initialDamage returns nothing
        local texttag tt = CreateTextTag()
        local string text = I2S(dmg)
        if initialDamage then
            set text = text + "!"
        endif
        call SetTextTagText(tt, text, FONT_SIZE)
        call SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
        call SetTextTagColor(tt, 160, 255, 0, 255)
        call SetTextTagVelocity(tt, 0.0, 0.04)
        call SetTextTagVisibility(tt, true)
        call SetTextTagFadepoint(tt, 2.0)
        call SetTextTagLifespan(tt, 5.0)
        call SetTextTagPermanent(tt, false)    
        set text = null
        set tt = null
    endfunction
    
endlibrary
