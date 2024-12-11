#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QThread>
#include <QQmlContext>
#include "csengine.h"
// #include "bluetooth/device.h"


#ifdef Q_OS_ANDROID
    #include <QtCore/private/qandroidextras_p.h>
    #include <QJniEnvironment>

bool requestPermission(QString permission)
{
    auto r = QtAndroidPrivate::requestPermission(permission).result();
    if (r == QtAndroidPrivate::Denied) {
        qDebug() <<  permission << " Denied.";
        return false;
    } else
        return true;

}

#endif


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Tarmo Johannes Events and Software");
    app.setOrganizationDomain("bourdon-app.org");
    app.setApplicationName("Bourdon App");

#ifdef Q_OS_ANDROID

    // check permissions
    // see: https://stackoverflow.com/questions/71216717/requesting-android-permissions-in-qt-6
    // https://doc-snapshots.qt.io/qt6-dev/qcoreapplication.html#requestPermission

    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE");
    requestPermission("android.permission.BLUETOOTH");

    //keep screen on:
    QJniObject activity =  QNativeInterface::QAndroidApplication::context(); //  QtAndroid::androidActivity();
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
        QJniEnvironment env; if (env->ExceptionCheck()) { env->ExceptionClear(); } //Clear any possible pending exceptions.
    }

#endif

#ifdef Q_OS_MACOS
    QString pluginsPath = QGuiApplication::applicationDirPath() + "/../Frameworks/CsoundLib64.framework/Versions/6.0/Resources/Opcodes64";
    qDebug()<<" Csound plugins in: " << pluginsPath;
    setenv("OPCODE6DIR64", pluginsPath.toLocal8Bit() ,1);
#endif

    CsEngine * cs = new CsEngine();
    cs->play();
    /*
    // move csound into another thread
    QThread  * csoundThread = new QThread();
    CsEngine * cs = new CsEngine();
    cs->moveToThread(csoundThread);

    QObject::connect(csoundThread, &QThread::finished, cs, &CsEngine::deleteLater);
    QObject::connect(csoundThread, &QThread::finished, csoundThread, &QThread::deleteLater);

    QObject::connect(csoundThread, &QThread::started, cs, &CsEngine::play);
    csoundThread->start();
    */

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("csound", cs); // forward c++ object that can be reached form qml by object name "csound" NB! include <QQmlContext>


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

//    QObject *qmlApp = engine.rootObjects().first();

//    QObject::connect(qmlApp, SIGNAL(setChannel(QString,double)), cs, SLOT(setChannel(QString,double)));
//    QObject::connect(qmlApp, SIGNAL(readScore(QString)), cs, SLOT(readScore(QString)));


    return app.exec();
}
