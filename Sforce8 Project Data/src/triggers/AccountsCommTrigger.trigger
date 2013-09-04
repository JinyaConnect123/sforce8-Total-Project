trigger AccountsCommTrigger on AccountAcount__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // before insert
    if(Trigger.isInsert && Trigger.isBefore){
        AccountsTriggerProcess handel = new AccountsTriggerProcess();
//      handel.setupSerialNo(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
        handel.autoSetupInfo(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
    // after insert
    else if(Trigger.isInsert && Trigger.isAfter){
        AccountsTriggerProcess handel = new AccountsTriggerProcess();
        handel.setupSerialNo(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
    // before update
    else if(Trigger.isUpdate && Trigger.isBefore){
        // 重複チェックを行う
        (new CommLogicProcess()).hasCandidateDuplicates(trigger.new, 
            AccountAcount__c.Name.getDescribe().getName(), 
            AccountAcount__c.sObjectType.getDescribe().getName());
        AccountsTriggerProcess handel = new AccountsTriggerProcess();
        handel.autoSetupInfo(trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
    }
//    else if(Trigger.isUpdate && Trigger.isAfter){}
    // before delete
//    else if(Trigger.isDelete && Trigger.isBefore){}
    // after delete
//    else if(Trigger.isDelete && Trigger.isAfter){}
    // after undelete
//    else if(Trigger.isUnDelete){}
}