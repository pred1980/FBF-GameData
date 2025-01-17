<?php
/**
 * FanartController
 * 
 * @author
 * @version 
 */
require_once 'Zend/Controller/Action.php';
class FanartController extends Zend_Controller_Action
{
    /**
     * The default action - show the home page
     */
    public function indexAction ()
    {
        $this->view->show = 'Fanart Frontend View Test';
    }
}
