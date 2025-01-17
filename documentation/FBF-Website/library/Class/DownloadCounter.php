<?php
class Class_DownloadCounter
{
	private $_download;
	private $_downloadModel;
	private $_options; //application.ini
	
	public function __construct() {
		$this->_downloadModel = new Default_Model_Download();
		$bootstrap = Zend_Controller_Front::getInstance()->getParam('bootstrap');
    	$this->_options = $bootstrap->getOptions();
	}
	
	public function onInit()
	{
		$this->_downloadModel->deleteIP();
		$this->userCheck();
	}
	
	function getClientIp() {
	    if (isSet($_SERVER)) {
	        if (isSet($_SERVER["HTTP_X_FORWARDED_FOR"])) {
	            $realip = $_SERVER["HTTP_X_FORWARDED_FOR"];
	        } elseif (isSet($_SERVER["HTTP_CLIENT_IP"])) {
	            $realip = $_SERVER["HTTP_CLIENT_IP"];
	        } else {
	            $realip = $_SERVER["REMOTE_ADDR"];
	        }
	    
	    } else {
	        if ( getenv( 'HTTP_X_FORWARDED_FOR' ) ) {
	            $realip = getenv( 'HTTP_X_FORWARDED_FOR' );
	        } elseif ( getenv( 'HTTP_CLIENT_IP' ) ) {
	            $realip = getenv( 'HTTP_CLIENT_IP' );
	        } else {
	            $realip = getenv( 'REMOTE_ADDR' );
	        }
	    }
	    return $realip;    
	}
	
	public function userCheck(){
		$ip = $this->getClientIp();
		$result = $this->_downloadModel->getIP($ip);
		if (empty($result)) {
			$this->_downloadModel->setIP($ip);
			$this->_downloadModel->increaseCounter();
		}
		//get map and prepare for donwload
		$this->publicMap();
	}
	
	public function publicMap() {
		header('Content-Type: application/octet-stream');
		header('Content-Disposition: attachment; filename="'.$this->_options['FBF']['map'].'"');
		readfile('downloads/'.$this->_options['FBF']['map'].'');
	}
	
	public function getMapSize() {
		$map = $this->_options['FBF']['map'];
		return (file_exists("downloads/" . $map) ? $this->getRealSize("downloads/" . $map) : '');
	}
	
	public function getCounts() {
		return $this->_downloadModel->getCounts();
	}
	
	public function getRealFileUploadTime() {
		return $this->getFileUploadTime("downloads/" . $this->_options['FBF']['map']);
	}
	
	private function getRealSize($file) {
        // Return size in Mb
        clearstatcache();
        $INT = 4294967295;//2147483647+2147483647+1;
        $size = filesize($file);
        $fp = fopen($file, 'r');
        fseek($fp, 0, SEEK_END);
        if (ftell($fp)==0) $size += $INT;
        fclose($fp);
        if ($size<0) $size += $INT;
        return round(($size/1024/1024), 2)." MB";
    }
    
	private function getFileUploadTime($file)
	{
	    if (!file_exists($file))
	        return 0;
	    else
	        return date("d.m.Y", filemtime($file));
	}
}
?>