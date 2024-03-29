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

QtObject {

    readonly property int cWall: Box.Category1;
    readonly property int cPlayer: Box.Category2;
    readonly property int cSounding: Box.Category3;
    readonly property int cThinkSpace: Box.Category4;


    // Path configuration so that the game can be developed with playground
    // but deployed as stand-alone app using Qt resource system
    readonly property string soundPath: (typeof ClayLiveLoader !== 'undefined'
                                         ? ClayLiveLoader.sandboxDir + "/sound"
                                         : "qrc:")
    readonly property string visualsPath: (typeof ClayLiveLoader !== 'undefined'
                                         ? ClayLiveLoader.sandboxDir + "/visuals"
                                         : "qrc:")

    property var world: null
}
