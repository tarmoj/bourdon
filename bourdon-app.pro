lessThan(QT_MAJOR_VERSION,6): error("Qt6 is required for this build.")

QT += quick core

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

#for iOS download Csound-iOS from https://csound.com/download.html and put to the source's root folder

SOURCES += main.cpp \
        fileio.cpp \
        csengine.cpp \
        languagemanager.cpp \


HEADERS += \
    csengine.h \
    fileio.h \
    languagemanager.h \


RESOURCES += qml.qrc


# to define variables CSOUND_ANDROID_LIB_DIR, CSOUND_INCLUDE_DIR
exists($$PWD/config.user.pri): include($$PWD/config.user.pri)


isEmpty( CSOUND_INCLUDE_DIR) {
  CSOUND_INCLUDE_DIR = /usr/local/include/csound/ # Linux default
}

!ios: INCLUDEPATH += CSOUND_INCLUDE_DIR

android {
  QT += core-private
  INCLUDEPATH += $$PWD/AndroidCsound/csound6/
  HEADERS += AndroidCsound/csound6/AndroidCsound.hpp \
            mediabuttonhandler.h
  SOURCES += mediabuttonhandler.cpp


#message(ANDROID_TARGET_ARCH: $$ANDROID_TARGET_ARCH)

    isEmpty(CSOUND_ANDROID_LIB_DIR) {
        message("CSOUND_ANDROID_LIB_DIR  is empty, using default path")
        CSOUND_ANDROID_LIB_DIR = "/home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs"
    }

# Link against the libraries
# Note: No space between -L and the path; ensure the slash is handled correctly
    LIBS += -L"$$CSOUND_ANDROID_LIB_DIR/$$ANDROID_TARGET_ARCH" \
            -lcsoundandroid \
            -lsndfile \
            #-lc++_shared

    ANDROID_EXTRA_LIBS = \
        $$CSOUND_ANDROID_LIB_DIR/$$ANDROID_TARGET_ARCH/libsndfile.so \
        $$CSOUND_ANDROID_LIB_DIR/$$ANDROID_TARGET_ARCH/libcsoundandroid.so


    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android

    # build with 16 kB pagesize to comply with Google Play requirements
    QMAKE_LFLAGS += -Wl,-z,max-page-size=65536

    message("Android lib: " CSOUND_ANDROID_LIB_DIR)

}

linux:!android {
  LIBS += -lcsound64 -lsndfile -lcsnd6
}

