#include "languagemanager.h"
#include <QDebug>

LanguageManager::LanguageManager(QGuiApplication *app, QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent), m_app(app), m_engine(engine), m_translator(new QTranslator(this))
{
}

void LanguageManager::switchLanguage(const QString &language)
{
    qDebug() << "Switching language to:" << language;
    
    // Remove previous translator
    m_app->removeTranslator(m_translator);
    
    // Load new translation
    bool loaded = false;
    if (language == "EST") {
        loaded = m_translator->load(":/translations/bourdon_et.qm");
    } else {
        // Default to English (no translation file needed)
        loaded = true;
    }
    
    if (loaded && language == "EST") {
        m_app->installTranslator(m_translator);
    }
    
    // Reload QML to apply translations
    m_engine->retranslate();
    
    qDebug() << "Language switch" << (loaded ? "successful" : "failed");
}