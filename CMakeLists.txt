cmake_minimum_required(VERSION 3.16)
project(scarlet-launcher)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets Qml Quick Sql QuickControls2)

qt_standard_project_setup()

qt_add_executable(scarlet-launcher
    src/app_window.cpp
    src/app_window.h
    src/icon_provider.h
    src/main.cpp
    src/model/list_model.cpp
    src/model/list_model.h
    src/model/store.h

    src/wine_worker.cpp
    src/wine_worker.h
    src/utils.cpp
    src/utils.h
)

qt_add_qml_module(scarlet-launcher
    URI ScarletLauncher
    VERSION 1.0
    QML_FILES 
        qml/main.qml
        qml/components/Row.qml
        qml/components/StatusDisplay.qml
        qml/components/ThemedButton.qml
        qml/theme/Theme.qml
    RESOURCES
        qml/qmldir
        resources/icon.png
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
