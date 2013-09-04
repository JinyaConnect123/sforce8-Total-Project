/**********************************
* 会計編集機能(BillInput_Ctrl)
* 2012/10/03 プラン明細表示機能改造
* 2012/10/04 商品単価定義にて、金額計算方法対応
***********************************/
public with sharing class BillInput_Controlller{

    /***************************
    * 定数定義を行う
    ****************************/
    public string productNm{set;get;}
    // 画面データ処理ステータス変数
    private Enum PAGE_STATUS {INS,UPD,SEL,UPDSPEC}
    private static final Integer TTEND_INPUT_MAX_ROWS = 3;
    private static final Integer TRAN1_INPUT_MAX_ROWS = 27;
    private static final Integer TRAN1_INPUT_DEF_ROWS = 27;
    // メディア種別コード：12 DEL(共通CommConstに集中)
    private static final String MediaTypeDisCount = CommConst.MEDIA_TYPE_CD_12;
    /***************************
    * 変数定義を行う
    ****************************/
    public PageInfo oPage{get; private set;}
    
    // 予約基本情報
    private Lead__c oLeadSobj{get; private set;}
    // 会計基本情報
    public AccountAcount__c oAcountSobj{get; private set;}
    // 支払い方法
    public List<TTendItem> oTTendSobjLst{get; private set;}
    // 会計明細
    public  List<TranItem> oTranSobjLst{get; private set;}
    //public static List<TranItem> oTranSobjLst1{get; private set;}
    // 会計明細Footer
    public TranFooter oTranFooter{get; private set;}    
    // 会計支払Footer
    public TTendFooter oTttendFooter{get; private set;}
    /***************************
    * 変数定義を行う
    ****************************/
    // 税金率選択リスト
    //public List<Selectoption> taxRateOptionLst{get; private set;}
    // メディア種別選択リスト
    public List<Selectoption> mediaTypeOptionLst{get; private set;}
    // 画面制御関連変数
    // 遷移先からパラメータ情報を格納する
    private Map<String,String> paramMap;
    private ApexPages.StandardController ctrl;
    public BillInput_Controlller(ApexPages.StandardController controller) {
        ctrl = controller;
    }
    /**
    * 初期化処理を行う
    **/
    private void initInfo(AccountAcount__c standObj) {
        // 格納用クラスの初期化を行う
        oPage = new PageInfo();
        // 戻るページ維持する
        paramMap = Apexpages.currentPage().getParameters();
        // データは新規の場合
        if (standObj.Id == null) {
            // 新規表示用情報を設定する
            oPage.dataStatus = PAGE_STATUS.INS;
            oAcountSobj = standObj.clone(true,true);

            // 扱い者初期値設定を行う
            /* 2012/08/21 該当設定は廃止
            List<Worker__c> workerLst = [select id, name from Worker__c where name = :userInfo.getName()];
            if (!workerLst.isEmpty()) oAcountSobj.Field146__c = workerLst[0].Id;*/
        }
        // データはすでに存在の場合
        else {
            // 既存の件名明細データを取得する
            if (!refreshAccoutAcountInfo(standObj.Id)) return;
            // 画面編集フラグを設定する
            oPage.dataStatus = PAGE_STATUS.UPD;
        }
        // 関連情報を設定を行う
        refreshTTendInfo(oAcountSobj.frs__c, oAcountSobj.Id);
        refreshTran1Info(oAcountSobj.frs__c, oAcountSobj.Id);
        
        // 選択リスト初期かを行う
        //taxRateOptionLst = new List<Selectoption>();
        //Schema.DescribeFieldResult fieldResult = Jinyaconnect__c.TaxType__c.getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();     
        //for( Schema.PicklistEntry f : ple) taxRateOptionLst.add(new SelectOption(f.getValue(),f.getLabel()));

        // メディア種別選択リスト初期値設定する(仮)
        mediaTypeOptionLst = CommConst.getPayMentTypeOptLst();
        /*
        mediaTypeOptionLst = new List<Selectoption>();
        mediaTypeOptionLst.add(new SelectOption('01',MediaCdName.get('01')));
        mediaTypeOptionLst.add(new SelectOption('02',MediaCdName.get('02')));
        mediaTypeOptionLst.add(new SelectOption('03',MediaCdName.get('03')));
//      mediaTypeOptionLst.add(new SelectOption('04','Edy支払'));
//      mediaTypeOptionLst.add(new SelectOption('05','社内使用(従食)'));
//      mediaTypeOptionLst.add(new SelectOption('06','キャッシュバック支払'));
//      mediaTypeOptionLst.add(new SelectOption('07','Suica 支払'));
        mediaTypeOptionLst.add(new SelectOption('11',MediaCdName.get('11')));
        mediaTypeOptionLst.add(new SelectOption(MediaTypeDisCount,MediaCdName.get(MediaTypeDisCount)));
        */
    }

    /**
    * VOID
    **/
    public Pagereference voidProcess () {
        
        // 最新情報取得、設定を行う
        refreshAccoutAcountInfo(((AccountAcount__c)ctrl.getRecord()).Id);
        
        // 既にVOIDの場合、再VOIDできませんチェックを行う
        if (oAcountSobj.Field39__c == CommConst.ACC_TRADE_VOID) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
              '既にVOID処理済みため、再VOID処理することができません。'));
            return null;
        }
        // VOID機能実施を行う
        // 取引種別:30 ＶＯＩＤ
        oAcountSobj.Field39__c = CommConst.ACC_TRADE_VOID;
        update oAcountSobj;
        // TODO ＶＯＩＤレシートＮｏ．->設定？いつ？
        // 詳細画面へ戻る
        return gotoAccountsDetailPg();
    }
    /**
    * VOID機能取消を行う
    **/
    public Pagereference voidProcessCancel() {
        
        // 最新情報取得、設定を行う
        refreshAccoutAcountInfo(((AccountAcount__c)ctrl.getRecord()).Id);
        
        if (oAcountSobj.Field39__c != CommConst.ACC_TRADE_VOID) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
              'VOID処理をされてない為、VOID取り消し処理ができません。'));
            return null;
        }
        // 取引種別:00 売上（通常）
        oAcountSobj.Field39__c = CommConst.ACC_TRADE_NORMAL;
        update oAcountSobj;
        
        // 詳細画面へ戻る
        return gotoAccountsDetailPg();
    }
    // 会計詳細画面へ戻る
    public Pagereference gotoAccountsDetailPg() {
        return new Pagereference('/' + ctrl.getRecord().id);
    }

    private static final String TTendSel = 'Select CardTypeLst__c ,CouponTypeLst__c, noneaccount__c, Taxfee__c, Taishou__c, RelAccount__c, POSNo__c, OutSideAccount__c, Field9__c, Field8__c, Field7__c, Field6__c, Field5__c, Field4__c, Field3__c, Field35__c, Field34__c, Field33__c, Field32__c, Field31__c, Field30__c, Field2__c, Field29__c, Field28__c, Field27__c, Field26__c, Field25__c, Field24__c, Field23__c, Field22__c, Field21__c, Field20__c, Field1__c, Field19__c, Field18__c, Field17__c, Field16__c, Field15__c, Field14__c, Field13__c, Field10__c, SystemModstamp, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From TTend__c ';
    private static final String TranSel = 'Select TaxRate__c,ServiceRate__c,SpecialTax__c,InvoiceNoShowFlg__c,ActionType__c, Field7__r.Name, rtaxsts__c, profitt__c, profitnonetax__c, profit__c, noneaccount__c, inside__c, guestRoom__c, freetotal3__c, freetotal2__c, freetotal1__c, freeprice__c, freecost__c, VoidReceiptNo__c, TankawithoutTax__c, Tankanonetax__c, TableNo__c, Subprice__c, Seq__c, RowNo__c, RelAccount__c, POSNo__c, OPcode__c, GoukeinoneTax__c, Genkaritsu__c, Field9__c, Field8__c, Field7__c, Field6__c, Field5__c, Field52__c, Field51__c, Field50__c, Field4__c, Field49__c, Field48__c, Field47__c, Field46__c, Field45__c, Field44__c, Field43__c, Field42__c, Field41__c, Field40__c, Field3__c, Field39__c, Field38__c, Field37__c, Field36__c, Field35__c, Field34__c, Field33__c, Field32__c, Field31__c, Field30__c, Field2__c, Field29__c, Field28__c, Field27__c, Field26__c, Field25__c, Field24__c, Field23__c, Field22__c, Field21__c, Field20__c, Field1__c,    Field1__r.Name    ,Field19__c, Field18__c, Field17__c, Field16__c, Field15__c, Field14__c, Field13__c, Field12__c, Field11__c, Field10__c, DivisionNameI__c, Categorya__c, Category__c, CategoryItem__c, Accountoutside__c, SystemModstamp, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From Tran1__c ';
    /**
    * 最新会計情報を取得する
    * billId: 会計ID
    **/
    private Boolean refreshAccoutAcountInfo(Id billId) {
        if (billId == null) return false;
        // 最新情報を取得する
        List<AccountAcount__c> billList = [
          Select relaccount__c, frs__c, comment__c, TeaTimeFlag__c, Target__c, TableNo__c, Seq__c, Relreserve__c, 
              PlanNo__c, POSNo__c, OutSideAccount__c, Field99__c, Field98__c, Field97__c, Field96__c, Field95__c, 
              Field94__c, Field93__c, Field92__c, Field91__c, Field90__c, Field89__c, Field88__c, Field87__c, 
              Field86__c, Field85__c, Field84__c, Field83__c, Field82__c, Field81__c, Field80__c, Field7__c, 
              Field79__c, Field78__c, Field77__c, Field76__c, Field75__c, Field74__c, Field73__c, Field72__c, 
              Field71__c, Field70__c, Field69__c, Field68__c, Field67__c, Field66__c, Field65__c, Field64__c, 
              Field63__c, Field62__c, Field61__c, Field60__c, Field59__c, Field58__c, Field57__c, Field56__c, 
              Field55__c, Field54__c, Field53__c, Field52__c, Field51__c, Field50__c, Field49__c, Field48__c, 
              Field45__c, Field44__c, Field43__c, Field42__c, Field40__c, Field39__c, Field159__c, Field158__c, 
              Field157__c, Field156__c, Field155__c, Field154__c, Field152__c, Field151__c, Field150__c, 
              Field149__c, Field148__c, Field147__c, Field146__c, Field145__c, Field143__c, Field142__c, 
              Field141__c, Field140__c, Field139__c, Field138__c, Field137__c, Field136__c, Field135__c, 
              Field134__c, Field133__c, Field132__c, Field131__c, Field130__c, Field129__c, Field128__c, 
              Field127__c, Field126__c, Field125__c, Field124__c, Field123__c, Field122__c, Field121__c, 
              Field120__c, Field119__c, Field118__c, Field117__c, Field116__c, Field115__c, Field114__c, 
              Field113__c, Field112__c, Field111__c, Field110__c, Field109__c, Field108__c, Field107__c, 
              Field106__c, Field105__c, Field104__c, Field103__c, Field102__c, Field101__c, Field100__c, 
              DivisionName__c, SystemModstamp, Name, SumSrvPriceIncTax__c, SumSrvPriceExcTax__c,AmoutSpecialPrice__c,
              LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById,
              Relreserve__r.StayPersons__c,Relreserve__r.Rroom__r.Name,Relreserve__r.Rroom__c   
          From AccountAcount__c where id = :billId];
        if (billList.isEmpty()) return false;
        oAcountSobj = billList[0];
        return true;
    }
    /**
    * 予約情報を取得を行います 1会計→1日予約対応する
    **//*
    private Lead__c getLeadInfo() {
        // 到着日（連泊場合：）→チェックイン日に設定を行う
        // TODO: 深夜チェックに関して（２４：００すぎ）、チェック日の設定に関して、次のVERSIONに対応
        List<Lead__c> leadInfoLst = [select EntryTime__c from Lead__c where id = :oAcountSobj.Relreserve__c limit 1];
        // 必ず存在ですね、
        if (leadInfoLst.isEmpty()) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '予約情報を登録されないため、会計情報を登録できません。'));
            return null;
        }
        return leadInfoLst[0];
    }*/

    private Boolean preAmoutTran1Info() {
        
        return true;
    }
    /**
    * 会計支払金額再計算を行う
    **/
    public Pagereference calPaymentInfo() {
        amoutTran1Info();
        return null;
    }
    // 会計明細金額合計計算を行う
    private Boolean amoutTran1Info() {
        // 有効性チェックを行う
        if (!preAmoutTran1Info()) return false;
        // 既存支払い明細合計情報をクリアする
        oTranFooter.clear();
        //
        CommUtils.ProductInfo priceInfo = new CommUtils.ProductInfo();
        // 会計明細金額を再計算を行う
        for (TranItem obj: oTranSobjLst) {
            // 無効のデータをクリアを行う
            if (!obj.isValidata) {
                obj.clear();
                continue;
            }
            // 請求書非表示の場合、統計対象外になる
            if (obj.sobj.InvoiceNoShowFlg__c) continue;
            // 合計金額計算を行う
            // 単価と数量はNULLの場合、
            Decimal unitPrice = CommUtils.nullToZero(obj.sobj.Field20__c);  // <-税金含め単価です
            Decimal qty = CommUtils.nullToZero(obj.sobj.Field21__c);
/* 20121005修正を行う（商品単価多目意味機能対応） */
            priceInfo.process(unitPrice , qty , obj.sobj.TaxRate__c, obj.sobj.ServiceRate__c);
            // 合計金額(税抜)※※※※（１円未満切り上げ）※※※※
            obj.amoutExcTax = priceInfo.priceExcTax;
            // サービス料金（税込）
            obj.servicePriceIncTax = priceInfo.priceService;
            // 合計金額(税込)
            obj.amoutIncTax = priceInfo.priceIncTax;
            // 2012/10/17 宿泊税の計算機能を追加する
            // 設定されている商品は室料場合、宿泊税計算を行う
            if (obj.sobj.ActionType__c == CommConst.PROD_ACTION_TYPE_RP) {
                // 単価価額(税抜) + サビース料金(税抜)で計算結果を取得する[数量固定１で計算を行う]
                priceInfo.process(unitPrice , 1, obj.sobj.TaxRate__c, obj.sobj.ServiceRate__c);
                Decimal roomPrice = priceInfo.priceExcTax + priceInfo.priceServiceExcTax;
                // 特別税計算を行う
                if (obj.sobj.SpecialTax__c == null) obj.sobj.SpecialTax__c = priceInfo.specialTaxCal(roomPrice) * qty;
            }
            // 宿泊税値合計値に追加する
            obj.amoutIncTax += CommUtils.nullToZero(obj.sobj.SpecialTax__c);
/*
            // 合計金額(税込)
            obj.amoutIncTax = CommUtils.RoundProcess((unitPrice * qty), 0);
            // 合計金額(税抜)※※※※（１円未満切り上げ）※※※※
            obj.amoutExcTax = CommUtils.CalExcTaxPrice(obj.amoutIncTax, obj.sobj.TaxRate__c, 0, RoundingMode.CEILING);
//            obj.amoutExcTax = CommUtils.CalExcTaxPrice(obj.amoutIncTax, obj.sobj.TaxRate__c, 0);
            // サービス料金（税込）
            obj.servicePriceIncTax = CommUtils.RoundProcess(obj.amoutIncTax * (CommUtils.nullToZero(obj.sobj.ServiceRate__c) / 100), 0);
            // サービス料金（税抜）
//            obj.servicePrice = CommUtils.RoundProcess(obj.amoutExcTax * (CommUtils.nullToZero(obj.sobj.ServiceRate__c) / 100), 0);
            // 合計金額(税込)：合計金額（税抜）をベースとして、サービス料を計算した後、サービス料を含む合計金額を計算
//          obj.amoutIncTax = CommUtils.CalIncTaxPrice((obj.amoutExcTax + obj.servicePrice),obj.sobj.TaxRate__c,0) 
//                              + obj.sobj.SpecialTax__c ;
//            obj.amoutIncTax = obj.amoutIncTax + CommUtils.CalIncTaxPrice(obj.servicePrice,obj.sobj.TaxRate__c,0) + obj.sobj.SpecialTax__c ;
            // 税込合計金額再計算を行う（商品合計金額＋サービス料金（税込）+特別税）
            obj.amoutIncTax = obj.amoutIncTax + obj.servicePriceIncTax + obj.sobj.SpecialTax__c;
*/
            // 商品処理種別は前受付金の場合、合計処理対象外：
            if (obj.sobj.ActionType__c != CommConst.PROD_ACTION_TYPE_AR) {
                // 支払明細合計計算を行う
                oTranFooter.add(obj);
            }
        }
        // 会計支払情報を設定をを行う
        if (!syncPriceToTtend(oTranFooter)) {
            return false;
        }
        // 会計明細から会計へ売り上げ金額を設定を行う
        syncPriceToAccount(oTranFooter, oTttendFooter);
        return true;
    }
    
    // 会計明細から会計支払へ設定を行う
    private Boolean syncPriceToTtend (TranFooter pTranFooter) {
        // 既に入力した金額に対して、自動設定必要かどうか、判断する
        Decimal paymentMoney = 0;
        // 合計値格納クラスをクリアする
        oTttendFooter.clear();
        
        // Tメディア毎の消費税金額と設定
        // TODO: メディア毎の消費税金額とならないですけれど、会計明細の各商品ごとの消費税金額を積み上げ集計した消費税の金額と考えて頂けませんか、この金額をメディア毎消費税額項目に設定する、会計明細の商品には、たとえば、消費税５％、８％、非課税の混在となる可能性がありますので、今回のバージョンでは、たとえば、最大３つのレコードが会計支払レコードに存在すれば、このうちどれか一つのレコードのみにメディア毎消費税額が設定されていればよいということにしましょう、メディアごとに消費税を分割するのはあまり意味がないと考えております、矛盾がおきなければよいけれど、
        Boolean mediaTaxSetupOverFlg = false;
        
        // 各行目に設定されている
        for (TTendItem item: oTTendSobjLst) {
            
            // TODO: メディア毎の消費税金額は先に全部クリアを行う 
            item.sobj.Field25__c = null;
            
            // 預かり金額と支払金額差計算を行う
            if (item.isCanEdit) {
                // 預り金を未登録して、金券存在する場合、金券の金額を自動計算を行って、設定を行う
                if(CommUtils.isBlank(item.sobj.Field19__c))  
                    item.sobj.Field19__c = String.valueOf(CommUtils.nullToZero(item.sobj.Field16__c) * CommUtils.nullToZero(item.sobj.Field17__c));
                // 預かり　金額
                Decimal currRowPayment = CommUtils.nullToZero(item.sobj.Field19__c);
                paymentMoney += currRowPayment;
                // 値割引対象額
//              paymentMoney += CommUtils.nullToZero(item.sobj.Field15__c);
                // 釣銭（差額）金額クリアする
                item.sobj.Field21__c = null;
                // メディア毎の消費税金額を設定する（一回設定のみ）
                if (!mediaTaxSetupOverFlg && item.isPaymented) {
                    item.sobj.Field25__c = String.valueOf(pTranFooter.amoutPriceIncTax - pTranFooter.amoutPriceExcTax);
                    mediaTaxSetupOverFlg = true;
                }
                // 預かり金は０円の場合、支払金額は自動クリアする
                if (currRowPayment == 0) item.sobj.Field20__c = null;
            } else {
                // 既存情報をクリアする
                item.clear();
            }
        }
        
//      // 前受付金があり場合、該当前受付金は預かり金額へ追加する
//      paymentMoney += pTranFooter.amoutAdvancesReceived;
        
//System.debug('-------- paymentMoney --------' + paymentMoney);
//System.debug('-------- pTranFooter.amoutPriceIncTax --------' + pTranFooter.amoutPriceIncTax);
        // 金額差を確認して、IF(支払金額 > (預かり金額+値割引対象額))場合：
        // 残り金額を自動設定：設定ルールのは：メディア種別設定して、「預かり　金額」未設定の場合、該当行目に預かり金額に設定すると、該当
        // そして、メディア種別、「預かり　金額」設定の場合、該当行目の支払い金額は　「預かり　金額」+ 値割引対象額 
        if (paymentMoney < pTranFooter.amoutPriceIncTax) {
            // 未支払金額が存在する場合、既に支払い金額の各行目に自動設定を行う
            for (TTendItem item: oTTendSobjLst) {
                // 支払額を自動設定する場合
                if (item.isPaymented) {
                    Decimal rowPayment = CommUtils.nullToZero(item.sobj.Field19__c);
                                         //CommUtils.nullToZero(item.sobj.Field15__c);
                    // 既に入力の預かり金額で該当行目にそのまま設定を行う
                    item.sobj.Field20__c = String.valueOf(rowPayment);
                }
            }
            // 残り金額を設定を行う、設定できる項目が存在しない場合、エラーを設定して、画面へ戻ります
            Decimal remaindMoney = pTranFooter.amoutPriceIncTax - paymentMoney;
            Boolean isAutoSetupRowFlg = false;
            for (TTendItem item: oTTendSobjLst) {
                // 支払額を自動設定する場合
                if (item.isAutoSetupPayment) {  
                    // 預かり　金額
                    item.sobj.Field19__c = String.valueOf(remaindMoney);
                    // 支払い金額
                    item.sobj.Field20__c = String.valueOf(remaindMoney);
                    // isAutoSetupRowFlg
                    isAutoSetupRowFlg = true;
                }
            }
            if (!isAutoSetupRowFlg) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '未支払い金額が存在してため、会計支払のメディア種別など設定を再確認お願いします'));
                return false;
            }
        }  
        // 顧客さんから支払い金額は支払いベキ金額は大きい場合
        else {
            // 支払金額：預かり金額の中から、会計に使用された金額を処理する。
            // 釣銭（差額）金額
            Decimal changeVal = paymentMoney - pTranFooter.amoutPriceIncTax;
            Decimal calMoney = 0;
            Boolean changeSetupOverFlg = false;
            for (TTendItem item: oTTendSobjLst) {
                // 支払いデータ入力あり場合
                if (item.isPaymented) {
                    // 該当行目に既に支払金額
                    Decimal rowPayment = CommUtils.nullToZero(item.sobj.Field19__c);
                    //                   CommUtils.nullToZero(item.sobj.Field15__c);
                    // 顧客から実際支払金額を計算を行う
                    calMoney += rowPayment;
                    /*
                    if (calMoney + changeVal > pTranFooter.amoutPriceIncTax) {
                       // 支払い金額設定を行う
                       item.sobj.Field20__c = String.valueOf(rowPayment);
                    }*/
                    // 釣銭（差額）金額設置えを行う
                    if (calMoney == pTranFooter.amoutPriceIncTax && !changeSetupOverFlg) {
                        // 支払い金額設定を行う
                        item.sobj.Field20__c = String.valueOf(rowPayment);
                        // 釣銭（差額）金額
                        item.sobj.Field21__c = null;
                        // 釣銭（差額）金額一回だけ設定する
                        changeSetupOverFlg = true;
                    } else if (calMoney > pTranFooter.amoutPriceIncTax && !changeSetupOverFlg) {
                        // 支払い金額設定を行う
                        item.sobj.Field20__c = String.valueOf(rowPayment - changeVal);
                        //if(!changeSetupOverFlg) {
                        // 釣銭（差額）金額
                        item.sobj.Field21__c = (changeVal == 0) ? null : String.valueOf(changeVal);
                        // 釣銭（差額）金額一回だけ設定する
                        changeSetupOverFlg = true;
                        //}
                    } else if (changeSetupOverFlg){
                        // 既存情報をクリアする
                        item.clear();
                    } else {
                        // 支払い金額設定を行う
                        item.sobj.Field20__c = String.valueOf(rowPayment);
                    }
                }
            }
        }
        for (TTendItem item: oTTendSobjLst) {
            // メディア種別選択する場合:<-該当行目
            if (item.isCanEdit) {
                oTttendFooter.add(item);
            }
        }
        return true;
    }
    
    // 会計明細から会計へ売り上げ金額を設定を行う
    private void syncPriceToAccount (TranFooter pTranFooter, TTendFooter pTttendFooter) {
        // 売上計4（税込）金額:Field116__c  ->値引き存在と関係なし、実際の商品の売上を合計で設定する
        oAcountSobj.Field116__c = String.valueOf(pTranFooter.amoutPriceIncTax);
        // 売上計3（税抜）金額:Field114__c
        oAcountSobj.Field114__c = String.valueOf(pTranFooter.amoutPriceExcTax);
        // サービス料金(税込)
        oAcountSobj.SumSrvPriceIncTax__c = pTranFooter.amoutServicePriceIncTax;
        // サービス料金(税抜)
        oAcountSobj.SumSrvPriceExcTax__c = pTranFooter.amoutServicePrice;
        // 宿泊税
        oAcountSobj.AmoutSpecialPrice__c = pTranFooter.amoutSpecialTax;
        // 割引金額（税込）
        oAcountSobj.Discount__c = pTttendFooter.amoutDiscountPrice;
    }

    /**
    * 最新会計支払情報を取得する
    * salesId: 売上ID
    * billId: 会計ID
    **/
    private Boolean refreshTTendInfo(Id salesId, Id billId) {
        
//      oTTendSobjLst = new List<TTend__c>();
        oTTendSobjLst = new List<TTendItem>();
        oTttendFooter = new TTendFooter();

        // 入力欄初期化する
        if (salesId != null && billId != null) {
            String queryStr = TTendSel + ' Where RelAccount__c = :salesId';
            if (!CommUtils.isBlank(billId)) queryStr+= ' And Field1__c = :billId ';
            for (TTend__c sobj: DataBase.query(queryStr)) {
                TTendItem newItem = new TTendItem(sobj, oTTendSobjLst.size());
                oTTendSobjLst.add(newItem); 
                // 合計情報を設定を行う
                oTttendFooter.add(newItem);
            }
        }
        
        if (oTTendSobjLst.size() < TTEND_INPUT_MAX_ROWS) {
            Integer appendRsSize = TTEND_INPUT_MAX_ROWS - oTTendSobjLst.size();
            // 2行目まで設定を行う
            for (Integer i = 0; i < appendRsSize; i++) {
                TTendItem newItem = new TTendItem(new TTend__c(RelAccount__c = salesId), oTTendSobjLst.size());
                // 支払データが未登録場合、第一行目の支払方法は自動設定を行う[現金]
                if (i == 0 && appendRsSize == TTEND_INPUT_MAX_ROWS) newItem.sobj.Field2__c = '01';
                oTTendSobjLst.add(newItem);  
            }
        }
        return true;
    }

    /**
    * 最新会計明細情報を取得する
    * salesId: 売上ID
    * billId: 会計ID
    **/
    private Boolean refreshTran1Info(Id salesId, Id billId) {
        
//      oTranSobjLst = new List<Tran1__c>();
        oTranSobjLst = new List<TranItem>();
        oTranFooter = new TranFooter();
        
        if (salesId != null && billId != null) {
            String queryStr = TranSel + ' Where RelAccount__c = :salesId';
            if (!CommUtils.isBlank(billId)) queryStr+= ' And Field1__c = :billId ';
// 20121002 ADD
queryStr += ' And ParentTran1Ref__c = null ' ;
            for (Tran1__c sobj: DataBase.query(queryStr)) {
                TranItem item = new TranItem(sobj, oTranSobjLst.size());
                oTranSobjLst.add(item);
                //oTranSobjLst.add(sobj);
                // 合計情報を設定する
                oTranFooter.add(item);
            }
        }
        if (oTranSobjLst.size() < TRAN1_INPUT_DEF_ROWS) {
            Integer appendRsSize = TRAN1_INPUT_DEF_ROWS - oTranSobjLst.size();
            // 2行目まで設定を行う
            for (Integer i = 0; i < appendRsSize; i++) {
                oTranSobjLst.add(new TranItem(new Tran1__c(RelAccount__c = salesId),oTranSobjLst.size()));
            }
        }
        
        // 会計情報を連携を行う
        //syncPriceToTtend(oTranFooter);
        //syncPriceToAccount(oTranFooter);
        return true;
    }
    
    public void initAction() {
        // 初期表示用データを設定する
        this.initInfo((AccountAcount__c)ctrl.getRecord());
    }
    /**
    * キャセンル画面に遷移する
    **/ 
    public Pagereference gotoCancel() {
        String retUrl = paramMap.get('retURL');
        if (!CommUtils.isBlank(retUrl)) {
            PageReference pageRef = new PageReference(retUrl);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public Boolean isShowAddItemBtnFlg{get{
        if (oTranSobjLst.size() > TRAN1_INPUT_MAX_ROWS) return false;
        return true;
    }}
    public Pagereference addTran1Item() {
        return null;
    }
    
    // 会計情報新規作成
    public Pagereference insertData() {
        insert preUpdateAccountInf(oAcountSobj);
        // 画面編集フラグを設定する
        oPage.dataStatus = PAGE_STATUS.UPD;
        // 最新インサート情報を取得する
        refreshAccoutAcountInfo(oAcountSobj.id);
        
        return null;
    }
    // プラン関連の商品明細を取得する
    // accId:会計ID/会計商品（プラン）ID
    @RemoteAction
    public static List<PlanDetail> getAccountMstLstByPlan(String tranId, String accId, String planId) {
        // 会計IDが存在する場合、既に登録された登録情報から情報を展開する
        // 会計IDが非存在場合、
        List<PlanDetail> rsLst = new List<PlanDetail>();
        if (CommUtils.isBlank(accId)) {
            for (PlanDetail__c pd : [select AccountMasterRef__r.name, Price__c from PlanDetail__c where PlanProdcut__c = :planId]) {
                PlanDetail item = new PlanDetail();
                item.prodName = CommUtils.nullToBlank(pd.AccountMasterRef__r.name);
                item.prodPrice = CommUtils.nullToZero(pd.Price__c).format();
                rsLst.add(item);
            }
        } else {
            for (Tran1__c tr : [select Field5__c, Field23__c from Tran1__c where  ParentTran1Ref__c!=null and Field1__c = :accId ]) {
                PlanDetail item = new PlanDetail();
                item.prodName = CommUtils.nullToBlank(tr.Field5__c);
                item.prodPrice = CommUtils.nullToZero(tr.Field23__c).format();
                rsLst.add(item);
            }
        }
        return rsLst;
    }
    // プラン明細情報を維持する
    public class PlanDetail {
        public String prodName{get; set;}
        public String prodPrice{get; set;}
    }
    /**
    * 集計対象になるため、デフォルト設定設定を行う
    **/
    private AccountAcount__c preUpdateAccountInf(AccountAcount__c pAcountSobj) {
        // 取引種別:00 売上(通常)
        pAcountSobj.Field39__c = CommConst.ACC_TRADE_NORMAL;
        // ＶＯＩＤレシートＮｏ．
        pAcountSobj.Field40__c = '';
        // 売上計3（内税抜き）金額
        //pAcountSobj.Field114__c ->会計明細から自動設定を行う
        // POSNo.
        pAcountSobj.POSNo__c = CommUtils.getPosNoByComdefine();
        // TODO：営業日付 ←　チェックイン日付で設定を行う　
        pAcountSobj.Field141__c = CommUtils.getBusinessDay();
        // 会計日時: TODO->原システム確認要
        pAcountSobj.Field53__c = DateTime.valueOf(String.valueOf(System.now())).format('yyyyMMddHHmmss');
        // 会計人数
        pAcountSobj.Field57__c = String.valueOf(
                                    CommUtils.nullToZero(pAcountSobj.Field66__c) + 
                                    CommUtils.nullToZero(pAcountSobj.Field67__c) +
                                    CommUtils.nullToZero(pAcountSobj.Field68__c));
        //pAcountSobj.Field57__c = String.valueOf(CommUtils.)
        
        return pAcountSobj;
    }
    private List<TTend__c> preUpdateTtendInfo (List<TTend__c> pTtendList) {
        // 集計対象条件
        // Field35__c = "00" && Field4__c = "1" && Field5__c ="1" && Field1__r.Field40__c ="" && Field29__c <> 0
        // 処理　種別１:Field4__c ->1
        // 処理　種別２:Field5__c ->1
        // 営業日付
        String strBusinessDay = CommUtils.getBusinessDay();
        for (TTend__c sobj: pTtendList) {
            sobj.Field4__c = '1';
            sobj.Field5__c = '1';
            sobj.POSNo__c = CommUtils.getPosNoByComdefine();
//          sobj.Field34__c = strBusinessDay;
            // メディア名称設定を行う
            //if (!CommUtils.isBlank(sobj.Field2__c)) sobj.Field3__c = MediaCdName.get(sobj.Field2__c);
            if (!CommUtils.isBlank(sobj.Field2__c)) sobj.Field3__c = CommConst.getPaymentTypeLabelByKey(sobj.Field2__c);
            /*
            // メディア毎消費税額(支払金額（税金含め）から消費税を計算を行う)
            if (!CommUtils.isBlank(sobj.Field20__c)) sobj.Field25__c = String.valueOf(
             CommUtils.CalTaxByPriceIncTax(Decimal.valueOf(sobj.Field20__c), obj.sobj.TaxRate__c, 0
             );*/
        }
        return pTtendList;
    }
    private List<Tran1__c> preUpdateTran1Info (List<Tran1__c> pTranList) {
        // if ( Field44__c = "00" && (Field39__c <> 0 || CONTAINS( Field5__c , "●") ) && ( Field2__c ="M" || Field2__c ="P" || Field2__c ="R") && Field3__c = "1" && Field4__c ="1" && Field22__c <> "+000" && VoidReceiptNo__c ="0" && noneaccount__c = false , 1, 0)
        // 商品種別:Field2__c
        // 処理種別１:Field3__c
        // 処理種別２:Field4__c
        // 残数量:Field22__c
        // TODO: 営業日付
        // 会計商品から商品種別を取得を行う
        Set<Id> prodcutIdSet = new Set<Id>();
        for (Tran1__c sobj: pTranList) {
            prodcutIdSet.add(sobj.Field7__c);
        }
        Map<Id, AccountMaster__c> productMap = new Map<Id, AccountMaster__c>([select SCP_5__c from AccountMaster__c where id in :prodcutIdSet]);
        
//      String strBusinessDay = CommUtils.getBusinessDay();
        for (Tran1__c sobj: pTranList) {
            // 商品種別 ->SCP(5) = '0'    M   ; SCP(5) != '0'   P
            if (productMap.containsKey(sobj.Field7__c)) {
                // TODO 現状のシステムを一回確認必要
                String scpCode = productMap.get(sobj.Field7__c).SCP_5__c;
                sobj.Field2__c = (scpCode == '0') ? 'M' : 'P';
            }
            // 処理種別１
            sobj.Field3__c = '1';
            // 処理種別２
            sobj.Field4__c = '1';
            // 残数量
            sobj.Field22__c = sobj.Field21__c;
            // 営業日付
//          sobj.Field45__c = strBusinessDay;   
            // POSNo.
            sobj.POSNo__c = CommUtils.getPosNoByComdefine();
            // 消費税　種別(消費税＝０の場合、非課税/)
            sobj.Field27__c = (sobj.TaxRate__c == 0 ? '2' : '1');
        }
        return pTranList;
    }
    
    public Pagereference upsertData() {
        // 最新入力情報にて、最新合計情報を再計算を行う
        if (!this.amoutTran1Info()) {
            return null;
        }
//System.debug('------- oAcountSobj ----' + oAcountSobj);
        // 更新処理を行う
        upsert preUpdateAccountInf(oAcountSobj);
        // 最新IDを取得する
        List<TTend__c> updTtendList = new List<TTend__c>();
        List<TTend__c> delTtendList = new List<TTend__c>();
        for (TTendItem obj: oTTendSobjLst) {
            if (CommUtils.isBlank(obj.sobj.Field2__c)) {
                if (obj.sobj.id != null) delTtendList.add(obj.sobj);
                continue;
            }
            obj.sobj.Field1__c = oAcountSobj.Id;
            if(obj.sobj.RelAccount__c == null) obj.sobj.RelAccount__c = oAcountSobj.frs__c;
            updTtendList.add(obj.sobj);
        }
        upsert preUpdateTtendInfo(updTtendList);
        if (!delTtendList.isEmpty()) delete delTtendList;
        
        List<Tran1__c> updTranList = new List<Tran1__c>();
        List<Tran1__c> delTranList = new List<Tran1__c>();
        for (TranItem obj: oTranSobjLst) {
            //if (CommUtils.isBlank(obj.sobj.Field25__c) || CommUtils.isBlank(obj.sobj.Field26__c)) continue;
            // 商品登録と、有効なデータで登録する
            if (!obj.isValidata) {
                if (obj.sobj.Id != null) delTranList.add(obj.sobj);
                continue;
            }
            obj.sobj.Field1__c = oAcountSobj.Id;
            if(obj.sobj.RelAccount__c == null) obj.sobj.RelAccount__c = oAcountSobj.frs__c;
            // 関連項目を自動設定をを行う
            // 商品名称（または券名称）
            //if (CommUtils.isBlank(obj.sobj.Field5__c))  obj.sobj.Field5__c = obj.productNm;
            obj.sobj.Field5__c = CommUtils.isBlank(obj.productNm) ? obj.orgProductNm : obj.productNm;
            updTranList.add(obj.sobj);
        }
        upsert preUpdateTran1Info(updTranList);
        if (!delTranList.isEmpty()) delete delTranList;
        
        Pagereference pg = new Pagereference('/' + oAcountSobj.id);
        pg.setRedirect(true);
        return pg;
    }

    public class PageInfo {
        // 画面データステータス維持する
        public PAGE_STATUS dataStatus{get;private set;}
        public Boolean isIns{get{return dataStatus == PAGE_STATUS.INS;}}
        public Boolean isUpd{get{return dataStatus == PAGE_STATUS.UPD;}}
        public Boolean isSel{get{return dataStatus == PAGE_STATUS.SEL;}}

    }
    // 会計支払
    public class TTendItem {
        public TTendItem(TTend__c o, Integer rsIndex) {
            sobj = o;
            index = rsIndex;
        }
        public void clear() {
            // メディア種別
            sobj.Field2__c = null;
            // カード種別
            sobj.CardTypeLst__c = null;
            // 金券種別
            sobj.CouponTypeLst__c = null;
            // 金券単価
            sobj.Field16__c = null;
            // 金券枚数
            sobj.Field17__c = null;
            // 預かり　金額
            sobj.Field19__c = null;
            // 値割引対象額
            sobj.Field15__c = null;
            // 支払　金額
            sobj.Field20__c = null;
            // 釣銭（差額）金額
            sobj.Field21__c = null;
            // メディア毎消費税額
            sobj.Field25__c = null;
        }
        public Integer index{get; private set;}
        public TTend__c sobj{get;set;}
        /*
        public Boolean isValidata{get{
            return true;
        }}*/
        public Boolean isCanEdit{get{
            return (!CommUtils.isBlank(sobj.Field2__c));
        }}
        // 顧客から支払金額を入力されたの場合
        public Boolean isPaymented{get{
            return (isCanEdit && ((CommUtils.nullToZero(sobj.Field19__c) !=0) ||
                                  (CommUtils.nullToZero(sobj.Field15__c) !=0)));
        }}
        // 支払　金額 自動設定必要場合
        public Boolean isAutoSetupPayment{get{
            // 預かり金額 + 値割引対象額 -> 支払　金額 
            return (isCanEdit && ((CommUtils.nullToZero(sobj.Field19__c) ==0) &&
                                  (CommUtils.nullToZero(sobj.Field15__c) ==0)));
        }}
        public Boolean isExist{get{return (sobj.id != null);}}
    }
    // 会計支払合計情報を格納する
    public class TTendFooter {
        public TTendFooter() {
            this.clear();
        } 
        // 割引値の合計
        public Decimal amoutDiscountPrice{get; private set;}
        // 預かり金額の合計
        public Decimal amoutPaymentPrice{get; private set;}
        // 支払金額の合計:預かり金額の中から、会計に使用された金額を処理する。
        public Decimal amoutSalesPrice{get; private set;}
        // 釣銭（差額）金額合計
        public Decimal amoutChangePrice{get; private set;}
        
        public void add(TTendItem item) {
            if (!item.isCanEdit) return;
            // 割引値の合計
            if (item.sobj.Field2__c == MediaTypeDisCount) amoutDiscountPrice += CommUtils.nullToZero(item.sobj.Field19__c);
            // 預かり金額の合計
            amoutPaymentPrice += CommUtils.nullToZero(item.sobj.Field19__c);
            // 支払金額の合計
            amoutSalesPrice += CommUtils.nullToZero(item.sobj.Field20__c);
            // 釣銭（差額）金額合計
            amoutChangePrice += CommUtils.nullToZero(item.sobj.Field21__c);
        }
        public void clear() {
            amoutDiscountPrice = 0;
            amoutPaymentPrice = 0;
            amoutSalesPrice = 0;
            amoutChangePrice = 0;
        }
    }
    // 会計明細
    public class TranItem {
        public TranItem(Tran1__c s, Integer rsIndex) {
            sobj = s;
            index = rsIndex;
            amoutIncTax = CommUtils.isBlank(s.Field23__c) ? 0 : Decimal.valueOf(s.Field23__c);
            amoutExcTax = s.GoukeinoneTax__c == null ? 0 : s.GoukeinoneTax__c;
            productNm = CommUtils.isBlank(sobj.Field5__c) ? s.Field7__r.Name : sobj.Field5__c;
            orgProductNm = s.Field7__r.Name;
            isPlanProduct = false;
            tranId = sobj.Id;
            accRefId = sobj.Field1__c;
        }
        public void clear() {
            // 消費税
            sobj.TaxRate__c = null;
            // サービス料
            sobj.ServiceRate__c = null;
            // 特別税
            sobj.SpecialTax__c = null;
        }
        public Integer index{get; private set;}
        /*
        public Decimal taxRate{get; set{
            taxRate = value;
            // 消費税　種別
            sobj.Field27__c = (taxRate == 0 ? '2' : '1');
        }}*/
        public String productNm{get;set;}
        // 該当商品名は商品名変更ため、ダミ用変数
        public String orgProductNm{get;set;}
        // サービス料金(税込)
        public Decimal servicePriceIncTax{get;set;}
        // 会計明細単位の合計金額（税抜）
        public Decimal amoutExcTax{get; set;}
        // 会計明細単位の合計金額（税込）[商品売価*数量  + サービス料　+ 特別税]
        public Decimal amoutIncTax{get; set{
            amoutIncTax = value;
            if (value !=null && String.valueOf(value) != sobj.Field23__c) sobj.Field23__c = String.valueOf(value);}}
        public Tran1__c sobj{get;set;}
        public Boolean isValidata{get{
            return (!CommUtils.isBlank(sobj.Field7__c) &&
                    !CommUtils.isBlank(sobj.Field20__c) &&
                    !CommUtils.isBlank(sobj.Field21__c));
        }}
        public Boolean isPlanProduct{get{return (sobj.ActionType__c == CommConst.PROD_ACTION_TYPE_PL ? true : false);} set;}
        public String tranId{get; set;}
        public String accRefId{get ;set;}
    }
    public class TranFooter {
        public TranFooter() {
            clear();
        }
        // 数量
        public Decimal unitNums{get; private set;}
        // 全会計明細合計金額（税抜き）->全サービス料/特別税含めない
        public Decimal amoutPriceExcTax{get; private set;}
        // 全会計明細合計金額（税含め）
        public Decimal amoutPriceIncTax{get; private set;}
        // 全消費税
        //public Decimal amoutSalesTax{get; private set;}
        // サービス料(税抜)
        public Decimal amoutServicePrice{get; private set;}
        // サービス料(税込)
        public Decimal amoutServicePriceIncTax{get;private set;}
        // 特別税合計
        public Decimal amoutSpecialTax{get; private set;}
        // 前受付金
        public Decimal amoutAdvancesReceived{get; private set;}
        // 会計明細積み上げ計算
        public void add(TranItem item) {
            // 請求書非表示の場合、集計対象外になる
            if (item.sobj.InvoiceNoShowFlg__c) return;
            // 商品は前受付金の場合
            if (item.sobj.ActionType__c == CommConst.PROD_ACTION_TYPE_AR) {
                amoutAdvancesReceived+= item.amoutIncTax;
                return;
            }
            unitNums += CommUtils.nullToZero(item.sobj.Field21__c);
            amoutPriceIncTax += CommUtils.nullToZero(item.sobj.Field23__c);
            amoutPriceExcTax += item.amoutExcTax == null ? 0 : item.amoutExcTax;
            amoutServicePriceIncTax += CommUtils.nullToZero(item.servicePriceIncTax);
            amoutServicePrice += CommUtils.CalExcTaxPrice(item.servicePriceIncTax, item.sobj.TaxRate__c, 0);
//            amoutServicePrice += CommUtils.nullToZero(item.servicePrice);
//            amoutServicePriceIncTax += CommUtils.CalIncTaxPrice(item.servicePrice, item.sobj.TaxRate__c, 0);
            
            amoutSpecialTax += CommUtils.nullToZero(item.sobj.SpecialTax__c);
            
        }
        public void clear() {
            unitNums = 0;
            amoutPriceExcTax = 0;
            amoutPriceIncTax = 0;
            amoutServicePrice = 0;
            amoutServicePriceIncTax = 0;
            amoutSpecialTax = 0;
            amoutAdvancesReceived = 0;
        }
    }
    
    public void OnChangeItemCode()
    {
        string s=apexpages.currentpage().getparameters().get('ItemCode');
        system.debug('@@@@@@@@@@@@= '+s);
        //Tran1__c tran= [Select TaxRate__c,ServiceRate__c,SpecialTax__c,InvoiceNoShowFlg__c,ActionType__c, Field7__r.Name, rtaxsts__c, profitt__c, profitnonetax__c, profit__c, noneaccount__c, inside__c, guestRoom__c, freetotal3__c, freetotal2__c, freetotal1__c, freeprice__c, freecost__c, VoidReceiptNo__c, TankawithoutTax__c, Tankanonetax__c, TableNo__c, Subprice__c, Seq__c, RowNo__c, RelAccount__c, POSNo__c, OPcode__c, GoukeinoneTax__c, Genkaritsu__c, Field9__c, Field8__c, Field7__c, Field6__c, Field5__c, Field52__c, Field51__c, Field50__c, Field4__c, Field49__c, Field48__c, Field47__c, Field46__c, Field45__c, Field44__c, Field43__c, Field42__c, Field41__c, Field40__c, Field3__c, Field39__c, Field38__c, Field37__c, Field36__c, Field35__c, Field34__c, Field33__c, Field32__c, Field31__c, Field30__c, Field2__c, Field29__c, Field28__c, Field27__c, Field26__c, Field25__c, Field24__c, Field23__c, Field22__c, Field21__c, Field20__c, Field1__c,    Field1__r.Name    ,Field19__c, Field18__c, Field17__c, Field16__c, Field15__c, Field14__c, Field13__c, Field12__c, Field11__c, Field10__c, DivisionNameI__c, Categorya__c, Category__c, CategoryItem__c, Accountoutside__c, SystemModstamp, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From Tran1__c ];
        for(TranItem tt:oTranSobjLst)
        {
            if(s==string.valueof(tt.index))
            {
                system.debug('Value of Index at index ='+tt.index+' Value of product ='+tt.productNm);
                for(AccountMaster__c ActMaster:[select id,name,Field3__c from AccountMaster__c where Field3__c=:tt.productNm])
                {
                
                list<Tran1__c> trn=[Select TaxRate__c,ServiceRate__c,SpecialTax__c,InvoiceNoShowFlg__c,ActionType__c, Field7__r.Name, rtaxsts__c, profitt__c, profitnonetax__c, profit__c, noneaccount__c, inside__c, guestRoom__c, freetotal3__c, freetotal2__c, freetotal1__c, freeprice__c, freecost__c, VoidReceiptNo__c, TankawithoutTax__c, Tankanonetax__c, TableNo__c, Subprice__c, Seq__c, RowNo__c, RelAccount__c, POSNo__c, OPcode__c, GoukeinoneTax__c, Genkaritsu__c, Field9__c, Field8__c, Field7__c, Field6__c, Field5__c, Field52__c, Field51__c, Field50__c, Field4__c, Field49__c, Field48__c, Field47__c, Field46__c, Field45__c, Field44__c, Field43__c, Field42__c, Field41__c, Field40__c, Field3__c, Field39__c, Field38__c, Field37__c, Field36__c, Field35__c, Field34__c, Field33__c, Field32__c, Field31__c, Field30__c, Field2__c, Field29__c, Field28__c, Field27__c, Field26__c, Field25__c, Field24__c, Field23__c, Field22__c, Field21__c, Field20__c, Field1__c,    Field1__r.Name    ,Field19__c, Field18__c, Field17__c, Field16__c, Field15__c, Field14__c, Field13__c, Field12__c, Field11__c, Field10__c, DivisionNameI__c, Categorya__c, Category__c, CategoryItem__c, Accountoutside__c, SystemModstamp, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From Tran1__c where Field7__c=:ActMaster.id ];
                if(trn.size()>0)
                {
                tt.sobj=trn[0];
                tt.amoutIncTax = CommUtils.isBlank(trn[0].Field23__c) ? 0 : Decimal.valueOf(trn[0].Field23__c);
                tt.amoutExcTax = trn[0].GoukeinoneTax__c == null ? 0 : trn[0].GoukeinoneTax__c;
                tt.orgProductNm = trn[0].Field7__r.Name;
                tt.isPlanProduct = false;
                tt.tranId = trn[0].Id;
                tt.accRefId = trn[0].Field1__c;
                //tt.isValidata=true;
                system.debug('@@@@@@@Parasuram@@@@@'+trn[0]);
                }
                }
                break;
            }
        }
        
        
    }
    public static list<Tran1__c> trn{set;get;}
   
    @remoteAction
    public static list<Tran1__c> getPlanInfo(String ItemCode, String Accountingid) {
        System.debug('getPlanInfo:planId::::' + ItemCode);
    
   // AccountAcount__c Ac=[select id,frs__c from AccountAcount__c where id=:Accountingid];
        for(AccountMaster__c ActMaster:[select id,name,Field3__c from AccountMaster__c where Field3__c=:ItemCode])
            {
                
              trn=[Select TaxRate__c,ServiceRate__c,SpecialTax__c,InvoiceNoShowFlg__c,ActionType__c, Field7__r.Name, rtaxsts__c, profitt__c, profitnonetax__c, profit__c, noneaccount__c, inside__c, guestRoom__c, freetotal3__c, freetotal2__c, freetotal1__c, freeprice__c, freecost__c, VoidReceiptNo__c, TankawithoutTax__c, Tankanonetax__c, TableNo__c, Subprice__c, Seq__c, RowNo__c, RelAccount__c, POSNo__c, OPcode__c, GoukeinoneTax__c, Genkaritsu__c, Field9__c, Field8__c, Field7__c, Field6__c, Field5__c, Field52__c, Field51__c, Field50__c, Field4__c, Field49__c, Field48__c, Field47__c, Field46__c, Field45__c, Field44__c, Field43__c, Field42__c, Field41__c, Field40__c, Field3__c, Field39__c, Field38__c, Field37__c, Field36__c, Field35__c, Field34__c, Field33__c, Field32__c, Field31__c, Field30__c, Field2__c, Field29__c, Field28__c, Field27__c, Field26__c, Field25__c, Field24__c, Field23__c, Field22__c, Field21__c, Field20__c, Field1__c,    Field1__r.Name    ,Field19__c, Field18__c, Field17__c, Field16__c, Field15__c, Field14__c, Field13__c, Field12__c, Field11__c, Field10__c, DivisionNameI__c, Categorya__c, Category__c, CategoryItem__c, Accountoutside__c, SystemModstamp, Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CreatedDate, CreatedById From Tran1__c where Field7__c=:ActMaster.id];  //and Field1__c=:accountingid and RelAccount__c=:Ac.frs__c
                
            }
            
            System.debug('Tran1__c values ==='+trn);
        
        return trn;
        
    }
}