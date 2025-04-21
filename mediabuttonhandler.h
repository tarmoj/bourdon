#ifndef MEDIABUTTONHANDLER_H
#define MEDIABUTTONHANDLER_H

#include <QObject>
#include <jni.h>

class MediaButtonHandler : public QObject
{
    Q_OBJECT
public:
    explicit MediaButtonHandler(QObject *parent = nullptr);
    static MediaButtonHandler* instance();

    // JNI callback function (will be called from Java)
    static void mediaButtonEvent(JNIEnv *env, jobject obj, jint action);

signals:
    void play();
    void pause();
    void stop();
    void next();
    void previous();



};

#endif // MEDIABUTTONHANDLER_H
