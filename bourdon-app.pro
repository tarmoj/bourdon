lessThan(QT_MAJOR_VERSION,6): error("Qt6 is required for this build.")

QT += quick core bluetooth

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
        bluetooth/characteristicinfo.cpp \
        bluetooth/device.cpp \
        bluetooth/deviceinfo.cpp \
        bluetooth/serviceinfo.cpp \
        csengine.cpp

HEADERS += \
    bluetooth/characteristicinfo.h \
    bluetooth/device.h \
    bluetooth/deviceinfo.h \
    bluetooth/serviceinfo.h \
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
    images/stop-button.png

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}


