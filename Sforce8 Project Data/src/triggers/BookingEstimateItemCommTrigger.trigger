trigger BookingEstimateItemCommTrigger on BookingEstimateItem__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // before insert
    if(Trigger.isInsert && Trigger.isBefore){
        BookingEstimateItemTriggerProcess handel = new BookingEstimateItemTriggerProcess();
        handel.syncAccountMstToBookingItem(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
        handel.autoSetupFieldValue(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
    // after insert
//    else if(Trigger.isInsert && Trigger.isAfter){}
    // before update
    else if(Trigger.isUpdate && Trigger.isBefore){
    	// 項目内容自動設定する
    	BookingEstimateItemTriggerProcess handel = new BookingEstimateItemTriggerProcess();
    	handel.autoSetupFieldValue(trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
    }
    // after update
//    else if(Trigger.isUpdate && Trigger.isAfter){}
    // before delete
//    else if(Trigger.isDelete && Trigger.isBefore){}
    // after delete
//    else if(Trigger.isDelete && Trigger.isAfter){}
    // after undelete
//    else if(Trigger.isUnDelete){}
}