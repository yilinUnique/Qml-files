import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import "qrc:/component/qml/component/common/"
import "qrc:/component/qml/component/common/blue/"
import "qrc:/js/qml/js/common/navconfig.js" as NavConfig
import "qrc:/js/qml/js/common/armapConfig.js" as ArConfig

//Add by csy

//AR图层管理-图标选择弹出页
CommonWindowBlue{
    id: arLayerOption;
    property var arLayerModel;
    property var layerIconValue;
    property var curIconInfo;
    property int cellwidth: 90 * scaleWidthFactor;
    property int cellheight: 80;

    signal clickedLayerInfo(var layerInfo)//点击的图层信息

    bgOpacity: 1;
    bCloseBtnVisible: true;
    bhaveTitle: false;
    width: 660 * scaleWidthFactor;
//    height: 290 * scaleHeightFactor;
    height: 386 * scaleHeightFactor;


    Component.onCompleted: {
        //console.log(layerIconValue,"layerIconValue===============");
        for(var i = 0; i < arLayerModel.count; i++)
        {
            arLayerModel.set(i,{"selected": false});
            if(layerIconValue && arLayerModel.get(i).value == layerIconValue)
            {
                arLayerModel.set(i,{"selected": true})
            }
        }
    }

    //图层icon component
    Component {
        id: layerFilterDtl
        Rectangle {
            id: layerFilterComp
            width: 68;
            height: 54;
            color: "transparent";

            ImageTextVertButtonEllipsis {
                id: imageTextBtn
                width: 68;
                height: 54;
                anchors.fill: parent
                fontSize: 12
                space: 5
                spaceImg: 2
                textCon: model.text
                toolTips: model.text
                imgNormal: model.image;
                imgHover: model.image;
                imgDown: model.image;
                imgDisable: model.image;
                bgNormal: ArConfig.armapList.layerFilterBg.iconLeave
                bgHover: ArConfig.armapList.layerFilterBg.iconDown
                bgDown: ArConfig.armapList.layerFilterBg.iconDown
                bgDisable: ArConfig.armapList.layerFilterBg.iconLeave
                bisSelected: model.selected;
                bSelectedEnabled: true;
                onClicked: {
                    var layerInfo = arLayerModel.get(index);
                    clickedLayerInfo(layerInfo);
                }
            }
        }
    }

    Rectangle{
        id: layerFilterRec
        color: "transparent"
        visible: true;
        width: 660 * scaleWidthFactor;
        height: 386 * scaleHeightFactor;

        ScrollViewCustomizeBlue{
            id: layerFilterScroll
            anchors.fill: parent;
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 20 * scaleWidthFactor
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            focus: true;
            horizontalScrollBarFixed : Qt.ScrollBarAlwaysOff;

            GridView {
                id: layerFilterView;
                anchors.fill: parent;
                cellWidth: cellwidth
                cellHeight: cellheight
                model: arLayerModel;
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
