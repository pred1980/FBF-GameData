library SoundTools requires Table
    
	globals
		private constant integer DEFAULT_SOUND_VOLUME = 127
		private constant integer DEFAULT_SOUND_PITCH = 1
	endglobals
	
	private struct slop
        string snd
    endstruct
   
    struct Sound
        private static HandleTable preloadDB
       
        private static method preloadAfter takes nothing returns nothing
            local timer time = GetExpiredTimer()
            local slop s = preloadDB[time]
            local sound snd = CreateSound(s.snd,false,false,false,12700,12700,"")
            
			call SetSoundVolume(snd,1)
            call StartSound(snd)
            call KillSoundWhenDone(snd)
            call s.destroy()
            set snd = null
            call DestroyTimer(time)
            set time = null
        endmethod
       
        static method preload takes string snd returns nothing
            local timer time = CreateTimer()
            local slop s = slop.create()
            
			set s.snd = snd
            set preloadDB[time] = s
            call TimerStart(time,.01,false,function thistype.preloadAfter)
            set time = null
        endmethod
       
        static method runSoundAtPoint takes string snd, real pitch, real x, real y, real z returns nothing
            local sound s = CreateSound(snd,false,true,true,12700,12700,"")
            
			call SetSoundPosition(s,x,y,z)
            call SetSoundVolume(s, DEFAULT_SOUND_VOLUME)
            call SetSoundPitch(s, DEFAULT_SOUND_PITCH)
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
        endmethod
		
		static method runSoundOnUnit takes string snd, unit whichUnit returns nothing
            local sound s = CreateSound(snd,false,true,true,12700,12700,"")
            
			call AttachSoundToUnit(s, whichUnit)
			call SetSoundVolume(s, DEFAULT_SOUND_VOLUME)
            call SetSoundPitch(s, DEFAULT_SOUND_PITCH)
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
        endmethod
       
        static method runSoundForPlayer takes string snd, player p returns nothing
            local sound s = CreateSound(snd,false,false,false,12700,12700,"")
            
			if GetLocalPlayer() == p then
                call SetSoundVolume(s, DEFAULT_SOUND_VOLUME)
            else
                call SetSoundVolume(s,0)
            endif
            call SetSoundPitch(s, DEFAULT_SOUND_PITCH)
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
        endmethod
       
        static method runSound takes string snd returns nothing
            local sound s = CreateSound(snd,false,false,false,12700,12700,"")
            
			call SetSoundVolume(s, DEFAULT_SOUND_VOLUME)
            call SetSoundPitch(s, DEFAULT_SOUND_PITCH)
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
        endmethod
       
        static method onInit takes nothing returns nothing
            set preloadDB = HandleTable.create()
        endmethod
    endstruct
endlibrary