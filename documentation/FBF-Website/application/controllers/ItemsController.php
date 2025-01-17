<?php

class ItemsController extends Zend_Controller_Action
{

    protected $_items;
    
    public function init()
    {
        $this->_items = new Default_Model_Items();
    }

    public function indexAction ()
    {
        //set Title
        $this->view->headTitle('FBF Items');
        
        //set keywords for the items site
        $this->view->placeholder('keywords')->set("FBF items, items for FBF, forsaken items, coalition items, Forsaken Bastion's Fall");
           
        //set description for the items site
        $this->view->placeholder('description')->set("FBF Items - See a list of all FBF Items, Charged Items, Consumed Items, Permanent Items, Artifacts and Recipe Items.");
        
        //add js+css
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/jquery-ui-1.8.16.custom.min.js', 'text/javascript');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/jquery-mousewheel.js', 'text/javascript');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/jScrollbar.jquery.js', 'text/javascript');
        $this->view->headLink()->appendStylesheet($this->view->baseUrl().'/files/frontend/css/items.css');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/items.js', 'text/javascript');
       
        $this->view->itemData = Class_Items::getAllItems();
        
        //Facebook
        $this->view->placeholder('fb-summary')->set("FBF Items - See a list of all FBF Items, Charged Items, Consumed Items, Permanent Items, Artifacts and Recipe Items.");
        $this->view->placeholder('fb-image')->set(urlencode($this->view->serverUrl().'/files/frontend/img/enUS/misc/facebook-items.jpg'));
    }
    
    public function iteminformationAction()
    {
        // Rendern deaktivieren
        $this->_helper->layout->disableLayout();
        $this->_helper->viewRenderer->setNoRender(true);
        
        $params = $this->getAllParams();
        //$params = $this->getRequest()->getParams();

        $affiliation = $params['affiliation'];
        $shopId      = $params['shop'];
        $itemNr      = $params['item'];

        // hole Information zum Item
        $itemInformation = Class_Items::getItemText($affiliation, $shopId, $itemNr);

        echo json_encode($itemInformation);        
    }
}

