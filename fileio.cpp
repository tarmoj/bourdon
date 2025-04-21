#include "fileio.h"
#include "qurl.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>

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
