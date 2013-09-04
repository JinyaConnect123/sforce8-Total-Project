trigger UpdateCountAndCharge on Contact (before insert, before Update)
{

    set<id> Conset=new set<id>();
    for(contact con:trigger.new)
        Conset.add(con.id);
        
    Map<Id,decimal> Mapcharge=new Map<Id,decimal>();
    Map<Id,decimal> Mapusage=new map<Id,decimal>();    
    
    List<aggregateResult> UsageCharge=[select sum(Field147__c) total,relaccount__c conid from AccountAcount__c where relaccount__c in:conset and relaccount__c !=null AND OutSideAccount__c =: 1 group by relaccount__c];
    List<aggregateResult> UsageCount=[select count(Id) cunt,Relcontact__c conid from Lead__c where Relcontact__c in:conset and Relcontact__c !=null and (ReservedStatus__c = '確認中' OR ReservedStatus__c = '確定') group by Relcontact__c ];
    
    for(aggregateResult ar:UsageCharge)
    {
       decimal d=(decimal)ar.get('total');
       id idval=(ID)ar.get('conid');       
       Mapcharge.put(idval,d);
    }
    
    
    for(aggregateResult ar:UsageCount)
    {
         decimal d=(decimal)ar.get('cunt');
         id idval=(ID)ar.get('conid');         
         Mapusage.put(idval,d);
    }
    
    for(contact c:trigger.new)
    {

        if(UsageCharge.size()>0)
        c.Usage_Charge__c=Mapcharge.get(c.id);
        Else
        c.Usage_Charge__c=null;
        if(UsageCount.size()>0)
        c.Usage_Count__c=Mapusage.get(c.id);
        Else
        c.Usage_Count__c=null;
    }
}