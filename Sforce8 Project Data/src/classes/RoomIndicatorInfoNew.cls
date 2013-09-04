public with sharing class RoomIndicatorInfoNew{

    public boolean refreshPage{set;get;}
    public pagereference LeadMove()
    {
        refreshPage=false;
        try{
            string leadid=apexpages.currentpage().getparameters().get('Leadid');
            String RoomId=apexpages.currentpage().getparameters().get('Roomid');
            Room__c Rm=[select id,TypeRoomRef__c from Room__c where id=:RoomId];
            Lead__C ld=[select id,Rroom__c,refTypeOfRooms__c from Lead__c where id=:leadid];
            ld.Rroom__c=RoomId;
            ld.refTypeOfRooms__c=Rm.TypeRoomRef__c;
            update ld; 
            //queryRoomStatus();          
            system.debug('Inside addLead');
        }
        catch(Exception e)
        {
            
        }
        refreshPage=true;
        pagereference p=new pagereference('/apex/RoomIndicatorInfoNew');
        return p;
    }
    
    public RoomIndicatorInfoNew() {
        // 初期化選択条件
        strLeadId = '';
        processDate = Date.today();
        selectDate = new BookingTimeTable__c();
        setInitBranShopLst();
    }
    // 過去・未来参照できる機能制御の追加
    public Boolean isShowHisFlg{get{ return CommDefine__c.getInstance().RoomIndicatorShowHisFlg__c;}}
    /**
    * ルーム情報検索する
    **/
    private final String QueryHeader = 'Select  Name ,Id ,Area__c ,Basu__c ,CapacityHaku__c ,Capacity__c ,Field10__c ,Field11__c ,Field12__c ,Field13__c ,Field14__c ,Field15__c ,Field16__c ,Field17__c ,Field18__c ,Field19__c ,Field1__c ,Field4__c ,Field5__c ,Field6__c ,Field7__c ,Field8__c ,Field9__c ,Height__c ,ID__c ,LAN__c ,Lat__c ,Left__c ,Lng__c ,Rank_2__c ,Rank_3__c ,Rank_4__c ,Rank_5__c ,Rank__c ,Rnumber__c ,RoomName__c ,Seq__c ,Tier123__c ,Top__c ,UseOfRoom__c ,Width__c ,centreLat__c ,centreLng__c ,furo__c ,heyadashiryou__c ,heyadashiryouryou__c ,kakuzuke__c ,priority__c ,roomimage__c ,rotenburo__c ,TypeRoomRef__c ,Nosmoking__c ,ParentRoomRef__c ,Floor__c ,TypeRoomRef__r.Name From  Room__c ';
    // 場所別部屋情報
    public List<AreaRoomInfo> areaInfLst {get; private set;}
    // Floor最大部屋数
    public Integer maxRooms{get; private set;}
    // 詳細画面情報維持
    public RoomInfo RoomDetail{get;set;}
    public String strLeadId{get;set;}
    public String strToday{get{
        return (System.now()).format('yyyy-MM-dd HH:mm');
    }}
    // 処理日
    private Date processDate = null;
    // 12時で、予約データを見える範囲
    private DateTime equalTime = DateTime.newInstance(Date.today(), Time.newInstance(12,0,0,0));
    /************************************
    * 各タイプルームのSTYLE　COLOR
    *************************************/
    // 空室
    private final String strEmptyStatusColor = 'isEmptyStatus';
    // 滞中
    private final String strIsStayStatusColor = 'isStayStatus';
    // 出発予定
    private final String strCheckOutDayStatusColor = 'isChkOutDayStatus';
    // 出発
    private final String strCheckOutStatusColor = 'isChkOutStatus';
    // 故障
    private final String strIsBadStatusColor = 'isBadStatus';

    //private final String strIsConfirmationingColor = 'isConfirmationing';
    /************************************
    * 各タイプルームの合計値統計
    *************************************/
    public Integer iEmptyStatusSum{get;set;}
    public Integer isStayStatusSum{get;set;}
    public Integer checkOutDayStatusSum{get;set;}
    public Integer checkOutStatusSum{get;set;}
    public Integer isBadStatusSum{get;set;}
    //public Integer isConfirmationSum{get;set;}

    private void queryRoomStatus () {
        // 統計情報内容の初期化
        iEmptyStatusSum = 0;
        isStayStatusSum = 0;
        checkOutDayStatusSum = 0;
        checkOutStatusSum = 0;
        isBadStatusSum = 0;
        //isConfirmationSum = 0;

        // 部屋情報を格納要配列初期化
        areaInfLst = new List<AreaRoomInfo>();
        // 行最大部屋数の初期化
        maxRooms = 0;
        // 部屋マスた情報を取得する
        // 各部屋のステータス取得する
        String queryWhere = ' where UseOfRoom__c = \'' + CommUtils.escStr(CommConst.ROOM_UseOfType_Guest) + '\'';
        if (!CommUtils.isBlank(branchShopNm)) queryWhere+= ' And BranchShopName__c = \'' + CommUtils.escStr(BranchShopNm) + '\'';
        String queryOrder = ' Order By AREA__c asc, Floor__c asc, Name asc ';
        String queryStr = QueryHeader + queryWhere + queryOrder;
        // 場所情報を維持する
        Set<String> areaSet = new Set<String>();
        Set<String> floorSet = new Set<String>();

        // 各部屋情報を取得する
        list<Room__C> lstroom=Database.query(queryStr);
        //system.debug('@@@@@@@lstroom@@@@'+lstroom.size());
        system.debug('@@@@@@@lstroom@@@@'+lstroom);
        for (Room__c s: Database.query(queryStr)) {
            String areaNm = CommUtils.nullToBlank(s.Area__c);
            system.debug('@@@@Room'+s);
            // 新た場所に切り替えする場合
            if (!areaSet.contains(areaNm)) {
                areaSet.add(areaNm);
                // リスト情報を格納する
                AreaRoomInfo newArea = new AreaRoomInfo(areaNm);
                areaInfLst.add(newArea);
                // 新規Floor初期化
                floorSet.clear();
            }
            // Floor情報が存在チェックを行う
            if (!floorSet.contains(s.Floor__c)) {
                FloorRoomInfo floor = new FloorRoomInfo();
                areaInfLst.get(areaSet.size()-1).addFoorRoomInfo(floor);
                floorSet.add(s.Floor__c);
                
            }
            // Room Info Add
            FloorRoomInfo floorRoom = areaInfLst[areaSet.size()-1].floorRoomLst[floorSet.size()-1];
            RoomInfo room = new RoomInfo(s);
            floorRoom.addRoom(room);
            system.debug('@@@@@floorSet'+floorSet);
            system.debug('@@@@areaSet'+areaSet);
            //system.debug('@@@Room'+S);
        } // End For
        
        system.debug('@@@@areaInfLst val'+areaInfLst);
        //system.debug();
        // ************************
        // 関連情報を取得する
        // ************************
        // 既存の予約データを取得する
        Map<Id, Lead__c> roomLeadMap = this.queryLeadInfo();
        system.debug('@@@@roomLeadMap '+roomLeadMap );
        // 故障部屋情報を取得する
        Set<Id> badRoomSet = this.queryBadRoomSet();
        system.debug('@@@@badRoomSet  '+badRoomSet  );
        // 予約情報は設定する
        for (AreaRoomInfo area : areaInfLst) {
            for (FloorRoomInfo floor : area.floorRoomLst) {
                // フロア単位の最大部屋数統計する
                if (maxRooms < floor.roomLst.size()) maxRooms = floor.roomLst.size();
                // 部屋に、予約データを設定する
                for (RoomInfo room : floor.roomLst) {
                    // 故障部屋の場合
                    system.debug('@@@@@@@inside room');
                    if (badRoomSet.contains(room.sobj.Id)) {
                        room.cssClass = this.strIsBadStatusColor;
                        isBadStatusSum += 1;
                        continue;
                    }
                    system.debug('@@@@Room Name in loop'+room.sobj.name);
                    // 予約データが存在する場合
                    if (roomLeadMap.containsKey(room.sobj.Id)) {
                        Lead__c lead = roomLeadMap.get(room.sobj.Id);
                        // 部屋情報に、予約情報を維持する
                        room.setLeadInfo(lead);
                            system.debug('@@@@@@@guestName'+room.guestName);
                        //お部屋ステータス：[未清掃]
                        if (lead.Field299__c == CommConst.LEAD_ROOM_ST_UNCLEAN) {
                            room.isUnClean = true;
                        }

                        // 予約ステータス[チェックイン完/外出中/滞在中]
                        String status = lead.Field298__c;
                        if( status == CommConst.LEAD_GUEST_ST_CI ||
                            status == CommConst.LEAD_GUEST_ST_OUT ||
                            status == CommConst.LEAD_GUEST_ST_BATH){
                            // 出発日は今の日付の場合：出発予定
                            if(lead.LeadIndexRef__r.DepartureDate__c == processDate){
                                room.cssClass = this.strCheckOutDayStatusColor;
                                checkOutDayStatusSum += 1;
                            }
                            // 滞中
                            else{
                                room.cssClass = this.strIsStayStatusColor;
                                isStayStatusSum += 1;
                            }
                        }
                        // 予約ステータス[チェックアウト完 && 出発日は処理日場合]
                        else if(lead.Field298__c == CommConst.LEAD_GUEST_ST_CO &&
                                lead.LeadIndexRef__r.DepartureDate__c == processDate) {
                            // 出発予定
                            room.cssClass = this.strCheckOutStatusColor;
                            checkOutStatusSum += 1;
                        }
                        else{
                            // 空室「顧客存在、未チェックイン場合」
                            room.cssClass = this.strEmptyStatusColor;
                            iEmptyStatusSum += 1;
                        }
                    }else{
                        // 空室「予約データがない場合」
                        //room.cssClass = this.strEmptyStatusColor;
                        iEmptyStatusSum += 1;
                    }
                }
            }
        }

        // 空欄を補足する
        for (AreaRoomInfo area : areaInfLst) {
            for (FloorRoomInfo floor : area.floorRoomLst) {
                //System.debug('floor::::::::::::::' + floor.floorName);
                //System.debug('floor.roomLst.size()::::::::::' + floor.roomLst.size());
                //System.debug('floor.roomLst.size() - dumy::::::::::' + (maxRooms - floor.roomLst.size()));
                Integer dumyRooms = maxRooms - floor.roomLst.size();
                for (Integer i = 0; i < dumyRooms; i++) {
                    floor.addRoom(new RoomInfo(new Room__c()));
                }
                System.debug('@@@@@');
            }
          system.debug('@@@@@areaInfLst Values in loop'+area );  
        }
        system.debug('@@@@@areaInfLst Values'+areaInfLst);
    }

    @RemoteAction
    public static PopupWinInfo getRoomInfo(String roomId, String leadId) {
        if(CommUtils.escStr(roomId) != '' && CommUtils.escStr(leadId) != ''){
            Lead__c leadDetail = [Select Id,Name,RecordType.Name,Receptiondate__c, Rroom__r.Name, Relcontact__r.Id,Relcontact__r.Name, ReservedStatus__c, LeadIndexRef__c,LeadIndexRef__r.EntryDate__c,LeadIndexRef__r.EntryTime__c,LeadIndexRef__r.DepartureDate__c,LeadIndexRef__r.DepartureTime__c, EntryTime__c, Field4__c, Departure__c, Field3__c, Field310__r.Name, Field298__c,StayPersons__c,SeminarOrderFlg__c,Field2__c,Field308__c,Comment3__c From Lead__c where Id = :leadId];
            Room__c tempRoom = [select Id,Name from Room__c where Id = :roomId];
            // 会計情報を取得する　
            List<AccountAcount__c> acountAcountLst = [select id from AccountAcount__c where Relreserve__c = :leadId order by LastModifiedDate desc limit 1];
            PopupWinInfo roomInfoDetail = new PopupWinInfo();
            // 予約名
            roomInfoDetail.leadId = leadDetail.Id;
            roomInfoDetail.leadName = leadDetail.Name;
            // お客様
            roomInfoDetail.customId = leadDetail.Relcontact__c;
            if (leadDetail.Relcontact__c != null) roomInfoDetail.customName = leadDetail.Relcontact__r.Name;
            // お客様ステータス
            roomInfoDetail.customStatus = CommUtils.nullToBlank(leadDetail.Field298__c);
            if (leadDetail.LeadIndexRef__c != null) {
                // 到着日
                roomInfoDetail.entryDate =  leadDetail.LeadIndexRef__r.EntryDate__c;
                // 到着時刻
                roomInfoDetail.entryTime = leadDetail.LeadIndexRef__r.EntryTime__c;
                // 出発日
                roomInfoDetail.departureDate = leadDetail.LeadIndexRef__r.DepartureDate__c;
                // 出発時刻
                roomInfoDetail.departureTime = leadDetail.LeadIndexRef__r.DepartureTime__c;
            }
            // 予約人数
            roomInfoDetail.leadPeopleNum = leadDetail.StayPersons__c;
            // 予約チャネル
            roomInfoDetail.leadChannel = leadDetail.Field2__c;
            // プラン
            roomInfoDetail.leadPlan = leadDetail.Field310__r.Name;
            // 部屋
            roomInfoDetail.leadRoom = leadDetail.Rroom__r.Name;
            // 特記事項
            roomInfoDetail.leadMemo = leadDetail.Comment3__c;
            //roomInfoDetail.setLeadInfo(leadDetail);
            if (!acountAcountLst.isEmpty()) roomInfoDetail.accountId = acountAcountLst[0].Id;
            return roomInfoDetail;
        }else {
            return null;
        }
    }
    // 支店選択リスト
    public List<SelectOption> branchShopLst{get; private set;}
    public String branchShopNm{get; set;}
    private void setInitBranShopLst() {
        branchShopLst = new List<SelectOption>();
        for (AggregateResult r : [  SELECT BranchShopName__c shopName FROM Room__c Where BranchShopName__c != null GROUP BY BranchShopName__c ORDER BY BranchShopName__c limit 1000]) {
            branchShopLst.add(new SelectOption(String.valueof(r.get('shopName')),String.valueof(r.get('shopName'))));
        }
        if (!branchShopLst.isEmpty()) branchShopNm = branchShopLst[0].getValue();
    }

    // 画面の部屋にて、該当予約情報をチェックインする
    public void checkInByRoom() {
        if(strLeadId != ''){
            // 宿泊のレコードタイプ
            Id bookingRecTypeId = CommLogicProcess.getLeadBookingRecType();
            // 昼12時過ぎすると、到着日は当日のデータを表示する、12時前の場合、到着日は前日のデータを表示する
            Date searchDt = getProcessDate(processDate);

            List<Lead__c> checkInLead = [select Id, Field298__c from Lead__c
                where Id = :strLeadId And CancelBool__c != :CommConst.LEAD_ST_CANCEL_FLG
                And DAY_ONLY(convertTimezone(EntryTime__c)) = :searchDt
                And RecordTypeId = :bookingRecTypeId
                And Field298__c != :CommConst.LEAD_GUEST_ST_CI And Field298__c != :CommConst.LEAD_GUEST_ST_CO];
            if(checkInLead.size() > 0){
                checkInLead[0].Field298__c = CommConst.LEAD_GUEST_ST_CI;
                try{
                    update checkInLead;
                }catch(Exception e){
                    return;
                }
                queryRoomStatus();

            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'the lead Detail is not able to checkin'));
                return;
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'the leadId is null'));
            return;
        }

    }
    private Date getProcessDate (Date procDate) {
        return (System.now().format('HH:mm') < equalTime.format('HH:mm') ? procDate.addDays(-1) : procDate);
    }
    //　部屋に関連付の予約情報を取得する
    private final String QueryLeadHeader = 'Select name,RecordType.Name, Rroom__c, Relcontact__r.Name, ReservedStatus__c, LeadIndexRef__c, LeadIndexRef__r.DepartureDate__c, EntryTime__c, Field4__c, Departure__c, Field3__c, Field310__c, Field298__c, Field299__c From Lead__c ';
    //private final String QueryBadRoomHeader = CommSqlUtils.
    private Map<Id, Lead__c> queryLeadInfo () {

        // 宿泊のレコードタイプを取得する
        Id bookRecTypeId = CommLogicProcess.getLeadBookingRecType();
        // 有効な予約データ、一日一部屋で処理するため、重複することは処理対象外
        // 昼12時過ぎすると、到着日は当日のデータを表示する、12時前の場合、到着日は前日のデータを表示する
        Date searchDt = getProcessDate(processDate);
        String queryWhere = ' Where DAY_ONLY(convertTimeZone(EntryTime__c)) = ' + String.valueOf(searchDt);
        //String queryWhere = ' where ' ;
        queryWhere += ' And  CancelBool__c != ' + CommConst.LEAD_ST_CANCEL_FLG;
        queryWhere += ' And Rroom__c != null ';
        queryWhere += ' And RecordTypeId = \'' + bookRecTypeId + '\'';
        if (!CommUtils.isBlank(branchShopNm)) queryWhere+= ' And Rroom__r.BranchShopName__c = \'' + CommUtils.escStr(BranchShopNm) + '\'';
        String queryStr = QueryLeadHeader + queryWhere;
        system.debug('@@@@queryStr'+queryStr);
        // Map<RoomId, Lead>
        Map<Id, Lead__c> roomLeadMap = new Map<Id, Lead__c>();
        for (Lead__c lead : Database.query(queryStr)) {
            roomLeadMap.put(lead.Rroom__c, lead);
        }
        system.debug('@@@@roomLeadMap'+roomLeadMap);
        return roomLeadMap;
    }

    // 部屋故障状態を読み込む
    private Set<Id> queryBadRoomSet () {
        Set<Id> badRoomSet = new Set<Id>();
        String queryHd = CommSqlUtils.generateQueryString('RoomsStatus__c');
        system.debug('@@@@queryHd@@@'+queryHd);
        String queryWhere = ' where Status__c = \'' + CommUtils.escStr(CommConst.ROOM_ST_TYPE_BED) + '\'';
        queryWhere += ' And StatusBeginDate__c <= ' + String.valueOf(processDate);
        queryWhere += ' And StatusEndDate__c >= ' + String.valueOf(processDate);
        String queryStr = queryHd + queryWhere;
        for (RoomsStatus__c roomSt : Database.query(queryStr)) {
            badRoomSet.add(roomSt.RoomRef__c);
        }
        return badRoomSet;
    }
        // ボタン「翌日」の処理
    public void toNext(){
        processDate = processDate.addDays(1);
        setDateField(processDate);
        queryRoomStatus();
    }

    public void toToday() {
        processDate = Date.today();
        setDateField(processDate);
        queryRoomStatus();
    }

    // ボタン「前日」の処理
    public void toPrev(){
        processDate = processDate.addDays(-1);
        setDateField(processDate);
        queryRoomStatus();
    }
    public BookingTimeTable__c selectDate{get; private set;}
    // 年/月/日を選択する場合
    public void gotoDate() {
        processDate = selectDate.Checkinday__c;
        queryRoomStatus();
    }
    // 業務ロジック関連日付設定を行う
    private void setDateField(Date currDate) {
        // 検索条件：日付連動設定
        selectDate.Checkinday__c = currDate;
        // 営業開始時間から営業終了時間設定を行う
        //beginBusinessTime = DateTime.newInstance(currDate,Time.newInstance(CONST_BUSNIESS_TIME, 0, 0, 0));
        //endBusinessTime = beginBusinessTime.addHours(24);
    }
    // 各エリアの部屋情報
    public class AreaRoomInfo {
        public AreaRoomInfo(String pArea) {
            areaName = CommUtils.nullToBlank(pArea);
            floorRoomLst = new List<FloorRoomInfo>();
            //index = pIndex;
        }
        public void addFoorRoomInfo(FloorRoomInfo floor) {
            floorRoomLst.add(floor);
        }
        public String areaName{get; private set;}
        // 場所に最大フロア数
        public Integer maxFloors{get{return floorRoomLst.size();}}
        public List<FloorRoomInfo> floorRoomLst{get; private set;}
        //public Integer index{get; private set;}
    }

    // OneFloorの部屋情報
    public class FloorRoomInfo {
        public FloorRoomInfo() {
            roomLst = new List<RoomInfo>();
            //index = pIndex;
        }
        public void addRoom(RoomInfo r) {
            roomLst.add(r);
        }
        public String floorName{get{return CommUtils.nullToBlank(roomLst[0].sobj.Floor__c); }}
        public List<RoomInfo> roomLst{get; private set;}
        //public Integer index{get; private set;}
    }
    // 部屋ステータス照会情報
    public class PopupWinInfo {
        // 予約名
        public String leadId{get; set;}
        public String leadName{get; set;}
        // お客様
        public String customId{get; set;}
        public String customName{get; set;}
        // お客様ステータス
        public String customStatus{get; set;}
        // 到着日
        public Date entryDate{get; set;}
        // 到着時刻
        public String entryTime{get; set;}
        // 出発日
        public Date departureDate{get; set;}
        // 出発時刻
        public String departureTime{get; set;}
        // 予約人数
        public Decimal leadPeopleNum {get ;set;}
        // 予約チャネル
        public String leadChannel{get; set;}
        // プラン
        public String leadPlan{get; set;}
        // 部屋
        public String leadRoom{get; set;}
        // 特記事項
        public String leadMemo{get; set;}
        // 会計ID
        public String accountId{get; set;}
    }
    // 部屋情報維持する
    public class RoomInfo {
        public RoomInfo (Room__c s) {
            sobj = s;
            // 空室の場合、色なし
            cssClass = '';
            leadId = '';
            //accountId = '';
            //清潔
            isUnClean = false;
        }
        public Room__c sobj{get; private set;}

        public void setLeadInfo (Lead__c pLead){
            leadDetail = pLead;
            guestName = CommUtils.nullToBlank(pLead.Relcontact__r.Name);
            system.debug('@@@guestName'+guestName);
            simpleGuestNm = (guestName.length() > 5) ? guestName.substring(0,5) : guestName;
            leadId = pLead.Id;
        }
        // 顧客名
        public String guestName{get; private set;}
        // 顧客名：省略名
        public String simpleGuestNm{get; private set;}
        // LeadId
        public String leadId{get; private set;}
        // LeadInfo
        public Lead__c leadDetail{get;set;}
        // 画面の部屋Sectionの下部のCSS制御クラス名
        public String cssClass{get; private set;}
        // 掃除ステータス
        public Boolean isUnClean{get;set;}
        // クリック可能標識
        public Boolean isCanClick{get{
            // 予約情報が存在する場合
            return !CommUtils.isBlank(leadId);
        }}
    }


   /* static testMethod void myUnitTest() {
        Test.startTest();
        Lead__c lead1 = TestCommon.createLead();
        Lead__c lead2 = TestCommon.createLead();
        Lead__c lead3 = TestCommon.createLead();
        Lead__c lead4 = TestCommon.createLead();
        Lead__c lead5 = TestCommon.createLead();

        String leadId = lead1.Id;
        String roomId = lead1.Rroom__c;

        Test.stopTest();
        // 予約データを作成する　
        RoomIndicatorInfoNew indicator = new RoomIndicatorInfoNew();
        indicator.toToday();
        List<AreaRoomInfo> areaInfLst = indicator.areaInfLst;
        indicator.strLeadId = leadId;
        indicator.checkInByRoom();
        // 予約データを作成する
        RoomIndicatorInfoNew.PopupWinInfo popupInfo = RoomIndicatorInfoNew.getRoomInfo(roomId, leadId);
        System.assertNotEquals(popupInfo.leadId, null);

    }*/
}