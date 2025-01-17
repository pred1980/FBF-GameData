<?php
/**
 * GlossaryController
 * 
 * @author
 * @version 
 */
require_once 'Zend/Controller/Action.php';
class GlossaryController extends Zend_Controller_Action
{
    /**
     * The default action - show the home page
     */
    public function indexAction ()
    {
        //set Title
        $this->view->headTitle('FBF Glossary');
        
        //set js & css
        $this->view->headLink()->appendStylesheet($this->view->baseUrl().'/files/frontend/css/glossary.css');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/jScrollbar.jquery.js', 'text/javascript');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/jquery-ui-1.8.16.custom.min.js', 'text/javascript');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/jquery-mousewheel.js', 'text/javascript');
        $this->view->headScript()->appendFile($this->view->baseUrl().'/files/frontend/js/glossary.js', 'text/javascript');
        
        //get glossary and set to view
        $glossary = new Class_Glossary();
        $this->view->glossary = $glossary->getGlossary();
     }
}
