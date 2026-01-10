#[[
  @file    CMakeLists.txt
  @brief   CMake build configuration for Reikon Dash application.

  Configures the build system for the Reikon Dash motorsport display application.
  Defines C++ standard requirements, Qt dependencies, source file compilation,
  QML module setup, and installation targets. Supports cross-compilation for
  embedded Linux targets and desktop builds for development.

  Build System Philosophy:
  - Modern CMake practices (Qt6 modules, qt_add_executable)
  - C++17 for modern language features
  - Qt 6 QML module system for proper resource handling
  - Configurable installation paths for deployment flexibility

  Requirements:
  - CMake 3.16+
  - Qt 6.x (Core, Quick modules)
  - C++17 compatible compiler (GCC 7+, Clang 5+)

  Build Instructions:
    mkdir build && cd build
    cmake ..
    cmake --build .

  Cross-compilation:
    cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/toolchain.cmake ..

  @author  Kevin Delaney
  @date    January 10, 2026
  @company Delaney Motorsports, LLC
  @address Sarasota, FL
]]

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
