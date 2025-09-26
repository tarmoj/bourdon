#include "fileio.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDirIterator>

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

bool FileIO::copyOggFilesToWritableLocation(const QString &targetDir)
{
    qDebug() << "Starting to copy .ogg files to" << targetDir;
    
    // Create target directory if it doesn't exist
    QDir dir;
    if (!dir.exists(targetDir)) {
        if (!dir.mkpath(targetDir)) {
            qDebug() << "Failed to create target directory:" << targetDir;
            return false;
        }
        qDebug() << "Created target directory:" << targetDir;
    }
    
    // List of all .ogg files in the resource
    QStringList oggFiles = {
        "A0.ogg", "G0.ogg", "a.ogg", "a1.ogg", "c.ogg", "c1.ogg", 
        "d.ogg", "d1.ogg", "e.ogg", "e1.ogg", "f.ogg", "f1.ogg",
        "fis.ogg", "fis1.ogg", "g.ogg", "g1.ogg", "h.ogg", "h1.ogg"
    };
    
    int copiedCount = 0;
    int skippedCount = 0;
    
    for (const QString &fileName : oggFiles) {
        QString resourcePath = ":/ogg/" + fileName;
        QString targetPath = targetDir + "/" + fileName;
        
        // Check if file already exists in target location
        if (QFile::exists(targetPath)) {
            qDebug() << "File already exists, skipping:" << fileName;
            skippedCount++;
            continue;
        }
        
        // Copy file from resource to target location
        if (QFile::copy(resourcePath, targetPath)) {
            qDebug() << "Successfully copied:" << fileName;
            copiedCount++;
            
            // Verify the copied file exists and has a reasonable size
            QFileInfo copiedFile(targetPath);
            if (copiedFile.exists() && copiedFile.size() > 0) {
                qDebug() << "Verified copied file:" << fileName << "size:" << copiedFile.size() << "bytes";
            } else {
                qDebug() << "Warning: Copied file appears to be empty or corrupted:" << fileName;
            }
        } else {
            qDebug() << "Failed to copy:" << fileName << "from" << resourcePath << "to" << targetPath;
            
            // Check if the source resource exists
            QFileInfo sourceFile(resourcePath);
            if (!sourceFile.exists()) {
                qDebug() << "Source resource file does not exist:" << resourcePath;
            } else {
                qDebug() << "Source resource exists but copy failed. Target dir writable?";
            }
            return false;
        }
    }
    
    qDebug() << "Copy operation completed. Copied:" << copiedCount << "Skipped:" << skippedCount;
    return true;
}

QString FileIO::getWritableSamplesPath() const
{
// #ifdef Q_OS_ANDROID
//     return "/sdcard/Music/Bourdon/samples";
// #elif defined(Q_OS_IOS)
//     return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/samples";
// #else
//     return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/samples";
// #endif
    // use a writable location for any OS, do not bundle OGG files separately
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/bourdon-samples";

}
