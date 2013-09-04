public with sharing class ProductSearch_Ctrl {

    // 画面に表示する情報を格納用変数
    public List<AccountMaster__c> oProductLst{get;private set;}
    // 商品DP選択リスト
    public List<Selectoption> dpOptionLst{get; private set;}
    public List<Selectoption> gpOptionLst{get; private set;}
//    public List<Selectoption> opOptionLst{get; private set;}
    /***************************
    * 定数定義を行う
    ****************************/
    // 画面データ処理ステータス変数
    private Enum PAGE_STATUS {INS,UPD,SEL,UPDSPEC}
    public PAGE_STATUS pageStatus{get;private set;}
    public Boolean isIns{get{return pageStatus == PAGE_STATUS.INS;}}
    public Boolean isUpd{get{return pageStatus == PAGE_STATUS.UPD;}}
    public Boolean isSel{get{return pageStatus == PAGE_STATUS.SEL;}}
    // 新規商品格納用クラス
    public AccountMaster__c newAccMst{get;set;} 
    // 会計種別：プラン
    public String ACTTYPE_PLAN{get{return CommConst.PROD_ACTION_TYPE_PL;}}
    
    public ProductSearch_Ctrl() {
        // パラメータ分析する
        initParam();
        // 格納変数を初期化する
        oProductLst = new List<AccountMaster__c>();
        
        // 商品分類選択リストを設定を行う
        dpOptionLst = new List<Selectoption>();
        gpOptionLst = new List<Selectoption>();
//      opOptionLst = new List<Selectoption>();
        for (DP__c s: [select id, name, Field1__c from DP__c order by Name limit 500]) dpOptionLst.add(new SelectOption(s.id, s.Name));
        for (GP__c s: [select id, name, Field1__c from GP__c order by Name limit 500]) gpOptionLst.add(new SelectOption(s.id, s.Name));
//      for (OP__c s: [select id, name, Field1__c from OP__c order by Name limit 500]) opOptionLst.add(new SelectOption(s.id, s.Name));
    }
    
    public void init() {
        
        this.queryInfo();
    }
    
    public void insertInit() {
        // 画面ページステータス設定を行う
        pageStatus = PAGE_STATUS.INS;
        newAccMst = new AccountMaster__c();
    }
    public void insertData() {
        try {
            insert newAccMst;
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '新規作成が失敗しました。', e.getmessage()));
        }
        // 最新情報を再設定をこなう
        newAccMst = [select Id, Name, Field5__c, TaxRateCal__c, ServiceRate__c, SpecialTax__c, ActionType__c From AccountMaster__c where id = :newAccMst.Id][0];
        pageStatus = PAGE_STATUS.UPD;
    }
    
    public void cancelAct() {
        this.queryInfo();
    }
    /*
    // 引渡しパラメータ情報
    public String p_operWinEleId{get;private set;}
    public String p_operWinEleNm{get;private set;}
    public String p_operWinEleHidNm{get;private set;}
    public String p_operWinElePrice{get;set;}
    public String p_operWinEleNum{get;set;}
    public String p_operWinEleTax{get;set;}*/
    // 親のJSを呼び出し関数名
    public String p_operWinJsFunNm{get;private set;}
    // 検索条件：商品名
    public String c_productNm{get;set;}
    public String c_gpId{get;set;}
    public String c_dpId{get;set;}
//    public String c_opId{get;set;}
    
    // 引渡しパラメータ分析する
    private void initParam() {
        /*
        PageReference pageRef = ApexPages.currentPage();
        // 設定するID
        p_operWinEleId = pageRef.getParameters().get('lkid');
        p_operWinEleNm = pageRef.getParameters().get('lknm');
        p_operWinEleHidNm = pageRef.getParameters().get('lkhidnm');
        p_operWinElePrice = pageRef.getParameters().get('lprice');
        p_operWinEleNum = pageRef.getParameters().get('lnumber');
        p_operWinEleTax = pageRef.getParameters().get('ltaxRate');
        // window.oper.xxx function name
        p_operWinJsFunNm = pageRef.getParameters().get('operJs');
        */
        Cookie dpidCookie = ApexPages.currentPage().getCookies().get('_produ_dpid');
        if (dpidCookie != null) c_dpId = dpidCookie.getValue();
        Cookie gpidCookie = ApexPages.currentPage().getCookies().get('_produ_gpId');
        if (gpidCookie != null) c_gpId = gpidCookie.getValue();
    }
    
    private static final String SQL_HEADER = 'Select Id ,TaxRateCal__c ,Name, ServiceRate__c, SpecialTax__c, ActionType__c ' + 
                                             ',DPChange__c ,Field10__c ,Field11__c ,Field12__c ,Field13_del__c ,Field2__c ,Field3__c ,Field4__c ' +
                                             ',Field5__c ,Field6__c ,Field7__c ,Field8__c ,Field9__c ,GPChange__c ,Genkaritsu__c ,KD__c ,OES__c ,OP__c ,PLU__c ,Profit__c ,SCP_5__c ' +
                                             ',SalesnoneTax__c ,StsTaxfee__c ,X1__c ,X3_2__c ,X4_3__c ,detail13__c ,nextitemcode__c ,proftPer__c ' +
                                             ' From AccountMaster__c where name != null ';
    
    public void queryInfo() {
        
        // 画面ページステータス設定を行う
        pageStatus = PAGE_STATUS.SEL;
        
        // 検索条件を取得する
        String whereStr = this.getWhereStr();
        // 画面検索条件を設定されている場合
        if (!CommUtils.isBlank(c_productNm)) {
            whereStr += ' AND ( name Like \'%' + CommUtils.escStr(c_productNm) + '%\''; 
            whereStr += ' OR X1__c   Like \'%' + CommUtils.escStr(c_productNm) + '%\'';
            whereStr += ' OR X3_2__c Like \'%' + CommUtils.escStr(c_productNm) + '%\''; 
            whereStr += ' OR X4_3__c Like \'%' + CommUtils.escStr(c_productNm) + '%\' )';
        }
        
        String sqlstr = SQL_HEADER + whereStr + this.getComOrderStr();    
        
        oProductLst = Database.query(sqlstr);

        // 20120915 選択した検索条件はCookiesに維持する
        Cookie dpidCookie = new Cookie('_produ_dpid', c_dpId, null, -1, true);
        Cookie gpidCookie = new Cookie('_produ_gpId', c_gpId, null, -1, true);
        ApexPages.currentPage().setCookies(new Cookie[]{dpidCookie,gpidCookie});
    }
    private String getWhereStr() {
        String whereStr = '';
        
        // DP設定場合
        if (!CommUtils.isBlank(c_dpId)) {
            whereStr += ' AND Field4__c = :c_dpId ';
        }
        // GP設定場合
        if (!CommUtils.isBlank(c_gpId)) {
            whereStr += ' And GPChange__c = :c_gpId ';
        }
        // OP設定場合
//        if (!CommUtils.isBlank(c_opId)) {
//            whereStr += ' And OP__c = :c_opId ';
//        }
        return whereStr;
    }
    // 100件まで表示する
    private String getComOrderStr () {
        return ' order by Field4__c,OP__c, name limit 101 ';
    }
}