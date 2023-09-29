cmake_minimum_required(VERSION 3.16)
project(bourdon-app VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Set up AUTOMOC and some sensible defaults for runtime execution
# When using Qt 6.3, you can replace the code block below with
# qt_standard_project_setup()
set(CMAKE_AUTOMOC ON)
include(GNUInstallDirs)

find_package(QT NAMES Qt5 Qt6 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Bluetooth Gui Quick)
find_package(Qt${QT_VERSION_MAJOR})

qt_add_executable(bourdon-app WIN32 MACOSX_BUNDLE
    bluetooth/characteristicinfo.cpp bluetooth/characteristicinfo.h
    bluetooth/device.cpp bluetooth/device.h
    bluetooth/deviceinfo.cpp bluetooth/deviceinfo.h
    bluetooth/serviceinfo.cpp bluetooth/serviceinfo.h
    csengine.cpp csengine.h
    main.cpp
)
target_include_directories(bourdon-app PRIVATE
    /usr/local/include/csound
)

target_link_libraries(bourdon-app PRIVATE
    Qt::Bluetooth
    Qt::Core
    Qt::Gui
    Qt::Quick
)


# Resources:
set(qml_resource_files
    "BourdonButton.qml"
    "BourdonForm.ui.qml"
    "PresetForm.ui.qml"
    "bourdon.csd"
    "main.qml"
    "qtquickcontrols2.conf"
)

qt_add_resources(bourdon-app "qml"
    PREFIX
        "/"
    FILES
        ${qml_resource_files}
)

if(ANDROID)
    target_sources(bourdon-app PUBLIC
        AndroidCsound.hpp
    )

    target_include_directories(bourdon-app PRIVATE
        /home/tarmo/src/csound/Android/CsoundAndroid/jni
    )

    target_link_libraries(bourdon-app PRIVATE
        # Remove: L/home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/arm64-v8a/
        Qt::CorePrivate
        c++_shared
        csoundandroid
        sndfile
    )
endif()

if(LINUX)
    target_link_libraries(bourdon-app PRIVATE
        csound64
        sndfile
    )
endif()

install(TARGETS bourdon-app
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Consider using qt_generate_deploy_app_script() for app deployment if
# the project can use Qt 6.3. In that case rerun qmake2cmake with
# --min-qt-version=6.3.
