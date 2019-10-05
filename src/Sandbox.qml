/*
 * Copyright (c) 2019 Serein Pfeiffer <serein.pfeiffer@gmail.com>
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software in
 *    a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution.
 *
 */
import QtQuick 2.12
import Box2D 2.0
import Clayground.SvgUtils 1.0
import Clayground.ScalingCanvas 1.0
import Clayground.GameController 1.0

CoordCanvas {
    id: world
    anchors.fill: parent
    pixelPerUnit: height / world.worldYMax

    property bool standaloneApp: false
    readonly property string map: (standaloneApp ? ":/" : ClayLiveLoader.sandboxDir)
                         + "/map.svg"
    readonly property string resPrefix: world.standaloneApp ? "qrc:/" : ""

    World {
        id: physicsWorld
        gravity: Qt.point(0,0)
        timeStep: 1/60.0
        pixelsPerMeter: pixelPerUnit
    }

    property var player: null

    Keys.forwardTo: gameCtrl
    GameController {
        id: gameCtrl
        anchors.fill: parent
        Component.onCompleted: {
            selectKeyboard(Qt.Key_Up, Qt.Key_Down, Qt.Key_Left, Qt.Key_Right, Qt.Key_A, Qt.Key_S);
        }

        onAxisXChanged: {
            if (axisX > 0) player.moveRight();
            else if (axisX < 0) player.moveLeft();
            else { player.stopLeft(); player.stopRight();}
        }
        onAxisYChanged: {
            if (axisY > 0) player.moveUp();
            else if (axisY < 0) player.moveDown();
            else { player.stopUp(); player.stopDown();}
        }

        function destroyOneSounding(color) {
            let objs = theSvgInspector.objs;
            let hit = -1
            for (let i=0; i<objs.length; ++i) {
                if (objs[i].noteColor && objs[i].noteColor === color) hit = i;
            }
            if (hit >= 0) {
                objs[hit].destroy();
                let obj = objs.splice(hit, 1);
            }
        }

        onButtonAPressedChanged: {
            if (buttonAPressed) destroyOneSounding("green")
        }

        onButtonBPressedChanged: {
            if (buttonBPressed) destroyOneSounding("blue")
        }
    }

    SvgInspector
    {
        id: theSvgInspector
        property var objs: []

        Component.onCompleted: setSource(world.map)

        onBegin: {
            world.viewPortCenterWuX = 0;
            world.viewPortCenterWuY = 0;
            world.worldXMax = widthWu;
            world.worldYMax = heightWu;
            player = null;
            for (let obj of objs) obj.destroy();
            objs = [];
        }

        onRectangle: {
            let cfg = JSON.parse(description);
            let compStr = world.resPrefix + cfg["component"];
            let comp = Qt.createComponent(compStr);

            let obj = null;
            let hasNoPhysics = compStr.includes("Sounding");
            if (hasNoPhysics) {
                obj = comp.createObject(coordSys,
                                {canvas: world,
                                 xWu: x,
                                 yWu: y,
                                 widthWu: width,
                                 heightWu: height,
                                 noteColor: cfg["color"]});
            }
            else {
                obj = comp.createObject(coordSys, {world: physicsWorld, xWu: x, yWu: y, widthWu: width, heightWu: height, color: "#3e1900"});
                obj.pixelPerUnit = Qt.binding( _ => {return world.pixelPerUnit;} );
                if (compStr === (world.resPrefix + "Player.qml")) {
                    player = obj;
                    player.color = "#d45500";
                    world.observedItem = player;
                }
            }

            objs.push(obj);
        }

    }

}
