/**
* 会計書表示ページ切り替え機能
* 施設コードにて、各会社専用ページに切り替えてする
**/
public with sharing class AccountPdfSwitch {

    private final String recordId;
    private final Map<String,String> paramMap;
    public AccountAcount__c curSObj{get; private set;}
    public AccountPdfSwitch(ApexPages.StandardController controller){
        paramMap = ApexPages.currentPage().getParameters();
        recordId = controller.getId();
        curSObj = [select id, name, Relreserve__r.LeadIndexRef__c,ContactName__c from AccountAcount__c where id = :recordId ];//Database.query(CommSqlUtils.generateQueryString('AccountAcount__c') + ' Where Id = \'' + recordId + '\'');
    }
    private static final Map<String, String> pageMap;
    static {
        pageMap = new Map<String,String>{
            // hotel-continental　会社会計書PDF専用ページ
            '2'=>'AccountPDF_1',
            // JINYA会社DefaultPDF専用ページ
            '1'=>'AccountPDF'};
    }
    public PageReference redirect() {
        // ページ遷移前のチェックを行う
        List<AccountAcount__c> checkLst = new List<AccountAcount__c>();
        checkLst.add(curSObj);
        if (!preDirectProcess(checkLst)) return null;
        // システムの施設コード定義取得
        String facilityCode = CommUtils.nullToBlank(CommDefine__c.getOrgDefaults().FacilityCode__c);
        PageReference customPage = new PageReference( pageMap.get(facilityCode) == null ? '/apex/AccountPDF' : '/apex/' + pageMap.get(facilityCode) );
        customPage.getParameters().putAll(paramMap);
        customPage.setRedirect(true);

        // 遷移直前前の関連処理
        aftDirectProcess(checkLst);

        return customPage;
    }
    /**
    * 一括会計情報を表示する
    **/
    public String termStartDt{get; set;}
    public String termEndDt{get; set;}
    //public String customTitle{get; set;}
    //public String redirectUrl{get; private set;}
    public void AccAcountsSelectorInit() {
        // 開始日と終了日初期値設定する
        // 初期値は今日から７日前まで
        DateTime formatter = DateTime.now();
        termStartDt = formatter.addDays(-7).format('yyyy/MM/dd');
        termEndDt = formatter.format('yyyy/MM/dd');
        checkedFlgMap = new Map<Id, Boolean>();
        queryAccAcountList();
    }

    public List<AccountAcount__c> accAcountLst{get; private set;}
    private boolean preQueryAccAcountList() {
        try {
            Date dt1 = Date.parse(termStartDt);
            Date dt2 = Date.parse(termEndDt);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '有効な処理日を入力ください.'));
            return false;
        }
        return true;
    }
    public void queryAccAcountList() {
        // 事前チェックを行う
        if (!preQueryAccAcountList()) {
            return;
        }
        String startDt = termStartDt.replaceAll('/','');
        String endDt = termEndDt.replaceAll('/','');
        // 同じグループの会計情報を一括表示する[到着日順]
        accAcountLst = [select id, name , Field147__c, Field151__c, relaccount__c, Relreserve__c,ContactName__c,
            Relreserve__r.EntryTime__c, (Select Id From AcountsRef__r)
            From AccountAcount__c where Relreserve__r.LeadIndexRef__c = :curSObj.Relreserve__r.LeadIndexRef__c
            And frs__r.Name >= :startDt And frs__r.Name <= :endDt 
            Order By frs__r.Name, Name limit 1000];
        // 宛名先名設定を行う
        //if(!accAcountLst.isEmpty()) customTitle = accAcountLst[0].ContactName__c;
        // 会計済フラグ情報格納する
        checkedFlgMap.clear();
        for (AccountAcount__c acc: accAcountLst) {
            Boolean checkedFlg = acc.AcountsRef__r.size() > 0 ? true : false;
            checkedFlgMap.put(acc.Id, checkedFlg);
        }
    }
    public Map<Id, Boolean> checkedFlgMap{get; private set;}

    // ページ遷移前のチェックを行う
    private Boolean preDirectProcess(List<AccountAcount__c> checkAccLst) {
        // 会計書を出力まで、会計済のレコードが存在がどうかチェックを行う
        // 20120915 該当チェックはまずなくします：TODO
        /*
        Set<Id> accsIdSet = new Set<Id>();
        for (AccountAcount__c acc: checkAccLst) {
            accsIdSet.add(acc.Id);
        }
        List<AcountsHistory__c> hisLst = [select id from AcountsHistory__c where AcountsRef__c in :accsIdSet limit 1];
        if (!hisLst.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '既に会計済会計情報が存在するため、会計書の作成が失敗しました。'));
            return false;
        }*/
        return true;
    }
    // ページ遷移前のチェックを行う
    private Boolean aftDirectProcess(List<AccountAcount__c> checkAccLst) {
        // 会計書出力処理記録を行う
        writePdfHistory(checkAccLst);
        return true;
    }
    // 会計書出力
    public PageReference redirectPlugin() {
        // ページ遷移前のチェックを行う
        if (!preDirectProcess(accAcountLst)) return null;
        // パラメータ設定を行う
        //Map<String,String> paramMap = ApexPages.currentPage().getParameters();
        // 表示する会計IDをパラメータに設定する
        Set<Id> accAcountIdSet = new Set<Id>();
        String bulkIdStr = '';
        for (AccountAcount__c acc: accAcountLst) {
            //accAcountIdSet.add(acc.Id);
            bulkIdStr += acc.Id + ',';
        }
        //paramMap.put('cuName',customTitle);
        paramMap.put('bulkid',bulkIdStr.substring(0,  bulkIdStr.length()-1));


        // 遷移直前前の関連処理
        aftDirectProcess(accAcountLst);

        return this.redirect();
        //redirectUrl = page.getUrl();
        //return page;
    }
    /**
    * 会計書出力Actionの記録
    **/
    private void writePdfHistory(List<AccountAcount__c> accLst) {
        // 会計出力Action記録する
        List<AcountsHistory__c> historyLst = new List<AcountsHistory__c>();
        for (AccountAcount__c acc: accLst) {
            historyLst.add(new AcountsHistory__c(Name = acc.Name, AcountsRef__c = acc.Id));
        }
        Database.upsert(historyLst, AcountsHistory__c.Name);
    }
    static testMethod void accountPdfSwitch() {
        Test.startTest();
        // 予約情報を作成する
        Lead__c leadInfo = TestCommon.createLead();
        // 商品情報を作成する
        List<AccountMaster__c> productLst = TestCommon.createProductMst(1);
        // 見積明細を作成する
        TestCommon.createBookEstItem(leadInfo, productLst[0]);
        // 予約情報のステータス：チェックインに変更する
        leadInfo.Field298__c = 'チェックイン完';
        update leadInfo;

        Test.stopTest();

        // 会計画面に動作確認を行う
        List<AccountAcount__c> accObjLst = [select id,frs__c,Relreserve__c from AccountAcount__c where Relreserve__c = :leadInfo.Id];
        AccountAcount__c accObj = accObjLst[0];
        ApexPages.StandardController contrl = new ApexPages.StandardController(accObj);
        BillInput_Ctrl ctrl = new BillInput_Ctrl(contrl);
        ctrl.initAction();
        ctrl.calPaymentInfo();
        ctrl.upsertData();

        ApexPages.StandardController contrl1 = new ApexPages.StandardController(accObj);
        AccountPdfSwitch ctrl1 = new AccountPdfSwitch(contrl1);
        ctrl1.AccAcountsSelectorInit();
        ctrl1.redirect();
        ctrl1.termStartDt = DateTime.newInstance(Date.today()-10, Time.newInstance(0, 0, 0, 0)).format('yyyy/MM/dd');
        ctrl1.termEndDt = DateTime.newInstance(Date.today()+10, Time.newInstance(0, 0, 0, 0)).format('yyyy/MM/dd');
        ctrl1.queryAccAcountList();
        System.assert(ctrl1.accAcountLst.size() > 0);
        Pagereference pg = ctrl1.redirectPlugin();
        System.assertNotEquals(pg, null);


    }
}