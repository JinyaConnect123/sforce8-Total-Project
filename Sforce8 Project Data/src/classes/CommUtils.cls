public class CommUtils {

	public static Boolean isBlank(String s) {
		return (s == null || s.length() == 0);
	}

	public static String escStr(String s) {
		if (isBlank(s)) return '';
		return String.escapeSingleQuotes(s);
	}
	/**
	* null -> ''変換関数
	**/
	public static String nullToBlank(String s) {
		return (s == null ? '' : s);
	}
	public static Decimal nullToZero(Decimal s) {
		return (s == null ? 0 : s);
	}
	public static Decimal nullToZero(String s) {
		return (isBlank(s) ? 0 : Decimal.valueOf(s.replaceAll(',', '')));
	}

	/**
	 * パッディング：左ゼロ埋め
	 * @param n 数値
	 * @param len 桁数（数値の桁を含める）
	 * @return
	 */
	public static String paddingLeftZero(Decimal n, Integer len) {
	    Integer nlen = (Math.floor(Math.log10(Double.valueOf(n))).intValue() + 1);
	    if(nlen >= len) return n.format();
	    String s = '';
	    for(Integer i=0, l=len-nlen; i<l; i++) {
	        s += '0';
	    }
	    return s + n;
	}
	/**
	* 小数端末処理方式
	**/
	public static System.RoundingMode pointRoundMode() {
		return(CommDefine__c.getOrgDefaults().RoundType__c == 0 ? RoundingMode.FLOOR : RoundingMode.HALF_UP );
		//return (CommDefine__c.RoundType__c == 0 ? RoundingMode.FLOOR : RoundingMode.HALF_UP );
	}
	// Profile単位で定義を行う
	public static String getPosNoByComdefine() {
		return(CommDefine__c.getInstance(UserInfo.getProfileId()).POSNo__c);
	}
	/**
	* 小数端末処理を行う
	**/
	public static Decimal RoundProcess(Decimal d, Integer pointSize) {
		return (d == null ? 0 : d.divide(1, pointSize, pointRoundMode()));
	}
    public static Decimal RoundProcess(Decimal d, Integer pointSize, RoundingMode mode) {
        return (d == null ? 0 : d.divide(1, pointSize, mode));
    }
	/**
	* 金額（税金抜く）処理を行う
	**/
	public static Decimal CalExcTaxPrice (Decimal d, Decimal taxRate, Integer pointSize) {
		return ( d == null || taxRate == null ? 0 : RoundProcess(d / (1+nullToZero(taxRate)/100), pointSize ));
	}
	public static Decimal CalExcTaxPrice (Decimal d, Decimal taxRate, Integer pointSize, RoundingMode mode) {
		return ( d == null || taxRate == null ? 0 : RoundProcess(d / (1+nullToZero(taxRate)/100), pointSize, mode ));
	}
	/**
	* 金額（税金込み）処理を行う
	**/
	public static Decimal CalIncTaxPrice (Decimal d, Decimal taxRate, Integer pointSize) {
		return ( d == null || taxRate == null ? 0 : RoundProcess(d * (1+taxRate/100), pointSize ));
	}
	/**
	* 金額（税金含め）から消費税取得処理を行う
	**/
	/*
	public static Decimal CalTaxByPriceIncTax(Decimal d, Decimal taxRate, Integer pointSize) {
		// 税金1円未満は切り捨てとなります。
		if (taxRate == null) taxRate =
		Decimal priceExcTax = CalPriceOfExcTax(d, taxRate, pointSize, RoundingMode.CEILING);
		return (d - priceExcTax);
	}*/
	// 営業日付
	public static String getBusinessDay() {
		return (DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0))).format('yyyyMMdd');
	}
	// 消費税を取得する
	public static Decimal getTaxRate(Date validate) {
		return [select TaxRate__c from JMST__c where TaxRate__c > 0 And BeginDate__c <= :validate And EndDate__c >= :validate limit 1].TaxRate__c;
	}
	public static Map<Date, Decimal> getTaxRateMap(Set<Date> validateSet) {
		Map<Date, Decimal> rateMap = new Map<Date, Decimal>();
		for (JMST__c rateMst: [select TaxRate__c,BeginDate__c,EndDate__c from JMST__c where TaxRate__c > 0 Order By BeginDate__c desc]) {
			for (Date dt: validateSet) {
				if (rateMst.BeginDate__c <= dt && rateMst.EndDate__c >= dt) {
					rateMap.put(dt, rateMst.TaxRate__c);
					validateSet.remove(dt);
				}
			}
		}
		for (Date dt: validateSet) {
			rateMap.put(dt, 0);
		}
		return rateMap;
	}


	/**
	 * CSV文字列からオブジェクトを作成するユーティリティクラス
	 * 使用例:
	 * ObjectBuilder builder = new ObjectBuilder(Account.getSObjectType());
	 * builder.setFieldNames('Name,Phone,Fax');
	 * Account acc = (Account)builder.create('Appirio,xxx-xxxx-xxxx,zzz-zzzz-zzzz');
	 */
	public virtual class ObjectBuilder {
	    /** sObjectType */
	    protected Schema.sObjectType sType;
	    /** インスタンスを作成する */
	    public virtual SObject newInstance() {
	        return sType.newSObject();
	    }
	    /**
	     * コンストラクタ
	     * @param sType 対象オブジェクトのsObjectType
	     */
	    public ObjectBuilder(Schema.sObjectType sType) {
	        this.sType = sType;
	        buildFieldTypeMap();
	    }

	    /** フィールド名と並び順を記録 */
	    protected List<String> fields = new List<String>();
	    /** フィールド名と型情報(Schema.DisplayType)のマッピング */
	    public Map<String, Schema.DisplayType> fieldTypeMap = new Map<String, Schema.DisplayType>();

	    /**
	     * CSVのヘッダを設定
	     *//*
	    public void setFieldNames(String headerCSV) {
	        if(headerCSV==null || headerCSV=='')
	            return;
	        List<String> headers = headerCSV.split(',');
	        for(String h : headers) {
	            fields.add(h.trim());
	        }
	    }*/
	    public Schema.DisplayType getDisplayType (String fieldNm) {
	    	return fieldTypeMap.get(fieldNm.toLowerCase());
	    }

	    /**
	     * CSV文字列からオブジェクトを作成し、データベースに保存して返す.
	     * テストクラス用途なので、upsertを行っています。また、エラー発生時はそのまま例外を送出します。
	     * （この部分は、用途に応じて改善の余地があります）
	     * @param csv
	     * @returns 保存後のオブジェクト
	     */
	     /*
	    public SObject create(String csv) {
	        if(csv==null)
	            return null;
	        SObject sobj = toObject(csv);
	        upsert sobj;
	        return sobj;
	    }*/

	    /**
	     * CSV文字列からオブジェクトを作成し、データベースに保存して返す.
	     * テストクラス用途なので、upsertを行っています。また、エラー発生時はそのまま例外を送出します。
	     * （この部分は、用途に応じて改善の余地があります）
	     * @param csvlist
	     * @returns 保存後のオブジェクト
	     *//*
	    public List<SObject> create(String[] csvlist) {
	        //具体的なオブジェクト名でリストを作成できないため、バッチアップデートできない。
	        //できそうな気もするが..
	        List<SObject> sobjs = new List<SObject>();
	        if(csvlist==null || csvlist.size()==0)
	            return sobjs;
	        for(String csv: csvlist) {
	            SObject sobj = toObject(csv);
	            if(sobj!=null) {
	                sobjs.add(sobj);
	                upsert sobj;
	            }
	        }
	        return sobjs;
	    }*/

	    /**
	     * フィールド名と型情報のマッピングを作る
	     */
	    protected virtual void buildFieldTypeMap() {
	        if(this.sType==null)
	            return;
	        Map<String, Schema.SObjectField> fmap = sType.getDescribe().fields.getMap();
	        for(Schema.Sobjectfield f : fmap.values()) {
	            Schema.DescribeFieldResult fd = f.getDescribe();
	            fieldTypeMap.put(fd.getName().toLowerCase(), fd.getType());
	        }
	    }

	    /**
	     * オブジェクトのインスタンスを作成し、CSVの値をセットして返す.
	     * @param values CSVの値
	     * @returns オブジェクトのインスタンス
	     *//*
	    protected SObject toObject(String csv) {
	        if(csv==null)
	            return null;
	        return toObject(csv.split(','));
	    }
	    */
	    /**
	     * オブジェクトのインスタンスを作成し、CSVの値をセットして返す.
	     * @param values CSVの値
	     * @returns オブジェクトのインスタンス
	     *//*
	    protected virtual SObject toObject(List<String> values) {
	        if(values==null || values.size()==0)
	            return null;

	        SObject sobj = newInstance();
	        if(sobj==null)
	            return null;

	        Integer i=0;
	        for(String f : fields) {
	            if(i >= values.size())
	                break;
	            sobj.put(f, conv(values.get(i), fieldTypeMap.get(f)));
	            i++;
	        }
	        return sobj;
	    }*/
	    /**
	     * 型情報に合わせて、文字列データを変換して返す.
	     * @param value データ
	     * @param fieldType 型情報
	     * @returns 変換後のデータ
	     *//*
	    public virtual Object conv(Object value, Schema.DisplayType fieldType) {
	        if(value==null)
	            return null;

	        if(fieldType == Schema.DisplayType.Integer ||
	            fieldType == Schema.DisplayType.Double ||
	            fieldType == Schema.DisplayType.Percent ||
	            fieldType == Schema.DisplayType.Currency ) {
	            // Decimal

//	            return value.trim()!='' ? Decimal.valueOf(value) : null;
				return value !=null ? Double.valueOf(value) : null;
	        }
	        else if(fieldType == Schema.DisplayType.Date) {
	            //Date
	            return value !=null ? Date.valueOf(value) : null;
	        }
	        else if(fieldType == Schema.DisplayType.DateTime) {
	            //DateTime
	            return value !=null ? DateTime.valueOf(value) : null;
	        }
	        else if(fieldType == Schema.DisplayType.Boolean) {
	            //Boolean
	            return value !=null ? Boolean.valueOf(value) : null;
	        }
	        //String
	        return value;
	    }*/
	}

    // 商品関連の金額計算結果を維持する
    public class ProductInfo {

        public decimal unitPriceIncTax{get; private set;}          // 本体単価（税込）
        public decimal unitPriceExcTax{get; private set;}          // 本体単価（税抜）
        public decimal unitPriceIncService{get; private set;}      // 単価サービス料（税込）
        public decimal unitPriceExcService{get; private set;}      // 単価サービス料（税抜）
        public decimal unitPriceTax{get; private set;}             // 単価（税込、サービス料込）

    	public decimal priceIncTax{get; private set;}              // 合計金額（税込:サービス込）
    	public decimal priceIncTaxNoService{get; private set;}     // 合計金額（税込：サービスなし）
    	public decimal priceExcTax{get; private set;}              // 合計金額(税抜)
    	public decimal priceService{get; private set;}             //　合計サービス料（税込）
    	public decimal priceServiceExcTax{get; private set;}       //　合計サービス料(税抜)
    	//public decimal priceTax{get; private set;}               // 金額（消費税）
    	// ***********************************
    	// unitPrice:      商品金額（単価）
    	// amount:         数量
    	// taxRate:        消費税
    	// serviceRate:    サービス料
    	// ***********************************
    	public void process(Decimal unitPrice, Decimal amount, Decimal taxRate, Decimal serviceRate) {
    		// 商品単価区分
    		Integer kbn = CommDefine__c.getInstance().UnitPriceDefKb__c == null ? 1 : CommDefine__c.getInstance().UnitPriceDefKb__c.intValue();
    		// 商品単価の意味は 1:税込、サービス料抜き
    		if(kbn == CommConst.APPOPTION_UTP_DEF_KB_OP1) {
		        // *****************[仕様説明]**************
		        //　単価：500円　数量：3
		        // 単価（税込）:500
                // 単価（税抜）：500 / 1.05 =  477 (切上げ)
                // 単価サービス料（税込）：500 * 0.1 = 50
                // 単価サービス料（税抜）：477 * 0.1 = 47.7 ->47(切り捨て)
                // 単価金額（税込:サービス込）：500 + 50 = 550
		        // 合計サービス料（税込）：50 * 3 = 150
		        // 合計サービス料（税抜）：47 * 3 = 141
		        // 合計金額(税抜)：477 * 3 = 1431
		        // 合計金額（税込：サービスなし）:500 * 3 = 1500
		        // ****************************************
		        // 合計金額（税込:サービス込）:550 * 3 = 1650
		        // ****************************************
		        // 本体単価（税込）
                unitPriceIncTax = unitPrice;
                // 本体単価（税抜き）※※※※（１円未満切り上げ）※※※※
                unitPriceExcTax = CalExcTaxPrice(unitPriceIncTax, nullToZero(taxRate), 0, RoundingMode.CEILING);
                // 単価サービス料（税込）
                unitPriceIncService = RoundProcess(unitPriceIncTax * (nullToZero(serviceRate) / 100), 0);
                // 単価サービス料（税抜）
                unitPriceExcService = RoundProcess(unitPriceExcTax * (nullToZero(serviceRate) / 100), 0);
                // 単価（税込、サービス料込）
                unitPriceTax = unitPriceIncTax + unitPriceIncService;

                // 合計金額(税抜)[Object数式計算式と一致する]
                priceExcTax = unitPriceExcTax * amount;
                // 合計サービス料金（税込）
                priceService = RoundProcess(unitPriceIncTax * amount * (nullToZero(serviceRate) / 100), 0);
                // 合計サービス料金（税抜）
                priceServiceExcTax = unitPriceExcService * amount;
                // 合計金額(税抜)
                priceExcTax = unitPriceExcTax * amount;
                // 合計金額（税込：サービスなし）
                priceIncTaxNoService = unitPriceIncTax * amount;
                // 合計金額（税込:サービス込）
                priceIncTax = unitPriceTax * amount;
                /*
                if (calTpKb == CommConst.APPOPTION_UTP_DEF_KB_TY2) {
	                priceIncTax = RoundProcess(unitPriceTax * amount, 0);
		        } else {
                    priceIncTax = RoundProcess(unitPriceExcTax * (1 + nullToZero(serviceRate) / 100) * amount * (1 + nullToZero(taxRate) / 100), 0);
		        }*/
                // 合計金額（税込）
	           /*
    			// 金額（税込）[サービス料も含めない]
    			priceIncTaxNoService = d;
	            // 合計金額(税抜)※※※※（１円未満切り上げ）※※※※
	            priceExcTax = CalExcTaxPrice(d, nullToZero(taxRate), 0, RoundingMode.CEILING);
	            // サービス料金（税込）
	            priceService = RoundProcess(d * (nullToZero(serviceRate) / 100), 0);
	            // サービス料金（税抜）
	            priceServiceExcTax = RoundProcess(priceExcTax * (nullToZero(serviceRate) / 100), 0);
	            // 税込合計金額再計算を行う（商品合計金額＋サービス料金（税込）+特別税）
	            priceIncTax = d + priceService;
	            // 消費税[本体消費税＋サビース消費税]
	            priceTax = priceIncTax - priceExcTax - priceServiceExcTax; // RoundProcess(d * (nullToZero(taxRate) / 100), 0);*/
    		}
    		// 商品単価の意味は 2:税込、サービス料込
    		else if (kbn == CommConst.APPOPTION_UTP_DEF_KB_OP2) {
                // *****************[仕様説明]**************
                //　単価：550円　数量：3
                // 単価（税抜）：550 / 1.1 / 1.05 =  477 (切上げ)
                // 単価（税込）：477 * 1.05 = 500.86 = 500(切り捨て)
                // 単価サービス料（税込）：550 - 500 = 50
                // 単価サービス料（税抜）：477 * 0.1 = 47.7 -> 47(切り捨て)
                // 単価金額（税込:サービス込）：550
                // 合計サービス料（税込）：50 * 3 = 150
                // 合計サービス料（税抜）：47 * 3 = 141
                // 合計金額(税抜)：477 * 3 = 1431
                // 合計金額（税込：サービスなし）:単価金額（税込:サービス込） * 3 = 1500
                // ****************************************
                // 合計金額（税込:サービス込）:550 * 3 = 1650
                // ****************************************
                // 本体単価（税抜き）※※※※（１円未満切り上げ）※※※※
                unitPriceExcTax = RoundProcess(unitPrice / ((1 + (nullToZero(taxRate) / 100)) * (1 + (nullToZero(serviceRate) / 100))), 0, RoundingMode.CEILING);
                // 本体単価（税込）
                unitPriceIncTax = CalIncTaxPrice(unitPriceExcTax, nullToZero(taxRate), 0);
                // 単価サービス料（税込）
                unitPriceIncService = unitPrice - unitPriceIncTax;
                // 単価サービス料（税抜）
                unitPriceExcService = RoundProcess(unitPriceExcTax * (nullToZero(serviceRate) / 100), 0);
                // 単価金額（税込:サービス込）
                unitPriceTax = unitPrice;

                // 合計金額(税抜)[Object数式計算式と一致する]
                priceExcTax = unitPriceExcTax * amount;
                // 合計サービス料金（税込）
                priceService = RoundProcess(unitPriceIncTax * amount * (nullToZero(serviceRate) / 100), 0);
                // 合計サービス料金（税抜）
                priceServiceExcTax = unitPriceExcService * amount;
                // 合計金額(税抜)
                priceExcTax = unitPriceExcTax * amount;
                // 合計金額（税込：サービスなし）
                priceIncTaxNoService = unitPriceIncTax * amount;
                // 合計金額（税込:サービス込）
                priceIncTax = unitPriceTax * amount;
                /*
                // 合計金額(税込)
                priceIncTax = d;
                // 合計金額(税抜)※※※※（１円未満切り上げ）※※※※
                priceExcTax = RoundProcess(priceIncTax / ((1 + (nullToZero(taxRate) / 100)) * (1 + (nullToZero(serviceRate) / 100))), 0, RoundingMode.CEILING);
                 // サービス料金（税込）[商品金額 / (サービス料+消費税) * サービス料率]
                priceService = RoundProcess(priceExcTax * (nullToZero(serviceRate) / 100) * (1 + (nullToZero(taxRate) / 100)), 0);
	            // サービス料金（税抜）
	            priceServiceExcTax = RoundProcess(priceExcTax * (nullToZero(serviceRate) / 100), 0);
                // 消費税[本体消費税＋サビース消費税]
                priceTax = priceIncTax - priceServiceExcTax - priceExcTax;
                // 金額（税込）[サービス料も含めない]
                priceIncTaxNoService = priceIncTax - priceService;
                */
    		}
    		// 商品単価の意味は 3:税抜、サービス料抜き
    		else if (kbn == CommConst.APPOPTION_UTP_DEF_KB_OP3) {
                // *****************[仕様説明]**************
                //　単価：477円　数量：3
                // 単価（税抜）：477
                // 単価（税込）：477 * 1.05 = 500.85 = 500(切り捨て)
                // 単価サービス料（税込）：477 * 0.1 * 1.05 = 50.085 = 50(切り捨て)
                // 単価サービス料（税抜）：477 * 0.1 = 47.7 = 47 (切り捨て)
                // 単価金額（税込:サービス込）：477 * 1.1 * 1.05 = 550.935 = 550(切り捨て)
                // 合計サービス料（税込）：50 * 3 = 150
                // 合計サービス料（税抜）：47 * 3 = 141
                // 合計金額(税抜)：477 * 3 = 1431
                // 合計金額（税込：サービスなし）:単価金額（税込:サービス込） * 3 = 1500
                // ****************************************
                // 合計金額（税込:サービス込）:550 * 3 = 1650
                // ****************************************
                // 本体単価（税抜き）※※※※（１円未満切り上げ）※※※※
                unitPriceExcTax = unitPrice;
                // 本体単価（税込）
                unitPriceIncTax = CalIncTaxPrice(unitPriceExcTax, nullToZero(taxRate), 0);
                // 単価サービス料（税込）
                unitPriceIncService = RoundProcess(unitPriceExcTax * (nullToZero(serviceRate) / 100) * (1 + nullToZero(taxRate) / 100), 0);
                // 単価サービス料（税抜）
                unitPriceExcService = RoundProcess(unitPriceExcTax * (nullToZero(serviceRate) / 100), 0);
                // 単価金額（税込:サービス込）
                unitPriceTax = RoundProcess(unitPriceExcTax * (1 + nullToZero(serviceRate) / 100) * (1 + nullToZero(taxRate) / 100), 0);

                // 合計サービス料金（税込）
                priceService = unitPriceIncService * amount;
                // 合計サービス料金（税抜）
                priceServiceExcTax = unitPriceExcService * amount;
                // 合計金額(税抜)
                priceExcTax = unitPriceExcTax * amount;
                // 合計金額（税込：サービスなし）
                priceIncTaxNoService = unitPriceIncTax * amount;
                // 合計金額（税込:サービス込）
                priceIncTax = unitPriceTax * amount;
    			/*
                // 合計金額(税抜)
                priceExcTax = d;
                // 金額（税込）[サービス料も含めない]
                priceIncTaxNoService = CalIncTaxPrice(priceExcTax, nullToZero(taxRate), 0);
                 // サービス料金（税込）[商品金額 / (サービス料+消費税) * サービス料率]
                priceService = RoundProcess(priceExcTax * (nullToZero(serviceRate) / 100) * (1 + (nullToZero(taxRate) / 100)), 0);
                // サービス料[合計金額(税抜) * サービス料率]= サービス料金（税込）
                priceServiceExcTax = RoundProcess(priceExcTax * (nullToZero(serviceRate) / 100), 0);
                // 消費税[本体消費税＋サビース消費税]
                //priceTax = RoundProcess(priceExcTax * (nullToZero(taxRate) / 100), 0);
                // 合計金額（税込） = [合計金額(税抜) * (1+消費税) * (1+サービス率)]
                priceIncTax = RoundProcess(priceExcTax * (1 + nullToZero(taxRate) / 100) *  (1 + nullToZero(serviceRate)/100), 0);
                // 消費税[本体消費税＋サビース消費税]
                priceTax = priceIncTax - priceServiceExcTax - priceExcTax;*/
    		}
    	}
    	// 特別税計算を行う
    	public Decimal specialTaxCal(Decimal roomPrice) {
			if (roomPrice >= CommConst.ROOM_TAX_MONEY_LEV1 && roomPrice < CommConst.ROOM_TAX_MONEY_LEV2) {
				return 100;
			} else if (roomPrice >= CommConst.ROOM_TAX_MONEY_LEV2) {
				return 200;
			} else {
				return 0;
			}
    	}
    }

	static testMethod void validateMstData() {
		// 消費税マスタ定義のチェツク
		try {
			CommUtils.getTaxRate(Date.today());
		} catch (Exception e) {
			System.assert(true, '消費税マスタデータ設定不正、確認してください。');
		}
	}
	static testMethod void validateKbProcess() {
		CommDefine__c comDef = null;
		List<CommDefine__c> existComDefList = Database.query(CommSqlUtils.generateQueryString('CommDefine__c') + ' limit 1');
		if (existComDefList.isEmpty()) {
			comDef = new CommDefine__c ();
			insert comDef;
		}
		// 区分１
		comDef.UnitPriceDefKb__c = 1;
		update comDef;
		CommUtils.ProductInfo prodInfo = new CommUtils.ProductInfo();
		prodInfo.process(1050,1, 5, 10);
		System.assertEquals(prodInfo.unitPriceIncTax, 1050);
		System.assertEquals(prodInfo.unitPriceExcTax, 1000);
		System.assertEquals(prodInfo.unitPriceIncService, 105);
		System.assertEquals(prodInfo.unitPriceExcService, 100);
		System.assertEquals(prodInfo.unitPriceTax, 1155);

		System.assertEquals(prodInfo.priceIncTax, 1155);
		System.assertEquals(prodInfo.priceIncTaxNoService, 1050);
		System.assertEquals(prodInfo.priceExcTax, 1000);
		System.assertEquals(prodInfo.priceService, 105);
		System.assertEquals(prodInfo.priceServiceExcTax, 100);
		//System.assertEquals(prodInfo.priceTax, 55);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
		// 区分２
		comDef.UnitPriceDefKb__c = 2;
		update comDef;
		prodInfo = new CommUtils.ProductInfo();
		prodInfo.process(1155,1, 5, 10);
        System.assertEquals(prodInfo.unitPriceIncTax, 1050);
        System.assertEquals(prodInfo.unitPriceExcTax, 1000);
        System.assertEquals(prodInfo.unitPriceIncService, 105);
        System.assertEquals(prodInfo.unitPriceExcService, 100);
        System.assertEquals(prodInfo.unitPriceTax, 1155);

		System.assertEquals(prodInfo.priceIncTax, 1155);
		System.assertEquals(prodInfo.priceIncTaxNoService, 1050);
		System.assertEquals(prodInfo.priceExcTax, 1000);
		System.assertEquals(prodInfo.priceService, 105);
		System.assertEquals(prodInfo.priceServiceExcTax, 100);
		//System.assertEquals(prodInfo.priceTax, 55);
		}
		// 区分３
		System.runAs ( thisUser ) {
		comDef.UnitPriceDefKb__c = 3;
		update comDef;
		prodInfo = new CommUtils.ProductInfo();
		prodInfo.process(1000,1, 5, 10);
        System.assertEquals(prodInfo.unitPriceIncTax, 1050);
        System.assertEquals(prodInfo.unitPriceExcTax, 1000);
        System.assertEquals(prodInfo.unitPriceIncService, 105);
        System.assertEquals(prodInfo.unitPriceExcService, 100);
        System.assertEquals(prodInfo.unitPriceTax, 1155);

		System.assertEquals(prodInfo.priceIncTax, 1155);
		System.assertEquals(prodInfo.priceIncTaxNoService, 1050);
		System.assertEquals(prodInfo.priceExcTax, 1000);
		System.assertEquals(prodInfo.priceService, 105);
		System.assertEquals(prodInfo.priceServiceExcTax, 100);
		//System.assertEquals(prodInfo.priceTax, 55);
		}
	}
}