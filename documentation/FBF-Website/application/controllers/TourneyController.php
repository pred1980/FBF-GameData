<?php
/**
 * TourneyController
 * 
 * @author
 * @version 
 */
require_once 'Zend/Controller/Action.php';
class TourneyController extends Zend_Controller_Action
{
    /**
     * The default action - show the home page
     */
    public function indexAction ()
    {
        $this->view->show = 'Tourney Frontend View Test';
    }
}
