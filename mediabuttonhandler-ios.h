#pragma once

#include <QObject>

class MediaButtonHandler : public QObject
{
    Q_OBJECT
public:
    explicit MediaButtonHandler(QObject* parent = nullptr);
    ~MediaButtonHandler();

    void setupRemoteCommandCenter();

public slots:
    void setPlayingState(bool isPlaying);

signals:
    void play();
    void pause();
    void stop();
    void next();
    void previous();
};
