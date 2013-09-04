/*================================================================
	Created by: Cherr Camba
	
	This is the CSS for the following pages:
		? Plan_Sitelist			(?????)
		? Plan_Details			(?????)
		? Plan_RsvForm			(?????????)
		? (?????)
		? (??????????)
=================================================================*/

/*--------------------------------------------------------------------------------------------------------
	   										    ????????         
---------------------------------------------------------------------------------------------------------*/
.pl_slide {
	padding-bottom: 0px;
	margin-left: 6px;
}

#pl_animation {
    position:relative;
}

#pl_animation IMG {
	position:absolute;
	left:640px;
	top:0px;
    z-index:8;
}

#pl_animation IMG.active {
    z-index:10;
}

#pl_animation IMG.last-active {
    z-index:9;
}

table.planList {
	width: 930px;
	background: white;
	align: center;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}

th.pl_title {
	font-size: 16px;
	font-weight: bold;
	text-align: left;
}

table.planInfo{
	align: center;
	width: 930px;
	background: #fff;
	border-left: 1px solid #ccb;
	border-right: 1px solid #ccb;
	border-top: 1px solid #ccb;
	border-bottom: 1px solid #ccb;
	margin: 0 auto;
}

th.pl_planName {
	height: 18px;
	text-align: center;
	font-size: 16px;
	font-weight: normal;
	background-color: black;
	color: white;
	border:0;
}

td.pl_planIntro {
	align: left;
	padding-top: 20px;
	padding-left: 30px;
	
}

table.weeklyCal {
	width: 100%;
	background: #fff;
	border-bottom: 3px solid #666666;
	margin: 0 auto;
	border: 1px solid #ccb;
	align: center;
	
}

th.calPlanRoom {
	background: #eee;
	font-size: 16px;
	text-align: center;
	border-bottom: 1px solid #ccb;
	border-right: 1px solid #ccb;
}

th.calPlanDate {
	background: #eee;
	font-size: 16px;
	text-align: center;
	border-bottom: 1px solid #ccb;
	border-right: 1px solid #ccb;
	font-weight: normal;
	padding: 5px;
	width: 8%;
}

td.calPlanRoom {
	font-size: 13px;
	padding-left: 7px;
	padding-top:10px;
	padding-bottom: 10px;
	border-right: 1px solid #ccb;
	background: #F6F6F6;
	border-bottom: 1px solid #ccb;
}

td.calPlanRoom:hover {
	font-size: 13px;
	padding-left: 7px;
	padding-top:10px;
	border-right: 1px solid #ccb;
	background: #D2691E;
	color:white;
	border-bottom: 1px solid #ccb;
}

td.calPlanDate {
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	border-bottom: 1px solid #ccb;
}

td.calPlanDate:hover {
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	background: #006400;
	color:white;
	border-bottom: 1px solid #ccb;
}

.comLink_plPlanRoom:hover {
	background: #D2691E;
	color:white;
}

.outLink_PlanDate:hover {
	background: #006400;
	color:white;
}

/*--------------------------------------------------------------------------------------------------------
	   											????????         
---------------------------------------------------------------------------------------------------------*/
.pd_slide {
	padding-bottom: 0px;
	margin-left: 6px;
}

#pd_animation {
    position:relative;
}

#pd_animation IMG {
	position:absolute;
	left:405px;
	top:0px;
    z-index:8;
}

#pd_animation IMG.active {
    z-index:10;
}

#pd_animation IMG.last-active {
    z-index:9;
}

table.planDetails {
	width: 930px;
	background: white;
	align: center;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}

th.pd_title {
	height: 18px;
	text-align: center;
	font-size: 16px;
	font-weight: normal;
	background-color: black;
	color: white;
	border:0;
}

th.pd_planName {
	height: 18px;
	text-align: center;
	font-size: 15px;
	font-weight: bold;
	color: black;
	background-color: #F5F5F5;
	border: 1px solid #ccb;
}

td.pd_leftCol {
	width: 25%;
	font-size: 14px;	
	font-weight: normal;
	border-bottom: dashed;
	border-width: 1px;
	border-color: #CCCCCC;
	background-color: #F5F5F5;
	padding-left: 25px;
}

