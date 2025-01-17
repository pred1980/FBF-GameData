<?php
class Class_Glossary
{
	protected $_glossaryModel;
	
	public function __construct()
	{
		$this->_glossaryModel = new Default_Model_Glossary();
	}
	
	public function getGlossary() 
	{
		$glossaryData = $this->_glossaryModel->getCompleteGlossary();
		
		$alphabet = array('[0-9]', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
						  'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
						  'W', 'X', 'Y', 'Z');
        
		for($i=0;$i<sizeof($alphabet);$i++){
	    	foreach ($glossaryData as $value) {
	    		if (preg_match('/^'.$alphabet[$i].'/i', $value['name']))
	    			$splittedGlossary[$alphabet[$i]][] = $value;
	      	}
    	}
		
		return $splittedGlossary;
	}
}
