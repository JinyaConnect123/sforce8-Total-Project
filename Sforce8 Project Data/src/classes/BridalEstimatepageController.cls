public class BridalEstimatepageController{

    public BridalEstimatepageController() 
    {
        Accountmasterdetails();
        contact=new contact();
        lead=new Lead__c();
    }


    public contact contact{set;get;}
    public Lead__c lead{set;get;}
   public class wrapper
   {
       public op__c opObject{set;get;}
       public integer rowindex{set;get;}
       public list<wrappersecond> lstAccMstr{set;get;}
       
   }
   
   public class wrappersecond
   {
       public AccountMaster__c lstAccMstr{set;get;}
       public string Comment{set;get;}
       public integer index{set;get;}
       public decimal Quantity{set;get;}
       public decimal amount{set;get;}
   }
   
   public class wrapperfirst
   {
       public op__c opObject{set;get;}
       public integer rowindex{set;get;}
       public list<wrapperAccMstr> lstAccMstr{set;get;}
       
   }
   public class wrapperAccMstr
   {
       public AccountMaster__c lstAccMstr{set;get;}
       public string Comment{set;get;}
       public integer index{set;get;}
       public decimal Quantity{set;get;}
       public decimal amount{set;get;}
   }
   
   
    public BridalEstimatepageController(ApexPages.StandardController controller) 
    {
        Accountmasterdetails();
        contact=new contact();
    }
    
    set<id> Opids=new set<id>();
    
    public void Accountmasterdetails()
    {
        integer i=0;
        integer j=0;
        for(AccountMaster__c ac:[select id,name,Field5__c,OP__c,GPChange__c from AccountMaster__c where GPChange__c!=:null and GPChange__r.name=:'ブライダル部門' ])
        {
            Opids.add(ac.OP__c);
        }
        system.debug('###########'+Opids.size());
        for(OP__c op:[select id,name,AliasName__c,(select id,name,Field5__c,OP__c,GPChange__c from OP__c.AccountMasterSUow__r where GPChange__c!=null and GPChange__r.name=:'ブライダル部門') from OP__c where id in:Opids and AliasName__c not in('お料理','お飲物')])
        {
            wrapper w=new wrapper();
            w.opObject=op;
            w.rowindex=lstwrap.size();
            w.lstAccMstr=new list<wrappersecond>();
            
            for(AccountMaster__c ac:op.AccountMasterSUow__r)
            {
                wrappersecond ws=new wrappersecond();
                ws.lstAccMstr=ac;
                ws.index=w.lstAccMstr.size();
                w.lstAccMstr.add(ws);
                i++;
            }           
            
            lstwrap.add(w);
        }
        
        for(OP__c opf:[select id,name,AliasName__c,(select id,name,Field5__c,OP__c,GPChange__c from OP__c.AccountMasterSUow__r where GPChange__c!=null and GPChange__r.name=:'ブライダル部門') from OP__c where id in:Opids and AliasName__c in('お料理','お飲物')])
        {
            wrapperfirst wf=new wrapperfirst();
            wf.opObject=opf;
            wf.rowindex=lstwrapfirst.size();
            wf.lstAccMstr=new list<wrapperAccMstr>();
            for(AccountMaster__c ac:opf.AccountMasterSUow__r)
            {
                wrapperAccMstr w=new wrapperAccMstr();                
                w.lstAccMstr=ac;
                w.index=wf.lstAccMstr.size();
                w.Quantity=null;
                wf.lstAccMstr.add(w);
                j++;
            }
             
            lstwrapfirst.add(wf);         
            
            
        }
    }
    
    public list<wrapper> lstwrap=new list<wrapper>();
    public list<wrapper> getdata()
    {
        return lstwrap;
    }
    
    public list<wrapperfirst> lstwrapfirst=new list<wrapperfirst>();
    public list<wrapperfirst> getdataStart()
    {
        return lstwrapfirst;
    }

    public decimal Subtotal{set;get;}
    public decimal Subtotal2{set;get;}
    public decimal FinalSum{set;get;}
    
    list<BookingEstimateItem__c> lstBridal=new list<BookingEstimateItem__c>();
    public string Testval{set;get;}
    public pagereference CopyData()
    {
        lstBridal.clear();
        
        for(wrapperfirst w:lstwrapfirst)
        {
            for(wrapperAccMstr wa:w.lstAccMstr)
            {
                system.debug('@@@@@@@@@'+wa.Quantity);
                if(wa.Quantity!=0)
                {
                    BookingEstimateItem__c b=new BookingEstimateItem__c();
                    b.ProductName__c=wa.lstAccMstr.name;
                    b.UnitPrice__c=wa.lstAccMstr.Field5__c;
                    b.Amount__c=wa.Quantity;
                    b.SpTotal__c=wa.amount;
                    b.Comment__c=wa.Comment;
                    b.refBooking__c=lead.id;
                    b.refAccountMaster__c=wa.lstAccMstr.id;
                    lstBridal.add(b);
                }
            }
        }
        try{
        if(lstBridal.size()>0)
        insert lstBridal;
        }
        catch(Exception ex)
        {
            apexpages.addmessage(new apexpages.message(ApexPages.Severity.ERROR, 'Error=='+ex));
        }
        return null;
    }
    
    public string rowindexmain{set;get;}
    public string rowin{set;get;}
    public void onChangefield5()
    {
        decimal total;
        Subtotal=0;
        integer row=integer.valueof(rowindexmain);
        integer rowi=integer.valueof(rowin);
        total=lstwrapfirst[row].lstAccMstr[rowi].lstAccMstr.field5__c*lstwrapfirst[row].lstAccMstr[rowi].quantity;
        lstwrapfirst[row].lstAccMstr[rowi].amount=total;
        
        for(wrapperfirst w:lstwrapfirst)
        {
            for(wrapperAccMstr ws:w.lstAccMstr)
            {
                if(ws.amount!=null)
                Subtotal+=ws.amount;
            }
        }
        if(Subtotal2!=null)
            FinalSum=Subtotal+Subtotal2;
        else
            FinalSum=Subtotal;
        
        
    }
    
    public void onChangequantity()
    {
        decimal total;
        Subtotal2=0;
        integer row=integer.valueof(rowindexmain);
        integer rowi=integer.valueof(rowin);       
        
        total=lstwrap[row].lstAccMstr[rowi].lstAccMstr.field5__c*lstwrap[row].lstAccMstr[rowi].quantity;
        lstwrap[row].lstAccMstr[rowi].amount=total;
        
        for(wrapper w:lstwrap)
        {
            for(wrappersecond ws:w.lstAccMstr)
            {
                if(ws.amount!=null)
                Subtotal2+=ws.amount;
            }
        }
        if(Subtotal!=null)
            FinalSum=Subtotal+Subtotal2;
        else
            FinalSum=Subtotal2;
        
    }
    

}