td.pd_rightCol {
	background-color: white;
	padding-left: 15px;
	padding-top: 10px;
	padding-bottom: 10px;
	font-size: 14px;
	font-weight: normal;
	border-bottom: dashed;
	border-width: 1px;
	border-color: #CCCCCC;
}
table.pd_calHeader {
	width: 930px;
	align: center;
	margin: 0 auto;
	border: 1px solid #ccb;
}

td.currentMonth {
	align: center;
	text-align: center;
	font-size: 20px;
	font-weight: bold;
	font-family: Verdana, sans-serif;
}

td.prevMonth {
	padding-left: 30px;
	align: left;
	text-align: left;
}

td.nextMonth {
	padding-right:30px;
	align: right;
	text-align: right;
}

table.monthlyCal{
	align: center;
	width: 930px;
	background: #fff;
	border-left: 1px solid #ccb;
	border-right: 1px solid #ccb;
	border-top: 1px solid #ccb;
	border-bottom: 5px solid black;
	margin: 0 auto;
}

td.calBlock {
	height: 100px;
	text-align: center;
	font-weight: bold;
	color: #666666;
	vertical-align: middle;
	border-right: 1px solid #ccb;
	border-bottom: 1px solid #ccb;
}

td.calBlock:hover {
	text-align: center;
	background: #228B22;
	border-bottom: 1px solid #ccb;
	border-right: 1px solid #ccb;
}

th.pd_wkHeader{
	padding: 5px;
	font-size: 14px;
	font-weight: bold;
	text-align: center;
	background: black;
	color: #fff;
	border: 1px solid #998;
}

td.calDate {
	padding: 5px;
	font-size: 13px;
	background: #F5F5F5;
	font-family: Verdana, sans-serif;
	border-right: 1px solid #ccb;
	border-bottom: 1px solid #ccb;
}

.comLink_pdPlanRoom {
	color:black;
	font-size: 14px;
	font-family: Verdana, sans-serif;
}

.comLink_pdPlanRoom:hover {
	color:white;
	font-size: 14px;
	font-weight: bold;
	font-family: Verdana, sans-serif;
}

/*--------------------------------------------------------------------------------------------------------
	   										 ????????????         
---------------------------------------------------------------------------------------------------------*/
table.planForm {
	width: 930px;
	background: white;
	align: center;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}

th.pf_title {
	height: 18px;
	text-align: center;
	font-size: 16px;
	font-weight: normal;
	background-color: black;
	color: white;
	border:0;
}

th.pf_planName {
	height: 18px;
	text-align: center;
	font-size: 15px;
	font-weight: bold;
	color: black;
	background-color: #F5F5F5;
	border: 1px solid #ccb;
}

td.pf_leftCol {
	width: 30%;
	padding-left: 40px;
	font-size: 14px;	
	font-weight: normal;
	border-bottom: dashed;
	border-width: 1px;
	border-color: #CCCCCC;
	background-color: #F5F5F5;
}

td.pf_rightCol {
	background-color: white;
	padding-left: 30px;
	padding-top: 10px;
	padding-bottom: 10px;
	font-size: 14px;
	font-weight: normal;
	border-bottom: dashed;
	border-width: 1px;
	border-color: #CCCCCC;
}

td.pf_ImptMsg {
	font-size: 14px;
	font-weight: normal;
	color: #CC3300;
	align: center;
	text-align:center;
	padding:20px;
}

.selectOption {
	font-size: 13px;
}

.inputText {
	width: 250px;
	height: 18px;
	font-size: 14px;
}

.inputTxt_Persons {
	width: 30px;
	height: 18px;
	font-size: 14px;
}

.inputTxt_ZipCode {
	width: 45px;
	height: 18px;
	font-size: 14px;
}

.inputTxt_Address {
	width: 450px;
	height: 18px;
	font-size: 14px;
}

.inputTxt_Mail {
	width: 300px;
	height: 18px;
	font-size: 14px;
}

.inputTxt_Request {
	width: 500px;
	height: 100px;
	font-size: 14px;
}

.imptMessage {
	font-size: 14px;
	font-weight: normal;
	color: #CC3300;
}

