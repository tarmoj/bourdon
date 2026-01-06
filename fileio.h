#ifndef FILEIO_H
#define FILEIO_H

#include <QFile>
#include <QObject>
#include <QTextStream>

class FileIO : public QObject
{
    Q_OBJECT
public:
    explicit FileIO(QObject *parent = nullptr);

    Q_INVOKABLE QString readFile(const QString &path);
    Q_INVOKABLE bool writeFile(const QString &path, const QString &content);
    Q_INVOKABLE QStringList listPresets();
    Q_INVOKABLE QString documentsPath() const;
    Q_INVOKABLE QString presetsPath() const;
    Q_INVOKABLE bool fileExists(const QString &path) const;
    Q_INVOKABLE bool deleteFile(const QString &fileName);
    Q_INVOKABLE bool renameFile(const QString &oldFileName, const QString &newFileName);
};

#endif // FILEIO_H
