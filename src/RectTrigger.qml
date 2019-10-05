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

VisualizedBoxBody {
    id: theTrigger
    color: "grey"
    sensor: true
    categories: Box.Category16
    signal triggered(var entity)

    Component.onCompleted: {
        console.log("#fixtures: " + theTrigger.fixtures.length)
        for (let i=0; i<fixtures.length; ++i) {
            let f = fixtures[i];
            f.beginContact.connect(_collidesWith);
        }
    }

    function _collidesWith(fixture) {
        var entity = fixture.getBody().target;
        triggered(entity);
    }

    function makeTriggerableBy(body) {
        body.collidesWith = body.collidesWith | Box.Category16
    }
}
