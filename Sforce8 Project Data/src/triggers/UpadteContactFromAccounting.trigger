trigger UpadteContactFromAccounting on AccountAcount__c (after  insert, after update, after delete) {
set<id> conset=new set<id>();
if(Trigger.isInsert || Trigger.isUpdate)
{
For(AccountAcount__c   acc: Trigger.new)
{
 conset.add(acc.relaccount__c);
}

}
if(Trigger.isdelete )
For(AccountAcount__c   acc: Trigger.old)
{
 conset.add(acc.relaccount__c);
}
list<Contact> conlist=[select id , lastname from contact where id in:conset];
 update conlist;
}