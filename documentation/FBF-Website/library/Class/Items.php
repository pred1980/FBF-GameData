<?php
class Class_Items
{
	/**
	 * 
	 * lädt alle Items
	 */
	public static function getAllItems()
	{
		
		// TODO caching 
		$model = new Default_Model_Items();
		
		$allItemsRaw = $model->getAllItems();
		
		$newList = array();
	    
		foreach($allItemsRaw as $item) {
	    	$newList[$item['affiliation']][$item['shop_id']][] = $item;
	    }
	    
	    return $newList;
	}
	
	
	/**
	 * 
	 * lädt ein spezifisches Item
	 */
	public static function getItemText($affiliation, $shopId, $itemId)
	{
		$allItems = self::getAllItems();
		
		return $allItems[$affiliation][$shopId][$itemId];
	}
}