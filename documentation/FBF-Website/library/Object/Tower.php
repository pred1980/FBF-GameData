<?php
class Object_Tower
{
    protected $_towerId       = 0;
    protected $_name          = '';
    protected $_description   = '';
    protected $_type          = '';
    protected $_level         = '';
    protected $_lumber        = 0;
    protected $_dps           = 0.0;
    protected $_damageMin     = 0.0;
    protected $_damageMax     = 0.0;
    protected $_coolDown      = 0.0;
    protected $_range         = 0;
    protected $_iconPath      = '';
    protected $_imagePath     = '';

    protected $_latestChangeLog = '';
    protected $_changeLogs      = array();

    /**
     *
     * @var Object_Tower 
     */
    protected $_nextLevel     = null;

    /**
     *
     * @var Object_Tower
     */
    protected $_previousLevel = null;

    /**
     *
     * @var Object_TowerSpell[] 
     */
    protected $_spells        = array();

    /**
     * 
     * @param int $towerId
     * @param Object_Tower $previousTower
     */
    public function __construct($towerId, $previousTower = null)
    {
        $this->_towerId       = (int)$towerId;
        $this->_previousLevel = $previousTower;
    }

    /**
     * 
     * @param String $towerName
     * @param String $towerDescription
     * @param int $towerLevel
     * @param String $towerLevel
     */
    public function setTowerMetaData($towerName, $towerDescription, $towerLevel, $type)
    {
        $this->_name        = (string)$towerName;
        $this->_description = (string)$towerDescription;
        $this->_level       = (int)$towerLevel;
        $this->_type        = $type;
        return $this;
    }

    public function setUpgradeTower($towerId)
    {
        $this->_nextLevel = new Object_Tower($towerId, $this);
        return $this;
    }

    /**
     * 
     * @param int $lumber
     * @param double $dps
     * @param double $damageMin
     * @param double $damageMax
     * @param double $coolDown
     * @param int $range
     */
    public function setProperties($lumber, $dps, $damageMin, $damageMax, $coolDown, $range)
    {
        $this->_lumber    = (int)$lumber;
        $this->_dps       = (double)$dps;
        $this->_damageMin = (double)$damageMin;
        $this->_damageMax = (double)$damageMax;
        $this->_coolDown  = (double)$coolDown;
        $this->_range     = (int)$range;
        return $this;
    }

    /**
     * 
     * @param String $iconPath
     * @param String $imagePath
     */
    public function setImages($iconPath, $imagePath)
    {
        $this->_iconPath  = (string)$iconPath;
        $this->_imagePath = (string)$imagePath;
        return $this;
    }

    /**
     * 
     * @param String $version
     * @param String $log
     */
    public function addChangelog($version, $log)
    {
        $this->_changeLogs[$version] = $log;

        if (strcmp($this->_latestChangeLog, $version) < 0) {
            $this->_latestChangeLog = $version;
        } // no else

        return $this;
    }

    /**
     * 
     * @param int $id
     * @param String $iconPath
     * @param String $name
     * @param String $description
     */
    public function addSpell($id, $iconPath, $name, $description)
    {
        if (!isset($this->_spells[$id])) {
            $this->_spells[$id] = new Object_TowerSpell($id, $iconPath, $name, $description);
        }

        return $this;
    }

    /**
     * 
     * @return bool
     */
    public function hasNextLevel()
    {
        return (($this->_nextLevel !== null) && ($this->_nextLevel instanceof Object_Tower));
    }

    /**
     * 
     * @return Object_Tower
     */
    public function getNextLevelTower()
    {
        return $this->_nextLevel;
    }

    public function getTowerId()
    {
        return $this->_towerId;
    }

    public function getName()
    {
        return $this->_name;
    }

    public function getDescription()
    {
        return $this->_description;
    }

    public function getLevel()
    {
        return $this->_level;
    }

    public function getLumber()
    {
        return $this->_lumber;
    }

    public function getDps()
    {
        return $this->_dps;
    }

    public function getDamageMin()
    {
        return $this->_damageMin;
    }

    public function getDamageMax()
    {
        return $this->_damageMax;
    }
    
    public function getDamage()
    {
        return $this->getDamageMin() . ' - ' . $this->getDamageMax();
    }
    
    public function getType()
    {
        return $this->_type;
    }

    public function getCoolDown()
    {
        return $this->_coolDown;
    }

    public function getRange()
    {
        return $this->_range;
    }

    /**
     * 
     * @return String
     */
    public function getIconPath()
    {
        return $this->_iconPath;
    }

    /**
     * 
     * @return String
     */
    public function getImagePath()
    {
        return $this->_imagePath;
    }

        /**
     * 
     * @return String
     */
    public function getLatestChangeLog()
    {
        return $this->_latestChangeLog;
    }

    /**
     * 
     * @param String $version
     * @return String
     */
    public function getChangeLogForVersion($version)
    {
        if (isset($this->_changeLogs[$version])) {
            return $this->_changeLogs[$version];
        }

        return '';
    }

    /**
     * 
     * @return Object_TowerSpell[]
     */
    public function getSpells()
    {
        return $this->_spells;
    }
}