mac: !ios {
    ICON = images/bourdon.icns
    QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64
    LIBS += -F/Library/Frameworks/ -framework CsoundLib64  -L/usr/local/lib/ -lcsnd6.6.0
    INCLUDEPATH += /Library/Frameworks/CsoundLib64.framework/Versions/6.0/Headers
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/mipmap-anydpi-v26/ic_launcher.xml \
    android/res/mipmap-anydpi-v26/ic_launcher_round.xml \
    android/res/mipmap-hdpi/ic_launcher.png \
    android/res/mipmap-hdpi/ic_launcher_foreground.png \
    android/res/mipmap-hdpi/ic_launcher_round.png \
    android/res/mipmap-ldpi/ic_launcher.png \
    android/res/mipmap-mdpi/ic_launcher.png \
    android/res/mipmap-mdpi/ic_launcher_foreground.png \
    android/res/mipmap-mdpi/ic_launcher_round.png \
    android/res/mipmap-xhdpi/ic_launcher.png \
    android/res/mipmap-xhdpi/ic_launcher_foreground.png \
    android/res/mipmap-xhdpi/ic_launcher_round.png \
    android/res/mipmap-xxhdpi/ic_launcher.png \
    android/res/mipmap-xxhdpi/ic_launcher_foreground.png \
    android/res/mipmap-xxhdpi/ic_launcher_round.png \
    android/res/mipmap-xxxhdpi/ic_launcher.png \
    android/res/mipmap-xxxhdpi/ic_launcher_foreground.png \
    android/res/mipmap-xxxhdpi/ic_launcher_round.png \
    android/res/values/ic_launcher_background.xml \
    android/res/values/libs.xml \
    config.user.pri \
    images/stop-button.png \




ios {

    QMAKE_BUNDLE_IDENTIFIER = org.tarmoj.bourdon

    csdfiles.files = bourdon.csd
    QMAKE_BUNDLE_DATA += csdfiles

    QMAKE_INFO_PLIST = $$PWD/ios/Info.plist

    # ios {
    #     QMAKE_IOS_DEPLOYMENT_TARGET = 26.0
    #     QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2
    # }

    QMAKE_ASSET_CATALOGS += $$PWD/ios/Assets.xcassets
    QMAKE_ASSET_CATALOGS_APP_ICON = AppIcon

    QMAKE_IOS_LAUNCH_SCREEN = $$PWD/ios/LaunchScreen.storyboard

    SOURCES += \
        csoundproxy.mm \
        csound-iOS/classes/CsoundObj.m \
        ios-screen.mm \
        mediabuttonhandler-ios.mm

    HEADERS += \
        csound-iOS/classes/CsoundObj.h \
        csoundproxy.h \
        ios-screen.h \
        mediabuttonhandler-ios.h

    SOURCES -= csengine.cpp
    HEADERS -= csengine.h

    HEADERS += \
        csound-iOS/classes/bindings/motion/CsoundAccelerometerBinding.h \
        csound-iOS/classes/bindings/motion/CsoundAttitudeBinding.h \
        csound-iOS/classes/bindings/motion/CsoundGyroscopeBinding.h \
        csound-iOS/classes/bindings/motion/CsoundMotion.h \
        csound-iOS/classes/bindings/ui/CsoundButtonBinding.h \
        csound-iOS/classes/bindings/ui/CsoundLabelBinding.h \
        csound-iOS/classes/bindings/ui/CsoundMomentaryButtonBinding.h \
        csound-iOS/classes/bindings/ui/CsoundSliderBinding.h \
        csound-iOS/classes/bindings/ui/CsoundSwitchBinding.h \
        csound-iOS/classes/bindings/ui/CsoundUI.h \
        csound-iOS/classes/midi/CsoundMIDI.h \
        csound-iOS/classes/midi/MidiWidgetWrapper.h \
        csound-iOS/classes/midi/MidiWidgetsManager.h \
        csound-iOS/classes/midi/SliderMidiWidgetWrapper.h

    SOURCES += \
        csound-iOS/classes/bindings/motion/CsoundAccelerometerBinding.m \
        csound-iOS/classes/bindings/motion/CsoundAttitudeBinding.m \
        csound-iOS/classes/bindings/motion/CsoundGyroscopeBinding.m \
        csound-iOS/classes/bindings/motion/CsoundMotion.m \
        csound-iOS/classes/bindings/ui/CsoundButtonBinding.m \
        csound-iOS/classes/bindings/ui/CsoundLabelBinding.m \
        csound-iOS/classes/bindings/ui/CsoundMomentaryButtonBinding.m \
        csound-iOS/classes/bindings/ui/CsoundSliderBinding.m \
        csound-iOS/classes/bindings/ui/CsoundSwitchBinding.m \
        csound-iOS/classes/bindings/ui/CsoundUI.m \
        csound-iOS/classes/midi/CsoundMIDI.m \
        csound-iOS/classes/midi/MidiWidgetsManager.m \
        csound-iOS/classes/midi/SliderMidiWidgetWrapper.m


    INCLUDEPATH += $$PWD/csound-iOS/headers
    INCLUDEPATH += $$PWD/csound-iOS/classes
    INCLUDEPATH += $$PWD/csound-iOS/classes/midi
    LIBS += $$PWD/csound-iOS/libs/libcsound.a
    LIBS += $$PWD/csound-iOS/libs/libsndfile.a
    LIBS += -framework Accelerate
    LIBS += -framework AVFAudio
    LIBS += -framework CoreMidi
    LIBS += -framework CoreMotion
    LIBS += -framework UIKit
    LIBS += -framework MediaPlayer


}

macx {

    samples.path = Contents/Resources/
        samples.files = $$PWD/samples
        QMAKE_BUNDLE_DATA += samples

    first.path = $$PWD
        first.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD # deployment

    second.path = $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks
        second.files = /Library/Frameworks/CsoundLib64.framework
        #second.commands = rm -rf $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework/
        #TODO: remove Resources Java, Luajit, Manual, Opcodes64 enamus...  PD, Python, samples
        # remove lbCsoundAc, võibolla libcsnd6

    third.path = $$PWD
        third.commands = install_name_tool -change /Library/Frameworks/CsoundLib64.framework/CsoundLib64 @rpath/CsoundLib64.framework/Versions/6.0/CsoundLib64 $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/bourdon-app ;
        third.commands += install_name_tool -change /Library/Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 @rpath/CsoundLib64.framework/Versions/6.0/CsoundLib64 $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework/Versions/6.0/libcsnd6.6.0.dylib ;
        third.commands += install_name_tool -change /Library/Frameworks/CsoundLib64.framework/libs/libsndfile.1.dylib @rpath/CsoundLib64.framework/libs/libsndfile.1.dylib $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64 ;
        third.commands += install_name_tool -change libcsnd6.6.0.dylib @rpath/CsoundLib64.framework/Versions/6.0/libcsnd6.6.0.dylib $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/MacOS/bourdon-app

    final.path = $$PWD
        #final.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD -dmg# deployment BETTER: use hdi-util
        final.commands = hdiutil create -fs HFS+ -srcfolder $$OUT_PWD/$$DESTDIR/$${TARGET}.app -volname \"Bourdon\" $$OUT_PWD/$$DESTDIR/$${TARGET}.dmg

    INSTALLS += first  third  final #final don't forget second on first compile!!! (later makes sense to remove extra folders from Csound.Frameworks)

}

TRANSLATIONS += \
    translations/bourdon_et.ts \
    translations/bourdon_et.ts \
    translations/bourdon_ga.ts \
    translations/bourdon_gd.ts



