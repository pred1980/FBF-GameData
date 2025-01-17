<?php
/**
 * Heroes
 * 
 * @author Development
 * @version 
 *///require_once 'Zend/Db/Table/Abstract.php';
class Default_Model_Glossary extends Zend_Db_Table_Abstract
{    /**     * The default table name     */    protected $_name = 'glossary';    protected $_db;        public function __construct()    {        $this->_db = Zend_Registry::get('db');    }        /*     * Return all data from Glossary Table     */    public function getCompleteGlossary()    {        $query = $this->_db->select()            ->from($this->_name);                    return $this->getAdapter()->fetchAll($query);    }    }
