<?php

/**
 * SitemapController
 * 
 * @author
 * @version 
 */

require_once 'Zend/Controller/Action.php';
class SitemapController extends Zend_Controller_Action
{
    protected $_heroModel;
    protected $_creepModel;
	protected $_towers;
    
    public function init()
    {
        $this->_heroModel = new Default_Model_Heroes();
		$this->_creepModel = new Default_Model_Creeps();
		$this->_towersModel = new Default_Model_Towers();
    }
    
    /**
     * The default action - show the home page
     */
    public function indexAction ()
    {
        //set Title
        $this->view->headTitle('FBF Sitemap');
        
        //Facebook
        $this->view->placeholder('fb-image')->set(urlencode($this->view->serverUrl().'/files/frontend/img/enUS/misc/facebook-FBF.jpg'));
        
        //return all needed hero data to the view
        $heroData = array('name', 'fname');
        $this->view->forsakenHeroes = $this->_heroModel->getHeroByAffilation('forsaken', $heroData ,'ID');
        $this->view->coalitionHeroes = $this->_heroModel->getHeroByAffilation('coalition', $heroData ,'ID');
		
		//Items
		$this->view->itemData = Class_Items::getAllItems();
		
		//Creeps
		$creepData = array('name', 'fname');
        $this->view->creepData = $this->_creepModel->getCreepData($creepData);
        
        //Towers
        $this->view->towerData = $this->_towersModel->getAllTowers();
    }
}

