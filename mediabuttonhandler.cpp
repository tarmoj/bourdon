#include "mediabuttonhandler.h"
#include <QDebug>

// Singleton instance
static MediaButtonHandler *s_instance = nullptr;

MediaButtonHandler::MediaButtonHandler(QObject *parent)
    : QObject{parent}
{
    s_instance = this;
}

MediaButtonHandler *MediaButtonHandler::instance()
{
    return s_instance;
}

// JNI function implementation
extern "C" JNIEXPORT void JNICALL Java_org_tarmoj_bourdon_MediaSessionHandler_nativeMediaButtonEvent(
    JNIEnv *env, jobject obj, jint action)
{
    if (!s_instance)
        return;

    qDebug() << "Received media button event from Java: " << action;

    switch (action) {
    case 1:
        emit s_instance->play();
        break;
    case 2:
        emit s_instance->pause();
        break;
    case 3:
        emit s_instance->stop();
        break;
    case 4:
        emit s_instance->next();
        break;
    case 5:
        emit s_instance->previous();
        break;
    }
}
