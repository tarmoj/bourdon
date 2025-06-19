#include "fileio.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDir>

FileIO::FileIO(QObject *parent) : QObject(parent) {}

QString FileIO::readFile(const QString &path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to open file " << path;
        return QString();
    }
    QTextStream in(&file);
    QString contents = in.readAll();
    //qDebug() << "Read from file" << path << " contents: " << contents;
    return contents;
}

bool FileIO::writeFile(const QString &path, const QString &content) {

    // test:
    // QFileInfo fileInfo(path);
    // qDebug() << "verifying fileUrl: " << path;
    // qDebug() << "BASE: " << fileInfo.baseName();
    // qDebug() << "FileName: " << fileInfo.fileName();
    // qDebug() << "Path: " << fileInfo.path();
    // qDebug() << "absoluteFilePath: " << fileInfo.absoluteFilePath();

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Failed to open file for writing: " << path;
        return false;
    }
    QTextStream out(&file);
    out << content;
    //qDebug() << "Saving to file:  "  << path << "content: " << content;
    file.close();
    return true;
}

QStringList FileIO::listPresets() {
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    QStringList list = dir.entryList(QStringList() << "*.*", QDir::Files);
    qDebug() << "File list in c++ " << list;
    return list;
}

QString FileIO::documentsPath() const {
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
}

bool FileIO::fileExists(const QString &path) const {
    return QFile::exists(path);
}