.commandBtn {
	width: 110px;
	height: 30px;
	font-weight: normal;
	font-size: 16px;
	background-color: #DDDDDD;
	color: black;
}

.commandBtn:hover {
	width: 110px;
	height: 30px;
	font-weight: normal;
	font-size: 14px;
	color: #228B22;
}




/*--------------------------------------------------------------------------------------------------------
	   										    ?????????         
---------------------------------------------------------------------------------------------------------*/





/*==================================================================================================================================================*/

/*---------------------------*/
/*	   ????????      */
/*---------------------------*/
table.login_main
{	
	background: white;
	width: 750px;
	align: center;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}

table.login_right
{
	background: white;
	height: 180px;
	float: right;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}

th.login_header
{
	align: center;
	background: black;
	color: white;
	padding: 15px;
	text-align: center;
	font-weight: normal;
	font-size: 18px;
	font-family: Arial, sans-serif;
}

th.login_title
{
	background-color: #BBBBBB;
	border:0;
	padding:5px;
	color: black;
	height: 16px;
	text-align: center;
	font-size: 14px;
	font-weight: bold;
	font-family: Arial, sans-serif;
}

td.login_left
{
	background-color: #F5F5F5;
	border: 1px solid #ccb;
	padding:10px;
	font-size:12px;
	font-family: Arial, sans-serif;
	width: 80px;
}

td.login_right
{
	background-color: white;
	padding:10px;
	font-size:12px;
	font-family: Arial, sans-serif;
	width: 150px;
	align: center;
	border: 1px solid #ccb;
}

.login_slide
{
	padding-bottom: 0px;
	margin-left: 6px;
}



/*---------------------------*/
/*	   ?????????      */
/*---------------------------*/

.survey_sheet
{
	align: center;
	width: 1100px;
	margin-top: 10px;
	margin: 0 auto;
	border-weight: 0.5px;
	border-style: solid;
}

.language_btn
{
	float: left;
	top-left: 10px;
	margin-left: 5px;
}

.submit_btn_top
{
	float: right;
	top-right: 10px;
	margin-right:5px;
}

.message_top1
{
	font-size: 14px;
	font-family: Verdana, sans-serif;
	border: none;
	background-color: transparent;
}

.message_top2
{
	font-size: 14px;
	border: none;
	background-color: transparent;
	alignment: left;
	margin-left: 340px;
}

.line
{
	border-bottom-style: solid;
	border-bottom-width:1px;
	margin-top: 20px;
	margin-left: 25px;
	width: 1050px;
}

.checkbox_grp
{
	margin-left: 30px;
	font-size: 14px;
	margin-top: 5px;
}

.answers
{
	margin-left: 35px;
	font-size: 14px;
	margin-bottom: 10px;
}

.my_left_col{
    float: left;
    padding: 10px;
    margin-left: 80px;
    margin-top: 20px;
    font-size:14px;
    font-weight:normal;
}

.my_right_col{
    float: right;
    padding: 10px;
    margin-left: 160px;
    margin-top: 20px;
    font-size:14px;
    font-weight:normal;

}

.inputTxt
{
	width: 200px;
	height: 15px;
	font-size: 14px;
	margin-left: 10px;
}

.customer_info
{
	margin-left: 105px;
	margin-top: 10px;
	font-size:14px;
    font-weight:normal;
    margin-bottom: 20px;
    width: 980px;
}

.def_inptxt
{
	width: 200px;
	height: 15px;
	font-size: 14px;
	margin-left: 10px;
}

.address_txt
{
	width: 300px;
	height: 15px;
	font-size: 14px;
	margin-left: 10px;
}

.age_txt
{
	width: 20px;
	height: 15px;
	font-size: 14px;
	margin-left: 10px;
}


/*This section is for Planform.page*/

th.p_title
{
	height: 18px;
	text-align: center;
	font-size: 16px;
	font-weight: normal;
	background-color: black;
	color: white;
	border:0;
}

th.plan_title
{
	height: 18px;
	text-align: center;
	font-size: 15px;
	font-weight: bold;
	color: black;
	background-color: #F5F5F5;
	border:0;
}

