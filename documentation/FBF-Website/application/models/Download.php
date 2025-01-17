<?php

class Default_Model_Download extends Zend_Db_Table_Abstract
{

    protected $_downloadStats = 'download_stats';
    protected $_downloadIP = 'download_ip';
    protected $_db;
    
    public function __construct()
    {
        $this->_db = Zend_Registry::get('db');
    }
    
    public function deleteIP(){
        
        // 3600 Sekunden (= 60 min.) IP Sperre!
        $timeIsUp = time() - 3600;
        $where = array();
        $where[] = $this->_db->quoteInto('time <= ?', $timeIsUp);
        $this->_db->delete($this->_downloadIP, $where);
    }
    
    public function getIP($ip) {
        $query = $this->_db->select()
            ->from($this->_downloadIP)
            ->where('ip  = ?', $ip);
            
        return $this->getAdapter()->fetchAll($query);
    }
    
    public function setIP($ip) {
        $data = array(
            'ip'   => $ip,
            'time' => time(),
        	'today' => time(),
        );
         
        $this->_db->insert($this->_downloadIP, $data);
    }
    
    public function increaseCounter() {
        $data = array(
            'hits' => new Zend_Db_Expr('hits + 1') 
        );
         
        $this->_db->update($this->_downloadStats, $data);
    }
    
    public function getCounts() {
        $query = $this->_db->select()
            ->from($this->_downloadStats);

        return $this->getAdapter()->fetchAll($query);
    }
    
    public function getDownloadsPerDay()
    {
        $time = time();
        $query = $this->_db->select()
                 ->from($this->_downloadIP, array('downloads' => new Zend_Db_Expr('count(1)')))
                 ->where('? < today', $time - ($time % 86400));
        
        return $this->_db->fetchOne($query);
    }
    
}
?>