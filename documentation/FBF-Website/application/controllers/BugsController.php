<?php

class BugsController extends Zend_Controller_Action
{

    public function init()
    {
        /* Initialize action controller here */
    }

    public function indexAction()
    {
        //Facebook
        $this->view->placeholder('fb-image')->set(urlencode($this->view->serverUrl().'/files/frontend/img/enUS/misc/facebook-FBF.jpg'));
        $this->_redirect('/forums/Forum-Open-Beta-Feedback');
    }
}

