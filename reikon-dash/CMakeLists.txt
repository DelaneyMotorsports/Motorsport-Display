cmake_minimum_required(VERSION 3.16)

project(reikon-dash VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)

qt_standard_project_setup()

qt_add_executable(reikon-dash
    app/main.cpp
    app/platform/CanBackend.cpp
    app/model/SignalBus.cpp
    app/services/Logger.cpp
)

qt_add_qml_module(reikon-dash
    URI ReikonDash
    VERSION 1.0
    QML_FILES
        qml/App.qml
        qml/screens/Screen01.ui.qml
        qml/components/GaugeArc.qml
        qml/components/ShiftLight.qml
)

target_link_libraries(reikon-dash PRIVATE Qt6::Core Qt6::Quick)

install(TARGETS reikon-dash
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
