<?php
/**
 * SpellsModel
 * 
 * @author Development
 * @version 
 */
require_once 'Zend/Db/Table/Abstract.php';
class Default_Model_Spells extends Zend_Db_Table_Abstract
{
    /**
     * The default table name 
     */
    protected $_spells = 'spells';
    protected $_creepSpells = 'creep_spells';
    protected $_heroes = 'heroes';
    protected $_creeps = 'creeps';
    protected $_primary = 'ID';
    protected $_db;
    
    public  function __construct()
    {
        $this->_db = Zend_Registry::get('db');
    }
    
    /*
     * Return all Spells of a hero by heroID
     */
    public function getHeroSpellsByHeroID($heroID)
    {
        $query = $this->_db->select()
            ->from($this->_spells)
            ->where('hero_ID = ?', $heroID)
            ->order('ID');
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return all Spells of a creep by creepID
    */
    public function getCreepSpellsByCreepID($creepID)
    {
    	$query = $this->_db->select()
    	->from($this->_creepSpells)
    	->where('creep_ID = ?', $creepID)
    	->order('ID');
    
    	return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return all Spells of a hero by heroName
     */
    public function getHeroSpellsByHeroName($heroName, $values = '*') {
        $query = $this->_db->select()
            ->from(array('h' => $this->_heroes),
                   array('ID', 'name'))
            ->join(array('s' => $this->_spells, $values), 'h.ID = s.hero_ID')
            ->where('h.name = ?', $heroName)
            ->order('s.ID');

        $result = $this->getAdapter()->fetchAll($query);

        if ($result !== 0)
            return $result;
        else
            return false; 
    }
    
    /*
     * Return all Spells of a creep by creepName
    */
    public function getCreepSpellsByCreepName($creepName, $values = '*') {
    	$query = $this->_db->select()
    	->from(array('c' => $this->_creeps),
    			array('ID', 'name'))
    			->join(array('s' => $this->_creepSpells, $values), 'c.ID = s.creep_ID')
    			->where('c.name = ?', $creepName)
    			->order('s.ID');
    
    	$result = $this->getAdapter()->fetchAll($query);
    
    	if ($result !== 0)
    		return $result;
    	else
    		return false;
    }
    
    /*
     * Return ability type of a spell
     */
    public function getAbillityTypes($heroID) {
        $query = $this->_db->select()
            ->from($this->_spells, 'ability_type')
            ->where('hero_ID = ?', $heroID)
            ->where('required_level = 1 OR required_level = 6'); 
        
        return $this->getAdapter()->fetchAll($query);
    }

}
