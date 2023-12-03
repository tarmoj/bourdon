lessThan(QT_MAJOR_VERSION,6): error("Qt6 is required for this build.")

QT += quick core

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
        csengine.cpp

HEADERS += \
    csengine.h

RESOURCES += qml.qrc

INCLUDEPATH += /usr/local/include/csound/


android {
  QT += core-private
  INCLUDEPATH += /home/tarmo/src/csound/Android/CsoundAndroid/jni/	 #TODO: should have an extra varaible, not hardcoded personal library
  HEADERS += AndroidCsound.hpp

#message(ANDROID_TARGET_ARCH: $$ANDROID_TARGET_ARCH)

    LIBS +=  -L/home/tarmo/src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/ -lcsoundandroid -lsndfile -lc++_shared

    ANDROID_EXTRA_LIBS = \
        $$PWD/../../../../src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/libsndfile.so \
        $$PWD/../../../../src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/libcsoundandroid.so \
        $$PWD/../../../../src/csound-android-6.18.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/$$ANDROID_TARGET_ARCH/libc++_shared.so
}

linux:!android {
  LIBS += -lcsound64 -lsndfile
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

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
    images/stop-button.png

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}


