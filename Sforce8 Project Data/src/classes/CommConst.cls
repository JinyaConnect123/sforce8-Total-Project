public class CommConst {

	// トリガー
	public Enum TriggerMethod {IsInsert, IsUpdate, IsDelete, IsUnDelete}

	/*************************
	* 会計画面に利用している定数
	*************************/
	// 取引種別
	public static final String ACC_TRADE_NORMAL = '00';   // 売上（通常）
	public static final String ACC_TRADE_VOID = '30';   // ＶＯＩＤ
	// 会計支払方式
	public static final String MEDIA_TYPE_01 = '預り／現計';
	public static final String MEDIA_TYPE_CD_01 = '01';
	public static final String MEDIA_TYPE_02 = 'ｸﾚ計・掛計等';
	public static final String MEDIA_TYPE_CD_02 = '02';
	public static final String MEDIA_TYPE_03 = '掛計';
	public static final String MEDIA_TYPE_CD_03 = '03';
	public static final String MEDIA_TYPE_11 = 'クーポン';
	public static final String MEDIA_TYPE_CD_11 = '11';
	public static final String MEDIA_TYPE_12 = '値引・割引券';
	public static final String MEDIA_TYPE_CD_12 = '12';
	public static List<Selectoption> getPayMentTypeOptLst() {
		List<Selectoption> optLst = new List<Selectoption>();
		optLst.add(new SelectOption(MEDIA_TYPE_CD_01,MEDIA_TYPE_01));
		optLst.add(new SelectOption(MEDIA_TYPE_CD_02,MEDIA_TYPE_02));
		optLst.add(new SelectOption(MEDIA_TYPE_CD_03,MEDIA_TYPE_03));
		optLst.add(new SelectOption(MEDIA_TYPE_CD_11,MEDIA_TYPE_11));
		optLst.add(new SelectOption(MEDIA_TYPE_CD_12,MEDIA_TYPE_12));
		return optLst;
	}
	public static String getPaymentTypeLabelByKey(String key) {
		if (key == MEDIA_TYPE_CD_01) return MEDIA_TYPE_01;
		else if (key == MEDIA_TYPE_CD_02) return MEDIA_TYPE_02;
		else if (key == MEDIA_TYPE_CD_03) return MEDIA_TYPE_03;
		else if (key == MEDIA_TYPE_CD_11) return MEDIA_TYPE_11;
		else if (key == MEDIA_TYPE_CD_12) return MEDIA_TYPE_12;
		return null;
	}
    /*************************
    * 会計商品マスた関連定数
    *************************/
    // 商品処理種別：前受付金(AdvancesReceived)
    public static final String PROD_ACTION_TYPE_AR = '前受付金';
    public static final String PROD_ACTION_TYPE_RP = '室料';
    public static final String PROD_ACTION_TYPE_PL = 'プラン';
	// 宿泊税
	// 宿泊料金1人1泊  １万円以上１万５千円未満の宿泊　１００円 １万５千円以上の宿泊　２００円*/
	public static final Integer ROOM_TAX_MONEY_LEV1 = 10000;
	public static final Integer ROOM_TAX_MONEY_LEV2 = 15000;
    /*************************
    * 予約ステータス
    *************************/
    public static final String LEAD_ST_CHECKING='確認中';
    public static final String LEAD_ST_CHECKED='確定';
    public static final String LEAD_ST_TENTAIVE='仮予約';
    public static final STRING LEAD_ST_ENKAIBOOK = '会場おさえ';
    public static final String LEAD_ST_NOSHOW = 'NO SHOW';
    public static final String LEAD_ST_CANCEL = 'キャンセル';
    public static final String LEAD_ST_DELETE = '削除';
    public static final String LEAD_ST_CANDEL_WAIT='キャンセルまち';
    public static final Integer LEAD_ST_CANCEL_FLG = 1;

    /*************************
    * お客様ステータス
    *************************/
    public static final String LEAD_GUEST_ST_CI = 'チェックイン完';
    public static final String LEAD_GUEST_ST_CO = 'チェックアウト完';
    public static final String LEAD_GUEST_ST_OUT = '外出中';
    public static final String LEAD_GUEST_ST_BATH = '入浴中';
    /*************************
    * お部屋ステータス
    *************************/
    public static final String LEAD_ROOM_ST_UNCLEAN = '未清掃';
	public static final String LEAD_ROOM_ST_CLEANED = '清掃済';

    /*************************
    * 部屋タイプ処理種別
    *************************/
    public static final String ROOMTYPE_NORMAL = '通常';
    public static final String ROOMTYPE_EB = 'E/B';


    /*************************
    * アプリ機能起動OPTION
    *************************/
    // E/B機能起動OPTION
    public static Boolean APPOPTION_ISUSR_EB{get{
        return CommDefine__c.getOrgDefaults().RoomUseEbFlg__c != true ? false : true;
    }}
    public static String APPOPTION_ROOMTYPE_REPNM{get{
    	return CommDefine__c.getOrgDefaults().RoomTypeReport__c == null ? '$0001 客室タイプ別予約表' : CommDefine__c.getOrgDefaults().RoomTypeReport__c;
    }}
    // プラン商品コードの頭数字
    public static Integer APPOPTION_PLANPRODCD_PREFIX_NUM{get{
    	return CommDefine__c.getOrgDefaults().PlanProdCdPrefixNum__c == null ? 5 : CommDefine__c.getOrgDefaults().PlanProdCdPrefixNum__c.intValue();
    }}
    // POSレジ
    public static String APPOPTION_POST_REG{get{
    	return CommDefine__c.getOrgDefaults().Posreg__c == null ? '0' : CommDefine__c.getOrgDefaults().Posreg__c;
    }}

    // 商品単価定義区分
    // public static Integer APPOPTION_UTP_DEF_KB = CommDefine__c.getInstance().UnitPriceDefKb__c == null ? 1 : CommDefine__c.getInstance().UnitPriceDefKb__c.intValue();
    // 1:税込、サービス料抜き
    public static Integer APPOPTION_UTP_DEF_KB_OP1 = 1;
    // 2:税込、サービス料込
    public static Integer APPOPTION_UTP_DEF_KB_OP2 = 2;
    // 3:税抜、サービス料抜き
    public static Integer APPOPTION_UTP_DEF_KB_OP3 = 3;

    // 1:単価（税抜き）ベースで商品合計計算を行う
    public static Integer APPOPTION_UTP_DEF_KB_TY1 = 1;
    // 2:単価（税込）ベースで商品合計計算を行う
    public static Integer APPOPTION_UTP_DEF_KB_TY2 = 2;
    /*************************
    * 予約ポップ、残室限界値の設定、残室数はこの数により以下の場合、予約できないよう、制限を行う
    *************************/
    public static final Integer VACANT_MIN_ROOMS = 5;

    /*************************
    * バッチ処理ステータス定数
    *************************/
    // 0:未処理
    public static final String BAT_STATUS_NOSTART = '0';
    // 1:処理待
    //public static final String BAT_STATUS_WAIT = '1';
    // 2:処理中
    //public static final String BAT_STATUS_PROCESSING = '2';
    // 3:処理済(成功)
    public static final String BAT_STATUS_PROCESS_OK = '3';
    // 9:処理済(失敗)
    public static final String BAT_STATUS_PROCESS_NG = '9';

    /*************************
    * 部屋のタイプリスト：客室/広間/レストラン/その他/Time/宴会場
    *************************/
    public static final String ROOM_UseOfType_Guest = '客室';
	public static final String ROOM_UseOfType_PTY='宴会場';

    /*************************
    * 部屋ステータス
    *************************/
    public static final String ROOM_ST_TYPE_BED = '故障';
}