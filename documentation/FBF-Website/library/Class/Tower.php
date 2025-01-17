<?php
class Class_Tower
{
    protected $_towerModel = null;

    public function __construct()
    {
        $this->_towerModel = new Default_Model_Towers();
    }

    public function getTower($type, $ordering)
    {
        $towerId   = $this->_towerModel->getTowerIdByType($type, $ordering);

        $mainTowerObject = new Object_Tower($towerId);
        $this->_loadTowerData($mainTowerObject)
             ->_loadTowerSpellData($mainTowerObject)
             ->_loadTowerVersionData($mainTowerObject);

        $workingObject = $mainTowerObject;

        while ($workingObject->hasNextLevel()) {
            $workingObject = $workingObject->getNextLevelTower();
            $this->_loadTowerData($workingObject)
                 ->_loadTowerSpellData($workingObject)
                 ->_loadTowerVersionData($workingObject);
        }

        return $mainTowerObject;
    }

    /**
     * 
     * @param Object_Tower $towerObject
     * @return \Class_Tower
     */
    protected function _loadTowerData($towerObject)
    {
        $towerData = $this->_towerModel->getTowerDataForId($towerObject->getTowerId());


        $towerObject->setTowerMetaData($towerData['name'], $towerData['description'], $towerData['level'], $towerData['type'])
                    ->setImages($towerData['iconPath'], $towerData['imagePath'])
                    ->setProperties($towerData['lumber'], $towerData['dps'], $towerData['damageMin'], 
                                    $towerData['damageMax'], $towerData['cooldown'], $towerData['range']);
        
        if (!empty($towerData['upgradeTo'])) {
            $towerObject->setUpgradeTower($towerData['upgradeTo']);
        }

        return $this;
    }
    
    /**
     * 
     * @param Object_Tower $towerObject
     * @return \Class_Tower
     */
    protected function _loadTowerSpellData($towerObject)
    {
        $spells = $this->_towerModel->getTowerSpells($towerObject->getTowerId());

        foreach ($spells as $oneSpell) {
            $towerObject->addSpell($oneSpell['id'], $oneSpell['icon'], $oneSpell['name'], $oneSpell['description']);
        }

        return $this;
    }

    /**
     * 
     * @param Object_Tower $towerObject
     * @return \Class_Tower
     */
    protected function _loadTowerVersionData($towerObject)
    {
        $versionData = $this->_towerModel->getTowerChangeLog($towerObject->getTowerId());

        foreach ($versionData as $oneVersion) {
            $towerObject->addChangelog($oneVersion['version'], $oneVersion['changelog']);
        }

        return $this;
    }
}