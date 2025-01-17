<?php

require_once ('Zend/Controller/Action.php');

class IndexController extends Zend_Controller_Action
{
    protected $_heroes;
    protected $_items;

    public function init ()
    {
        $this->_heroes = new Default_Model_Heroes();
        $this->_items = new Default_Model_Items();
    }

    public function indexAction ()
    {

        //set Title
        $this->view->headTitle('Official FBF Website - Forsaken Bastion\'s Fall');

        //set keywords for the heroes site
        $this->view->placeholder('keywords')->set("FBF, Forsaken Bastion's Fall, forsaken, fall, forsaken bastion, forsaken bastions, bastions fall, forsaken world");

        //set description for the heroes site
        $this->view->placeholder('description')->set("FBF - Forsaken Bastion's Fall is a Warcraft 3 mod which combines a Tower Defense with a Hero Defense. forsaken-bastions-fall.com is the Official Website for FBF.");

        //Facebook
        $this->view->placeholder('fb-summary')->set("FBF - Forsaken Bastion's Fall is a Warcraft 3 mod which combines a Tower Defense with a Hero Defense. forsaken-bastions-fall.com is the Official Website for FBF.");
        $this->view->placeholder('fb-image')->set(urlencode($this->view->serverUrl().'/files/frontend/img/enUS/misc/facebook-FBF.jpg'));

        $this->view->headLink()->appendStylesheet($this->view->baseUrl().'/files/frontend/css/index.css');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/index.js', 'text/javascript');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/zclip.js', 'text/javascript');

        $model = new Default_Model_Media();
        $this->view->mediaDataSlider1 = $model->getMediasForArea('start_slider1');
        $this->view->mediaDataSlider2 = $model->getMediasForArea('start_slider2');
    }

/*
     * Sitemap
     */
    public function sitemapAction()
    {
        //set Title
        $this->view->headTitle('FBF Sitemap');

        //Facebook
        $this->view->placeholder('fb-image')->set(urlencode($this->view->serverUrl().'/files/frontend/img/enUS/misc/facebook-FBF.jpg'));
    }

    /*
     * Disclaimer
     */
    public function disclaimerAction()
    {
        //set Title
        $this->view->headTitle('FBF Disclaimer');

        //Facebook
        $this->view->placeholder('fb-image')->set(urlencode($this->view->serverUrl().'/files/frontend/img/enUS/misc/facebook-FBF.jpg'));
    }

    public function ghoppleAction()
    {
        $bootstrap = Zend_Controller_Front::getInstance()->getParam('bootstrap');

        /* @var Zend_Db_Adapter_Abstract $adapter */
        $adapter = $bootstrap->getPluginResource('multidb')->getDb('slashgaming');
        $select  = $adapter->select();

        $select->from(array('g' => 'oh_gamelist'))
            ->where('g.map like "%FBF%"')
            ->limit(30);

        $this->view->games = $adapter->query($select)->fetchAll(Zend_Db::FETCH_ASSOC);

        $this->_helper->layout->disableLayout();
    }
}