td.left_col
{
	width: 25%;
	padding-left: 7px;
	font-size: 14px;	
	font-weight: normal;
	border-bottom: dashed;
	border-width: 1px;
	border-color: #CCCCCC;
	background-color: #F5F5F5;
}

td.right_col
{
	background-color: white;
	padding-left: 10px;
	padding-top: 10px;
	padding-bottom: 10px;
	font-size: 14px;
	font-weight: normal;
	border-bottom: dashed;
	border-width: 1px;
	border-color: #CCCCCC;
}

.selectOpt
{
	font-size: 15px;
}

.input_def
{
	width: 220px;
	height: 18px;
	font-size: 14px;
}

.input_short
{
	width: 45px;
	height: 18px;
	font-size: 14px;
}

.input_long
{
	width: 400px;
	height: 18px;
	font-size: 14px;
}

.red_msg
{
	font-size: 14px;
	font-weight: normal;
	color: #CC3300;
}

.res_btn
{
	width: 100px;
	height: 30px;
	font-weight: normal;
	background-color: #DDDDDD;
}

.plan_imgs
{
	background-color: white;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	padding: 3px;
	
}

.tbl_prop
{
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}

th.small_tbl
{
	background-color: #F5F5F5;
	height: 40px;
}

body
{
	color: #333333;
	cursor: default;
	margin: 0;
	padding: 0;
}
caption
{
	border-top: 5px solid #c96;
	padding: 10px;
	margin: 0 auto;
	text-align: center;
	font-size: 20px;
}
table.calendar
{
	background: #fff;
	border-bottom: 3px solid black;
	border-right: 1px solid #ccb;
	margin: 0 auto;
}

th.calendar,
td.calendar
{
	border-left: 1px solid #ccb;
	border-top: 1px solid #ccb;
	font-family: Verdana, sans-serif;
	font-weight: bold;
	color: #666666;
	padding: 0 2px;
	vertical-align: middle;
	width: 100px;
	height: inherit;
	
}


col.Sat
{
	background: #F0F8FF;
}

col.Sun
{
	background: #FAF0E6;
}

tr.day
{
	color: #665;
	font-size: 12px;
	height: 70px;
	text-align:center;
	vertical-align: middle;
	background-position: 162px 0px;
	color: white;
	
}

td.cal_day:hover
{
	background: #006400;
	color:black;
	font-size:15px;
}


td.holiday
{
	background: #FAF0E6;
		border-left: 1px solid #ccb;
	border-top: 1px solid #ccb;
	font-family: Verdana, sans-serif;
	font-weight: bold;
	color: black;
	padding: 0 2px;
	vertical-align: middle;
	width: 100px;
	height: inherit;
}

td.holiday:hover
{
	background: #006400;
	color:black;
	font-size:15px;
}

td.cal_day
{
	border-left: 1px solid #ccb;
	border-top: 1px solid #ccb;
	font-family: Verdana, sans-serif;
	font-weight: bold;
	color: black;
	padding: 0 2px;
	vertical-align: middle;
	width: 100px;
	height: inherit;
}

tr.number
{
	background: #eee;
	color: #333333;
	font-size: 12px;
	font-weight: bold;
	height: 20px;
	text-align: left;
	vertical-align: middle;
	margin-top:20px;
}

th.cal_head
{
	background: black;
	color: #fff;
	font-size: 15px;
	font-variant: small-caps;
	font-weight: normal;
	height: 20px;
	text-transform: capitalize;
	text-align: center;
	vertical-align: middle;
	border: 1px solid #998;
}


.events {
	position: relative;
}
.events ul {
	text-align: left;
	position: absolute;
	display: none;
	z-index: 1000;
	padding: 15px;
	background: #E7ECF2 url(../img/popup.png) no-repeat;
	color: white;
	border: 1px solid white;
	font-size: 15px;
	width: 200px;
	-moz-border-radius: 3px;
	-khtml-border-radius: 3px;
	-webkit-border-radius: 3px;
	-border-radius: 3px;
	list-style: none;
	color: #444444;
	-webkit-box-shadow: 0px 8px 8px #333;
}
.events li {
	padding-bottom: 5px;
}
.events li span {
	display: block;
	font-size: 12px;
	text-align: justify;
	color: #555;
}
.events li span.title {
	font-weight: bold;
	color: #222;
}


