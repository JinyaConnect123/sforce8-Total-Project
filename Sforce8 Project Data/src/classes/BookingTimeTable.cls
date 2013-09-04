/**********************************
* 宴会場予約管理画面
* 2012/07/31 初版作成
* 2012/09/01 作業開始時間：9時から5時に変更する
* 2012/09/30 会場おさえ：ステータス追加の対応
***********************************/
public with sharing class BookingTimeTable {

    

        public List<Room__c>      room{get;private set;}                                          /* Room data    */
//      public List<Lead__c>      booking;                                                                                                        /* Booking data */
        public Lead__c            bookingform {get; set;}                                                                       /* For creating new Booking Data*/
//      public Lead__c            pbookingform;                                                                                         /* Previous Booking Form Data for Checkking Duplication */
//      public string             linkid {get; set;}                                                                            /* Created Booking Record Id */
//      public string             linkname {get; set;}                                                                          /* Created Booking Record Name */
        public List<integer>      hours;                                                                                                  /* Hours of Columns */
//      public integer            starthour {get; set; }                                                                        /* Hour of Start Column */
//      public integer            endhour {get; set; }                                                                          /* Hour of End Column */

        private DateTime   beginBusinessTime;
        private DateTime   endBusinessTime;
        //public String beginBusinessHm{get; private set;}
        //public String endBusinessHm{get; private set;}
        // 時間設定アリアに情報を維持する
        public Map<Id, OneRoomAssingInfo> roomBookingMap{get;private set;}
        private static final String ROOM_TYPE_PTY = CommConst.ROOM_UseOfType_PTY;
        private static final Integer CONST_BUSNIESS_TIME = 5;
        // 到着日
        private date               cdate;
    // 当日のDataId
    private final String bookingTimeTbId;
    // 当日のタイムテーブル情報
    public final BookingTimeTable__c currSobj{get; private set;}
        
        public BookingTimeTable(ApexPages.StandardController stdController){
                // タイムテーブルのID
                bookingTimeTbId = stdController.getId();
                // 到着日情報を取得する
                currSobj = [select Id, Name, Checkinday__c from BookingTimeTable__c where Id = :stdController.getId() limit 1];
                cdate = currSobj.Checkinday__c;
                // 宴会ルーム情報を取得する
                room = [select Id, Name, UseOfRoom__c, Seq__c from Room__c where UseOfRoom__c =: ROOM_TYPE_PTY order by Seq__c];

        // 入りフォーム情報を初期化する
        initBookingFormInfo();

        // 営業開始時間から営業終了時間設定を行う
        beginBusinessTime = DateTime.newInstance(cdate,Time.newInstance(CONST_BUSNIESS_TIME, 0, 0, 0));
        endBusinessTime = beginBusinessTime.addHours(24);

        // 既にアサイン済み時間を画面に表示するの設定
        refreshTimePanel();
        }
        // 初期化処理
    public BookingTimeTable() {
        // 初期化選択条件
        selectDate = new BookingTimeTable__c();

        // 当日の情報を表示する
        cdate = Date.today();
        // 宴会ルーム情報を取得する
        room = [select Id, Name, UseOfRoom__c, Seq__c from Room__c where UseOfRoom__c =: ROOM_TYPE_PTY order by Seq__c];

        // 入りフォーム情報を初期化する
        initBookingFormInfo();

        // 日付関連項目を一括設定する
        setDateField(cdate);
    }

    // ボタン「翌日」の処理
    public void toNext(){
        cdate = cdate.addDays(1);
        setDateField(cdate);
        refreshTimePanel();
    }
    // ボタン「翌週」の処理
    public void toNextWeek(){
        cdate = cdate.addDays(7);
        setDateField(cdate);
        refreshTimePanel();
    }
    public void toToday() {
        cdate = Date.today();
        setDateField(cdate);
        refreshTimePanel();
    }
    // ボタン「前週」の処理
        public void toPrevWeek() {
                cdate = cdate.addDays(-7);
                setDateField(cdate);
                refreshTimePanel();
        }
    // ボタン「前日」の処理
    public void toPrev(){
        cdate = cdate.addDays(-1);
        setDateField(cdate);
        refreshTimePanel();
    }
    public BookingTimeTable__c selectDate{get; private set;}
    // 年/月/日を選択する場合
    public void gotoDate() {
        cdate = selectDate.Checkinday__c;
        setDateField(cdate);
        refreshTimePanel();
    }
    // 業務ロジック関連日付設定を行う
    private void setDateField(Date currDate) {
        // 検索条件：日付連動設定
        selectDate.Checkinday__c = currDate;
        // 営業開始時間から営業終了時間設定を行う
        beginBusinessTime = DateTime.newInstance(currDate,Time.newInstance(CONST_BUSNIESS_TIME, 0, 0, 0));
        endBusinessTime = beginBusinessTime.addHours(24);
    }

        // 部屋一覧を取得する
        public List<Room__c> getRoom(){                                                                                           /* Get Room data */
                return room;
        }

        // 最新時間設定表示を最新化を行う
        public void refreshTimePanel() {

                roomBookingMap = new Map<Id, OneRoomAssingInfo>();
                for (Room__c r: room) {
                        roomBookingMap.put(r.Id, new OneRoomAssingInfo(beginBusinessTime, endBusinessTime, roomBookingMap.size()));
                }
                // 既に登録済みの時間を取得する
                Set<Id> leadIdSet = new Set<Id>();
        List<Lead__c> booking = [select Id, Name, Relcontact__c, Rroom__c, Rroom__r.Name, Rroom__r.Seq__c, StayPersons__c,
                    EntryTime__c,Departure__c,ReservedStatus__c,
                    Field310__c, Field2__c, Field4__c, Field3__c, Field363__c
                    from Lead__c
                    where ReservationDate__c = :cdate
                    and CancelBool__c != :CommConst.LEAD_ST_CANCEL_FLG         // キャンセルデータは対象外
                    and Rroom__c != null and Rroom__r.UseOfRoom__c =: ROOM_TYPE_PTY order by Rroom__r.Seq__c];
        for (Lead__c lead: booking) {
                // 存在する場合
                if (roomBookingMap.containsKey(lead.Rroom__c)) {
                OneRoomAssingInfo roomAss = roomBookingMap.get(lead.Rroom__c);
                roomAss.assingLeadInfo(lead);
                } else {
                        OneRoomAssingInfo roomAss = new OneRoomAssingInfo(beginBusinessTime, endBusinessTime, roomBookingMap.size());
                        roomAss.assingLeadInfo(lead);
                        roomBookingMap.put(lead.Rroom__c, roomAss);
                }
                leadIdSet.add(lead.Id);
        }
        // 20121003 ADD 会計情報を取得する
        // 顧客ID/会計ID
        Map<Id, Id> leadAccRefMap = new Map<Id, Id>();
        // １予約->1会計（基本：1->N存在可能性があり（操作ルール違反）も対応：最新作成の会計は使用する）
        for (AccountAcount__c acc : [select id, relaccount__c from AccountAcount__c where Relreserve__c in :leadIdSet And relaccount__c != null order by LastModifiedDate desc ]) {
            if (leadAccRefMap.containsKey(acc.relaccount__c)) continue;
            leadAccRefMap.put(acc.relaccount__c, acc.id);
        }

        // 会計情報は各InnerClassに引き渡す
        if (!leadAccRefMap.isEmpty()) {
                for (OneRoomAssingInfo oneRoom : roomBookingMap.values()) {
                        oneRoom.assingAccountInfo(leadAccRefMap);
                }
        }
        }

        public List<Integer> getHours(){                                                                                                  /* List of Hours */
                hours = new List<Integer>();
                for (Datetime dt = beginBusinessTime; dt < endBusinessTime;) {
            hours.add(dt.hour());
            dt = dt.addHours(1);
                }
                return hours;
        }

        public PageReference bookingCreate() {                                                                                          /* Save New Booking Record */
        try{
            // yyyy-mm-dd hh:mm
            String s = bookingform.Field4__c + ':00';
            String e = bookingform.Field3__c + ':00';

            bookingform.Field4__c = bookingform.Field4__c.subString(11,16);
            bookingform.Field3__c = bookingform.Field3__c.subString(11,16);

            bookingform.EntryTime__c = DateTime.valueOf(s);//datetime.newInstance(cdate,time.newInstance(Integer.valueOf(beginHH),Integer.valueOf(beginMM),0,0));
            bookingform.Departure__c = DateTime.valueOf(e);//datetime.newInstance(cdate,time.newInstance(Integer.valueOf(endHH),Integer.valueOf(endMM),0,0));
                        // 予約ステータス初期値設定[確定]
                        bookingform.ReservedStatus__c = CommConst.LEAD_ST_CHECKED;
                        // 予約確認の方
                        bookingform.Field357__c = UserInfo.getName();
                        // 予約確認済み
                        bookingform.Field356__c = true;
            insert bookingform;
        } catch (Exception e) {
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the object or try again later');
                        ApexPages.addMessage(errormsg);
                        System.debug('Create Error:' + e.getMessage());
                        return null;
        }

        // 入りフォーム情報を初期化する
                initBookingFormInfo();
                // 2012/09/12 Add
                setDateField(cdate);
        // 最新表示情報を作成する
                refreshTimePanel();

                return null;
        }
        public void initBookingFormInfo() {
        bookingform = new Lead__c();
        bookingform.ReservedDate__c = datetime.now();
        bookingform.RecordTypeId = CommLogicProcess.getLeadEnkaiRecType();
        bookingform.StayPersons__c = 2;
        bookingform.ReservedType__c = '宴会';
        }

        // １部屋24時間アサイン情報
        public class OneRoomAssingInfo {
                // 部屋名
                //public String roomName{get;set;}

                //List<TimeAssignInfo> timeAssingList {get; private set;}
                // 2012/09/12 Status Color Class Add
                // 確認中
                private final String STATUS_CHECKING_STYLE_CLS = 'comfirmStatus';
                // 確認
                private final String STATUS_CHECKED_STYLE_CLS = 'comfirmedStatus';
                // 仮予約
                private final String STATUS_CHECKING_TENTAIVE_CLS = 'tmpBookinged';
                // 会場おさえ
                private final String STATUS_PARTYROOM_BOOKING_CLS = 'partyroomBook';
        // 予約開始時間と終了時間
        private Map<DateTime, DateTime> assingedTimeMap;
        private Map<DateTime, Lead__c> assingedLeadMap;
        private Map<Id, Id> assingedAccMap;

        // 営業開始時間と終了時間
        private DateTime beginBusinessTime;
        private DateTime endBusinessTime;
        //private Room__c roomInfo;
        private Integer rowIndex;

                public OneRoomAssingInfo(DateTime pBeginBusinessTime, DateTime pEndBusinessTime, Integer pRowIndex) {
                        beginBusinessTime = pBeginBusinessTime;
                        endBusinessTime = pEndBusinessTime;
                        assingedTimeMap = new Map<DateTime, DateTime>();
                        assingedLeadMap = new Map<DateTime, Lead__c>();
                        assingedAccMap = new Map<Id, Id>();
                        //roomInfo = pRoomInfo;
                        rowIndex = pRowIndex;
                }
                // 初期化を行う
                public void assingLeadInfo(Lead__c pLead) {
                        if (pLead.EntryTime__c != null && pLead.Departure__c != null) {
                                DateTime beginTimeKey = pLead.EntryTime__c < beginBusinessTime ? beginBusinessTime : pLead.EntryTime__c;

                                beginTimeKey = getCalTimeDate(beginTimeKey, pLead.Field4__c);
                                DateTime endTimeKey = pLead.Departure__c > endBusinessTime ? endBusinessTime : pLead.Departure__c;
                endTimeKey = getCalTimeDate(endTimeKey, pLead.Field3__c);
                                assingedTimeMap.put(
                                    beginTimeKey,
                    endTimeKey);
                assingedLeadMap.put(
                        beginTimeKey,
                        pLead);
                        }
                }
                // 20121003: ADD 会計情報を設定する
                public void assingAccountInfo(Map<Id, Id> pAccMap) {
                        assingedAccMap = pAccMap;
                }

                // orgDateTime: DateTime: hmTime→HH:mm
                private DateTime getCalTimeDate(DateTime orgDateTime, String hmTime) {
            Integer hh = (hmTime.length() == 4 ? Integer.valueOf(hmTime.substring(0,1)) : Integer.valueOf(hmTime.substring(0,2)));
            Integer mm = (hmTime.length() == 4 ? Integer.valueOf(hmTime.substring(2,4)) : Integer.valueOf(hmTime.substring(3,5)));
            if (hh >= 24) { hh = hh - 24; orgDateTime = orgDateTime.addDays(1);}
            return DateTime.newInstance(orgDateTime.date(), Time.newInstance(hh, mm, 0, 0));
                }
                
           public String tdHtml{get{
                        // 時間SORTする
                        //Value=new list<String>();
            String tdStr = '';
            for (Datetime dt = beginBusinessTime; dt < endBusinessTime;) {
                // 既に予約済み場合
                // 共通情報
                tdStr +='<td rowIndex="' + rowIndex + '" colTime = "' + dt.format('yyyy-MM-dd HH:mm') ;
                tdStr +='" style="border-right:dotted 1px #CCC; width: 9px; height: 30px;border-top:solid 1px #777;';
                if (dt.minute() == 0) tdStr += ' border-left:solid 1px #BBB;"';
                else tdStr +='"';

                if (assingedTimeMap.containsKey(dt)) 
                {
                        DateTime endTime = assingedTimeMap.get(dt);
                        Long intst = dt.getTime();
                        Long inted = endTime.getTime();
                        // 10分単位数
                        Long diffMinutes = (inted - intst) / 1000 / 60 / 10;
                        // 予約情報を維持する
                        Lead__c plead = assingedLeadMap.get(dt);
                        // Div Class add
                        String styleCls = '';
                        if (plead.ReservedStatus__c == CommConst.LEAD_ST_CANDEL_WAIT) {
                                // [キャンセルまち]
                                styleCls = STATUS_CHECKING_STYLE_CLS;
                        } else if (plead.ReservedStatus__c == CommConst.LEAD_ST_CHECKED) {
                                // 確認
                                styleCls = STATUS_CHECKED_STYLE_CLS;
                        } else if (plead.ReservedStatus__c == CommConst.LEAD_ST_TENTAIVE) {
                                // 仮予約
                                styleCls = STATUS_CHECKING_TENTAIVE_CLS;
                        } else if (plead.ReservedStatus__c == CommConst.LEAD_ST_ENKAIBOOK) {
                                // 会場おさえ
                                styleCls = STATUS_PARTYROOM_BOOKING_CLS;
                        }
                        tdStr += ' class="ui-selected ' + styleCls + '" colspan="' + diffMinutes + '" ';
                    // 会計データが存在する場合
                    String accDivHtml = '';
                    if (assingedAccMap.containskey(plead.Relcontact__c)) {
                        accDivHtml += '<div style="float:right"><a href="javascript:void(0);" onclick="window.open(\'/'+ assingedAccMap.get(plead.Relcontact__c) + '\')" ><img src="/img/icon/bank32.png" class="imgstyle" title="会計" /></a></div> ';
                    }
                                        String containDiv = '<div class="timeAssignedTd"  style="width: 100%">';
                                        String linkUrl = '<a target="_blank" onclick="window.open(\'/' + plead.id + '\')" href="javascript:void(0);" id="' +plead.id+ '" onblur="LookupHoverDetail.getHover(\'' +plead.id+  '\').hide();" onfocus="LookupHoverDetail.getHover(\'' + plead.id + '\', \'/' + plead.id +  '/m?retURL=%2F'+ plead.id + '&isAjaxRequest=1\').show();" onmouseout="LookupHoverDetail.getHover(\''+ plead.id + '\').hide();" onmouseover="LookupHoverDetail.getHover(\''+ plead.id + '\', \'/'+ plead.id + '/m?retURL=%2F'+ plead.id + '&isAjaxRequest=1\').show();">' + plead.name + '</a>';
                                        tdStr +='> ' + containDiv +linkUrl+ accDivHtml + ' </div></td>';
                        // 次の処理を行う
                        dt = endTime;
                }
                // 空白場合
                else {
                        // 時間は0分場合
                        //if (dt.minute() == 0) tdStr += ' class="oneHourPanel" ';
                        //else tdStr += ' class="oneHourPanel" ';
                        tdStr += ' class="oneHourPanel" ';
                        // 10分単位、TD作成する、既に予約済み場合、TDはcolspanに変更する
                        dt = dt.addMinutes(10);

                        tdStr +='> &nbsp; </td>';
                }
                //colIndex++;
                //tdStr +='> &nbsp; </td>';
            }
            system.debug('@@@'+tdStr);
            return tdStr;
                }}
        }

        static testMethod void testBookingTimeTable(){  /* Testmethod of BookingTimeTable */

                Room__c roomtest = new Room__c(Name = 'Test', UseOfRoom__c = ROOM_TYPE_PTY, Seq__c = 1, CapacityHaku__c = 0, Capacity__c = 80, heyadashiryou__c = 20000, heyadashiryouryou__c = 20000);
                insert roomtest;
                Date curDay  = Date.today();
                DateTime startDate = DateTime.newInstance(curDay.addDays(30), Time.newInstance(0, 0, 0, 0));
//              Lead__c bookingtest = new Lead__c(Name = 'TestBooking', Morningfood__c = true, room1__c = 20000, EntryTime__c = datetime.now(), ReservedDate__c = datetime.now(), Rroom__c = roomtest.Id);
                Lead__c bookingtest = new Lead__c(
                   name = '予約単体テスト_UNIT_TEST_LEAD' + System.now(), // 予約名
           Relcontact__c = TestCommon.createContact().Id,                  // 顧客名
           ReservedStatus__c = '確認中',
           ReservedDate__c = System.now(),
           ReservedContact__c = 'Ono',
           EntryTime__c = startDate,
           Field4__c = '15:30',
           Departure__c = startDate.addDays(1),
           Field3__c = '10:00',
           StayPersons__c = 4,
           Field2__c = 'FAX',
           Rroom__c = roomtest.Id);
                insert bookingtest;
                BookingTimeTable__c btttest = new BookingTimeTable__c(Checkinday__c = bookingtest.EntryTime__c.date());
                insert btttest;

                OP__c opothertest = new OP__c(Name = 'その他');
                insert opothertest;
                AccountMaster__c amtest = new AccountMaster__c(OP__c = opothertest.Id);
                insert amtest;
                BookingEstimateItem__c beifoodtest  = new BookingEstimateItem__c(refBooking__c = bookingtest.Id, refAccountMaster__c = amtest.Id);
                insert beifoodtest;

                BookingTimeTable btt = new BookingTimeTable();
                btt.selectDate.Checkinday__c = bookingtest.EntryTime__c.date();
                btt.gotoDate();
                System.assertEquals(btt.cdate, bookingtest.EntryTime__c.date());

                List<Room__c>     wgetRoom                = btt.getRoom();
//              Object[]                wgetBookingData = btt.getBookingData();
//              Object[]                wgetRoomData    = btt.getRoomData();

        for (OneRoomAssingInfo obj: btt.roomBookingMap.values()) {
                System.assertNotEquals(obj.tdHtml, null);
        }
                List<integer>     wgetHours               = btt.getHours();
                btt.refreshTimePanel();
                PageReference   wbookingCreate  = btt.bookingCreate();
                btt.toNext();
                btt.toPrev();
                btt.toToday();

                BookingTimeTable btt2 = new BookingTimeTable(new ApexPages.StandardController(btttest));
                
        }
}