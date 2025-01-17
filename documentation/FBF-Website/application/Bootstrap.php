<?php

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
    protected function _initApplication()
    {
        //$this->bootstrap('frontcontroller');
    }

    protected function _initControllers()
    {
        $this->bootstrap('frontcontroller');
    }

    protected function _initConfig()
    {
        if (file_exists(CONFIG_FILE) && is_readable(CONFIG_FILE)) {
            $config = new Zend_Config_Ini(CONFIG_FILE, APPLICATION_ENV);
            Zend_Registry::set('config', $config);
        } else {
            throw new Zend_Config_Exception('Unable to load config file');
        }
    }

    protected function _initEnvironment()
    {
        // set up baseURL
        $this->_BASE_URL = Zend_Controller_Front::getInstance()->getBaseUrl();
        if (!$this->_BASE_URL) {
          $this->_BASE_URL = rtrim(preg_replace( '/([^\/]*)$/', '', $_SERVER['PHP_SELF'] ), '/\\');
          Zend_Controller_Front::getInstance()->setBaseUrl($this->_BASE_URL);
        }
    }

    protected function _initDbs()
    {
        $this->bootstrap('multidb');
        $resource = $this->getPluginResource('multidb');
        $resource->init();

        Zend_Registry::set('db', $resource->getDb('fbf'));
        Zend_Registry::set('ghostpp', $resource->getDb('ghostpp'));
    }

    protected function _initAutoLoader()
    {
        Zend_Loader_Autoloader::getInstance()->setFallbackAutoloader(true);
          $autoloader = new Zend_Application_Module_Autoloader(
         array(
            'namespace' => 'Default',
            'basePath' => dirname(__FILE__)
            )
         );
         return $autoloader;
    }

//    //db profiling in firebug
//    protected function _initDbProfiler()
//    {
//        $profiler = new Zend_Db_Profiler_Firebug('All DB Queries');
//        $profiler->setEnabled(true);
//        Zend_Registry::get('db')->setProfiler($profiler);
//    }

    protected function _initJQuery()
    {
        $this->bootstrap( 'view' );
        $view = $this->getResource( 'view' );
        $view->addHelperPath('ZendX/JQuery/View/Helper/', 'ZendX_JQuery_View_Helper');
        $view->headScript()->appendFile($view->baseUrl().'/files/frontend/js/jquery-1.7.1.js', 'text/javascript');
        /*$view->jQuery()->setVersion('1.6.2');
        $view->jQuery()->setUiVersion('1.8.12');
        $view->jQuery()->addStylesheet('files/frontend/css/jquery-ui.css');*/

        $viewRenderer = new Zend_Controller_Action_Helper_ViewRenderer();
        $viewRenderer->setView($view);
        Zend_Controller_Action_HelperBroker::addHelper($viewRenderer);
    }

    protected function _initDoctype()
    {
        $this->bootstrap( 'view' );
        $view = $this->getResource( 'view' );
          $view->doctype( 'HTML5' );
    }

    protected function _initHeadLink()
    {
        $this->bootstrap('view');
        $view = $this->getResource('view');
        $view->headLink()->appendStylesheet($view->baseUrl().'/files/frontend/css/reset.css')
                         ->appendStylesheet($view->baseUrl().'/files/frontend/css/default.css')
                         ->appendStylesheet($view->baseUrl().'/files/frontend/css/colorbox.css');
    }

    protected function _initHeadMeta() {
        $this->bootstrap('view');
        $view = $this->getResource('view');
        $view->headMeta()->appendHttpEquiv('X-UA-Compatible', 'IE=edge,chrome=1');

    }

    protected function _initHeadScript()
    {
        $this->bootstrap('view');
        $view = $this->getResource('view');
        $view->headScript()->appendFile($view->baseUrl().'/files/frontend/js/base.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/plugins.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/jquery.ui.widget.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/jquery.ui.core.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/jquery.ui.tabs.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/galleria-1.3.2.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/galleria.classic.js', 'text/javascript')
                           ->appendFile($view->baseUrl().'/files/frontend/js/jquery.colorbox.js', 'text/javascript');
    }

    protected function _initHeadTitle()
    {
        $this->bootstrap('view');
        $view = $this->getResource('view');
        $view->headTitle('forsaken-bastions-fall.com')->setSeparator(' - ');
    }

    protected function _initViewHelpers()
    {
        //$view = $this->bootstrap('view')->getResource('view');
         #$this->bootstrap('layout');
          #$layout = $this->getResource('layout');
          #$view = $layout->getView();
          #$view->setHelperPath(APPLICATION_PATH . '/views/helpers', 'FBF_View_Helper');
    }

    protected function _initRouter()
    {
        $router = Zend_Controller_Front::getInstance()->getRouter();
        $config = new Zend_Config_Ini(APPLICATION_PATH . '/configs/routes.ini', APPLICATION_ENV);
        $router->addConfig($config, 'routes');
    }
}