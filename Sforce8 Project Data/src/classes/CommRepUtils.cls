public with sharing class CommRepUtils {
	// LOGO_01_BILL:請求書/ LOGO_02_ACCOUNT:会計書/ LOGO_03_LEAD:見積書 /LOGO_00_SYSDEF 組織Default値
	public enum REP_TYPE{LOGO_00_SYSDEF, LOGO_01_BILL, LOGO_02_ACCOUNT, LOGO_03_LEAD}
	
	public static ReportLogo__c getReplogoInfoByTypeId (REP_TYPE rType) {
		List<ReportLogo__c> rs =[select name, ReportLogo__c from ReportLogo__c where (name = :rType.name() Or name = :REP_TYPE.LOGO_00_SYSDEF.name()) Order By Name desc limit 1];
		if (rs.isEmpty()) throw new CommException('レポートのロゴ設定ファイルを見つかりません、ロゴオブジェクトの設定情報を確認ください。');
		return rs[0];
	}
}