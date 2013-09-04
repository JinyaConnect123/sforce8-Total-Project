public class CommSqlUtils {
   // 指定オブジェクトのみを取得対象とする
   public static String generateQueryString(String name) {
       // sObjectを生成
       sObject newObj = (sObject)Type.forName(name).newInstance();
       // 設定情報を取得
       Schema.DescribeSObjectResult descResult = newObj.getsObjectType().getDescribe();
       // 整形して戻す
       return 'Select ' + concatSet(descResult.fields.getMap().keySet(), ', ') + ' From ' + name;
   }
   // 指定オブジェクトと指定された子リレーションも取得対象とする
   public static String generateQueryString(String name, Set<String> childSet) {
       // sObjectを生成
       sObject newObj = (sObject)Type.forName(name).newInstance();
       // 設定情報を取得
       Schema.DescribeSObjectResult descResult = newObj.getsObjectType().getDescribe();
       // 取得用項目Set
       Set<String> targetSet = new Set<String>{concatSet(descResult.fields.getMap().keySet(), ', ')};
       // 子リレーションを取得
       for (Schema.ChildRelationship child : descResult.getChildRelationships()) {
           String rName = child.getRelationshipName();
           // 取得対象ではない場合、次へ
           if (!childSet.contains(rName)) continue;
           // 子リレーションの設定情報を取得
           Schema.DescribeSObjectResult childDesc = child.getChildSObject().getDescribe();
           Set<String> tempSet = getAllFieldsForChild(childDesc);
           targetSet.add('(Select ' + concatSet(tempSet, ', ') + ' From ' + rName + ')');
       }
       // 整形して戻す
       return 'Select ' + concatSet(targetSet, ', ') + ' From ' + name;
   }
   // 子リレーションの項目取得
   private static Set<String> getAllFieldsForChild(Schema.DescribeSObjectResult descResult) {
       Set<String> retSet = new Set<String>();
       Map<String, Schema.SObjectField> fieldMap = descResult.fields.getMap();
       for (String api : fieldMap.keySet()) {
           // 子リレーションでBase64は取得対象外
           if (fieldMap.get(api).getDescribe().getType() == Schema.DisplayType.base64) continue;
           retSet.add(api);
       }
       return retSet;
   }
   // 連結
   private static String concatSet(Set<String> strSet, String sep) {
       String retStr;
       for (String str : strSet) {
           retStr = retStr == null ? str : retStr + sep + str;
       }
       return retStr == null ? '' : retStr;
   }

   static testMethod void myunit() {
		String sql = CommSqlUtils.generateQueryString('Account');
		CommSqlUtils.generateQueryString('Account',new Set<String>{'Contacts'});
		CommException exc = new CommException('テスト情報');
        System.assert(sql != null);
   }
}