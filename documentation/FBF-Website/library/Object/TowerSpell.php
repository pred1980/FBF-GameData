<?php
class Object_TowerSpell
{
    protected $_id          = 0;
    protected $_iconPath    = '';
    protected $_name        = '';
    protected $_description = '';

    /**
     * 
     * @param int $id
     * @param String $iconPath
     * @param String $name
     * @param String $description
     */
    public function __construct($id, $iconPath, $name, $description)
    {
        $this->_id          = $id;
        $this->_iconPath    = $iconPath;
        $this->_name        = $name;
        $this->_description = $description;
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
    public function getName()
    {
        return $this->_name;
    }

    /**
     * 
     * @return String
     */
    public function getDescription()
    {
        return $this->_description;
    }


}