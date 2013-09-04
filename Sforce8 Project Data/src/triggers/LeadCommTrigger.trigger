trigger LeadCommTrigger on Lead__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // before insert
    if(Trigger.isInsert && Trigger.isBefore){
        // 部屋から部屋タイプの自動設定()
        LeadTriggerProcess handel = new LeadTriggerProcess();
        handel.autoSetupInfo(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
        // 宴会重複チェック
        handel.checkDuplicateTime(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
    // after insert
    else if(Trigger.isInsert && Trigger.isAfter){
      
        // 予約情報から関連処理を行う
        LeadTriggerProcess handel = new LeadTriggerProcess();
        // プラン情報から見積明細自動作成
        handel.autoSetupBookingItemByPlan(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
        // 予約から会計側へ連携処理を行う
        handel.syncBookingInfoToAccounts(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
        // 在庫更新処理を行う
        handel.syncGuestRoomStock(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsInsert);
    }
    // before update
    else if(Trigger.isUpdate && Trigger.isBefore){
        // 部屋から部屋タイプの自動設定()
        LeadTriggerProcess handel = new LeadTriggerProcess();
        handel.autoSetupInfo(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
        // 宴会重複チェック
        handel.checkDuplicateTime(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
    }
    // after update
    else if(Trigger.isUpdate && Trigger.isAfter){
        // 予約情報から関連処理を行う
        LeadTriggerProcess handel = new LeadTriggerProcess();
        // プラン情報から見積明細自動作成
        handel.autoSetupBookingItemByPlan(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
        // 予約から会計側へ連携処理を行う
        handel.syncBookingInfoToAccounts(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
        // 在庫更新処理を行う
        handel.syncGuestRoomStock(Trigger.new, Trigger.old, CommConst.TriggerMethod.IsUpdate);
    }
    // before delete
//    else if(Trigger.isDelete && Trigger.isBefore){}
    // after delete
//    else if(Trigger.isDelete && Trigger.isAfter){}
    // after undelete
//    else if(Trigger.isUnDelete){}
}