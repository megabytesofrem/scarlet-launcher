#pragma once

#include <QIcon>
#include <QPixmap>
#include <QQuickImageProvider>

namespace scarlet::provider {

/**
 * System theme icon provider for using system icons in custom components.
 */
class ThemeIconProvider : public QQuickImageProvider
{
  public:
    ThemeIconProvider()
      : QQuickImageProvider(QQuickImageProvider::Image)
    {
    }

    QPixmap requestPixmap(const QString& id,
                          QSize* size,
                          const QSize& requestedSize) override
    {
        qDebug() << "ThemeIconProvider requested: " << id;

        QIcon icon = QIcon::fromTheme(id);
        if (icon.isNull()) {
            qDebug() << "ThemeIconProvider: Icon not found for id:" << id;
        }

        QSize actualSize = requestedSize.isValid() ? requestedSize : QSize(20, 20);
        QPixmap pixmap = icon.pixmap(actualSize);

        if (size) {
            *size = pixmap.size();
        }

        return pixmap;
    }

    QImage requestImage(const QString& id,
                        QSize* size,
                        const QSize& requestedSize) override
    {
        QPixmap pixmap = requestPixmap(id, size, requestedSize);
        return pixmap.toImage();
    }
};

} // namespace scarlet::provider
