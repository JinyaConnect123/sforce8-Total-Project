/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestCommon {

    // 売上情報を作成する
    public static RsvAccount__c createRsvAccount() {
    	RsvAccount__c item = new RsvAccount__c();
    	item.name = '20120101';
    	insert item;
    	return item;
    }
    // 仕入[調理]
    public static Purchase__c createPurchase() {
    	Purchase__c item = new Purchase__c();
    	item.JinyaRevenue__c = createRsvAccount().id;
    	item.Denpyoukei__c = 12000;
    	insert item;
    	return item;
    }
    // 予約情報を作成する
    public static Lead__c createLead() {
    	Date curDay  = Date.today();
    	DateTime startDate = DateTime.newInstance(curDay.addDays(10), Time.newInstance(0, 0, 0, 0));
    	LeadIndex__c leadIndex = createLeadIndex(3, startDate, startDate.addDays(1));
    	// 連泊データを自動作成
    	Lead__c item = new Lead__c(
    	   RecordTypeId = CommLogicProcess.getLeadBookingRecType(),
    	   name = '予約単体テスト_UNIT_TEST_LEAD' + System.now(), // 予約名
    	   Relcontact__c = createContact().Id,                  // 顧客名
    	   ReservedStatus__c = '確認中',
    	   ReservedDate__c = System.now(),
    	   ReservedContact__c = 'Ono',
    	   EntryTime__c = startDate,
    	   Field4__c = '15:30',
    	   Departure__c = startDate.addDays(1),
    	   Field3__c = '10:00',
    	   StayPersons__c = 4,
    	   Field2__c = 'FAX',
    	   LeadIndexRef__c = leadIndex.Id,
    	   Rroom__c = createRooms().Id);
    	insert item;
    	return item;
    }
    public static LeadIndex__c createLeadIndex(Integer nights, DateTime s, DateTime e ) {
    	LeadIndex__c item = new LeadIndex__c(
    		ID__c = String.valueOf(Math.random()),
    		Nights__c = nights,
     		EntryTime__c = '10:00',
    		EntryDate__c = s.date(),
    		DepartureTime__c = '15:30',
    		DepartureDate__c = e.date(),
			EventSource__c = 'テストクラスから',
			Rooms__c = 1
    	);
    	insert item;
    	return item;
    }
    public static Contact createContact() {
    	Contact item = new Contact(
    		firstName = 'UNIT_TEST_顧客名' + System.now(),
    		LastName = 'LASTNAME');
    	insert item;
    	return item;
    }

    public static Room__c createRooms() {
    	Room__c item = new Room__c(
    		Name = '部屋テストUNIT_VIP_TEST',
    		CapacityHaku__c = 4,
    		Capacity__c = 2,
    		Area__c = '本館',
    		Floor__c = '1F',
    		UseOfRoom__c = '客室',
    		heyadashiryouryou__c = 40000,
    		heyadashiryou__c = 25000);
		insert item;
		return item;
    }

    // 見積明細
    public static BookingEstimateItem__c createBookEstItem(Lead__c leadInfo, AccountMaster__c prod) {
        BookingEstimateItem__c item = new BookingEstimateItem__c (
           //Name = '名称2(漢1)_UNIT_TEST_AUTONUM_' + system.now(),
           Amount__c = 4,
           refBooking__c = leadInfo.id,
           refAccountMaster__c = prod.Id,      // 商品名
           Field3__c = prod.Field3__c         // 商品コード
        );
        insert item;
        return item;
    }

    // 会計商品
    public static List<AccountMaster__c> createProductMst(Integer intNum) {
    	List<AccountMaster__c> insLst = new List<AccountMaster__c>();
    	JMST__c taxMst =  createTaxMst();
        for (Integer i =0; i < intNum; i++) {
	        AccountMaster__c item = new AccountMaster__c(
	           Name = '名称2(漢1)UNIT_TEST' + i,
	           jmstRef__c = taxMst.Id,
	           StsTaxfee__c = '0',
	           Field3__c = 'UNIT_TPD' + i,         // 商品コード
	           Field5__c = 1050,
	           ServiceRate__c = 10,
	           SpecialTax__c = 100
	        );
        	insLst.add(item);
        }
        insert insLst;
        return insLst;
    }
    // 税金マスた
    public static JMST__c createTaxMst() {
    	JMST__c item = new JMST__c(
    	   TaxRate__c = 5
    	);
    	insert item;
    	return item;
    }

    // レポートロゴ
    public static ReportLogo__c createRepLogo() {
    	ReportLogo__c item = new ReportLogo__c();
    	item.name = CommRepUtils.REP_TYPE.LOGO_00_SYSDEF.name();
    	item.ReportLogo__c = 'ImagePiciure';
    	insert item;
    	return item;
    }

    public static Plan__c createPlan() {
    	Plan__c plan = new Plan__c();
    	plan.name = 'テストプランデータ';
    	plan.PlanNo__c = '700001';
    	plan.Price__c = 35000;
    	insert plan;
    	return plan;
    }

}