/*
(function($) {
$.commUtils = {};
$.commUtils.Dto = {};
$.commUtils.clearValue =function() {
	for (i=0; i<arguments.length; i++) {
		document.getElementById(arguments[i]).value = "";
	}
}
$.commUtils.popup = function(url,name,objs,width,height) {
	var win;
	window.receivers = objs;

    var paramAry = new Array(
        "top=0",
        "left=0",
        "toolbar=yes",
        "menubar=yes",
        "scrollbars=yes",
        "resizable=yes",
        "location=yes",
        "status=no"
    );
	if(width && height) {
		paramAry.push("height=" + height + "px");
		paramAry.push("width=" + width + "px");
	}else {
		paramAry.push("height=600px");
		paramAry.push("width=800px");
	}
	win = window.open(url, name, paramAry);
	return win;
}

$.commUtils.popupSetter = function(setter) {
	getter = window.opener.receivers;
	if(getter == null || setter	== null) {
		top.window.close();
	}
	rLen = getter.length;
	bLen = setter.length;
	len	= 0;
	if(rLen	> bLen)	{
		len	= bLen;
	}else {
		len	= rLen;
	}

	for(i =	0; i< len ;	i ++) {
        if ($(getter[i]).is("span")) {
            $(getter[i]).text(setter[i]);
        } else {
            $(getter[i]).val(setter[i]);
        }
		//getter[i].value	= setter[i];

	}
}

})(jQuery)

*/
var commUtils = {};
commUtils.clearValue = function() {
    for (i=0; i<arguments.length; i++) {
        document.getElementById(arguments[i]).value = "";
    }
}
commUtils.popup = function(url,name,objs,width,height,callFun) {
	var win;
	window.receivers = objs;
	window.popup_callFunction=callFun;
    var paramAry = new Array(
        "top=0",
        "left=0",
        "toolbar=yes",
        "menubar=yes",
        "scrollbars=yes",
        "resizable=yes",
        "location=yes",
        "status=no"
    );
	if(width && height) {
		paramAry.push("height=" + height + "px");
		paramAry.push("width=" + width + "px");
	}else {
		paramAry.push("height=600px");
		paramAry.push("width=800px");
	}
	win = window.open(url, name, paramAry);
//win = window.open(url, name);
	return win;
}

commUtils.popupSetter = function(setter) {
	getter = window.opener.receivers;
	if(getter == null || setter	== null) {
		top.window.close();
	}
	rLen = getter.length;
	bLen = setter.length;
	len	= 0;
	if(rLen	> bLen)	{
		len	= bLen;
	}else {
		len	= rLen;
	}
	for(i =	0; i< len ;	i ++) {
		if (getter[i].nodeName == "INPUT") {
			getter[i].value	= setter[i];
		} else if (getter[i].nodeName == "SPAN") {
			getter[i].innerText = setter[i];
		}
		//getter[i].value	= setter[i];
	}
	//if (window.opener.popup_callFunction == null) return;
	// CallFunction Callout
	if (commUtils.isFunction(window.opener.popup_callFunction)) {
	   window.opener.popup_callFunction();
	}
//	if(getter[0].type == "text") {
//		getter[0].focus();
//		getter[0].blur();
//	}
}

commUtils.isFunction = function(functionToCheck) {
 var getType = {};
 return functionToCheck && getType.toString.call(functionToCheck) == '[object Function]';
}

/**********************************
* 各機能個別利用JS　FUN
*
**********************************/
/*********************************
* 部屋選択用POPUP機能
* pageUrl: Open VF PAGE
* ctrlId:設定する部屋ID
* ctrlNm:設定する部屋名
* filterParamUrl:部屋検索用条件
*********************************/
commUtils.showRoomLookup = function showLookup(pageUrl,ctrlId,ctrlNm,filter,height,width) {
    var openUrl = pageUrl + "?lkid=" + ctrlId + "&lknm=" + ctrlNm;
    if (typeof(filter) != "undefined" && filter != "") {
        openUrl += "&" + filter;
    }
    var paramAry = new Array(
        "top=0",
        "left=0",
        "toolbar=no",
        "menubar=no",
        "scrollbars=yes",
        "resizable=no",
        "location=no",
        "status=no"
    );
    if (typeof(height) == "undefined") {
        paramAry.push("height=800");
    } else {
        paramAry.push("height="+height);
    }
    if (typeof(width) == "undefined") {
        paramAry.push("width=600");
    } else {
        paramAry.push("width="+width);
    }
    window.open(encodeURI(openUrl), "showRoomLookup", paramAry);
}
