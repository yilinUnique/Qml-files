import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import eplatplugins.qtdata 1.0

import "qrc:/component/qml/component/common/"
import "qrc:/component/qml/component/common/blue/"
import "qrc:/commonpage/qml/commonpage"
import "qrc:/js/qml/js/common/common.js" as CommonFun
import "qrc:/js/qml/js/common/navconfig.js" as NavConfig
import "qrc:/js/qml/js/common/emapCommon.js" as EcommonFun
import "qrc:/js/qml/js/common/emapConfig.js" as EmapConfig
import "qrc:/js/qml/js/common/armapConfig.js" as ArConfig
import "qrc:/js/qml/js/common/armapCommon.js" as ArCommonFun

Rectangle {
    id: arFunctionRect

    property color bgColor: NavConfig.ColorList.colorBgnNum3.bgColor;//"#38393d";
    property color traceBgColor: NavConfig.ColorList.colorBgnNum3.btnBckColor;//"#333438"
    property color traceBgColor2: NavConfig.ColorList.colorBgnNum3.traceBgColor;//"#282a2d"
    property color myTextColor: NavConfig.ColorList.colorBgnNumOther.dataColor;//文本编辑框内文本颜色
    property color borderColor:NavConfig.ColorList.colorBgnNum1.bordercolor;//"#15181a"
    property string fontFamily: NavConfig.FontList.fontFamilyNormal;
    property int myFontSize: NavConfig.FontList.fontSizeNormal;
    property int myFontSizeSmall: NavConfig.FontList.fontSizeSmall; // 12

    property int leftMarg: 20 * scaleWidthFactor;
    property int topMarg: 10 * scaleHeightFactor;
    property int leftPadding: 10 * scaleWidthFactor;
    property int titleHeight: 30;
    property int spaceing: 5;
    property int btnW: 44 * scaleWidthFactor;
    property int btnH: 43 * scaleHeightFactor;
    property int optBtnHeight: 37 * scaleHeightFactor
    property int optBtnWidth: 37 * scaleWidthFactor
    property int optBtnRectWidth: 38 * scaleWidthFactor;
    property int optBtnRectHeight: 374 * scaleHeightFactor;
    property int addObjRectWidth:  271// * scaleWidthFactor; //添加兴趣点区域的宽度
    property int addObjRectHeight:  197// * scaleHeightFactor;//添加兴趣点区域的高度
    property int layerCtrlWidth:  271 //* scaleWidthFactor; //添加兴趣点区域的宽度
    property int layerCtrlHeight:  741 //* scaleHeightFactor;//添加兴趣点区域的高度
    property var arObjCanvas: null;//标记ar兴趣点使用的canvas
    property ListModel funOptModel: ListModel{} //操作model
    property double bgOpacity: 0.3;
    property var funOptRectArray: [addArObjRect, layerCtl, searchArObjRect, toolRect]; //操作框

    //图层控制
    property var showInterestArr: new Array;//图层筛选选中的图层id数组
    property var allInterestArr: new Array;//初始显示的所有图层arr id值
    property var allInterestArr1: new Array;
    property var allScenceInfo;//所有的兴趣点信息
    property bool allSelect: true;//默认展示所有图层(高亮状态)
    property var allLayerIdInfo;//进来所有图层信息
    property bool bisSelecteds: true;
    property int cellwidth: 68;
    property int cellheight: 54;
    property string title: ArConfig.EmapLang.layerFilter;
    property var emapLang: ArConfig.EmapLang;//语言
    property var curIconInfo: ArConfig.armapList.arObjType;//图层图标
    property bool editCanvasArea: false;

    signal subscribeDev(var subscribeDevId);//父页面订阅
    signal getLayerValue(var value);

    width: 350;
    height: 800;

    //新建兴趣点工具model
    ListModel{
        id: addObjToolModel
    }

    ListModel{
        id: layerFilterModel
    }

    //初始化model
    function initAddObjToolModel()
    {
        var aMenuStrText = ArConfig.armapList.objList.addObjItem;
        addObjToolModel.append(aMenuStrText);
    }

    //初始化操作model，不包含图层管理
    function initFunOptModel()
    {
        funOptModel.clear();
        var funArr = ArConfig.armapList.arFunOptList;
        for(var idx = 2; idx < 4/*funArr.length - 1*/; idx++)
        {
            var obj = funArr[idx];
            obj.funOptRect = funOptRectArray[obj.value];
            funOptModel.append(obj);
        }
        console.log("funOptModel", funOptModel.count)
//        var obj = funArr[0];
//        obj.funOptRect = funOptRectArray[obj.value];
//        funOptModel.append(obj);
//        var obj1 = funArr[3];
//        obj1.funOptRect = funOptRectArray[obj1.value];
//        funOptModel.append(obj1);

    }

    //改变左侧操作按钮的状态
    //当value=-1, bSelected=false时，将所有的左侧按钮不选中
    function changeOneFunOptSelect(value, bSelected)
    {
        var idx = 0;
        var data = null;
        if(value === -1 && !bSelected)
        {
            for(idx = 0; idx < funOptModel.count; idx++)
            {
                data = funOptModel.get(idx);
                funOptModel.setProperty(idx, "selected", false);
                data.funOptRect.visible = false;
            }
        }
        else
        {
            for(idx = 0; idx < funOptModel.count; idx++)
            {
                data = funOptModel.get(idx);
                if(data.value == value)
                {
                    funOptModel.setProperty(idx, "selected", bSelected);
                    data.funOptRect.visible = bSelected;
                }
                else if(bSelected)
                {
                    funOptModel.setProperty(idx, "selected", false);
                    data.funOptRect.visible = false;
                }
            }
        }
    }

    //开始画图
    function startAddArObj(arCanvas, msgIndex)
    {
        var info = {
            "color": "#0000FF",//"#FF0000",//"red",
            "lineWidth": 2
        }
        if(arCanvas == null)
        {
            return;
        }

        if(arVideoRect.videoSource !== "") {
            switch(msgIndex)
            {
            case 2://多边形
                console.log("多边形1111=====>");
                info={
                    "color": "#0000FF",
                    "fillColor":"#0000FF",//"lightgrey",
                    "fillOpacity":0.5,
                    "lineWidth":2
                }
                arCanvas.beginDraw("polygon", info);
                break;
            case 0://点
                console.log("点选1111=====>");
                info = {
                    "type":ArConfig.armapList.arDevPointList[0].type,
                   // "url":ArConfig.armapList.arDevPointList[0].icon_normal,//"qrc:/image/qml/image/btn/ar/dev-tip-bg.png",
                   // "url_select":ArConfig.armapList.arDevPointList[0].icon_down,
                   // "width": ArConfig.armapList.arDevPointList[0].width,//263,
                   // "height":ArConfig.armapList.arDevPointList[0].height, //103,
                   // "offsetX": ArConfig.armapList.arDevPointList[0].offsetX,//-16,
                   // "offsetY": ArConfig.armapList.arDevPointList[0].offsetY,//-84
                    "typeIcon":"",//ArConfig.armapList.arObjType[0].image,

                }
                arCanvas.beginDraw("point", info);
                break;
            case 1://线
                console.log("线选1111=====>");
                arCanvas.beginDraw("line", info);
                break;
            case 3://文本
                var info = {
                    "type": "text",
                    "text": "eagle AR地图"+Math.random() * 360,
                    "color":"#D3D3D3",// "blue",
                    "fontSize": 14,
                    "fontFamily": "Microsoft Yahei",
                    "rotate": 0,//Math.random() * 360
                    "boldSelected":false,
                    "italicSelected":false,
                    "underlineSelected":false
                }
                arCanvas.beginDraw("point", info);
                break;
            case 4: //标记
                //console.log("标记1111=====>");
                arCanvas.markShapeArr = [];
                var info4 = {
                    "color": "#0000FF",
                    "fillColor": "#0000FF",
                    "fillOpacity":0.5,
                    "lineWidth":2
                }
                arCanvas.beginDraw("mark", info4);
                break;
            default:
                break;
            }
        } else {
            console.log("请选择视频进行标注");
        }
    }

    //重新计算兴趣点的位置
    function reLocationScenceObjects(objects)
    {
        console.log("scenceObjectInfos", objects)
        for(var idx = 0; idx < objects.length; idx++)
        {
            var data = JSON.parse(JSON.stringify(objects[idx]));
//            console.log("scenceObjectInfoAAs", JSON.stringify(data))
            var geo = JSON.parse(data.geometry);
            if(!!geo.points)
            {
                var screenXY = realPointToScreenPoint(geo.points);
                geo.points = screenXY;
                data.geometry = geo;
                var obj = {
                    "geometry": geo,
                    "attribute": JSON.parse(data.attribute)
                }
                //console.log("换算成屏幕坐标====",JSON.stringify(obj));
                arCanvas.editCanvasItem(data.id, obj);
            }
        }
        arCanvas.requestPaint();
    }

    //更新兴趣点bVisible的值 传坐标、属性、bVisible 其他不要动
    function updateVisibleState(object, bVisibles)
    {
        //console.log("bVisible==========",bVisibles,JSON.stringify(object))

        var data = JSON.parse(JSON.stringify(object));
        data.bVisible = bVisibles;
        var attributes = data.attribute;
        if(!!attributes)
        {
            data.attribute = JSON.parse(attributes);
        }

        if(!!data.geometry)
        {
            var geo = JSON.parse(data.geometry);
            if(!!geo.points)
            {
                var screenXY = realPointToScreenPoint(geo.points);
                geo.points = screenXY;
                //console.log("换算成屏幕坐标====",JSON.stringify(obj.geometry));
            }
            data.geometry = geo;
        }

        var obj = {
            "geometry": data.geometry,
            "attribute": data.attribute,
            "bVisible": data.bVisible
        }

        return obj;
    }

    //转化获取到的数据格式
    function transferDataFormat(scenceInterest, bVisibles)
    {
        //console.log(JSON.stringify(scenceInterest),"scenceInterest.layerData")
        var obj = {
            "id": scenceInterest.id,
            "name": scenceInterest.name,
            "attribute": {},
            "layerId": "",
            "bVisible": false,
            "isDetailVisible": false,
            "layerData": {},
            "layerUserData": [],
            "alarmInfo": {},
            "relatedId": "",
            "devInfo": {},
            "geometry": {},
            "bLocked":scenceInterest.bLocked
        };
        //obj.id = scenceInterest.id;
        //obj.name = scenceInterest.name;
        //obj.geometry = JSON.parse(scenceInterest.geometry);
        if(!!scenceInterest.attribute)
        {
            obj.attribute = JSON.parse(scenceInterest.attribute);
        }
        //obj.attribute = JSON.parse(scenceInterest.attribute);
        obj.layerId = scenceInterest.layerId;
        obj.bVisible = bVisibles;
        if(!!scenceInterest.layerData)
        {
            obj.layerData = JSON.parse(scenceInterest.layerData);
        }
        //obj.layerData = JSON.parse(scenceInterest.layerData);
        if(!!scenceInterest.layerUserData)
        {
            obj.layerUserData = JSON.parse(scenceInterest.layerUserData);
        }
        //obj.layerUserData = JSON.parse(scenceInterest.layerUserData);
        obj.isDetailVisible = false;
        obj.alarmInfo = new Object;
        if(!!scenceInterest.relatedId)
        {
            obj.relatedId = scenceInterest.relatedId;
            var devInfo = CommonFun.getDeviceInfo(scenceInterest.relatedId);
            if(!!devInfo)
            {
                obj.devInfo = devInfo;
            }
        }

        if(!!scenceInterest.geometry)
        {
            var geo = JSON.parse(scenceInterest.geometry);
            if(!!geo.points)
            {
                var screenXY = realPointToScreenPoint(geo.points);
                geo.points = screenXY;
                //console.log("换算成屏幕坐标====",JSON.stringify(obj.geometry));
            }
            obj.geometry = geo;
        }

        //console.log(JSON.stringify(obj),"json obj==============");
        return obj;
    }

    /**
     * 进行筛选的时候调用 进来是默认全选 画出所有兴趣点
     * @param scenceInfo 界面上所有的兴趣点信息
     * @param bSubscribe 是否订阅
     * @param allInterestArrs 界面图层id(初始是所有)
     * @param optId 非全选状态下点击的图层id
     * @param visibleState 非全选状态下点击的图层 显示/隐藏状态
    **/
    function showInterestArrs(scenceInfo, bSubscribe, allInterestArrs, optId, visibleState)
    {
        console.log("初始化的场景信息======",JSON.stringify(scenceInfo))
        if(allInterestArrs.length > 0)//初次进入 和 操作非全选图层 allInterestArrs存在
        {
            if(bSubscribe)//首次进入 清空画布 刻画所有兴趣点 bVisible=true
            {
                arCanvas.deleteAllLRComp();
                arCanvas.clearCanvasState();
                for(var k = 0; k < scenceInfo.length; k++)
                {
                    var oneInfo = scenceInfo[k];
                    var curIdx = allInterestArrs.indexOf(scenceInfo[k].layerId);
                    if(curIdx !== -1)
                    {
                        var obj_1 = transferDataFormat(oneInfo, true);

                        //if(bSubscribe)
                        //{
                            arCanvas.addItemsToCanvas(obj_1);

                        //}

                        //if(bSubscribe)
                        //{
                            if(!!oneInfo.relatedId && scenceDevIds.indexOf(info.relatedId) == -1)
                            {
                                scenceDevIds.push(oneInfo.relatedId);
                            }
                        //}
                    }
                }
                arCanvas.drawing();
            }
            else//后面操作 控制bVisible
            {
                if(scenceInfo && scenceInfo.length > 0)
                {
                    for(var j = 0; j < scenceInfo.length; j++)
                    {
                        if(optId == scenceInfo[j].layerId)
                        {
                            var obj_2 = updateVisibleState(scenceInfo[j], visibleState);
                            arCanvas.editCanvasItem(scenceInfo[j].id, obj_2);
                        }
                    }
                }
            }
        }
        else//操作全选图层 allInterestArrs为空
        {
            //refreshInterest();

            if(scenceInfo && scenceInfo.length > 0)
            {
                for(var i = 0; i < scenceInfo.length; i++)
                {
                    if(!!allSelect)
                    {
                        var obj_3 = updateVisibleState(scenceInfo[i], true);
                        arCanvas.editCanvasItem(scenceInfo[i].id, obj_3);
                    }
                    else
                    {
                        var obj_4 = updateVisibleState(scenceInfo[i], false);
                        arCanvas.editCanvasItem(scenceInfo[i].id, obj_4);
                    }
                }
            }
        }

        arCanvas.requestPaint();
        if(bSubscribe)
        {
            console.log(allSelect,"allSelect==========")
            allSelect = true;//初始化选中所有图层
            for(var ii = 0; ii < layerFilterModel.count; ii++)
            {
                layerFilterModel.set(ii, {"selected": true});
            }

            //订阅设备抓拍
            subscribeIpcSnap(scenceDevIds);
        }
    }

    //初始化时候调用一次 默认订阅为true
    function getMatchedInterest(bSubscribe)
    {
        //todo-----新建或修改兴趣点 及时更新
        ArCommonFun.getScenceInfo(curSceneId, function(scenceInfo){
            //console.log("scenceInfo=========",JSON.stringify(scenceInfo));
            allScenceInfo = scenceInfo;//界面上所有的兴趣点信息
            showInterestArrs(allScenceInfo, bSubscribe, allInterestArr);
        })
    }

    //刷新兴趣点信息
    function refreshInterest()
    {
        ArCommonFun.getScenceInfo(curSceneId, function(scenceInfo){
           // console.log("scenceInfo=========new",JSON.stringify(scenceInfo));
            allScenceInfo = scenceInfo;//刷新界面上所有的兴趣点信息
        })
    }

    //新增兴趣点操作
    function addNewInterest(newInterestInfo)
    {
        if(newInterestInfo.attribute)
        {
            newInterestInfo.attribute = JSON.stringify(newInterestInfo.attribute);
        }

        if(!!newInterestInfo.geometry && !!newInterestInfo.geometry.points)
        {
            var realPoints = screenPointToRealPoint(newInterestInfo.geometry.points);
            newInterestInfo.geometry.points = realPoints;
            newInterestInfo.geometry = JSON.stringify(newInterestInfo.geometry);
        }
        else
        {
            newInterestInfo.geometry = JSON.stringify(newInterestInfo.geometry);//执法仪
        }

        if(allScenceInfo.length > 0)
        {
            for(var k = 0; k < allScenceInfo.length; k++)
            {
                var oneInfo = allScenceInfo[k];
                var curId = newInterestInfo.id;

                var curIdx = curId.indexOf(allScenceInfo[k].id);
                if(curIdx == -1)
                {
                    allScenceInfo.push(newInterestInfo);
                }
            }
        }
        else
        {
            allScenceInfo.push(newInterestInfo);
        }

        //console.log(JSON.stringify(allScenceInfo),"allScenceInfo=============ADD")
    }

    //删除兴趣点操作
    function deleteOneInterest(id)
    {
        for(var k = allScenceInfo.length - 1; k >= 0; k--)
        {
            var oneInfo = allScenceInfo[k];
            if(id == oneInfo.id)
            {
                allScenceInfo.splice(k,1);
                break;
            }
        }
//        console.log(JSON.stringify(allScenceInfo),"allScenceInfo=============DELETE")
    }

    //修改兴趣点操作
    function modifyNewInterest(modifyInterestInfo)
    {
        console.log(JSON.stringify(modifyInterestInfo),"modifyInterestInfo==========")
        for(var idx = 0; idx < allScenceInfo.length; idx++)
        {
            var oneInfo = allScenceInfo[idx];
            if(modifyInterestInfo.id == oneInfo.id)
            {
//                console.log(JSON.stringify(oneInfo),"oneInfo1111==============")
                oneInfo = ArCommonFun.setObjectToArrayData(oneInfo, modifyInterestInfo);
//                console.log(JSON.stringify(oneInfo),"oneInfo==============")
                allScenceInfo[idx] = oneInfo;
                break;
            }
        }

//        console.log(JSON.stringify(allScenceInfo),"allScenceInfo=============MODIFY")
    }


    //获取所有图层信息
    function initLayerInfo()
    {
        layerFilterModel.clear();
        var info1 = {"name":emapLang.allSelect,"id":"allSelected",
            "image":ArConfig.armapList.layerFilterBg.allSelectIcon}
        layerFilterModel.append(info1);

        //图层筛选
        var content={};
        ArCommonFun.getLayerInfo(content,function(layerInfo)
        {
            allLayerIdInfo = layerInfo;
            getLayerValue(allLayerIdInfo);

            for(var i = 0; i < allLayerIdInfo.length; i++)
            {
                var info = allLayerIdInfo[i];
                allInterestArr.push(info.id);
                for(var j = 0; j < curIconInfo.length; j++)
                {
                    if(info.type == curIconInfo[j].value)//根据返回类型 匹配图标
                    {
                        info.image = curIconInfo[j].image;
                    }
                }
                layerFilterModel.append(info);
            }
            console.log(JSON.stringify(allLayerIdInfo),"allLayerIdInfo==============");
        });

        for(var k = 0; k < layerFilterModel.count; k++)
        {
            layerFilterModel.set(k, {"selected": true});//初始所有项都是checked
            console.log(layerFilterModel.get(k).name,"layerFilterModel==========")
        }
    }

    function createLayerComp(confirmCallBack)
    {
        if(confirmCallBack)
        {
            editCanvasArea = true;
        }
        else
        {
            editCanvasArea = false;
        }

        //图层管理组件
        var component = Qt.createComponent("qrc:/evss/qml/evss/armap/ArLayerManage.qml");
        console.log("createComponent ArLayerManage", component.errorString())
        if(component.status === Component.Ready)
        {
            var arLayer = component.createObject(arFunctionRect, {"visible": true,
                                                    "windowTitle": emapLang.layerManage,
                                                    "bEditCanvas": editCanvasArea,
                                                    "curSceneId": curSceneId});

            //设置窗口的位置--居中显示; //todo-----更新后的图层信息要传到编辑框中去
            CommonFun.getSubWindowsPos(arFunctionRect, arLayer, 1, 1);

            arLayer.confirmLayerOpt.connect(function(bEditModal, msgCurLayer, curAllLayerInfo)
            {
                getLayerValue(curAllLayerInfo);//传到arMap使用

                //console.log(JSON.stringify(msgCurLayer),"msgCurLayer=============");//新增或修改的图层信息 更新图层控制里的图层
                var newLayerinfo = {"name":"","id":"","image":""}
                newLayerinfo.id = msgCurLayer.id
                newLayerinfo.name = msgCurLayer.name
                for(var j = 0; j < curIconInfo.length; j++)
                {
                    if(msgCurLayer.type == curIconInfo[j].value)//根据返回类型 匹配图标
                    {
                        newLayerinfo.image = curIconInfo[j].image;
                    }
                }

                if(bEditModal)
                {
                    for(var i = 0; i < layerFilterModel.count; i++)
                    {
                        if(layerFilterModel.get(i).id == newLayerinfo.id)
                        {
                            //console.log(JSON.stringify(newLayerinfo),"修改==============")
                            layerFilterModel.set(i,newLayerinfo);
                        }
                    }
                }
                else
                {
                    newLayerinfo.selected = true;
                    //console.log(JSON.stringify(newLayerinfo),"新增==============")
                    layerFilterModel.append(newLayerinfo);
                }


                if(confirmCallBack)
                {
                    confirmCallBack(msgCurLayer);
                }

                if(editCanvasArea)
                {
                    arLayer.destroy();//在新建兴趣点里面新建图层后 关闭图层管理
                }
            })

            arLayer.deleteLayerOpt.connect(function(curInterestArrs,deleteLayerid,curAllLayerInfo){//图层管理---删除图层后的操作 更新图层控制里的图层
                //console.log(JSON.stringify(curInterestArrs),"删除的图层兴趣点==========");
                getLayerValue(curAllLayerInfo);//传到arMap使用

                //for(var i = 0; i < curInterestArrs.length; i++)
                for(var i = curInterestArrs.length - 1; i >= 0; i--)
                {
                    arCanvas.removeShape(curInterestArrs[i].id);
                }

                //for(var idx = 0; idx < layerFilterModel.count; idx++)
                for(var idx = layerFilterModel.count - 1; idx >= 0; idx--)
                {
                    if(layerFilterModel.get(idx).id == deleteLayerid)
                    {
                        layerFilterModel.remove(idx);
                    }
                }

                var selecteds = [];
                for(var k = 0; k < layerFilterModel.count; k++)
                {
                    if(layerFilterModel.get(k).id != "allSelected")
                    {
                        selecteds.push(layerFilterModel.get(k).selected);
                    }
                }

                var resArr = selecteds.filter(function(item){
                    return item == false
                });

                //console.log(resArr.length,"resArr.length===========")
                if(resArr.length > 0)
                {
                    layerFilterModel.set(0, {"selected": false});//不高亮
                    allSelect = false;
                }
                else
                {
                    layerFilterModel.set(0, {"selected": true});//高亮
                    allSelect = true;
                }
            })
        }
    }

    //获取需要显示的图层id
    function getSelectedLayerid(state)
    {
        var idArray = [];
        for(var i = 0; i < layerFilterModel.count; i++)
        {
            if(layerFilterModel.get(i).id != "allSelected" && !!layerFilterModel.get(i).selected)
            {
                idArray.push(layerFilterModel.get(i).id)
            }
        }
        //console.log(JSON.stringify(idArray),"idArray===========");
        return idArray;
    }

    Component.onCompleted: {
        initFunOptModel();
        initAddObjToolModel();
        initLayerInfo();
    }

    //图层筛选component
    Component {
        id: layerFilterDtl
        Rectangle {
            id: layerFilterComp
            width: cellwidth;
            height: cellheight;
            color: "transparent";

            ImageTextVertButtonEllipsis {
                id: imageTextBtn
                width: cellwidth
                height: cellheight
                //anchors.fill: parent
                fontSize: myFontSizeSmall
                space: spaceing
                spaceImg: 2
                textCon: model.name
                toolTips: model.name
                imgNormal: model.image;
                imgHover: model.image;
                imgDown: model.image;
                imgDisable: model.image;
                bgNormal: ArConfig.armapList.layerFilterBg.iconLeave
                bgHover: ArConfig.armapList.layerFilterBg.iconDown
                bgDown: ArConfig.armapList.layerFilterBg.iconDown
                bgDisable: ArConfig.armapList.layerFilterBg.iconLeave
                bIsEnabled: true;
                bisSelected: model.selected;
                bSelectedEnabled: true;
                btnForModel: true;
                onClicked: {
                    model.selected = !model.selected;

                    //refreshInterest();

                    //console.log(JSON.stringify(allScenceInfo),"点击前的场景信息===============")

                    if(model.id !== "allSelected")
                    {
                        var curSelectedArr = getSelectedLayerid();//当前选中的图层id;
                        if(model.selected)
                        {
                            showInterestArrs(allScenceInfo, false, curSelectedArr, model.id, true)//show
                        }
                        else
                        {
                            showInterestArrs(allScenceInfo, false, curSelectedArr, model.id, false)//hide
                        }

                        //根据当前显示的图层个数 判断全选的高亮状态
                        if(curSelectedArr.length < layerFilterModel.count - 1)//多了一个全选
                        {
                            layerFilterModel.set(0, {"selected": false});//不高亮
                            allSelect = false;
                        }
                        else
                        {
                            layerFilterModel.set(0, {"selected": true});//高亮
                            allSelect = true;
                        }
                    }
                    else
                    {
                        var showInterestArr = [];
                        if(!!allSelect)//全选状态下
                        {
                            //本来是全选 现在取消全选
                            allSelect = false;//取消全选
                            showInterestArrs(allScenceInfo, false, showInterestArr)
                            for(var jj = 0; jj < layerFilterModel.count; jj++)
                            {
                                layerFilterModel.set(jj, {"selected": false})
                            }
                        }
                        else if(allSelect == false)//未全选状态下
                        {
                            //本来是非全选 现在进行全选
                            allSelect = true;//全选
                            showInterestArrs(allScenceInfo, false, showInterestArr)
                            for(var ii = 0; ii < layerFilterModel.count; ii++)
                            {
                                layerFilterModel.set(ii, {"selected": true})
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle{
        id: bgRect
        anchors.fill: parent
        color: bgColor
        opacity: bgOpacity
        border.width: 1
        border.color: "blue"
    }
    Rectangle{
        id: leftOptRect
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -25
        width: optBtnRectWidth
        height: optBtnRectHeight
        color: "transparent"
        //防止鼠标点击事件触发导致取消选中设备
        MouseArea{
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {

            }
        }
        //底图
        Image{
            id: rightBg
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 19
            source: ArConfig.arContolList.leftOptBg
        }
        Column{
            id: leftOptCol
            anchors.right: rightBg.right
            anchors.rightMargin: -optBtnWidth / 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            //路人识别是否可用
            ImageButton{
                id: passerBtn
                width: optBtnWidth;
                height: optBtnWidth
                bIsNeedBgPic: false
                toolTip: ArConfig.armapList.arFunOptList[1].text
                imgnormal: ArConfig.armapList.arFunOptList[1].icon_normal
                imghover: ArConfig.armapList.arFunOptList[1].icon_down
                imgdown: ArConfig.armapList.arFunOptList[1].icon_down
                bSelectedEnabled: true
                bisSelected: bShowPasserInfo
                onClicked: {
                    bShowPasserInfo = bisSelected;
                }
            }
            Repeater{
                model: funOptModel
                ImageButton{
                    id: snapBtn
                    width: optBtnWidth;
                    height: optBtnWidth
                    bIsNeedBgPic: false
                    toolTip: model.text
                    imgnormal: model.icon_normal
                    imghover: model.icon_down
                    imgdown: model.icon_down
                    btnForModel: true
                    bSelectedEnabled: true
                    bisSelected: model.selected

                    onClicked: {
                        model.selected = !model.selected;
                        model.funOptRect.visible = model.selected;
                        if(model.selected)
                        {
                            for(var idx = 0; idx < funOptModel.count; idx++)
                            {
                                if(idx != index)
                                {
                                    var data = funOptModel.get(idx);
                                    funOptModel.setProperty(idx, "selected", false);
                                    data.funOptRect.visible = false;
                                }
                            }
                        }
                        if(model.value == ArConfig.armapList.arFunOptList[2].value)//图层控制
                        {
                            refreshInterest();
                        }
                    }
                }
            }
            //图层管理
            ImageButton{
                id: manageLayerBtn
                width: optBtnWidth;
                height: optBtnWidth
                bIsNeedBgPic: false
                toolTip: ArConfig.armapList.arFunOptList[0].text
                imgnormal: ArConfig.armapList.arFunOptList[0].icon_normal
                imghover: ArConfig.armapList.arFunOptList[0].icon_down
                imgdown: ArConfig.armapList.arFunOptList[0].icon_down
                bSelectedEnabled: false
                onClicked: {
                    ArCommonFun.changeOneFunOptSelect(funOptModel, -1, false);
                    createLayerComp();
                }
            }
        }
    }

    //右侧的操作区域
    Rectangle{
        id: functionRect
        anchors.left: leftOptRect.right
        anchors.leftMargin: leftPadding
        anchors.verticalCenter: parent.verticalCenter
        color:"transparent"
//        width: layerCtrlWidth
        height: optBtnRectHeight
        //新增兴趣点
        Rectangle{
            id: addArObjRect
            anchors.left: parent.left
            anchors.top: parent.top
            width: addObjRectWidth
            height: addObjRectHeight
            color: "transparent"
            visible: false
            //防止鼠标点击事件触发导致取消选中设备
            MouseArea{
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {

                }
            }
            //底图
            Image{
                anchors.fill: parent
                source: ArConfig.arContolList.toolBg
                cache: false
            }
            Text{
                id: addTitle
                anchors.left: addRow.left
                anchors.top: parent.top
                anchors.topMargin: topMarg
                text: ArConfig.armapList.arFunOptList[2].name
                font.pixelSize: myFontSize
                font.family:fontFamily
                color: myTextColor
            }

            GridView{
                id: addRow
                anchors.left: parent.left
                anchors.leftMargin: leftMarg
                anchors.top: addTitle.bottom
                anchors.topMargin: topMarg
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                model:addObjToolModel
                cellWidth: cellwidth + leftPadding / 2
                cellHeight: cellheight + topMarg
                delegate: Component{
                    id: addObjComp
                    ImageTextVertButton{
                        width: cellwidth;
                        height: cellheight;
                        fontSize: myFontSizeSmall
                        space: spaceing
                        spaceImg: 2
                        textCon: model.name
                        imgNormal: model.iconPath;
                        imgHover: model.selectedicon;
                        imgDown: model.downicon;
                        imgDisable: model.downicon;
                        bgNormal: ArConfig.armapList.layerFilterBg.iconLeave
                        bgHover: ArConfig.armapList.layerFilterBg.iconDown
                        bgDown: ArConfig.armapList.layerFilterBg.iconDown
                        bgDisable: ArConfig.armapList.layerFilterBg.iconLeave
                        bIsEnabled: true;
                        onClicked:{
                            if(model.value == 5)
                            {
                                //展台，移动设备，没有具体位置
                                var obj={
                                    "id": "",
                                    "name": "",
                                    "attribute": {"type":"mobile","typeIcon":""},
                                    "layerId": "",
                                    "bVisible": true,
                                    "isDetailVisible": false,
                                    "layerData": {},
                                    "layerUserData": [],
                                    "alarmInfo": {},
                                    "relatedId": "",
                                    "devInfo": {},
                                    "geometry": {"type":"point"},
                                    "belongsId":"",
                                    "bLocked":0//默认不锁定
                                }

                                setImagePoint(obj,"add");
                            }
                            else
                            {
                                //开启画图功能
                                startAddArObj(arObjCanvas, index);
                            }

                            //关闭画图操作窗口
                            //ArConfig.armapList.arFunOptList[2].value
                            changeOneFunOptSelect(0, false);
                        }
                    }
                }
            }
        }

        //搜索兴趣点
        Rectangle{
            id: searchArObjRect
            anchors.left: parent.left
            anchors.top: parent.top
            width: layerCtrlWidth
            height: layerCtrlHeight
            color: "transparent"
            visible: false
            //防止鼠标点击事件触发导致取消选中设备
            MouseArea{
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {

                }
            }
            //底图
            Image{
                anchors.fill: parent
                source: ArConfig.arContolList.searchBg
                visible: parent.visible
            }
            Text{
                anchors.left: parent.left
                anchors.leftMargin: leftMarg
                anchors.top: parent.top
                anchors.topMargin: topMarg
                text: ArConfig.armapList.arFunOptList[3].text
                font.pixelSize: myFontSize
                font.family:fontFamily
                color: myTextColor
            }
        }
        //工具
        Rectangle{
            id: toolRect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 100
            width: addObjRectWidth
            height: addObjRectHeight
            color: "transparent"
            visible: false
            //防止鼠标点击事件触发导致取消选中设备
            MouseArea{
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked: {

                }
            }
            //底图
            Image{
                anchors.fill: parent
                source: ArConfig.arContolList.toolBg
                visible: parent.visible
            }
            Text{
                anchors.left: parent.left
                anchors.leftMargin: leftMarg
                anchors.top: parent.top
                anchors.topMargin: topMarg
                text: ArConfig.armapList.arFunOptList[4].text
                font.pixelSize: myFontSize
                font.family:fontFamily
                color: myTextColor
            }
            //雨刷器
        }

    }

    //图层控制
    Rectangle{
        id: layerCtl
        anchors.left: leftOptRect.right
        anchors.leftMargin: 10//leftPadding
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        width: layerCtrlWidth
        height: layerCtrlHeight
        color: "transparent"
        visible: false
        //防止鼠标点击事件触发导致取消选中设备
        MouseArea{
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {

            }
        }
        //底图
        Image{
            anchors.fill: parent
            source: ArConfig.arContolList.layerCtlBg
            visible: parent.visible
        }

        Rectangle{
            id: layerFilterTitleRect
            anchors.top: parent.top
            anchors.topMargin: 10//topMarg
            anchors.left: parent.left
            //anchors.leftMargin: 5
            height: titleHeight
            color: "transparent"

            Text{
                id: filterTitleTxt
                anchors.left: parent.left
                anchors.leftMargin: 20//leftMarg
                color: myTextColor;
                font.pixelSize: myFontSize;
                font.family: fontFamily;
                verticalAlignment: Text.AlignVCenter;
                anchors.verticalCenter: parent.verticalCenter;
                text: title;
            }
        }

        Rectangle{
            id: layerFilterRec
            anchors.left: parent.left
            //anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.topMargin: 5
            anchors.top: layerFilterTitleRect.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20//topMarg * 2
//                visible: layerCtl.visible
            color: "transparent"

            ScrollViewCustomizeBlue{
                id: layerFilterScroll
                //anchors.fill: parent;
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 20//leftMarg
                anchors.right: parent.right
               // anchors.bottom: parent.bottom
                height: 620//*scaleHeightFactor
                width: parent.width;
                horizontalScrollBarFixed : Qt.ScrollBarAlwaysOff;

                GridView {
                    id: layerFilterView;
                    anchors.fill: parent;
                    cellWidth: cellwidth + 10
                    cellHeight: cellheight + 10
                    model: layerFilterModel;
                    delegate: layerFilterDtl;
                    currentIndex: -1
                    clip: true;
                    focus: true;
                    keyNavigationWraps: true;
                    onCurrentIndexChanged: {

                    }
                }
            }
        }
    }
}
