<?php
class FBF_View_Helper_MediaManager extends Zend_View_Helper_Abstract {
    
    protected $_typeToFunctionMapper = array('photo' => '_buildPhoto',
                                             'link'  => '_buildLink',
                                             'video' => '_buildVideo');

    public function mediaManager($type, $title, $description, $source)
    {
        if (!array_key_exists($type, $this->_typeToFunctionMapper)) {
            return '';
        } // no else

        $function = $this->_typeToFunctionMapper[$type];

        return $this->$function($title, $description, $source);
    }
    
    protected function _buildPhoto($title, $description, $source)
    {
        return '';
    }
    
    protected function _buildLink($title, $description, $source)
    {
        return '';
    }
    
    protected function _buildVideo($title, $description, $source)
    {
        return '';
    }
}