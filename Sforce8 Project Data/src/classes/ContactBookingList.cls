/**
* 顧客に所属する予約データ一覧を表示する・一括キャンセル・一括チェックアウト
**/
public with sharing class ContactBookingList {

	/**
	* 検索条件変数定義する
	**/
	// 表示表示範囲日付（From）
	public String c_fromSearchDate{get;set;}
	public String c_toSearchDate{get;set;}
	// 過去データ表示フラグ
	public Boolean c_showHistoryFlg{get;set;}
	public Boolean topMsgShowFlg{get;set;}
	private String contactId;
	private List<BookingItem> leadInfoLst = new List<BookingItem>();
 	public ContactBookingList(ApexPages.StandardController stdController) {
        contactId = stdController.getId();
        initParameter();
        setQueryRsList();
    }
    private void initParameter() {
    	// 照会日付範囲はと今年から１年間予約データを表示する
    	DateTime nowTime = DateTime.now();
    	c_fromSearchDate = nowTime.format('yyyy/MM/dd');
    	c_toSearchDate = nowTime.addYears(1).format('yyyy/MM/dd');
    	c_showHistoryFlg = false;
    	topMsgShowFlg = false;
    	cancelSeason = 'キャンセル対応　' + UserInfo.getName();
    }

    // 検索条件有効性チェックを行う
    private Boolean preSetQueryRsList() {
    	try {
			Date dtfromSearchDate = Date.parse(c_fromSearchDate);
			Date dttoSearchDate = Date.parse(c_toSearchDate);
    	} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '有効な日付を入力ください。'));
    		return false;
    	}
    	return true;
    }
    /**
    * 200件まで明細データを表示する
    **/
	public void setQueryRsList() {
		// 既存の検索結果をクリアする
		leadInfoLst.clear();
		// 有効性チェックを行う
		if (!preSetQueryRsList()) {
			topMsgShowFlg = true;
			return;
		} else topMsgShowFlg = false;
		// 該当ユーザーに関連付け予約一覧リストを取得する
		// 予約ステータス And お客様ステータス:
		//Date todayDt = Date.today();
		Date dtfromSearchDate = Date.parse(c_fromSearchDate);
		Date dttoSearchDate = Date.parse(c_toSearchDate);

		String strQuery = strSelect + createWhere() + createOrder();
//System.debug('strQuery: ' + strQuery);
//System.debug('contactId:' + contactId);
//System.debug('dtfromSearchDate:' + dtfromSearchDate);
//System.debug('dttoSearchDate:' + dttoSearchDate);
		for (Lead__c leadItem: Database.query(strQuery)) {
			BookingItem item = new BookingItem(leadItem);
			leadInfoLst.add(item);
		}
	}
	/**
	* 一括予約キャンセル処理成功を行う
	**/
	// キャンセル理由
	public String cancelSeason{get; set;}
	public void batchCancelProc() {
//System.debug('batchCancelProc:Reason:' + cancelSeason);

		// 選択対応データから、ステータス更新を行う
		List<Lead__c> updList = new List<Lead__c>();
		for (BookingItem item: leadInfoLst) {
			// 非選択されている場合、SKIPする
			if (!item.isSelected) continue;
			// すでにキャンセル済みデータは対象外
			if (item.sobj.CancelBool__c == CommConst.LEAD_ST_CANCEL_FLG) continue;
			// 顧客データステータスはチェッキン完了またはチェックアウト場合、対象外？
			// TODO?
			// キャンセルステータスを設定を行う
			item.sobj.ReservedStatus__c = CommConst.LEAD_ST_CANCEL;
			// 特記事項にキャンセル理由を追加する
// System.debug('cancelSeason:' + cancelSeason);
			item.sobj.Comment3__c = CommUtils.nullToBlank(item.sobj.Comment3__c) + '\n' + cancelSeason;
			updList.add(item.sobj);
		}
		// 更新処理を行う
		try {
// System.debug('updList:' + updList);
			update updList;
		} catch (Exception e) {
			System.debug(e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
		// 最新情報を取得する
		this.setQueryRsList();
	}
	/**
	* 一括チェックアウト処理を行う
	**/
	public void batchCheckoutProc() {
		// 選択対応データから、ステータス更新を行う
		List<Lead__c> updList = new List<Lead__c>();
		for (BookingItem item: leadInfoLst) {
			// 非選択されている場合、SKIPする
			if (!item.isSelected) continue;
			// すでにキャンセル済みデータは対象外
			if (item.sobj.CancelBool__c == CommConst.LEAD_ST_CANCEL_FLG) continue;
			// 顧客データステータスはチェッキン完了またはチェックアウト場合、対象外？
			if (item.sobj.Field298__c == CommConst.LEAD_GUEST_ST_CO) continue;
			// TODO?
			// お客様ステータスにチェックアウトを設定する
			item.sobj.Field298__c = CommConst.LEAD_GUEST_ST_CO;
			updList.add(item.sobj);
		}
		// 更新処理を行う
		try {
			update updList;
		} catch (Exception e) {
			System.debug(e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
		// 最新情報を取得する
		this.setQueryRsList();
	}

	public List<BookingItem> getLeadInfoLst() {
		return this.leadInfoLst;
	}
	private final String strSelect = 'select id, name, CancelBool__c, Field372__c,checkoutdate__c,ReservedStatus__c, Field298__c,Receptiondate__c,refTypeOfRooms__c,StayPersons__c from Lead__c ';
	/**
	* 画面検索条件を作成する
	**/
	private String createWhere() {
		String strWhere = ' Where Relcontact__c = :contactId ';
		if (!CommUtils.isBlank(c_fromSearchDate)) strWhere+= ' And DAY_ONLY(convertTimezone(EntryTime__c)) >= :dtfromSearchDate ';
		if (!CommUtils.isBlank(c_toSearchDate)) strWhere+= ' And DAY_ONLY(convertTimezone(EntryTime__c)) <= :dttoSearchDate ';
		// すべてデータを表示する場合
		if (!c_showHistoryFlg) strWhere+= ' And CancelBool__c != ' + CommConst.LEAD_ST_CANCEL_FLG;
		return strWhere;
	}
	/**
	* 並び順情報を取得する
	**/
	private String createOrder() {
		String strOrder = ' Order By EntryTime__c asc limit 200 ';
		return strOrder;
	}

	public class BookingItem {
		public 	BookingItem(Lead__c psobj) {
			sobj = psobj;
			isSelected = false;
		}
		// 予約情報格納する
		public Lead__c sobj{get; private set;}
		public Boolean isSelected{get; set;}
	}

	/**
	* 有効性チェックを行う
	**/
	static testMethod void testCase1() {
		Lead__c lead1 = TestCommon.createLead();
		Contact refContact = [select id from Contact where id =:lead1.Relcontact__c];
		ApexPages.StandardController scontrol = new ApexPages.StandardController(refContact);
		// 一括キャンセル処理を行う
		ContactBookingList ctrl = new ContactBookingList(scontrol);
		ctrl.c_fromSearchDate = '1A';
		ctrl.c_toSearchDate = '2C';
		ctrl.batchCheckoutProc();
		ctrl.batchCancelProc();
		System.assert(ctrl.getLeadInfoLst() != null);
	}
	static testMethod void testCase2() {
		Lead__c lead1 = TestCommon.createLead();
		Contact refContact = [select id from Contact where id =:lead1.Relcontact__c];
		ApexPages.StandardController scontrol = new ApexPages.StandardController(refContact);
		// 一括キャンセル処理を行う
		ContactBookingList ctrl = new ContactBookingList(scontrol);
		List<ContactBookingList.BookingItem> rs = ctrl.getLeadInfoLst();
		rs[0].isSelected = true;
		ctrl.batchCheckoutProc();
		rs = ctrl.getLeadInfoLst();
		rs[0].isSelected = true;
		ctrl.batchCancelProc();
		System.assert(ctrl.getLeadInfoLst() != null);
	}
}