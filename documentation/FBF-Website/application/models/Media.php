<?php
class Default_Model_Media
{
    const MEDIA_MAIN_TABLE = 'media';
    const MEDIA_AREA_TABLE = 'mediaPosition';
    const MEDIA_HERO_TABLE = 'heroes_x_media';
    
    protected $_db = null;

    public function __construct()
    {
        $this->_db = Zend_Registry::get('db');
        $this->_db->setFetchMode(Zend_Db::FETCH_ASSOC);
    }
    
    public function getMediasForArea($area)
    {
        $select = $this->_db->select()
               ->from(array('mp' => self::MEDIA_AREA_TABLE), array())
               ->where('area = ?', $area)
               ->order('mp.positionInArea');

        $this->_addBasicJoin($select, 'mp.mediaId');

        return $this->_db->fetchAll($select);
    }
    
    public function getHeroMedia($heroId)
    {
        $select = $this->_db->select()
        ->from(array('mh' => self::MEDIA_HERO_TABLE), array())
        ->where('heroId = ?', $heroId)
        ->order('mh.position');

        $this->_addBasicJoin($select, 'mh.mediaId');

        return $this->_db->fetchAll($select);
    }
    
    protected function _addBasicJoin($select, $columnName)
    {
        $select->joinInner(array('mm' => self::MEDIA_MAIN_TABLE), $columnName . ' = mm.id');
        return $this;
    }
}