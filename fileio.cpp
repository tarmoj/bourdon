#include "fileio.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>

FileIO::FileIO(QObject *parent)
    : QObject(parent)
{}

QString FileIO::readFile(const QString &path)
{
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

bool FileIO::writeFile(const QString &path, const QString &content)
{
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

QStringList FileIO::listPresets()
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    QStringList list = dir.entryList(QStringList() << "*", QDir::Files);
    qDebug() << "File list in c++ " << list;
    return list;
}

QString FileIO::documentsPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
}

bool FileIO::fileExists(const QString &path) const
{
    return QFile::exists(path);
}

bool FileIO::deleteFile(const QString &fileName)
{
    const QString basePath = documentsPath();
    const QString fullPath = basePath + "/" + fileName;

    if (!QFile::exists(fullPath)) {
        qDebug() << "File does not exist: " << fullPath;
        return false;
    }

    bool success = QFile::remove(fullPath);
    if (!success) {
        qDebug() << "Failed to delete file: " << fullPath;
    } else {
        qDebug() << "Successfully deleted file: " << fullPath;
    }
    return success;
}

bool FileIO::renameFile(const QString &oldFileName, const QString &newFileName)
{
    const QString basePath = documentsPath();
    const QString oldPath = basePath + "/" + oldFileName;
    const QString newPath = basePath + "/" + newFileName;

    if (!QFile::exists(oldPath)) {
        qDebug() << "Source file does not exist: " << oldPath;
        return false;
    }

    if (QFile::exists(newPath)) {
        qDebug() << "Target file already exists: " << newPath;
        return false;
    }

    bool success = QFile::rename(oldPath, newPath);
    if (!success) {
        qDebug() << "Failed to rename file from" << oldPath << "to" << newPath;
    } else {
        qDebug() << "Successfully renamed file from" << oldPath << "to" << newPath;
    }
    return success;
}
