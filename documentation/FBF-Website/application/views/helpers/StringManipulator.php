<?php
/**
 *
 * @author Development
 * @version 
 */
class FBF_View_Helper_StringManipulator extends Zend_View_Helper_Abstract {
    
    public function stringManipulator() {
        return $this;
    }
    
    /**
     * Returns an cutted String from the hero description
     *
     * @param string $description
     * @param int start
     * @param int end
     * @return string
     */  
    public function cut($description, $start = 0, $end = 255) {
        
        return preg_replace('#[^\s]*$#s', '', substr($description, $start, $end)). ' ...';
    }
    
    /*
     * Split the first word from a string and return it and the rest of the string
     *
     * @param string $text
     * @return array ( [0] = first word | [1] = rest )
     */ 
    public function split($text) {
        
        $splitedText = array();
        $completeText = explode(" ", $text);
        $splitedText[0] = $completeText[0];
        unset($completeText[0]); 
        $splitedText[1] = implode(" ", $completeText);
        
        return $splitedText;
    }
    
    /*
     * return a camelcase string
     */
    public function strtocamelcase($str) {
      return preg_replace_callback('#[\s]+(.)#',
               create_function('$r', 'return strtoupper($r[1]);'), $str);
    }
    
    /*
     * Split content which has a seperator like this | and return data as array
     */
    public function splitData($value, $seperator = '|') {
        $arrContent = array();
        $newValue = $value;
        $count = substr_count ( $value, $seperator );
        
        for ($i = 0; $i <= $count; $i++)
        {
            $firstPos = strpos ( $newValue, $seperator );
            if ($firstPos != "")
            {
                $found = substr($newValue, 0, $firstPos);
                $newValue = substr($newValue, $firstPos+1, strlen($newValue));
                $arrContent[$i] = $found;
            }
            else {
                $arrContent[$i] = $newValue;
            }
        }
        return $arrContent;
    }
}