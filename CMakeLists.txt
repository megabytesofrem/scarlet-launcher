cmake_minimum_required(VERSION 3.16)
project(scarlet-launcher)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets Qml Quick Sql QuickControls2)

qt_standard_project_setup()

qt_add_executable(scarlet-launcher
    src/app_window.cpp
    src/app_window.h
    src/main.cpp
    src/model/list_model.cpp
    src/model/list_model.h
    src/model/store.h

    src/provider/icon_provider.h
    src/provider/theme_icon_provider.h

    src/wine_worker.cpp
    src/wine_worker.h
    src/utils.cpp
    src/utils.h
)

# Automatically find all QML files
file(GLOB_RECURSE QML_SOURCES 
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "qml/*.qml"
)

message(STATUS "Found QML files: ${QML_SOURCES}")


qt_add_qml_module(scarlet-launcher
    URI ScarletLauncher
    VERSION 1.0
    QML_FILES ${QML_SOURCES}
    RESOURCES
        qml/qmldir
        resources/icon.png
        resources/ui/icon_default.png
        resources/ui/icon_warning.png
    RESOURCE_PREFIX /
)

target_link_libraries(scarlet-launcher PRIVATE
    Qt6::Core
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
)
