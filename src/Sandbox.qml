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
import QtGamepad 1.0

CoordCanvas {
    id: world
    height: parent.height
    width: parent.width
    pixelPerUnit: .75 * width / 70

    property bool standaloneApp: typeof ClayLiveLoader === 'undefined'
    readonly property string qmlResPrefix: standaloneApp ? "qrc:/" : ""

    GameConfig {id: gameCfg; world: world}
    //DebugDraw { world: physicsWorld }

    World {
        id: physicsWorld
        gravity: Qt.point(0,0)
        timeStep: 1/60.0
        pixelsPerMeter: pixelPerUnit
    }

    property var player: null
    onPlayerChanged: {
       if (player) {
           gameCtrls.sync();
           player.caughtSounding.connect(onPlayerCaughtSound);
       }
    }

    function onPlayerCaughtSound(snd) {
        let objs = theSvgInspector.objs;
        let hit = -1
        for (let i=0; i<objs.length; ++i)
            if (objs[i] === snd) hit = i;

        if (hit >= 0) {
            objs[hit].destroy();
            let obj = objs.splice(hit, 1);
            theSheet.pushNote(snd.noteColor);
        }
    }

    function onPlayerEnteredStage() {
        theSheet.play();
    }

    Keys.forwardTo: gameCtrl
    Item {
        id: gameCtrls
        anchors.fill: parent

        GameController {
            id: gameCtrl
            anchors.fill: parent
            Component.onCompleted: {
                selectKeyboard(Qt.Key_Up, Qt.Key_Down, Qt.Key_Left, Qt.Key_Right, Qt.Key_A, Qt.Key_S);
            }

            onAxisXChanged: gameCtrls.updateXMovement(gameCtrl)
            onAxisYChanged: gameCtrls.updateYMovement(gameCtrl)
        }

        // Resynchronizes states of game input and
        // player movement
        function sync() {
            let moves = updateXMovement(gameCtrl);
            moves = moves || updateYMovement(gameCtrl);
            if (moves) return;
            let gamepadCand = onDemandGamepadLoader.item;
            if (gamepadCand) {
                updateXMovement(gamepadCand);
                updateYMovement(gamepadCand);
            }
        }

        function updateXMovement(ctrl) {
            if (ctrl.axisX > 0) player.moveRight();
            else if (ctrl.axisX < 0) player.moveLeft();
            else { player.stopLeft(); player.stopRight(); return false;}
            return true;
        }

        function updateYMovement(ctrl) {
            if (ctrl.axisY > 0) player.moveUp();
            else if (ctrl.axisY < 0) player.moveDown();
            else { player.stopUp(); player.stopDown(); return false;}
            return true;
        }

        Loader {
            id: onDemandGamepadLoader
            anchors.fill: parent
            property bool gamepadAvailable: GamepadManager.connectedGamepads.length > 0
            sourceComponent: gamepadAvailable ? gamepadComp : null
            Component {
                id: gamepadComp
                GameController {
                    id: gamepad
                    anchors.fill: parent
                    Component.onCompleted: { selectGamepad(0, true); }
                    onAxisXChanged: gameCtrls.updateXMovement(gamepad)
                    onAxisYChanged: gameCtrls.updateYMovement(gamepad)
                }
            }
        }
    }

    SvgInspector
    {
        id: theSvgInspector
        property var objs: []

        property string map: ""
        property string spawnLocation: "south"
        readonly property string _mapPath: (world.standaloneApp ? ":/" : ClayLiveLoader.sandboxDir)
                                      + "/" + map + ".svg"
        on_MapPathChanged: { if (map.length > 0) setSource(_mapPath); }
        Component.onCompleted: map = "map1"

        onBegin: {
            world.observedItem = null;
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
            let compStr = world.qmlResPrefix + cfg["component"];
            let comp = Qt.createComponent(compStr);

            let obj = comp.createObject(coordSys,{world: physicsWorld});
            obj.pixelPerUnit = Qt.binding( _ => {return world.pixelPerUnit;} );
            obj.visible = false;
            obj.xWu = x;
            obj.yWu = y;
            obj.widthWu = width;
            obj.heightWu = height;

            if (obj instanceof Player) {
                if (cfg["location"] !== theSvgInspector.spawnLocation) {
                   obj.destroy();
                   return;
                }
                player = obj;
                player.color = "#d45500";
                world.observedItem = player;
            }
            else if (obj instanceof Entrance) {
               obj.map = cfg["map"];
               obj.location = cfg["location"];
            }
            else if (obj instanceof Sounding) {
                obj.noteColor = cfg["color"];
            }

            obj.visible = true;
            objs.push(obj);
        }

        onEnd: {
            for (let o of objs) {
                if (o instanceof Entrance) {
                    o.makeTriggerableBy(player);
                    o.entered.connect(_changeMap)
                }
                if (o instanceof StageTrigger) {
                    o.makeTriggerableBy(player);
                    o.entered.connect(world.onPlayerEnteredStage);
                }
            }
        }

        function _changeMap(map, location) {
            theSvgInspector.spawnLocation = location;
            theSvgInspector.map = map;
        }
    }

    SheetOfMusic {
        id: theSheet
        width: parent.width * .5
        height: .05 * parent.height
        anchors {
           top: parent.top
           topMargin: height * .1
           horizontalCenter: parent.horizontalCenter
        }
        color: "black"
        opacity: .8
    }

}
