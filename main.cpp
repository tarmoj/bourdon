#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>
#include "fileio.h"
#ifdef Q_OS_IOS
    #include "csoundproxy.h"
#else
    #include "csengine.h"
#endif

#ifdef Q_OS_ANDROID
    #include <QtCore/private/qandroidextras_p.h>
    #include <QJniEnvironment>
    #include "mediabuttonhandler.h"

bool requestPermission(QString permission)
{
    auto r = QtAndroidPrivate::requestPermission(permission).result();
    if (r == QtAndroidPrivate::Denied) {
        qDebug() << permission << " Denied.";
        return false;
    } else
        return true;
}


extern "C" {
Q_DECL_EXPORT void JNICALL Java_org_qtproject_example_MediaSessionHandler_keyEvent(JNIEnv *, jobject, jint keyCode) {
    qDebug() << "Media key received in Qt:" << keyCode;

    switch (keyCode) {
    case 85:  // KEYCODE_MEDIA_PLAY_PAUSE
        qDebug() << "Play/Pause Pressed!";
        break;
    case 86:  // KEYCODE_MEDIA_STOP
        qDebug() << "Stop Pressed!";
        break;
    case 87:  // KEYCODE_MEDIA_NEXT
        qDebug() << "Next Track!";
        break;
    case 88:  // KEYCODE_MEDIA_PREVIOUS
        qDebug() << "Previous Track!";
        break;
    }
}
}

void initializeMediaSession() {
    qDebug() << "Initializing Media Session";

    QJniObject context = QNativeInterface::QAndroidApplication::context();

    if (context.isValid() ) {
        QJniObject::callStaticMethod<void>(
            "org/tarmoj/bourdon/MediaSessionHandler",
            "initialize",
            "(Landroid/content/Context;)V", // Signature with Context parameter
            context.object<jobject>() // Pass the Context object
            );
    } else {
        qDebug() << "Context is null";
    }
}

#endif

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    app.setOrganizationName("Tarmo Johannes Events and Software");
    app.setOrganizationDomain("bourdon-app.org");
    app.setApplicationName("Bourdon App");


#ifdef Q_OS_ANDROID

    // check permissions
    // see: https://stackoverflow.com/questions/71216717/requesting-android-permissions-in-qt-6
    // https://doc-snapshots.qt.io/qt6-dev/qcoreapplication.html#requestPermission

    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    //requestPermission("android.permission.BLUETOOTH");

    //keep screen on:
    QJniObject activity
        = QNativeInterface::QAndroidApplication::context(); //  QtAndroid::androidActivity();
    if (activity.isValid()) {
        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

        if (window.isValid()) {
            const int FLAG_KEEP_SCREEN_ON = 128;
            window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);

            // test:
            // try setting titlebar color here...
            window.callMethod<void>("addFlags", "(I)V", 0x80000000);
            window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
            window.callMethod<void>("setStatusBarColor", "(I)V", 0x1c1b1f); // hardcoded color for now. later try to get via QML engine Material.background
            QJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
            decorView.callMethod<void>("setSystemUiVisibility", "(I)V", 0x00002000);
        }
        QJniEnvironment env;
        if (env->ExceptionCheck()) {
            env->ExceptionClear();
        } //Clear any possible pending exceptions.
    }

    // media session
    if (QThread::currentThread() != QCoreApplication::instance()->thread()) {
        QMetaObject::invokeMethod(&app, []() {
            initializeMediaSession();
        }, Qt::QueuedConnection);
    } else {
        initializeMediaSession();
    }

#endif

#ifdef Q_OS_MACOS
    QString pluginsPath = QGuiApplication::applicationDirPath()
                          + "/../Frameworks/CsoundLib64.framework/Versions/6.0/Resources/Opcodes64";
    qDebug() << " Csound plugins in: " << pluginsPath;
    setenv("OPCODE6DIR64", pluginsPath.toLocal8Bit(), 1);
#endif

#ifdef Q_OS_IOS
    CsoundProxy *cs = new CsoundProxy();
#else
    CsEngine *cs = new CsEngine();
    cs->play();
#endif

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("csound", cs); // forward c++ object that can be reached form qml by object name "csound" NB! include <QQmlContext>

#ifdef Q_OS_ANDROID
    MediaButtonHandler mediaButtonHandler;
    engine.rootContext()->setContextProperty("MediaButtonHandler", &mediaButtonHandler);
#endif

    qmlRegisterType<FileIO>("MyApp.FileIO", 1, 0, "FileIO");


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);


    // QObject *qmlApp = engine.rootObjects().first();
    // QObject::connect(qmlApp, SIGNAL(tableSet(int, int,double)), cs, SLOT(tableSet(int, int, double)));

//    QObject::connect(qmlApp, SIGNAL(setChannel(QString,double)), cs, SLOT(setChannel(QString,double)));
//    QObject::connect(qmlApp, SIGNAL(readScore(QString)), cs, SLOT(readScore(QString)));


    //    QObject::connect(qmlApp, SIGNAL(setChannel(QString,double)), cs, SLOT(setChannel(QString,double)));
    //    QObject::connect(qmlApp, SIGNAL(readScore(QString)), cs, SLOT(readScore(QString)));

    return app.exec();
}
