<?php

//require_once 'Zend/Db/Table/Abstract.php';

class Default_Model_Items extends Zend_Db_Table_Abstract

{
    /**
     * The default table name 
     */
    protected $_items = 'items';
    protected $_shops = 'shops';
    protected $_primary = 'ID';
    protected $_db;
    
    public  function __construct()
    {
        $this->_db = Zend_Registry::get('db');
    }
    
    /**
     * Return number of BaseItems which are new
     */
    public function getNewBaseItems($numElements)
    {
        $query = $this->_db->select()
            ->from($this->_items)
//            ->where('isNew = ?', 1)
            ->limit($numElements, 0);
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    /**
     * Return number of RecipeItems which are new
     */
    public function getNewRecipeItems($numElements)
    {
        $query = $this->_db->select()
            ->from($this->_items)
//            ->where('isNew = ?', 1)
            ->limit($numElements, 0);
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     *  Return all shop data from an affiliation
     */
    public function getAllShopsFromAffilation($affiliation)
    {
        $query = $this->_db->select()
            ->from($this->_shops)
            ->where('affiliation = ?', $affiliation);
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     *  Return all shop data from an affiliation
     */
    public function getShopById($id)
    {
        $query = $this->_db->select()
            ->from($this->_shops)
            ->where('ID = ?', $id);
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return all data from a single item
     * $id(int): Item ID
     * $type(String): Item types
     * 0 = BASIC_ITEMS
     * 1 = ADVANCED_ITEMS
     * 2 = ANCIENT_ITEMS
     */
    public function getItemDataById($itemId, $values, $type) {
        $query = $this->_db->select()
            ->from($type, $values)
            ->where('ID = ?', $itemId);
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    /*
     * Return all data from a multiple items
     */
    public function getItemsByID($itemIds, $values) {
        $ids = explode(',',$itemIds);
        
        $query = $this->_db->select()
            ->from($this->_items, $values)
            ->where('ID IN (?)', $ids);
        
        return $this->getAdapter()->fetchAll($query);
    }
    
    
    public function getAllItems() {
        $sub = $this->_db->select()
            ->from(array('i' => $this->_items),
                   array('iID'                    => 'ID',
                            'iName'                => 'name',
                            'fName'                => 'f-name',
                            'iDesc'                => 'description',
                         'iCosts'                => 'costs',
                         'iBonus'                => 'bonus',
                         'affiliation'         => 'affiliation',
                            'shop_id'             => 'shop_id'))
            ->joinInner(array('s' => $this->_shops),
                        'i.shop_id = s.ID',
                        array('name', 'image'))
            ->group('i.ID')           
            ->order('shop_id')
            ->order('i.order_id');

        $select = $this->_db->select()
               ->from(array('sub' => $sub))
               ->joinLeft(array('hxi' => 'heroes_x_items'),
                             'sub.iID = hxi.itemId',
                             array())
               ->joinLeft(array('h' => 'heroes'),
                            'h.ID = hxi.heroId',
                            array('heroesRecommend' => new Zend_Db_Expr('Group_Concat(Concat(h.name, " , ", h.image) SEPARATOR "|")')))
               ->group('sub.iID')
               ->order('sub.iID');             
            
        return $this->getAdapter()->fetchAll($select);
    }
}