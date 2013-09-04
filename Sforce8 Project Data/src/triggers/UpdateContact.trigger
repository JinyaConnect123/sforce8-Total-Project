trigger UpdateContact on Lead__c (after insert, after update, after Delete) {
set<Id> conset=new set<Id>();
if(Trigger.isInsert || Trigger.isUpdate)
{
For(Lead__c  l: Trigger.new)
{
 conset.add(l.Relcontact__c);
}
}
if(Trigger.isdelete )
For(Lead__c  l: Trigger.old)
{
 conset.add(l.Relcontact__c);
}
list<Contact> conlist=[select id , lastname from contact where id in:conset];
 update conlist;
}