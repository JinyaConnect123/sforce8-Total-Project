trigger BookingTimeTableCommTrigger on BookingTimeTable__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // before insert
    if(Trigger.isInsert && Trigger.isBefore){
    	// 重複チェックを行う
    	(new CommLogicProcess()).hasCandidateDuplicates(trigger.new, 
    		BookingTimeTable__c.Checkinday__c.getDescribe().getName(), 
    		BookingTimeTable__c.sObjectType.getDescribe().getName());
    }
    // after insert
//    else if(Trigger.isInsert && Trigger.isAfter){}
    // before update
    else if(Trigger.isUpdate && Trigger.isBefore){
    	// 重複チェックを行う
    	(new CommLogicProcess()).hasCandidateDuplicates(trigger.new, 
    		BookingTimeTable__c.Checkinday__c.getDescribe().getName(), 
    		BookingTimeTable__c.sObjectType.getDescribe().getName());
	}
//    else if(Trigger.isUpdate && Trigger.isAfter){}
    // before delete
//    else if(Trigger.isDelete && Trigger.isBefore){}
    // after delete
//    else if(Trigger.isDelete && Trigger.isAfter){}
    // after undelete
//    else if(Trigger.isUnDelete){}
}