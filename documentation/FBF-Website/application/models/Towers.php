<?php
class Default_Model_Towers
{
    protected $_db = null;

    public function __construct()
    {
        $this->_db = Zend_Registry::get('db');
        $this->_db->setFetchMode(Zend_Db::FETCH_ASSOC);
    }

    /**
     * 
     * @param String $type
     * @param int $order
     * @return int
     */
    public function getTowerIdByType($type, $order)
    {
        $select = $this->_db->select()
               ->from('tower', array('towerId'))
               ->where('type = ?', $type)
               ->where('ordering = ?', $order);

        return $this->_db->fetchOne($select);
    }

    /**
     * 
     * @param int $towerId
     * @return array
     */
    public function getTowerDataForId($towerId)
    {
        $select = $this->_db->select()
               ->from('tower')
               ->where('towerId = ?', $towerId);
        
        return $this->_db->fetchRow($select);
    }

    /**
     * 
     * @param int $towerId
     * @return array
     */
    public function getTowerChangeLog($towerId)
    {
        $select = $this->_db->select()
               ->from(array('txc' => 'tower_x_changelog'), array('version', 'changelog'))
               ->where('txc.towerId = ?', $towerId);
        
        return $this->_db->fetchAll($select);
    }

    /**
     * 
     * @param int $towerId
     * @return array
     */
    public function getTowerSpells($towerId)
    {
        $select = $this->_db->select()
               ->from(array('txs' => 'tower_x_towerSpell'), array())
               ->joinInner(array('ts' => 'towerSpells'), 'txs.towerSpellId = ts.id')
               ->where('txs.towerId = ?', $towerId);
        
        return $this->_db->fetchAll($select);
    }
    
    public function getAllTowers()
    {
    	$select = $this->_db->select()
               ->from('tower', array('name', 'type'))
               ->order('towerId');
    
    	return $this->_db->fetchAll($select);
    }
}