cmake_minimum_required (VERSION 3.5.0 FATAL_ERROR)
project (empty_sheet_of_music)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)

add_executable (${PROJECT_NAME}
    main.cpp
    main.qml
    GameConfig.qml
    Decoration.qml
    Entrance.qml
    RectTrigger.qml
    Sandbox.qml
    SheetOfMusic.qml
    Sounding.qml
    StageTrigger.qml
    Player.qml
    Wall.qml
    res.qrc
    sound/sound.qrc
    visuals/visuals.qrc
)

set_target_properties (${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS NO
)

target_link_libraries(${PROJECT_NAME}
PRIVATE
  Qt5::Core
  Qt5::Quick
)
