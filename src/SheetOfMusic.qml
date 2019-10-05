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

Rectangle {
    id: theSheet
    property var notes: []

    function pushNote(color) {
        if (notes.length < theGrid.columns) {
            notes.push(color);
            notesChanged();
        }

        // TODO Emit that sheet of music is full
    }


    Grid {
        id: theGrid
        anchors.fill: parent
        rows: 2
        columns: 20

        function _cellColor(idx, notes) {
            let row = Math.floor(idx/theGrid.columns);
            let col = idx % theGrid.columns;
            let color = "white"
            if (col < notes.length) {
                let desColor = (row === 0) ? "blue" : "green"
                if (desColor === notes[col])
                    color = desColor;
            }

            return color;
        }

        Repeater {
            model: theGrid.rows * theGrid.columns
            Rectangle {
                color: theGrid._cellColor(index, theSheet.notes)
                border.color: "black"
                border.width: .1 * width
                width: theGrid.width / theGrid.columns
                height: theGrid.height / theGrid.rows
            }
        }
    }

}