td.date_has_event {
	background-position: 162px 0px;
	border-left: 1px solid #ccb;
	border-top: 1px solid #ccb;
	color: #666666;
}
td.date_has_event:hover {
	background-position: 162px -81px;
	border-left: 1px solid #ccb;
	border-top: 1px solid #ccb;
	background: #006400;
	color:black;
	font-size:15px;
}

.outlink:hover
{	
	font-size: 16px;
	color: black;
}

table.wkcalendar
{
	background: #fff;
	border-bottom: 3px solid #666666;
	margin: 0 auto;
	border: 1px solid #ccb;
	align: center;
	
}

th.wkcalendar1
{
	background: #eee;
	font-size: 16px;
	text-align: center;
	border-bottom: 1px solid #ccb;
	border-right: 1px solid #ccb;
}

th.wkcalendar2
{
	background: #eee;
	font-size: 16px;
	text-align: center;
	border-bottom: 1px solid #ccb;
	border-right: 1px solid #ccb;
	font-weight: normal;
	padding: 5px;
	width: 8%;
	
}

td.wkcalendar1
{
	
	font-size: 13px;
	padding-left: 7px;
	padding-top:10px;
	padding-bottom: 10px;
	border-right: 1px solid #ccb;
	background: #F6F6F6;
	border-bottom: 1px solid #ccb;
}

td.wkcalendar1:hover
{
	font-size: 13px;
	padding-left: 7px;
	padding-top:10px;
	border-right: 1px solid #ccb;
	background: #D2691E;
	color:white;
	border-bottom: 1px solid #ccb;
	
	
}

td.wkcalendar2
{
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	border-bottom: 1px solid #ccb;
	
}

td.wkcalendar2:hover
{
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	background: #006400;
	color:white;
	border-bottom: 1px solid #ccb;
	
}

td.wkcal_holiday
{
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	background:#FAF0E6;
	border-bottom: 1px solid #ccb;
}

td.wkcal_holiday:hover
{
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	background: #006400;
	border-bottom: 1px solid #ccb;
}

td.wkcal_sat
{
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	background:#F0F8FF;
	border-bottom: 1px solid #ccb;
}

td.wkcal_sat:hover
{
	font-size: 14px;
	padding:5px;
	border-right: 1px solid #ccb;
	text-align: center;
	background: #006400;
	border-bottom: 1px solid #ccb;
}




.outlink_wk1:hover
{
	background: #006400;
	color:white;
}

.outlink_wk2:hover
{
	background: #D2691E;
	color:white;
}

table.separator
{
	width: 100%;
	border-bottom: 5px solid #666666;
	padding: 5px;
}

table.legend
{
	background: #F8F8FF;
	padding: 5px;
	border: 1px solid #ccb;
	align:center;
	font-size: 10px;
	
}

a
{
	font-size: 14px;
}

.btn_login
{
	width: 100px;
	height: 30px;
	font-size: 14px;
	align: center;
}

.login_txt
{
	width: 130px;
	font-size: 16px;
	font-family: Arial, sans-serif;
	align: center;
	margin-left:7px;
}


#animation {
    position:relative;
}

#animation IMG {
    position:absolute;
    top:0;
    left:0;
    z-index:8;
}

#animation IMG.active {
    z-index:10;
}

#animation IMG.last-active {
    z-index:9;
}

.slide
{

	padding-bottom: 0px;
	margin-left: 6px;
}






/*Plan_Cancel*/
table.cancel_page{
	background: white;
	width: 1000px;
	align: center;
	border-style: solid;
	border-width: 1px;
	border-color: #CCCCCC;
	margin: 0 auto;
}
tbody.cal{
	background: #F0F8FF;
	text-align: left;
	font-size:16px;
}

td.calTitle
{
	background: black;
	color: #fff;
	font-size: 20px;
	text-align: center;
}

td.calOption
{
	align: center;
}


th.plan_name
{
	font-size: 16px;
	font-weight: bold;
}

planImg
{
	PADDING: 2px; 
	BORDER:2px solid #ccb;
	HEIGHT = 150px;
	WIDTH = 205px;
}
