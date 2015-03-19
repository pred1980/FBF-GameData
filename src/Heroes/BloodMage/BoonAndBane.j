scope BoonAndBane initializer init
    /*
     * Description: The Blood Mage launches a Fire Blast that spits smaller fireballs at the closest enemy unit. 
                    When the Blast lands, it fires one last wave of fireballs at all nearby enemies.
     * Last Update: 03.01.2014
     * Changelog: 
     *     03.01.2014: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: removed all debug-messages
     */
	//////////////////////////////////////////////////////////////////////////////////////////
	//																						//
	// 	Beschreibung:																		//
	// 																						//
	//	Verhört das Ziel und belegt diese mit einem Buff. Wenn das Ziel ein Feind ist,		//
	//	wird der angerichtete Schaden um 20% verringert und der erlittene Schaden um		//
	//	30% erhöht. Ist das Ziel freundlich, wird sein angerichteter Schaden um				//
	//	35% erhöht und sein erlittener Schaden um 50% verringert. 							//
	//																						//
	//	Dauer des Buffs: 15 Sekunden oder...												//
	//																						//
	//		bei Feinden bis der gesamte angerichtete Schaden um 200 verringert wurde,		//
	//		bei Freunden bis der gesamte erlittene Schaden um 250 verringert wurde.			//
	//																						//
	//////////////////////////////////////////////////////////////////////////////////////////
	
    globals
        private constant integer SPELL_ID = 'A094'
        private constant integer BUFF_PLACER_ID = 'A095'
        private constant integer BUFF_ID = 'B01V'
        private constant real BUFF_DURATION = 15.0
        
        private constant real array ENEMY_MAX_DAMAGE_MODIF
        private constant real array ALLY_MAX_DAMAGE_MODIF
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set ENEMY_MAX_DAMAGE_MODIF[1] = 100
        set ENEMY_MAX_DAMAGE_MODIF[2] = 150
        set ENEMY_MAX_DAMAGE_MODIF[3] = 200
        set ENEMY_MAX_DAMAGE_MODIF[4] = 250
        set ENEMY_MAX_DAMAGE_MODIF[5] = 300
        
        set ALLY_MAX_DAMAGE_MODIF[1] = 150
        set ALLY_MAX_DAMAGE_MODIF[2] = 200
        set ALLY_MAX_DAMAGE_MODIF[3] = 250
        set ALLY_MAX_DAMAGE_MODIF[4] = 300
        set ALLY_MAX_DAMAGE_MODIF[5] = 350
    endfunction
	
	//Die Keyword werden benötigt, um Struct oberhalb ihrer Deklarierung zu benutzen
	private keyword DamageManipulator
	private keyword Main
	
	//Der DamageManipulator Struct, welcher den DamageModifier extendet.
	private struct DamageManipulator extends DamageModifier
	
		//Dieser Integer ist die Priorität des DamageModifiers, je höher der Wert, desto eher wird der DamageModifier aufgerufen
		static constant integer prio = 100
		
		//Dies sind nur "Config Constants", die man beliebig ändern kann um den Spell anzupassen
		static constant real enemyIncomingDamageModification = 0.30 		//das sind die 30% mehr Schaden die Feinde erleiden
		static constant real allyIncomingDamageModification = -0.50		//das sind die 50% weniger Schaden die Freunde erleiden
		
		static constant real enemyOutgoingDamageModification = -0.20 	//das sind die 20% weniger Schaden, die Feinde anrichten
		static constant real allyOutgoingDamageModification = 0.35		//das sind die 25% mehr Schaden, die Freunde anrichten
		
		//Natürlich können hier auch persönliche Variablen verwendet werden und es kann sogar mehrere DamageModifier des selben Types
		//auf der gleichen Einheit sein, was jedoch zu vermeiden ist.
		
		//Das sind die "Buff-Daten" vom Ziel
		Main data = 0
        
        //Es ist wirklich ganz einfach... Man muss nur diese Methode in dem Struct deklarieren, welche dann vom System aufgerufen wird
		//Die Variablen sollten selbsterklärend sein, der Rückgabewert gibt an, um welchen Wert der Schaden manipuliert werden soll.
		//Ein positiver Wert erhöht den Schaden, ein negativer verringert den Schaden, den das Ziel anrichtet.
		method onDamageDealt takes unit damagedUnit, real damage returns real
			local real modification = 0.00
			
			//erst fragen wir anhand der Daten ab, ob der Buff freundlich ist
			if not data.isFriendly then
			
				//wenn das Ziel feindlich ist, wird sein Schaden verringert
				set modification = damage * enemyOutgoingDamageModification
				
				//den Schaden updaten (mithilfe der RAbsBJ-Funktion den absoluten Wert nehmen!)
				call data.updateCounter(RAbsBJ(modification))
				
				//nun den eben errechneten Wert zurückgeben, der Schaden wird nun verringert.
				//Beispiel: 100 Damage * (-0.20) = -20 als Rückgabewert (Endschaden = 80)
				return modification
			else
				//hier braucht man die lokale Variable nicht benutzen, da der Counter für Freunde bei einer Erhöhung des Schadens
				//nicht verändert wird, sondern nur, wenn er Schaden erleidet.
					
				//hier brauche ich also nur den Schaden ausrechnen, um welchen er erhöht werden soll
				//Beispiel: 100 Damage * 0.35 = 35 Damage als Rückgabewert. (Endschaden = 135)
				return damage * allyOutgoingDamageModification
			endif
			
			//Nur damit keine Syntax-Fehler aufkommen... dies wird eh nie aufgerufen, da ein Boolean nur wahr oder falsch sein kann :)
			return 0.00
		endmethod
		
		//Hier ist dies die selbe Situation wie eben, nur das diese Methode aufgrufen wird, wenn das Ziel (sprich die Einheit, der der
		//DamageModifier zugewiesen wurde) Schaden erleidet.
		method onDamageTaken takes unit damageSource, real damage returns real
            local real modification = 0.00
			
			//erst fragen wir anhand der Daten ab, ob der Buff freundlich ist
			if not data.isFriendly then
			
				//hier brauchen wir wieder nicht die Variable benutzen, da erhöhter Schaden bei Feinden nicht in den Counter mit einfließen.
				//wir brauchen nur den Wert zurückgeben, um welchen der Schaden erhöht werden soll
				//Beispiel: 100 Damage * (0.30) = 30 als Rückgabewert (Endschaden = 130)
				return damage * enemyIncomingDamageModification
			else
				//wenn das Ziel freundlich ist, wird sein Schaden verringert
				set modification = damage * allyIncomingDamageModification
				
				//den Schaden updaten (mithilfe der RAbsBJ-Funktion den absoluten Wert nehmen!)
				call data.updateCounter(RAbsBJ(modification))
			
				//nun den eben errechneten Wert zurückgeben, der erlittene Schaden wird nun verringert.
				//Beispiel: 100 Damage * (-0.50) = -50 als Rückgabewert (Endschaden = 50)
				return modification
			endif
			
			//Nur damit keine Syntax-Fehler aufkommen... dies wird eh nie aufgerufen, da ein Boolean nur wahr oder falsch sein kann :)
			return 0.00
		endmethod
		
		//Dies ist die create methode die aufgerufen wird, um einen neuen Modifier zu erzeugen
		//Wichtig ist hier, dass man beachten muss, dass die Allocate-Methode die Parameter der create Methode des
		//DamageModifier Structs annehmen muss, da dieser ihn extendet.
		static method create takes Main buffData returns thistype
			//DamageModifier-Create-Method:
            //static method create takes unit u, integer priority returns DamageModifier
			local thistype this = allocate(buffData.target, prio)
            
        	set data = buffData
			
			return this
		endmethod
		
	endstruct
	
	
	//Der "Main"-Struct welcher im Prinzip auch der Buff-Struct ist.
	private struct Main
	
		//Benötigte Variablen meines Spell-Systems
		static constant integer spellId = SPELL_ID
		static constant integer spellType = SPELL_TYPE_TARGET_UNIT
		static constant boolean autoDestroy = false
		
		//Benötigte Variablen für das Buff-System
		static constant integer buffPlacerId = BUFF_PLACER_ID //basierend auf Tornado-Aura
		static constant integer buffId = BUFF_ID
	
		//Dauer des Buffs
		static constant real buffDuration = BUFF_DURATION
        
        //Der Buff-Type welcher in der onInit-Methode erzeugt wird
        static integer buffType = 0
	
		//Das ist die Zählervariable für die Buff-Auslauf Bedingung (siehe Beschreibung)
		real damageCounter = 0.00
		
		//Dies ist der Buff auf der Einheit, dieser verhindert unter anderem, dass die Einheit den Buff doppelt erhält und lässt diesen
		//auch auslaufen (insofern nicht die Schadensgrenze vorerst eintritt).
		dbuff buffData = 0
		
		//Der DamageManipulator, welcher zu dem Buff gehört.
		DamageManipulator manipulator = 0
		
		//Benötigte Variable um zu gucken, ob das Ziel feindlich/freundlich ist
		boolean isFriendly = false
		
		//Nur eine TempVariable zum zwischenspeichern...
		static thistype temp = 0
		
		//Wenn der Struct hier (sprich der Buff) zerstört wird, soll auch der DamageManipulator zerstört werden!
		method onDestroy takes nothing returns nothing
            call manipulator.destroy()
        endmethod
		
		//Entfernt den Buff und zerstört daraufhin das Struct welches auch den Manipulator zerstört (siehe oben)
		method releaseBuff takes nothing returns nothing
            call buffData.destroy()
            call destroy()
		endmethod
		
		//Wird jedesmal aufgerufen, wenn der Schaden manipuliert wird
		method updateCounter takes real damage returns nothing
			//den DamageCounter erhöhen
            set damageCounter = damageCounter + damage
			
			//checken, ob die Grenze erreicht ist
            if (isFriendly and damageCounter >= ALLY_MAX_DAMAGE_MODIF[lvl]) or (not isFriendly and damageCounter >= ENEMY_MAX_DAMAGE_MODIF[lvl]) then
                //falls das zutrifft, den Buff releasen (und somit auch den DamageModifier und den Struct hier selbst)
                call releaseBuff()
			endif
        endmethod
		
		//Die Methode wird von dem BuffSystem aufgerufen, sobald dieser ausläuft, der Struct wurde als die Variable
		//"data" im Buff gespeichert, damit auf den Struct zugegriffen werden kann.
		static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff() //Returned immer den Buff, um den es gerade geht
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
        
		//Diese Methode wird von dem BuffSystem aufgerufen, sobald der Buff einer Einheit hinzugefügt wird.
		//Hier wird geprüft, ob die Einheit den Buff bereits hatte. Falls dies zutrifft, wird der alte DamageModifier
		//zerstört und ein neuer passend zum neuem Buff erzeugt
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            if b.isRefreshed then
                //Der Buff wurde refreshed, also die alten Daten löschen, welche noch in der Variable "data" gespeichert sind.
                call thistype(b.data).destroy()
            endif
            
			//neue Daten speichern
            set this = temp
            set b.data = integer(this)
            set buffData = b
			//Nur noch checken, ob das Ziel freundlich oder fendlich gesinnt ist
			set isFriendly = IsUnitAlly(target, GetOwningPlayer(caster))
            //Den DamageModificator erzeugen
            set manipulator = DamageManipulator.create(this)
        endmethod
	
		//Wird von meinem Spell-Module aufgerufen und added den Buff zum Ziel
		method onCast takes nothing returns nothing
            set lvl = lvl
            set temp = this
            call UnitAddBuff(caster, target, buffType, buffDuration, 1)
		endmethod
	
		implement Spell
		
		static method onInit takes nothing returns nothing
			//Erzeugt den BuffType, mehr Informationen zu der Funktion in der Dokumentation des Systemes
			set buffType = DefineBuffType(buffPlacerId, buffId, 0.00, false, true, thistype.onBuffAdd, 0, thistype.onBuffEnd)
        endmethod
	
	endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(BUFF_PLACER_ID)
    endfunction
	
endscope