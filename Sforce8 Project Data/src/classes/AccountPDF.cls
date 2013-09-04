/**
* 会計書
* 会計書機能対応
**/
public with sharing class AccountPDF {
    // 施設コードにて、レポート改ページ定義を格納する
    private static final Map<String, Integer> pageMap;
    // 開始ページに詳細データ明細件数
    private static final Integer maxLineNums = 28;
    // 商品名表示言語
    private static final String lang_jp='jp';
    private static final String lang_en='en';
    public Boolean isShowEnName{get; private set;}

    static {
        pageMap = new Map<String,Integer>{
            // hotel-continental　会社会計書PDF専用ページ
            '2'=>22,
            // JINYA会社DefaultPDF専用ページ
            '1'=>maxLineNums};
    }
    // 合計金額など集計用会計情報リスト
    private List<AccountAcount__c> account;
    // 会計明細情報を格納する
    private List<TranItem> tran;
    // 課税対象商品の売上金額合計を格納する
    private Decimal amoutIncTaxprice = 0;
    // サビース料金（税込）
    private Decimal amoutIncServicePrice = 0;
    // 特別税合計
    private Decimal amoutIncSpecialPrice = 0;
    // 割引合計
    private Decimal amoutIncDiscont = 0;
    // 前受付金の金額合計を格納する
    private Decimal amoutARprice = 0;
    // 税込前金額合計を格納する
    private Decimal amoutAllMoney = 0;
    // 一ページに最大格納できる明細レコード数
    // FirstPage [Default 29行]
    private Integer PAGE_FIRSTPG_BREAK_RSNUM = pageMap.get(CommDefine__c.getOrgDefaults().FacilityCode__c) == null ? maxLineNums : pageMap.get(CommDefine__c.getOrgDefaults().FacilityCode__c);
    // SecondPage以後 [Default 29行]
    private final Integer PAGE_NEXTPG_BREAK_RSNUM = 45;
    // 前頁から引渡パラメータ情報を維持する変数
    private final Map<String,String> parMap;

    // PDFページ毎の明細情報を格納用
    public List<OnePage> allPageList{get; private set;}
    public class OnePage {
        // startRsIndex：データ開始行目
        public OnePage () {
            onePageList = new List<TranItem>();
            currPages = 1;
        }
        // ページ内に追加するITEM
        public void addItem(TranItem item) {
            onePageList.add(item);
        }
        // 現在表示してページ数
        public Integer currPages{get;set;}
        public Boolean isFirstPage{get{
          return currPages == 1;
        }}
        // １ページ表示用データを格納
        public List<TranItem> onePageList{get; private set;}
    }
    /**
    * 初期化処理を行う
    **/
    public AccountPDF(ApexPages.StandardController controller){
        // パラメータ情報を取得する
        parMap = ApexPages.currentPage().getParameters();
        System.debug('@@@@@@@@'+parMap);
        // 2012/10/22 URLから引渡パラメータ情報（明細行数設定がある場合、設定の行数で優先に設定する）
        String strPageSize = parMap.get('pgsize');
        if (!CommUtils.isBlank(strPageSize)) PAGE_FIRSTPG_BREAK_RSNUM = Integer.valueOf(strPageSize);
        // 2012/08/25 WSQ ADD
        String bulkid = parMap.get('bulkid');
        System.debug('@@@@Bulk ids@@@@'+bulkid);
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(controller.getId());
        if (!CommUtils.isBlank(bulkId)) {
            String[] accIdLst = bulkId.split(',');
            for (String s : accIdLst) {accIdSet.add(s);}
        }
        // 2012/10/25 WSQ ADD 商品名：英語を表示フラグ
        isShowEnName = parMap.get('language') != lang_en ? false : true;

        Set<Date> rateGetDaySet = new Set<Date>();
        //query '会計' current page
        account = [
            select id, name, POSNo__c, relaccount__r.name, Field141__c, Discount__c,
                AmoutSpecialPrice__c,SumSrvPriceExcTax__c,SumSrvPriceIncTax__c,
                Field145__c, Field147__c, Field148__c, Field151__c, Relreserve__c, Relreserve__r.RecordTypeId,
                relaccount__r.Account.Name          // 会計書の請求書欄の請求先名は取得の機能追加　
            from AccountAcount__c
            //where id = :controller.getId()
            where id in :accIdSet
            Order By frs__r.Name, Name      // 売上日/会計日で並べ順
            ];
        // 総税込金額を合計する
        for (AccountAcount__c acc: account) {
            // 総計金額を計算する
            amoutAllMoney += CommUtils.nullToZero(acc.Field151__c);
            // 割引額を合計する
            amoutIncDiscont += CommUtils.nullToZero(acc.Discount__c);
            // 会計日設定を行う
            //rateGetDaySet.add(acc.Field148__c);
        }

        //query '会計明細' current page
        List<Tran1__c> tranRsLst = [
                select id, name, RowNo__c, Field5__c, Tankanonetax__c, Field20__c, Field21__c,ServiceRate__c ,Field7__r.ProductEnName__c,
                    Field41__c,TaxRate__c, ActionType__c, Field23__c, RelAccount__r.Salesday__c, SpecialTax__c
                from Tran1__c
                //where Field1__c = :account.id
                where Field1__c in :accIdSet 
                And Accountoutside__c =1 And InvoiceNoShowFlg__c != true                
                Order By RelAccount__r.Name, Name];
        tran = new List<TranItem>();
        for(Tran1__c sobj : tranRsLst) {
            // 前受付金の商品する場合
            if (sobj.ActionType__c == CommConst.PROD_ACTION_TYPE_AR) {
                amoutARprice += CommUtils.nullToZero(sobj.Field23__c);
                continue;
            }
/* 20121005修正を行う（商品単価多目意味機能対応） */
            Decimal unitPrice = CommUtils.nullToZero(sobj.Field20__c);  // 商品単価
            Decimal qty = CommUtils.nullToZero(sobj.Field21__c);
            CommUtils.ProductInfo priceInfo = new CommUtils.ProductInfo();
            priceInfo.process(unitPrice, qty , sobj.TaxRate__c, sobj.ServiceRate__c);

            // 税率は0以上の場合、該当合計金額は課税対象です[商品本体の単価＊数量（税込）= 税込金額]
//            if(sobj.TaxRate__c > 0) amoutIncTaxprice += CommUtils.nullToZero(sobj.Field20__c) * CommUtils.nullToZero(sobj.Field21__c);
            TranItem item = new TranItem(sobj, tran.size()+1);
            //if(sobj.TaxRate__c > 0) amoutIncTaxprice += priceInfo.priceIncTaxNoService;
            if(sobj.TaxRate__c > 0) amoutIncTaxprice += priceInfo.priceIncTax;
            // 商品単価（税込、サービス込）
            item.unitPrice = priceInfo.unitPriceTax;
            // 英語の場合、英語名を再設定を行う
            if (isShowEnName) item.produceNm = sobj.Field7__r.ProductEnName__c;
            tran.add(item);
        }
        //integer len = MAX_SHOW_DETAIL_ROWS - tran.size();
        // サービス料金が存在する場合、明細へ追加する
        /*
        for (AccountAcount__c acc: account) {
            // サービス料（税込）情報を合計する
            amoutIncServicePrice += CommUtils.nullToZero(acc.SumSrvPriceIncTax__c);
        }
        if (amoutIncServicePrice > 0) {
            tran.add(new TranItem(new Tran1__c(
                                       Field5__c = 'サービス料',
                                       Field20__c = String.valueOf(amoutIncServicePrice),
                                       Field21__c = '1',
                                       RowNo__c = tran.size() + 1),
                                       tran.size()+1));
        }*/
        // 特別税金が存在する場合、明細へ追加する
        for (AccountAcount__c acc: account) {
            if (acc.AmoutSpecialPrice__c != null && acc.AmoutSpecialPrice__c > 0) {
                amoutIncSpecialPrice += acc.AmoutSpecialPrice__c;
            }
        }
        if (amoutIncSpecialPrice > 0) {
            tran.add(new TranItem(new Tran1__c(
                                       Field5__c = (isShowEnName == true ? 'Accommodation Tax' : '宿泊税'),
                                       Field20__c = String.valueOf(amoutIncSpecialPrice),
                                       Field21__c = '1',
                                       RowNo__c = tran.size() + 1),
                                       tran.size()+1));
        }

        // 改ページ情報を設定する
        // 改ページ処理機能初期化
        allPageList = new List<OnePage>();
        Integer breakNum = PAGE_FIRSTPG_BREAK_RSNUM;
        for (Integer index =0; index < tran.size(); index++) {
            // 改ページ計算
            Integer breakLine = index - (allPageList.isEmpty() ? 0 : 1) * PAGE_FIRSTPG_BREAK_RSNUM - (allPageList.size() > 1 ? allPageList.size() -1 : 0 ) * PAGE_NEXTPG_BREAK_RSNUM;
            // 改ページする場合
            if (breakLine == 0) {
                OnePage onePg = new OnePage();
                onePg.addItem(tran[index]);
                allPageList.add(onePg);
                // ページ数を設定する
                onePg.currPages = allPageList.size();
            } else {
                OnePage onePg = allPageList[allPageList.size() - 1];
                onePg.addItem(tran[index]);
            }
        }

        Integer dumyLen = 0;
        OnePage dumyPage = null;
        // 明細データが非存在する場合
        if (allPageList.isEmpty()) {
            // だみデータ作成件数
            dumyLen = breakNum;
            dumyPage = new OnePage();
            allPageList.add(dumyPage);
        }
        // 全部データは一ページ場合、空白行を追加する
        if (allPageList.size() == 1) {
            dumyLen = breakNum - allPageList[0].onePageList.size();
            dumyPage = allPageList[0];
        }
        for (integer i=0; i < dumyLen; i++) {
          dumyPage.onePageList.add(new TranItem(new Tran1__c(), null));
        }
        // Header Pdf 情報を設定する[宿泊場合、設定を行う]
        if (account[0].Relreserve__c != null && account[0].Relreserve__r.RecordTypeId == CommLogicProcess.getLeadBookingRecType())
          this.setHeaderInfo(account[0].Relreserve__c);
    }

    /**
    * レポートロゴ取得する
    **/
    public ReportLogo__c getReportLogo() {
        return CommRepUtils.getReplogoInfoByTypeId(CommRepUtils.REP_TYPE.LOGO_00_SYSDEF);
    }
    /*
    public AccountAcount__c getAccoutInfo() {
        return account;
    }
    */
    //get Account#
    public string getAccountNo(){
        return account[0].name;
    }
    // get 請求書の宛名先名
    public String getAccountName() {
     String recpName = parMap.get('recpName');
    return CommUtils.isBlank(recpName) ? account[0].relaccount__r.Account.Name : recpName;
    }
    //get 'お客様'
    public string getCustomer(){
        /*
        if(account.relaccount__c!=null){
            return account.relaccount__r.name;
        }else{
            return '　　　　　　　　　　';
        }*/
        String cuName = parMap.get('cuName');
        return (CommUtils.isBlank(cuName) ? '　' : cuName);
    }

    //get '$売上計IV（税込）金額'
    public Decimal getCharge(){
        return amoutAllMoney;
        /*
        if ( account.Field151__c != null ) {
            //return putComma(string.valueof(account.Field151__c));
            return account.Field151__c;
        } else {
            return 0;
        }*/
    }

    //get Tax
    public Decimal getTax(){
        // 会計日付にて、消費税計算を行う[会計日付から税率を取得する][連泊場合：初日の税率で]
        // TODO:最後の会計日の消費税率で計算を行う
        Decimal taxRate = CommUtils.getTaxRate(account[0].Field148__c);
        //Map<Date, Decimal> rateMstmap = CommUtils.getTaxRateMap()
        // 消費税計算を行う：課税商品金額(税込) + サービス料(税込)　- 割引金額
        if ( amoutIncTaxprice > 0 ) {
            Decimal locAmoutIncTaxprice = amoutIncTaxprice
                               //+ CommUtils.nullToZero(amoutIncServicePrice)
                               - CommUtils.nullToZero(amoutIncDiscont);
            // TODO 消費税マスタの関連設定を再設定を行う
            return CommUtils.RoundProcess(locAmoutIncTaxprice / (1 + taxRate / 100) * (taxRate / 100), 0);
        } else {
            return 0;
        }
    }



    //get '$会計日付'
    public string getDate(){
        if ( account[0].Field148__c != null ) {
            string s = string.valueof(account[0].Field148__c)+' ';
            string year = s.substring(0,4);
            string month = s.substring(5,7);
            string day = s.substring(8,10);
            return  year+'年'+month+'月'+day+'日';
        } else {
            return  '    年'+'  月'+'  日';
        }
    }
    // 前受付金
    public Decimal getAdvancesReceived() {
        return amoutARprice;
    }
    //get '会計明細'
    public List<TranItem> getTran(){
        return tran;
    }
    // 割引合計
    public Decimal getAmoutIncDiscont() {
        return amoutIncDiscont;
    }
    public class TranItem {
        // 明細番号
        public Integer rowNo{get; private set;}
        // 商品名
        public String produceNm{get; private set;}
        // 価格
        public Decimal unitPrice{get; private set;}
        // 数量
        public Decimal quantity{get; private set;}
        // 利用日
        public String usedDate{get; private set;}

        public TranItem(Tran1__c sobj, Integer index) {
            rowNo = index;
            if (index == null) return;
            produceNm = sobj.Field5__c;
            unitPrice = CommUtils.nullToZero(sobj.Field20__c);
            quantity = CommUtils.nullToZero(sobj.Field21__c);
            //System.debug('RelAccount__c:' + sobj.RelAccount__r.Salesday__c);
            if (sobj.RelAccount__r.Salesday__c != null) {
                usedDate = (DateTime.newInstance(sobj.RelAccount__r.Salesday__c, Time.newInstance(0,0,0,0))).format('yyyy/MM/dd');
            }
        }
        public Boolean isShowInfo{get{return (rowNo != null);}}
    }

    // ヘーダ情報を設定する
    public void setHeaderInfo(String leadId) {
        headInfo = [select id, Name, Rroom__r.Rnumber__c, LeadIndexRef__r.DepartureDate__c, LeadIndexRef__r.EntryDate__c,
            LeadIndexRef__r.Nights__c, StayPersons__c From Lead__c where Id = :leadId];
    }
    public Lead__c headInfo{get; private set;}

}