import QtQuick 2.5
import QtQuick.Controls 1.4
import QtMultimedia 5.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import eplatplugins.qtdata 1.0
import "qrc:/component/qml/component/common/"
import "qrc:/component/qml/component/common/blue/"
import "qrc:/js/qml/js/common/navconfig.js" as NavConfig
import "qrc:/js/qml/js/edas/edasNavconfig.js" as EdasConfig
import "qrc:/js/qml/js/common/common.js" as CommonFun
import "qrc:/js/qml/js/common/emapConfig.js" as EmapConfig
import "qrc:/js/qml/js/common/armapConfig.js" as ArConfig
import "qrc:/js/qml/js/common/armapCommon.js" as ArCommonFun

//Add by csy

//AR图层管理-弹窗页面
CommonWindowBlue{
    id: arLayerManage;
    property int fontSize: 14;
    property int fontSizeSmall: 12;
    property string fontFamily: "微软雅黑";
    //property color bgColor: "#4D4F54";
    property int btnH: 28 * scaleHeightFactor
    property string windowTitle: "图层管理";
    //property color dataColor1: "#d5d5d5"
    property color dataColor: NavConfig.ColorList.blueColorList.textColor;
    property bool bCanAddIcon: true; //是否新增图层图标
    property bool bEditDisable: false; //图层名称是否可编辑
    //property color divideLineColor: NavConfig.ColorList.colorBgnNum2.bordColor;// 分割线的颜色
    //property color differColor: "#4D4F54";//#4D4F54
    property var curIconInfo: ArConfig.armapList.arObjType;//图层图标信息
    property var curLayerInfos: [];//左侧图层信息
    property var layerIconSrc;//图层图标src
    //property var layerName;//图层名称
    property bool bShowOptBtn: false;//是否显示 编辑、删除 按钮
    property bool bShowBottomBtn: true;//是否显示 新增属性 和 确认、取消按钮
    property bool layerNameFocus: false;//光标聚焦 图层名称
    property var layerIconType;//图层图标 类型
    property var layerIconValue;//图层图标 value值
    property bool isEditModal: false;//是否 在编辑模式下 选中图标
    property var lastClickedLayerId;//最后点击的图层的id(用于在新增图层时候 点击取消操作 回到上一次状态)
    property bool isCreateClicked: false;//是否点击了新增按钮
    //property color compBgColor: Qt.rgba(33/255,39/255,51/255,0.5);
    property var firstClickedType;//打开默认的图层的type
    //property var firstClickedValue;//打开默认的图层的value
    property var firstClickedId;//打开默认的图层的id
    property var lastClickedLayerType;//点击的当前的图层type
    property var lastClickedLayerValue;//点击的当前的图层value
    property var curLayerAttrName;//当前图层名称
    property var deleteLayerId;//删除的图层id
    //property color titleBgColor: Qt.rgba(1/255,50/255,91/255,0.88);//标题背景色
    //property color searchBgColor: Qt.rgba(25/255,124/255,173/255,0.7);//搜索框背景色
    property color leftScrollBgColor: NavConfig.ColorList.blueColorList.scrollBgColor;//左侧滚动部分背景色
    property color textColor: NavConfig.ColorList.blueColorList.textColor;//文本编辑框内文本颜色
    property color leftScrollBorderColor: NavConfig.ColorList.blueColorList.border;//左侧滚动部分边框颜色
    property color layerCheckedBg: NavConfig.ColorList.blueColorList.bgDown;//点击图层背景色
    property color inputBg: NavConfig.ColorList.blueColorList.scrollBgColor;//新增属性model input背景色
    property int fontsize: 14;//本页面字体大小
    property int fontSmallSize: 12;//本页面input字体大小
    property int maxNameDescLen: 20
    property string warningContent: "";//提示文本
    property var emapLang: ArConfig.EmapLang;//语言
    property bool bEditCanvas: false;
    property var curSceneId;

    signal confirmLayerOpt(var bEditModal, var msgCurLayer, var curAllLayerInfo);//如果新增或修改了图层 传信号到父页面 及时更新allLayerInfo
    signal deleteLayerOpt(var curInterestArrs, var deleteLayerid, var curAllLayerInfo);//删除的图层信息

    width: 662 * scaleWidthFactor;
    height: 442 * scaleHeightFactor;
    titleText: windowTitle;
    bCloseBtnVisible: true;
    borderColor: NavConfig.ColorList.blueColorList.outline;

    //获取图层图标
    function getLayerImg(value)
    {
        var img = ""
        var curIconInfo = ArConfig.armapList.arObjType;
        var res = curIconInfo.filter(function(item){
            return item.value == value;
        });
        if(res.length > 0)
        {
            img = res[0].image;
        }

        return img;
    }

    //图标信息
    function initIconInfoModel(curSInfo)
    {
        iconModel.clear();
        var oneIconInfo = {"text": "", "type": "", "imagedown": "", "value": "","image":""};
        for(var i = 0; i < curSInfo.length; i++)
        {
            oneIconInfo.text = curSInfo[i].text;
            oneIconInfo.type = curSInfo[i].type;
            oneIconInfo.imagedown = curSInfo[i].imagedown;
            oneIconInfo.image = curSInfo[i].image;
            oneIconInfo.value = curSInfo[i].value;
            oneIconInfo.selected = false;
            iconModel.append(oneIconInfo);
            console.log(JSON.stringify(oneIconInfo),"oneIconInfo============");
        }
    }

    //获取图层信息(根据条件查询ar图层信息 初始化是查询所有 传{})
    function getLayerInfo(content)
    {
        var keyUrl = NavConfig.urlKeyList.arServiceList[12].keyUrl;
        var layerInfo = [];
        //console.log(keyUrl,"keyUrl=============");
        CommonFun.sendRequest(false, "POST", keyUrl, content, function(responseText0)
        {
            var res = JSON.parse(responseText0);
            console.log("获取所有图层信息res===========", JSON.stringify(res.para));
            if(res.result === 0)
            {
                //console.log(JSON.stringify(res.para));
                layerInfo = res.para; //JSON.stringify(res.para);
            }
            else
            {
                CommonFun.warningWindow(arLayerManage,qsTr("图层信息获取失败！"));
            }
        });
        return layerInfo;
    }

    //初始化图层信息model
    function initLayerInfoModel(curSInfo)
    {
        layerDtlModel.clear();
        var oneObj = {"text": "", "type": "", "id": "", "value": ""};
        var curSInfo_1 = curSInfo;//JSON.parse(curSInfo)
        for(var ii = 0; ii < curSInfo_1.length; ii++)
        {
            oneObj.text = curSInfo_1[ii].name;
            oneObj.value = curSInfo_1[ii].type;
            oneObj.id = curSInfo_1[ii].id;
            oneObj.image = getLayerImg(oneObj.value);
//            curIconInfo.forEach(function(values, i)
//            {
//                if(oneObj.value === values.value)
//                {
//                    //console.log(oneObj.value,"oneObj.value==========")
//                    oneObj.image = values.image;
//                }
//            })
            oneObj.state = "leave";//所有项state设置默认
            //console.log(JSON.stringify(oneObj),"oneObj==============");
            layerDtlModel.append(oneObj);

//            for(var k = 0; k < layerDtlModel.count; k++)
            if(ii == 0)
            {
                layerDtlModel.set(0, {"state": "checked"});//初始第一项是checked选中
            }
        }
    }

    //查找图层
    function searchLayer(searchKeyText)
    {
        //console.log(searchKeyText,"searchKeyText1==========");
        layerDtlModel.clear();
        //搜索图层---部分匹配
        var originLayerInfo = curLayerInfos;//JSON.parse(curLayerInfos);
//        console.log(JSON.stringify(originLayerInfo),"originLayerInfo========")
        if(!!originLayerInfo)
        {
            if(searchKeyText != "")
            {
                var resArr = originLayerInfo.filter(function(item){
//                    if(item.name.indexOf(searchKeyText) != -1)
//                    {
//                        return item;
//                    }
                    return item.name.indexOf(searchKeyText) != -1
                });
                //console.log(JSON.stringify(resArr),"匹配到的数组==========");
                if(resArr.length > 0)
                {
//                    initLayerInfoModel(JSON.stringify(resArr));
                    initLayerInfoModel(resArr);
                }
            }
            else
            {
                initLayerInfoModel(curLayerInfos);
                bCanAddIcon = false;
            }

            if(layerDtlModel.count > 0)
            {
                 getClickedLayerInfo(layerDtlModel.get(0).id);
            }
            else
            {
                bCanAddIcon = true;
                bEditDisable = false;
                curLayerAttrName = "";
                layerAttrName.textInput = "";
                bShowOptBtn = false;
                bShowBottomBtn = false;
                isEditModal = false;
                isCreateClicked = true;
                layerIconType = "";
                layerIconValue = "";
                detailOptModel.clear();
//                var oneObj = {};
//                oneObj.attrNameText = "";
//                oneObj.attrAliasText = "";
//                detailOptModel.append(oneObj);
            }
        }
    }

    //新增图层图标
    function addLayerIcon()
    {
        //console.log("新增图层图标=======");
        var detailComponent = Qt.createComponent("qrc:/evss/qml/evss/armap/ArLayerOption.qml");
        if(detailComponent.status === Component.Ready)
        {
            arLayerManage.bCloseBtnVisible = false;
            //TODO-------弹出框位置
            var sprite = detailComponent.createObject(arLayerManage, {visible: "true",
                                                                      "arLayerModel": iconModel,
                                                                      "layerIconValue":layerIconValue});
            sprite.clickedLayerInfo.connect(function(layerInfo)
            {
                bCanAddIcon = false;
                layerIconSrc = layerInfo.image;
                layerIconType = layerInfo.type;
                layerIconValue = layerInfo.value;

                //console.log(layerIconType,layerIconValue,"layerIconValue=========")

                arLayerManage.bCloseBtnVisible = true;
                sprite.destroy();
                warningTxt.visible = false;
            })
            sprite.windowClosed.connect(function()
            {
                arLayerManage.bCloseBtnVisible = true;
                sprite.destroy();
                warningTxt.visible = false;
            })
        }
    }

    //确认按钮点击事件
    function confirmAddLayer()
    {
        var layerdata = [];
        for(var i = 0; i < detailOptModel.count; i++)
        {
            var oneModel = detailOptModel.get(i);
            //console.log("oneModel.key",oneModel.attrNameText,oneModel.attrAliasText);
            if(oneModel.attrNameText == "" && oneModel.attrAliasText == "")
            {
                //console.log(i,"delete index==============");
                deleteSelectedLine(i);
            }
            else
            {
                var obj = {};
                obj.attrNameText = oneModel.attrNameText;
                obj.attrAliasText = oneModel.attrAliasText;
                layerdata.push(obj);
            }
        }
        //console.log(JSON.stringify(layerdata),"layerdata==============");

        var userData = [];
        for(var k = 0; k < layerdata.length; k++)
        {
            var bIsExist = false;
            var curAttrVal = layerdata[k].attrNameText;
            var curAttrAlias = layerdata[k].attrAliasText;

            //判断别名是否重复
            for(var ii = k + 1; ii < layerdata.length; ii++)
            {
                var curAttrAlias2 = layerdata[ii].attrAliasText;
                if(!!curAttrAlias && curAttrAlias == curAttrAlias2)
                {
                    warningTxt.visible = true;
                    warningContent = emapLang.moreAliasTip//"存在重复别名！";
                    return;
                }

            }

            var str = curAttrVal;
            if (str.indexOf(" ") != -1) {
                //console.log("有空格");
                warningTxt.visible = true;
                warningContent = emapLang.attrWithBlankTip//"属性名称中存在空格";
                return;
            }

            var str2 = curAttrAlias;
            if (str2.indexOf(" ") != -1) {
                //console.log("有空格");
                warningTxt.visible = true;
                warningContent = emapLang.aliasWithBlankTip//"别名中存在空格";
                return;
            }

            //验证属性名
            var curAttrVal1 = new RegExp(/^[-_0-9a-zA-Z\u4e00-\u9fa5]{0,20}$/);
            if(!curAttrVal1.test(curAttrVal))
            {
                warningTxt.visible = true;
                warningContent = emapLang.attrWarning
                return;
            }

            //验证别名
            var curAttrAlias1 = new RegExp(/^[0-9a-zA-Z]{0,20}$/);
            if(!curAttrAlias1.test(curAttrAlias))
            {
                warningTxt.visible = true;
                warningContent = emapLang.aliasWarning
                return;
            }

            if(curAttrVal && !curAttrAlias)
            {
                warningTxt.visible = true;
                warningContent = emapLang.aliasWarning
                return;
            }
            if(!curAttrVal && curAttrAlias)
            {
                warningTxt.visible = true;
                warningContent = emapLang.attrWarning
                return;
            }

            if(curAttrVal != "" && curAttrAlias != "")
            {
                var dataObj = {'name': "",'key': ""};
                dataObj.name = curAttrVal;
                dataObj.key = curAttrAlias;
                userData.push(dataObj);
            }
            else
            {
                userData = "[]";
            }
        }
        //console.log(JSON.stringify(userData),"userData==============")

        //firstClickedId和firstClickedType是一进入组件赋的值 如果刚进组件值为空
        //则需要遍历新增的图层 重新取值
        //console.log(firstClickedId,firstClickedType,"firstClickedType1======")
        var curLayerInfos_2 = curLayerInfos;//JSON.parse(curLayerInfos);
        if(curLayerInfos_2.length > 0)
        {
            for(var j = 0; j < curLayerInfos_2.length; j++)
            {
                var firstClickedId_1 = curLayerInfos_2[0].id;
                var firstClickedType_1 = curLayerInfos_2[0].type;
                //var firstClickedValue_1 = curLayerInfos_2[0].value;
            }
        }
        //console.log(firstClickedType_1,firstClickedValue,"firstClickedType_1======")

        //分为编辑和新增状态下的确认
        //新增需要获取传出来的图标type值 编辑type值是不变的
        var keyUrl;
        var type;
        var value;
        var curLayerName;
        var content = {};
        var layerId;
        //验证图层名称
        var curLayerAttrName1 = new RegExp(/^[-_0-9a-zA-Z\u4e00-\u9fa5]{0,20}$/);
        if(isEditModal)//编辑图层
        {
            console.log("编辑==========")
            keyUrl = NavConfig.urlKeyList.arServiceList[10].keyUrl;
            if(!lastClickedLayerId)
            {
                type = firstClickedType ? firstClickedType : firstClickedType_1;
                layerId = firstClickedId ? firstClickedId : firstClickedId_1;
            }
            else
            {
                type = lastClickedLayerValue;
                layerId = lastClickedLayerId;
            }

            var str3 = curLayerAttrName;
            if (str3.indexOf(" ") != -1) {
                //console.log("有空格");
                warningTxt.visible = true;
                warningContent = "图层名称中存在空格";
                return;
            }

            if(!curLayerAttrName || !curLayerAttrName1.test(curLayerAttrName))
            {
                //CommonFun.warningWindow(arLayerManage,"请输入图层名称！")
                warningTxt.visible = true;
                warningContent = emapLang.layerNameWarning
                return;
            }
            else
            {
                curLayerName = curLayerAttrName;
                warningTxt.visible = false;
            }

            content = {
                "id": layerId,
                "name": curLayerName,
                "type": type,
                "userData": userData.length > 0 ? JSON.stringify(userData) : "[]"
            }
        }
        else if(!isEditModal && isCreateClicked || curLayerInfos_2.length <= 0)
        {//新增图层时
            console.log("新增==========")
            keyUrl = NavConfig.urlKeyList.arServiceList[8].keyUrl;
            if(!layerIconValue)
            {
                //CommonFun.warningWindow(arLayerManage,"请选择图层图标！")
                warningTxt.visible = true;
                warningContent = emapLang.chooseLayerIcon
                return;
            }
            else
            {
                type = layerIconType;//菜单弹出框传出来的值
                value = layerIconValue;
                //console.log(value,"value================")
                warningTxt.visible = false;
            }

            var str4 = curLayerAttrName;
            if (str4.indexOf(" ") != -1) {
                //console.log("有空格");
                warningTxt.visible = true;
                warningContent = "图层名称中存在空格";
                return;
            }

            if(!curLayerAttrName || !curLayerAttrName1.test(curLayerAttrName))
            {
                //CommonFun.warningWindow(arLayerManage,"请输入图层名称！")
                warningTxt.visible = true;
                warningContent = emapLang.layerNameWarning
                return;
            }
            else
            {
                curLayerName = curLayerAttrName;
                warningTxt.visible = false;
            }

            content = {
                "name": curLayerName,
                "type": value,
                "userData": userData.length > 0 ? JSON.stringify(userData) : "[]"
            }
        }
        //console.log("content1111", JSON.stringify(content))
        warningTxt.visible = false;
        console.log(keyUrl,JSON.stringify(content),"keyUrl=================")

        CommonFun.sendRequest(false, "POST", keyUrl, content, function(responseText0)
        {
            var res = JSON.parse(responseText0);
            if(res.result === 0)
            {
                if(res.para.id)
                {
                    lastClickedLayerId = res.para.id;
                }
                console.log(JSON.stringify(res.para),"新增图层res===========");
                //更新model 并点击layerId
                var content0 = {};
                var curLayerInfo = getLayerInfo(content0);
                initLayerInfoModel(curLayerInfo);

                var curLayer = content;
                if(curLayer.id == undefined)
                {
                    curLayer.id = res.para.id;
                }

                confirmLayerOpt(isEditModal, curLayer, curLayerInfo);//传到arMap的allLayerInfo

                curLayerInfos = curLayerInfo;

                if(isEditModal)//编辑图层
                {
                    //getClickedLayerInfo(layerId);
//                    console.log(layerId,res.para.id,"res.para.id=========")
//                    if(layerId){
//                        getClickedLayerInfo(layerId);
//                    } else {
//                        //存在一种情况 如果进来数据为空 不存在firstClicked 也不存在lastClicked 就取新增返回的res.para.id
//                        getClickedLayerInfo(lastClickedLayerId);
//                    }

                    for(var k = 0; k < layerDtlModel.count; k++)
                    {
                        layerDtlModel.set(k, {"state": "leave"});
                        if(layerDtlModel.get(k).id == layerId)
                        {
                            layerDtlModel.set(k, {"state": "checked"});
                        }
                    }

                }
                else if(!isEditModal && isCreateClicked)
                {//新增图层
                    //getClickedLayerInfo(lastClickedLayerId);

                    for(var kk = 0; kk < layerDtlModel.count; kk++)
                    {
                        layerDtlModel.set(kk, {"state": "leave"});
                        if(layerDtlModel.get(kk).id == lastClickedLayerId)
                        {
                            layerDtlModel.set(kk, {"state": "checked"});
                        }
                    }
                }
                bShowBottomBtn = false;
                bEditDisable = true;
                queryInput.textSearch = "";

                if(bEditCanvas)
                {
                    bShowOptBtn = false;
                }
                else
                {
                    bShowOptBtn = true;
                }
            }
            else
            {
                //console.log(res.result,"error============")
                CommonFun.warningWindow(arLayerManage,qsTr("操作图层失败！"));
            }
        });
    }

    //根据ID查询ar图层信息
    function getClickedLayerInfo(layerId)
    {
        detailOptModel.clear();
        var keyUrl = NavConfig.urlKeyList.arServiceList[11].keyUrl;
        var content = {
            "id": layerId, //查询ID为xxx的图层
        }

        //console.log(keyUrl,"keyUrl=============")
        CommonFun.sendRequest(false, "POST", keyUrl, content, function(responseText0)
        {
            var res = JSON.parse(responseText0);
            if(res.result === 0)
            {
                console.log(JSON.stringify(res.para),"单个图层res===========");

                for(var k = 0; k < layerDtlModel.count; k++)
                {
                    layerDtlModel.set(k, {"state": "leave"});
                    if(layerDtlModel.get(k).id == res.para.id)
                    {
                        layerDtlModel.set(k, {"state": "checked"});
                    }
                }

                layerIconSrc = getLayerImg(res.para.type);

//                curIconInfo.forEach(function(values, i)
//                {
//                    if(res.para.type == values.value)
//                    {
//                        layerIconSrc = values.image;
//                    }
//                })
                layerAttrName.textInput = res.para.name;

                var oneObj_1 = {"attrNameText": "","attrAliasText": ""};
                if(res.para.userData)
                {
                    var userData = res.para.userData;
                    var userDataArr = JSON.parse(userData);
                    for(var j = 0; j < userDataArr.length; j++)
                    {
                        console.log(JSON.stringify(userDataArr[j]),"userDataArr=======")
                        oneObj_1.attrNameText = userDataArr[j].name;
                        oneObj_1.attrAliasText = userDataArr[j].key;
                        detailOptModel.append(oneObj_1);
                    }
                }
            }
            else
            {
                CommonFun.warningWindow(arLayerManage,qsTr("查询图层失败！"));
            }
        });
    }

    //删除图层按钮点击事件
    function deleteSelectedLayer()
    {
        var layerId;//删除图层id
        var curLayerInfos_2 = curLayerInfos;//JSON.parse(curLayerInfos);
        if(curLayerInfos_2.length > 0)
        {
            for(var j = 0; j < curLayerInfos_2.length; j++)
            {
                var firstClickedId_1 = curLayerInfos_2[0].id;
            }
        }

        if(!lastClickedLayerId)
        {
            layerId = firstClickedId_1;
        }
        else
        {
            layerId = lastClickedLayerId;
        }

        deleteLayerId = layerId;

        console.log(layerId,"删除的图层layerId==========");

        //提示信息 确定要删除此图层吗？
        var msg = qsTr("你确定要删除此图层吗？图层删除后，该图层下的兴趣点也将被删除")
        var warnComponent = Qt.createComponent("qrc:/component/qml/component/common/ConfirmDialog.qml");
        if(warnComponent.status === Component.Ready)
        {
            var sprite = warnComponent.createObject(arLayerManage, {"warnText": msg,"visible": "true", "selfDestroyFlg": false});
            sprite.okBtnClicked.connect(confirmDeleteOk);
            sprite.cancelClicked.connect(cancelDeleteOk);
        }
    }

    //确定删除图层操作
    function confirmDeleteOk()
    {
        //删除成功 返回上一个图层;删的是第一个 就去往下一个;如果上一个图层不存在 点击新增图层
        var keyUrl = NavConfig.urlKeyList.arServiceList[9].keyUrl;
        var content = {
            "id": deleteLayerId, //删除ID为xxx的图层
        }

        var curInterestArr = [];
        ArCommonFun.getScenceInfo(curSceneId, function(scenceInfo){
           // console.log("scenceInfo=========new",JSON.stringify(scenceInfo));
            var allScenceInfo = scenceInfo;//刷新界面上所有的兴趣点信息
            if(allScenceInfo.length > 0)
            {
                for(var i = 0; i < allScenceInfo.length; i++)
                {
                    if(allScenceInfo[i].layerId == deleteLayerId)
                    {
                        curInterestArr.push(allScenceInfo[i]);
                    }
                }
            }
        })

        //console.log(deleteLayerId,"deleteLayerId=========");

        var deleteIndex = matchLayerIndex(deleteLayerId);
        //console.log(deleteIndex,"deleteIndex==============");

        var index;//应该显示的图层信息index在原model的位置
        var showLayerId;//删除后需要展示的图层id
        if(deleteIndex > 0)
        {
            index = deleteIndex - 1;
        }
        else
        {
            index = 1;
        }

        var curLayerInfos_2 = curLayerInfos;//JSON.parse(curLayerInfos);

        for(var k = 0; k < curLayerInfos_2.length; k++)
        {
            if(index === k)
            {
                showLayerId = curLayerInfos_2[index].id;
                console.log(showLayerId,"需要显示的图层Id============");
            }
        }

        CommonFun.sendRequest(false, "POST", keyUrl, content, function(responseText0)
        {
            var res = JSON.parse(responseText0);
            if(res.result === 0)
            {
                console.log("显示的id======",showLayerId);

                if(showLayerId)
                {
                    getClickedLayerInfo(showLayerId);
                    lastClickedLayerId = showLayerId;
                }
                else
                {
                    //点击新增图层
                    bCanAddIcon = true;
                    bEditDisable = false;
                    curLayerAttrName = "";
                    layerAttrName.textInput = "";
                    bShowOptBtn = false;
                    bShowBottomBtn = true;
                    isEditModal = false;
                    isCreateClicked = true;
                    layerIconType = "";
                    layerIconValue = "";

                    detailOptModel.clear();
                    var oneObj = {};
                    oneObj.attrNameText = "";
                    oneObj.attrAliasText = "";
                    detailOptModel.append(oneObj);
                }

                //更新左侧model
                var content = {}
                var curLayerInfos_2 = getLayerInfo(content);
                curLayerInfos = curLayerInfos_2;
                initLayerInfoModel(curLayerInfos_2);

                deleteLayerOpt(curInterestArr,deleteLayerId,curLayerInfos_2);//传到图层控制的图层信息(删除的兴趣点，删除的图层id,图层信息)

                for(var k = 0; k < layerDtlModel.count; k++)
                {
                    layerDtlModel.set(k, {"state": "leave"});
                    if(layerDtlModel.get(k).id == showLayerId)
                    {
                        layerDtlModel.set(k, {"state": "checked"});
                    }
                }

                if(queryInput.textSearch != "")
                {
                    queryInput.textSearch = "";//搜索图层的时候进行删除
                }
            }
            else
            {
                //console.log("删除失败======",JSON.stringify(responseText0))
                CommonFun.warningWindow(arLayerManage,qsTr("删除图层失败！"));
            }
        });
    }

    //取消删除图层操作
    function cancelDeleteOk()
    {
        //还回到当前图层
        console.log(deleteLayerId,"deleteLayerId========")
    }

    //删除某行操作
    function deleteSelectedLine(index)
    {
        console.log(index,"删除model index是==========");
        detailOptModel.remove(index,1);
    }

    //上移某行操作
    function moveUpOpt(index)
    {
        //detailOptModel.count - 1 是index的最大值(index范围 0<index<detailOptModel.count-1)
        var moveFromIndex,moveToIndex;
        if(index === 0 && detailOptModel.count == 1)
        {
            console.log("已经是第一行=====")
        }
        else if(index === detailOptModel.count-1 && detailOptModel.count == 1)
        {
            console.log("已经是最后一行=====")
        }
        else if(index > 0)
        {
            moveFromIndex = index;
            moveToIndex = index - 1;
            detailOptModel.move(moveFromIndex,moveToIndex,1);
            console.log(moveFromIndex,moveToIndex,"上移---index");
        }
    }

    //下移某行操作
    function moveDownOpt(index)
    {
        //detailOptModel.count - 1 是index的最大值(index范围 0<index<detailOptModel.count-1)
        var moveFromIndex,moveToIndex;
        if(index === 0 && detailOptModel.count == 1)
        {
            console.log("已经是第一行=====")
        }
        else if(index === detailOptModel.count-1 && detailOptModel.count == 1)
        {
            console.log("已经是最后一行=====")
        }
        else if(index < detailOptModel.count-1)
        {
            moveFromIndex = index;
            moveToIndex = index + 1;
            detailOptModel.move(moveFromIndex,moveToIndex,1);
            console.log(moveFromIndex,moveToIndex,"下移---index");
        }
    }

    //匹配当前id在左侧列表里所对应的index值
    function matchLayerIndex(curLayerId)
    {
        var deleteLayerIndex;
        var content = {}
        var curLayerInfos = getLayerInfo(content);
        initLayerInfoModel(curLayerInfos);
        var curLayerInfos_2 = curLayerInfos;//JSON.parse(curLayerInfos);
        if(curLayerInfos_2.length > 0)
        {
            for(var j = 0; j < curLayerInfos_2.length; j++)
            {
                if(curLayerId == curLayerInfos_2[j].id)
                {
                    deleteLayerIndex = j;
                    //console.log(deleteLayerIndex,"deleteLayerIndex==========");
                }
            }
        }
        return deleteLayerIndex;
    }

    //左侧图层model
    ListModel{
        id: layerDtlModel
    }

    //选择icon的model
    ListModel{
        id: iconModel;
    }

    //详情操作model
    ListModel{
        id: detailOptModel;
    }

    //单个图层详情component
    Component{
        id: layerDtl
        Rectangle {
            id: layerDtlElement
            property var newstate: model.state;
            width: 185 * scaleWidthFactor;
            height: 30 * scaleHeightFactor;
            anchors.left: parent.left;
            color: "transparent";

            Rectangle{
                id: dataElement
                anchors.top: parent.top
                anchors.left: parent.left;
                height: 29 * scaleHeightFactor;

                Image {
                    id: layerImg
                    source: model.image
                    anchors.left: parent.left;
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22;
                    height: 22
                }

//                Text {
//                    id: layerNameText
//                    anchors.left: layerImg.right;
//                    anchors.leftMargin: 20
//                    anchors.verticalCenter: parent.verticalCenter
//                    text: model.text
//                    color: textColor
//                }

                TextWithTips {
                    id: layerNameText
                    anchors.left: layerImg.right;
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    textStr: model.text
                    toolTips: textStr
                    height: 22
                    myTextColor: NavConfig.ColorList.blueColorList.textColor//textColor
                }
            }

            Rectangle {
                id: lineElement
                anchors.top: dataElement.bottom
                anchors.left: parent.left;
                width: 185;
                height: 1;
                color: leftScrollBorderColor;
            }

            MouseArea {
                id: itemMouse;
                anchors.fill: parent;
                acceptedButtons: Qt.LeftButton;
                onClicked: {
                    for(var k = 0; k < layerDtlModel.count; k++)
                    {
                        if(k == index)
                        {
                           layerDtlModel.set(k, {"state": "checked"});//点击的index变背景色
                        }
                        else
                        {
                            layerDtlModel.set(k, {"state": "leave"});//其他项恢复默认
                        }
                    }

                    //console.log(model.id,"model.id=============");
                    getClickedLayerInfo(model.id);
                    bCanAddIcon = false;
                    bEditDisable = true;
                    if(bEditCanvas)
                    {
                        bShowOptBtn = false;
                    }
                    else
                    {
                        bShowOptBtn = true;
                    }
                    bShowBottomBtn = false;
                    isCreateClicked = false;
                    lastClickedLayerId = model.id;
                    //lastClickedLayerType = model.type;
                    lastClickedLayerValue = model.value;
                }
            }
            onNewstateChanged: {
                //console.log(newstate,"newstate==========");
                if(newstate == "checked")
                {
                    //换背景色
                    layerDtlElement.color = layerCheckedBg;
                }
                else
                {
                    //换背景色
                    layerDtlElement.color = "transparent"
                }
            }
        }

    }

    //单个详情操作行component
    Component {
        id: detailOpt

        Rectangle{
            id: detailOptComp
            width: 426 * scaleWidthFactor;
            height: 28 * scaleHeightFactor;
            anchors.left: parent.left;
            anchors.right: parent.right
            color: leftScrollBgColor;
            border.width: 1
            border.color: leftScrollBorderColor

            CommonTextInputBlue {
                id: attrNameInput
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter;
                charaterMax: maxNameDescLen
                //validatorType: RegExpValidator{regExp: /^[0-9a-zA-Z\u4e00-\u9fa5]{0,20}$/}//属性长度为不超过20字符的中英文数字-_
                width: 144 * scaleWidthFactor
                height: 25 * scaleHeightFactor;
                textReadOnly: bEditDisable;
                inputFocus: layerNameFocus;
                textInput: model.attrNameText;
                tableUsed: true;
                noticetext: model.attrNameText ? "" : emapLang.enterAttr;//如果textInput值为空 才显示noticetext
                textBgColor: inputBg
                myTextColor: dataColor
                //myInTextColor: textColor
                //myNoticeTextColor: textColor
                noticeFontSize: fontSmallSize
                fontSize: fontSmallSize//fontsize
                border.width: 0
                onIputTxtChanged: {
                    model.attrNameText = textStr;
                    if(textStr != "")
                    {
                        warningTxt.visible = false;
                    }
                }
            }

            Rectangle{
                id: middleLine;
                anchors.left: attrNameInput.right;
                anchors.verticalCenter: parent.verticalCenter;
                width: 1;
                height: 26 * scaleHeightFactor;
                color: leftScrollBorderColor;
            }

            CommonTextInputBlue {
                id: attrAliasInput
                anchors.left: middleLine.right
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter;
                charaterMax: maxNameDescLen
                validatorType: RegExpValidator{regExp: /^[0-9a-zA-Z]{0,20}$/}//别名长度为不超过20字符的英文加数字,在确认时校验
                width: 144 * scaleWidthFactor
                height: 25 * scaleHeightFactor;
                textReadOnly: bEditDisable;
                inputFocus: layerNameFocus
                textInput: model.attrAliasText;
                tableUsed: true;
                noticetext: model.attrAliasText ? "" : emapLang.aliasText;
                textBgColor: inputBg
                myTextColor: dataColor
                //myInTextColor: textColor
                //myNoticeTextColor: textColor
                noticeFontSize: fontSmallSize
                fontSize: fontSmallSize//fontsize
                border.width: 0
                onIputTxtChanged: {
                    model.attrAliasText = textStr;
                    if(textStr != "")
                    {
                        warningTxt.visible = false;
                    }
                }
            }

            Rectangle{
                id: middleLine1;
                anchors.left: attrAliasInput.right;
                anchors.verticalCenter: parent.verticalCenter;
                width: 1;
                height: 26 * scaleHeightFactor;
                color: leftScrollBorderColor;
            }

            Rectangle {
                id: attrOptBtn
                anchors.left: middleLine1.right
                anchors.verticalCenter: parent.verticalCenter;
                width: 146 * scaleWidthFactor
                height: 28 * scaleHeightFactor;
                color: "transparent"
                visible: bShowBottomBtn

                ImageButton {
                    id: moveDownIcon;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left;
                    anchors.leftMargin: 10 * scaleWidthFactor;
                    width: 18 * scaleWidthFactor;
                    imgnormal: NavConfig.CtrlList.DirectBtn[2].logonormal;
                    imghover: NavConfig.CtrlList.DirectBtn[2].logodis;
                    imgdown: NavConfig.CtrlList.DirectBtn[2].logodis;
                    bIsNeedBgPic: false
                    toolTip: emapLang.moveDown
                    onClicked: {
                        moveDownOpt(index);
                    }
                }

                ImageButton {
                    id: moveUpIcon;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: moveDownIcon.right;
                    anchors.leftMargin: 20 * scaleWidthFactor;
                    width: 18 * scaleWidthFactor;
                    imgnormal: NavConfig.CtrlList.DirectBtn[1].logonormal;
                    imghover: NavConfig.CtrlList.DirectBtn[1].logodis;
                    imgdown: NavConfig.CtrlList.DirectBtn[1].logodis;
                    bIsNeedBgPic: false
                    toolTip: emapLang.moveUp
                    onClicked: {
                        moveUpOpt(index);
                    }
                }

                ImageButton {
                    id: deleteAttrIcon;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: moveUpIcon.right;
                    anchors.leftMargin: 20 * scaleWidthFactor;
                    width: 18 * scaleWidthFactor;
                    imgnormal: NavConfig.VideoCapture.deleteNormalIcon;
                    imghover: NavConfig.VideoCapture.deleteNormalIcon;
                    imgdown: NavConfig.VideoCapture.deleteNormalIcon;
                    bIsNeedBgPic: false
                    toolTip: emapLang.deleteIcon
                    onClicked: {
                        attrNameInput.inputFocus = false;
                        attrAliasInput.inputFocus = false;
                        deleteSelectedLine(index);
                    }
                }
            }
        }
    }

    //左侧区域
    Rectangle {
        id: leftRec;
        anchors.top: parent.top;
        anchors.topMargin: titleY;
        anchors.left: parent.left;
        height: arLayerManage.height - titleY;
        width: 200 * scaleWidthFactor;
        color: "transparent";

        //左侧搜索框
        RoundCornerTextInputBlue {
            id: queryInput;
            anchors.top: parent.top;
            anchors.topMargin: 5;
            anchors.left: parent.left;
            anchors.leftMargin: 10;
            fontSize: fontSmallSize
            //anchors.bottomMargin: 5;
            inputRectHeight: 26 * scaleHeightFactor;
            width: 185 * scaleHeightFactor;
            height: 26 * scaleHeightFactor;
            textIn: emapLang.searchHolder;
            charaterMax: maxNameDescLen;
            //fieldBgColor: searchBgColor
            //inputHoverColor: searchBgColor
            //inputBoderColor: searchBgColor
            myTextColor: dataColor
            textDisColor: dataColor
            border.color: leftScrollBorderColor
            onClicked: {
                searchLayer(queryInput.textSearch);
            }
            onTextSearchChanged: {
                searchLayer(queryInput.textSearch);
            }

            onCloseClicked: {
                searchLayer("");
//                initLayerInfoModel(curLayerInfos);
////                for(var k = 0; k < layerDtlModel.count; k++)
//                if(layerDtlModel.count > 0)
//                {
//                    var curId = layerDtlModel.get(0).id;
//                    getClickedLayerInfo(curId);
//                }
            }
        }

        //搜索框下面部分 带边框的
        Rectangle{
            id: leftBorderPart
            anchors.top: queryInput.bottom;
            anchors.topMargin: 5;
            anchors.left: parent.left;
            anchors.leftMargin: 10
            height: 365 * scaleHeightFactor;
            width: 185 * scaleWidthFactor;
            color: leftScrollBgColor;
            border.width: 1
            border.color: leftScrollBorderColor

            //所有图层 上下滑动框
            Rectangle {
                id: slideRec;
                anchors.top: parent.top;
                //anchors.topMargin: 10;
                anchors.left: parent.left;
                //anchors.leftMargin: 10
                height: 320 * scaleHeightFactor;
                width: 185 * scaleWidthFactor;
                color: "transparent";

                ScrollViewCustomizeBlue{
                    id: layerView
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.fill: parent;
                    focus: true;
                    horizontalScrollBarFixed : Qt.ScrollBarAlwaysOff;

                    ListView{
                        id: layerDtlView
                        visible: true
                        //model: iconModel //试验一下
                        model: layerDtlModel
                        clip: false;
                        focus: true;
                        keyNavigationWraps: false;
                        highlightFollowsCurrentItem: true; //currentIndex自动显示
                        highlightMoveVelocity: 10000;//控制竖向移动速度,10000pixels/second
                        delegate: layerDtl;
                        //spacing: 10 * scaleWidthFactor;
                    }
                }
            }

            //新增图层
            Rectangle {
                id: createLayerRec;
                anchors.top: slideRec.bottom;
                anchors.topMargin: 15;
                anchors.left: parent.left;
                height: 14 * scaleHeightFactor;
                width: 185 * scaleWidthFactor;
                color: "transparent";
                GradButtonBlue {
                    anchors.centerIn: parent;
                    textCon: emapLang.addLayer;
                    smallImagestr: ArConfig.armapList.objList.addObj.icon;
                    width: 160 * scaleFullWidthFactor;
                    onClicked: {
                        console.log("新增图层======");
                        bCanAddIcon = true;
                        bEditDisable = false;
                        curLayerAttrName = "";
                        layerAttrName.textInput = "";
                        bShowOptBtn = false;
                        bShowBottomBtn = true;
                        isEditModal = false;
                        isCreateClicked = true;
                        layerIconType = "";
                        layerIconValue = "";

                        detailOptModel.clear();
                        var oneObj = {};
                        oneObj.attrNameText = "";
                        oneObj.attrAliasText = "";
                        detailOptModel.append(oneObj);

                        for(var k = 0; k < layerDtlModel.count; k++)
                        {
                            layerDtlModel.set(k, {"state": "leave"});
                        }
                    }
                }
            }
        }
    }

//    // 左右区域分隔线
//    Rectangle{
//        id: middleLine;
//        anchors.left: leftRec.right;
//        //anchors.leftMargin: 200 * scaleWidthFactor;
//        anchors.top: parent.top;
//        anchors.topMargin: titleY;
//        width: 1;
//        height: arLayerManage.height - titleY;
//        color: divideLineColor;
//    }

    //右侧区域
    Rectangle {
        id: rightRec;
        anchors.top: parent.top;
        anchors.topMargin: titleY;
        anchors.left: leftRec.right;
        anchors.leftMargin: 1 * scaleWidthFactor;
        height: arLayerManage.height - titleY;
        width: 462 * scaleWidthFactor;
        color: "transparent";

        //操作按钮区域(编辑、删除)
        Rectangle {
            id: optBtnRec;
            height: 30 * scaleHeightFactor;
            width: 462 * scaleWidthFactor;
            anchors.top: rightRec.top;
            anchors.topMargin: 4;
            anchors.right: parent.right;
            anchors.rightMargin: 10
            color: "transparent";
            visible: bShowOptBtn

            GradButtonBlue {
                id: editLayerBtn;
                anchors.right: deleteLayerBtn.left;
                anchors.rightMargin: 18// * scaleFullWidthFactor;
                textCon: emapLang.editLayer;
                smallImagestr: ArConfig.armapList.objList.editObj.icon;
                width: 100 * scaleFullWidthFactor;
                onClicked: {
                    console.log("编辑图层======");
                    bShowBottomBtn = true;
                    bEditDisable = false;
                    isEditModal = true;
                    isCreateClicked = false;
                }
            }
            GradButtonBlue {
                id: deleteLayerBtn;
                anchors.right: optBtnRec.right;
                //anchors.rightMargin: 18// * scaleFullWidthFactor;
                textCon: emapLang.deleteLayer;
                smallImagestr: ArConfig.armapList.objList.deleteObj.icon;
                width: 100 * scaleFullWidthFactor;
                onClicked: {
                    console.log("删除图层======")
                    deleteSelectedLayer();
                }
            }
        }

        //图层信息(图标、名称)
        Rectangle {
            id: layerInfoRec;
            anchors.top: optBtnRec.bottom;
            anchors.topMargin: 20 * scaleHeightFactor;
            height: 40 * scaleHeightFactor;
            width: 462 * scaleWidthFactor;
            color: "transparent";

            Rectangle {
                id: layerIcon
                anchors.top: parent.top;
                height: 40 * scaleHeightFactor;
                width: 462 * scaleWidthFactor;
                color: "transparent";

                //图层图标
                Text {
                    id: iconTitle;
                    anchors.left: parent.left;
                    anchors.leftMargin: 20 * scaleWidthFactor;
                    anchors.verticalCenter: parent.verticalCenter;
                    text: emapLang.layerIcon;
                    color: NavConfig.ColorList.blueColorList.textColor//textColor;//"#d5d5d5"
                    font.pixelSize: fontSmallSize//fontsize;
                    font.family: fontFamily;
                }

                Rectangle{
                    id: iconRec
                    anchors.left: iconTitle.right
                    anchors.leftMargin: 10 * scaleWidthFactor;
                    anchors.top: parent.top
                    width: 44
                    height: 44
                    color: "transparent"
                    visible: true

                    //底图
                    Image{
                        anchors.fill: parent
                        source: ArConfig.armapList.layerFilterBg.imageNormal
                        visible: parent.visible

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                //addIcon.clicked();

                                //addLayerIcon();
                                if(isEditModal)
                                {
                                    console.log("编辑操作下...")
                                }
                                else if(!isEditModal && isCreateClicked)
                                {
                                    addLayerIcon(); //新增图层时 点击图标可以替换 编辑的时候不可以再替换
                                }
                            }
                        }
                    }

                    SquarButton {
                        id: addIcon;
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: parent.left;
                        //anchors.leftMargin: 10 * scaleWidthFactor;
                        toolTip: ""
                        imgnormal:""
                        imghover:""
                        imgdown:""
                        hoverColor: "transparent"
                        hovBorderColor: "transparent"
                        downColor: "transparent"
                        downBorderColor: "transparent"
                        colorInputEnable: true
                        width: 28 * scaleWidthFactor;
                        smallImagestr: EmapConfig.eagleMapList.mapPointOperator[2].nor;
                        disIcon: EmapConfig.eagleMapList.mapPointOperator[2].nor
                        visible: bCanAddIcon ? true : false
                        onClicked: {
//                            addLayerIcon();
                        }
                    }

                    Image {
                        id: iconImg
                        source: layerIconSrc ? layerIconSrc : ""
                        anchors.left: parent.left;
                        anchors.leftMargin: 7 * scaleWidthFactor;
                        anchors.verticalCenter: parent.verticalCenter;
                        //anchors.horizontalCenter: parent.horizontalCenter
                        width: 30
                        height: 30
                        visible: bCanAddIcon ? false : true
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(isEditModal)
                                {
                                    console.log("编辑操作下...")
                                }
                                else if(!isEditModal && isCreateClicked)
                                {
                                    addLayerIcon(); //新增图层时 点击图标可以替换 编辑的时候不可以再替换
                                }
                            }
                        }
                    }
                }

                //图层名称
                Text {
                    id: nameTitle;
                    anchors.right: layerAttrName.left;
                    anchors.rightMargin: 15//80 * scaleWidthFactor;
                    anchors.verticalCenter: parent.verticalCenter;
                    text: emapLang.layerName;
                    color: NavConfig.ColorList.blueColorList.textColor//textColor;//"#d5d5d5"
                    font.pixelSize: fontSmallSize//fontsize;
                    font.family: fontFamily;
                }

                CommonTextInputBlue{
                    id: layerAttrName
                    anchors.right: layerIcon.right
                    anchors.rightMargin: 10;
                    anchors.verticalCenter: parent.verticalCenter;
                    //validatorType: RegExpValidator{regExp: /^[0-9a-zA-Z\u4e00-\u9fa5]{0,20}$/}//图层名称为长度不超过20字符的中英文数字-_
                    width: 166 * scaleWidthFactor;
                    height: 26 * scaleHeightFactor;
                    textReadOnly: bEditDisable;
                    focus: layerNameFocus;
                    textInput: "";
                    tableUsed: true;
                    noticetext: layerAttrName.textInput ? "" : emapLang.enterLayerName;
                    //textBgColor: searchBgColor
                    //myInTextColor: textColor
                    myTextColor: dataColor
                    //myNoticeTextColor: textColor
                    fontSize: fontSmallSize//fontsize
                    noticeFontSize: fontSmallSize
                    charaterMax: maxNameDescLen;
                    border.width: 1
                    border.color: leftScrollBorderColor
                    onIputTxtChanged: {
                        //console.log(textStr,"textStr=============")
                        curLayerAttrName = textStr;
                        if(textStr != "")
                        {
                            warningTxt.visible = false;
                        }
                    }
                }
            }
        }

        //图层详情(属性、别名、操作)
        Rectangle {
            id: layerDetailRec
            anchors.top: layerInfoRec.bottom;
            anchors.topMargin: 20 * scaleHeightFactor;
            height: 200 * scaleHeightFactor;
            width: 462 * scaleWidthFactor;
            color: "transparent";

            //图层详情 标题行部分
            Rectangle {
                id: attrTitleRec
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20 * scaleWidthFactor;
                anchors.rightMargin: 10;
                anchors.top: parent.top;
                color: leftScrollBgColor;
                width: 426 * scaleWidthFactor
                height: 28 * scaleHeightFactor;
                border.width: 1
                border.color: leftScrollBorderColor
                Text {
                    id: attrName
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    anchors.verticalCenter: parent.verticalCenter;
                    anchors.top: parent.top;
                    anchors.topMargin: 5
                    text: emapLang.attribute;
                    font.pixelSize: fontSmallSize//fontsize;
                    font.family: fontFamily;
                    width: 142 * scaleWidthFactor
                    height: 28 * scaleHeightFactor;
                    color: NavConfig.ColorList.blueColorList.textColor//textColor;
                }
                //分隔线
                Rectangle{
                    id: attrNameLine;
                    anchors.left: attrName.right;
                    width: 1;
                    height: 28 * scaleHeightFactor;
                    color: leftScrollBorderColor;
                }
                Text {
                    id: attrAlias
                    anchors.left: attrName.right
                    anchors.leftMargin: 3
                    anchors.top: parent.top;
                    anchors.topMargin: 5
                    anchors.verticalCenter: parent.verticalCenter;
                    text: emapLang.alias;
                    font.pixelSize: fontSmallSize//fontsize;
                    font.family: fontFamily;
                    width: 142 * scaleWidthFactor
                    height: 28 * scaleHeightFactor;
                    color: NavConfig.ColorList.blueColorList.textColor//textColor;
                }
                //分隔线
                Rectangle{
                    id: attrAliasLine;
                    anchors.left: attrAlias.right;
                    width: 1;
                    height: 28 * scaleHeightFactor;
                    color: leftScrollBorderColor;
                }
                Text {
                    id: attrOpt
                    anchors.left: attrAlias.right
                    anchors.leftMargin: 3
                    anchors.top: parent.top;
                    anchors.topMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: emapLang.operate;
                    font.pixelSize: fontSmallSize//fontsize;
                    font.family: fontFamily;
                    width: 142 * scaleWidthFactor
                    height: 28 * scaleHeightFactor;
                    color: NavConfig.ColorList.blueColorList.textColor//textColor;
                }
            }

            //图层详情 可编辑部分
            Rectangle {
                id: detailOptRec;
                anchors.top: attrTitleRec.bottom;
                anchors.topMargin: 10 * scaleHeightFactor;
                anchors.left: parent.left;
                anchors.leftMargin: 20 * scaleWidthFactor;
                anchors.right: parent.right
                anchors.rightMargin: 10;
                height: 146 * scaleHeightFactor;
                width: 426 * scaleWidthFactor;
                color: "transparent";

                ScrollViewCustomizeBlue{
                    id: detailOptScroll
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.fill: parent;
                    focus: true;
                    horizontalScrollBarFixed : Qt.ScrollBarAlwaysOff;

                    ListView{
                        id: detailOptView
                        visible: true
                        model: detailOptModel
                        clip: false;
                        focus: true;
                        keyNavigationWraps: false;
                        highlightFollowsCurrentItem: true; //currentIndex自动显示
                        highlightMoveVelocity: 10000;//控制竖向移动速度,10000pixels/second
                        delegate: detailOpt;
                        spacing: 5 * scaleWidthFactor;
                    }
                }
            }
        }

        //新增属性(按钮)
        Rectangle {
            id: addNewAttrRec
            anchors.top: layerDetailRec.bottom;
            anchors.topMargin: 10 * scaleHeightFactor;
            width: 462 * scaleWidthFactor;
            height: 30 * scaleHeightFactor;
            color: "transparent";
            visible: bShowBottomBtn

            GradButtonBlue {
                id: addNewAttrBtn;
                anchors.left: parent.left;
                anchors.leftMargin: 20 * scaleWidthFactor;
                textCon: emapLang.addAttr;
                smallImagestr: ArConfig.armapList.objList.addObj.icon;
                width: 90 * scaleFullWidthFactor;
                onClicked: {
                    console.log("新增属性======")
                    var oneObj = {};
                    oneObj.attrNameText = "";
                    oneObj.attrAliasText = "";
                    detailOptModel.append(oneObj);
                }
            }
        }

        //底部操作按钮区域(取消、确认)
        Rectangle {
            id: bottomBtnRec;
            height: 30 * scaleHeightFactor;
            width: 462 * scaleWidthFactor;
            anchors.top: addNewAttrRec.bottom;
            anchors.topMargin: 4;
            color: "transparent";
            visible: bShowBottomBtn

            Text {
                id: warningTxt
                text: warningContent
                anchors.left: bottomBtnRec.left;
                anchors.leftMargin: 20 * scaleWidthFactor;
                anchors.verticalCenter: parent.verticalCenter
                color: "#FF0000"
                width: 160
                visible: false
            }

            CommonButtonBlue {
                id: confirmOptBtn;
                anchors.right: cancelOptBtn.left;
                anchors.rightMargin: 20//125 * scaleWidthFactor;
                textCon: emapLang.confirm;
                width: 60 * scaleFullWidthFactor;
                onClicked: {
                    // console.log("确认======");
                    confirmAddLayer();
                }
            }

            CommonButtonBlue {
                id: cancelOptBtn;
                anchors.right: bottomBtnRec.right;
                anchors.rightMargin: 10//20 * scaleWidthFactor;
                textCon: emapLang.cancel;
                width: 60 * scaleFullWidthFactor;
                onClicked: {
                    console.log("取消======");
                    warningTxt.visible = false;
                    bShowBottomBtn = false;
                    bEditDisable = true;
                    bCanAddIcon = false;
                    var lastClickedId;
                    if(lastClickedLayerId)
                    {//回到上次点击的那个图层
                        lastClickedId = lastClickedLayerId;
                        getClickedLayerInfo(lastClickedId);
                        isCreateClicked = false;
                        if(bEditCanvas)
                        {
                            bShowOptBtn = false;
                        }
                        else
                        {
                            bShowOptBtn = true;
                        }
                    }
                    else
                    {//回到第一个图层
                        //console.log(curLayerInfos,"curLayerInfos============")
                        var curLayerInfos_1 = curLayerInfos;//JSON.parse(curLayerInfos);
                        if(curLayerInfos_1.length > 0)
                        {
//                            for(var j = 0; j < curLayerInfos_1.length; j++)
                            {
                                lastClickedId = curLayerInfos_1[0].id;
                                getClickedLayerInfo(lastClickedId);
                                bCanAddIcon = false;
                                isCreateClicked = false;
                            }
                            if(bEditCanvas)
                            {
                                bShowOptBtn = false;
                                arLayerManage.destroy();//如果是新建兴趣点进入的图层管理 取消操作 关闭窗口
                            }
                            else
                            {
                                bShowOptBtn = true;
                            }
                        }
                        else
                        {//图层不存在 点击新增
                            bCanAddIcon = true;
                            bEditDisable = false;
                            curLayerAttrName = "";
                            layerAttrName.textInput = "";
                            bShowOptBtn = false;
                            bShowBottomBtn = true;
                            isEditModal = false;
                            isCreateClicked = true;
                            console.log("未创建图层");
                            arLayerManage.destroy();//如果图层不存在 点击取消 关闭窗口
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        //获取图层图标信息
        curIconInfo = ArConfig.armapList.arObjType;
        initIconInfoModel(curIconInfo);

        //获取所有图层信息 左侧
        var content = {}
        var curLayerInfo = getLayerInfo(content);
        if(curLayerInfo == undefined)
        {
            return;
        }
        initLayerInfoModel(curLayerInfo);

        curLayerInfos = curLayerInfo;//初始图信息层全局变量
        var curLayerInfos_1 = curLayerInfos;
//        console.log(JSON.stringify(curLayerInfos));
        if(curLayerInfos_1.length > 0)
        {
//            for(var j = 0; j < curLayerInfos_1.length; j++)
            {
                firstClickedId = curLayerInfos_1[0].id;
                firstClickedType = curLayerInfos_1[0].type;
                //firstClickedValue = curLayerInfos_1[0].value;
                getClickedLayerInfo(firstClickedId);
                bCanAddIcon = false;
                isCreateClicked = false;
                bShowBottomBtn = false;
                bEditDisable = true;
                if(bEditCanvas)
                {
                    bShowOptBtn = false;
                }
                else
                {
                    bShowOptBtn = true;
                }
            }
            //console.log(firstClickedType,firstClickedValue,"firstClickedType==========")
        }
        else//如果图层信息为空 显示新增界面，默认显示新增属性行
        {
            detailOptModel.clear();
            var oneObj = {};
            oneObj.attrNameText = "";
            oneObj.attrAliasText = "";
            detailOptModel.append(oneObj);
        }
    }
}
