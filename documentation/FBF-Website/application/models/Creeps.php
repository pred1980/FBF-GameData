<?php

//require_once 'Zend/Db/Table/Abstract.php';

class Default_Model_Creeps extends Zend_Db_Table_Abstract

{

	const MAX_ROUND_NUMBER = 20;
	
    /**
     * The default table name 
     */
    protected $_name             = 'creeps';
    protected $_creepXRoundTable = 'creeps_x_round';
    protected $_db;
    
    public  function __construct()
    {
        $this->_db = Zend_Registry::get('db');
    }
    
    /*
     * Return a Creep by Name
    * Optional: Array->Returns the specific informations
    */
    public function getCreepByName($name, $values = '*')
    {
        $query = $this->_db->select()
        ->from(array('c' => $this->_name), $values)
        ->where('c.name = ?', $name);
            
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return Creep Id
    */
    public function getCreepId($creepName) {
        $query = $this->_db->select()
        ->from($this->_name, 'ID')
        ->where('name = ?', $creepName);
            
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return a Creep by friendly Name
    * Optional: Array->Returns the specific informations
    */
    public function getCreepByFriendlyName($name, $values = '*')
    {
        $query = $this->_db->select()
        ->from(array('h' => $this->_name), $values)
        ->where('h.fname = ?', $name);
    
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return a Creep by ID
    */
    public function getCreepDataById($id)
    {
        $query = $this->_db->select()
        ->from(array('c' => $this->_name))
        ->where('c.id = ?', $id)
        ->order('c.ID');
    
        return $this->getAdapter()->fetchAll($query);
    }
    
    
    /*
     * Return specific Creep-Data order by ID
	 * 	 * type:
	 * 0 = Melee
	 * 1 = Ranged
	 * 2 = Caster
    */
    public function getCreepData($values = '*', $order = 'ID')
    {
        $query = $this->_db->select()
        ->from(array('c' => $this->_name), $values)
        ->order($order);
    
        return $this->getAdapter()->fetchAll($query);
    }
	
	/*
     * Return the amount of creeps running in the rounds
    */
    public function getCreepRoundData()
    {
        $select = $this->_db->select()
        	   ->from(array('cxr' => $this->_creepXRoundTable))
        	   ->order('creepId')
        	   ->order('round');
        
        $result = $this->_db->fetchAll($select);
        
        $clean        = array();
        $actualCreep = array();
		$resultCount  = count($result); 
        
		for ($i = 0; $i < $resultCount; $i++) {
			$oneDbRow = $result[$i];
			
            if (empty($actualCreep)) {
                $actualCreep             = $this->_getWholeRoundsForCreep();
                $actualCreep['creep_ID'] = $oneDbRow['creepId'];
            } elseif ($actualCreep['creep_ID'] != $oneDbRow['creepId']) {
                $clean[]                  = $actualCreep;
                $actualCreep             = $this->_getWholeRoundsForCreep();
                $actualCreep['creep_ID'] = $oneDbRow['creepId'];
            } 

            $actualCreep['round_' . $oneDbRow['round']] = (int)$oneDbRow['count'];
			
			if ($i === $resultCount - 1) {
				$clean[] = $actualCreep;
			}
		}

        return $clean;
    }
    
    public function getRoundsForCreep($creepId)
    {
        $select = $this->_db->select()
               ->from(array('cxr' => $this->_creepXRoundTable),
				      array('rounds' => new Zend_Db_Expr('GROUP_CONCAT(round)')))
			   ->group('creepId')
			   ->where('creepId = ?', $creepId);
			   
		$result = $this->_db->fetchRow($select);
		$allRounds = explode(',', $result['rounds']);
		$roundCount = count($allRounds);
		
		if ($roundCount === 1) {
			return $allRounds[0];
		} else if ($roundCount > 1) {
			$roundString = '';
			
			for ($i = 0; $i < $roundCount; $i++) {
				if ($i === 0) {
					$roundString .= $allRounds[$i];
				} else if ($i === $roundCount - 1) {
					$roundString .= (' and ' . $allRounds[$i]);
				} else {
					$roundString .= (', ' . $allRounds[$i]);
				}
			}
			
			return $roundString;
		} else {
			return '';
		}
    }
    
    public function getAggregatedCreepRoundData()
    {
        $select = $this->_db->select()
               ->from(array('c' => $this->_name), 
                      array('type'))
               ->joinInner(array('cxr' => $this->_creepXRoundTable), 'c.ID = cxr.creepId',
                           array('round' => 'round',
                                 'cnt'   => new Zend_Db_Expr('SUM(count)')))
               ->group('type')
               ->group('round')
               ->order('round');
               
        $result = $this->_db->fetchAll($select);

        $clean       = array();
		$actualRound = array();
		$countRows   = count($result);
		$index       = 1;

        foreach ($result as $oneDbRow) {
            if (empty($actualRound)) {
                $actualRound = $this->_getAggregatedRoundNew();
				$actualRound['round'] = (int)$oneDbRow['round'];
            } elseif ($actualRound['round'] !== (int)$oneDbRow['round']) {
				$clean[]               = $actualRound;
				$actualRound           = $this->_getAggregatedRoundNew();
				$actualRound['round'] = (int)$oneDbRow['round'];
			}
			
			$actualRound[$oneDbRow['type']] += (int)$oneDbRow['cnt'];
			$actualRound['total']           += (int)$oneDbRow['cnt'];
			
			if ($countRows === $index) {
				$clean[] = $actualRound;
			}
			$index++;
        }
		return $clean;
    }
    
    protected function _getWholeRoundsForCreep()
    {
        $roundArray = array();
        
        for($i = 1; $i <= self::MAX_ROUND_NUMBER; $i++) {
            $roundArray['round_' . $i] = '-';
        }
        
        return $roundArray;
    }
    
    protected function _getAggregatedRoundNew()
    {
        return array('melee'  => 0,
                     'ranged' => 0,
                     'caster' => 0,
				     'total'  => 0);
    }
}