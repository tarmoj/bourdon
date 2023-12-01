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

mac: {
    ICON = images/bourdon.icns
	QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64
	LIBS += -F/Library/Frameworks/ -framework CsoundLib64
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
    images/stop-button.png

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
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
	third.commands += install_name_tool -change /Library/Frameworks/CsoundLib64.framework/libs/libsndfile.1.dylib @rpath/CsoundLib64.framework/libs/libsndfile.1.dylib $$OUT_PWD/$$DESTDIR/$${TARGET}.app/Contents/Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64

    final.path = $$PWD
	#final.commands = $$[QT_INSTALL_PREFIX]/bin/macdeployqt $$OUT_PWD/$$DESTDIR/$${TARGET}.app -qmldir=$$PWD -dmg# deployment BETTER: use hdi-util
	final.commands = hdiutil create -fs HFS+ -srcfolder $$OUT_PWD/$$DESTDIR/$${TARGET}.app -volname \"Bourdon\" $$OUT_PWD/$$DESTDIR/$${TARGET}.dmg

    INSTALLS += first second third  final #final don't forget second on first compile!!! (later makes sense to remove extra folders from Csound.Frameworks)

}


