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
import Clayground.Physics 1.0

VisualizedBoxBody
{
    id: thePlayer
    bodyType: Body.Dynamic
    color: "#3fa4c8"
    bullet: true
    property real maxVelo: 25
    categories: collCats.cPlayer
    collidesWith: collCats.cWall

    function moveUp() { body.linearVelocity.y = -maxVelo; }
    function moveDown() { body.linearVelocity.y = maxVelo; }
    function moveLeft() { body.linearVelocity.x = -maxVelo; }
    function moveRight() { body.linearVelocity.x = maxVelo; }

    function stopUp() { if (body.linearVelocity.y < 0) body.linearVelocity.y = 0; }
    function stopDown() { if (body.linearVelocity.y > 0) body.linearVelocity.y = 0; }
    function stopLeft() { if (body.linearVelocity.x < 0) body.linearVelocity.x = 0; }
    function stopRight() { if (body.linearVelocity.x > 0) body.linearVelocity.x = 0; }

    signal caughtSounding(var sounding);

    Component.onCompleted: {
        let obj = thinkSpaceComp.createObject(thePlayer,{});
        obj.beginContact.connect(_soundingDetected);
//        obj.endContact.connect(_soundingLost);
        body.addFixture(obj);
    }

    function _soundingDetected(fixture) {
        console.log("That might sound good ...");
        thePlayer.caughtSounding(fixture.getBody().target);
    }

//    function _soundingLost(fixture) {
//        console.log("... don't mind, just a bad idea");
//    }

    Component {
        id: thinkSpaceComp
        Box {
            x: -thePlayer.width
            y: -thePlayer.height
            width: thePlayer.width * 3
            height: thePlayer.height * 3
            sensor: true
            categories: collCats.cThinkSpace
            collidesWith: collCats.cSounding
        }
    }
}
