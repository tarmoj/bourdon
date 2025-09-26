#ifndef LANGUAGEMANAGER_H
#define LANGUAGEMANAGER_H

#include <QGuiApplication>
#include <QObject>
#include <QQmlApplicationEngine>
#include <QTranslator>

class LanguageManager : public QObject
{
    Q_OBJECT

public:
    explicit LanguageManager(QGuiApplication *app,
                             QQmlApplicationEngine *engine,
                             QObject *parent = nullptr);

public slots:
    void switchLanguage(const QString &language);

private:
    QGuiApplication *m_app;
    QQmlApplicationEngine *m_engine;
    QTranslator *m_translator;
};

#endif // LANGUAGEMANAGER_H
