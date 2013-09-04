/**
* 部屋タイプ共通トリガー
**/
trigger TypeOfRoomsCommTrigger on TypeOfRooms__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
    // before insert
    if(Trigger.isInsert && Trigger.isBefore){
    	//TypeOfRoomsTriggerProcess handel = new TypeOfRoomsTriggerProcess();
    	//handel.preCheck(trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
}