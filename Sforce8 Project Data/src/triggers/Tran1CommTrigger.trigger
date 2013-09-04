trigger Tran1CommTrigger on Tran1__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
    // before insert
    if(Trigger.isInsert && Trigger.isBefore){}
    // after insert
    else if(Trigger.isInsert && Trigger.isAfter){
        Tran1TriggerProcess handel = new Tran1TriggerProcess();
        handel.expandPlanItem(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
    // before update
//    else if(Trigger.isUpdate && Trigger.isBefore){}
//    else if(Trigger.isUpdate && Trigger.isAfter){}
    // before delete
    else if(Trigger.isDelete && Trigger.isBefore){
        Tran1TriggerProcess handel = new Tran1TriggerProcess();
        handel.expandPlanItem(trigger.new, Trigger.old, CommConst.TriggerMethod.IsDelete);
    }
    // after delete
    else if(Trigger.isDelete && Trigger.isAfter){}
    // after undelete
//    else if(Trigger.isUnDelete){}
}