scope GameSounds initializer Init

	/*
	 * Hier werden alle Sounds hinterlegt, die ueberall mehr als 1x verwendet werden
	 * Sie sind damit ueberall verfuegbar 
	 */  
	globals
		string GLOBAL_SOUND_1 = "Sound\\Interface\\Hint.wav" //Hint Sound
		string GLOBAL_SOUND_2 = "Sound\\Interface\\BattleNetTick.wav" //Tick
		string GLOBAL_SOUND_3 = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.wav" //Teleporter Sound
	endglobals

	private function Init takes nothing returns nothing
		call Sound.preload(GLOBAL_SOUND_1)
		call Sound.preload(GLOBAL_SOUND_2)
		call Sound.preload(GLOBAL_SOUND_3)
	endfunction
	
endscope