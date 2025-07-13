#pragma once

#include <QObject>

class MediaButtonHandler : public QObject
{
    Q_OBJECT
public:
    explicit MediaButtonHandler(QObject* parent = nullptr);
    ~MediaButtonHandler();

    void setupRemoteCommandCenter();

signals:
    void play();
    void pause();
    void stop();
    void next();
    void previous();
};
