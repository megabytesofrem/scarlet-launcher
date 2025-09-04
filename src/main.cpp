#include "app_window.h"
#include "model/list_model.h"
#include "provider/icon_provider.h"
#include "provider/theme_icon_provider.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

using AppWindow = scarlet::AppWindow;
using ListModel = scarlet::model::ListModel;

using IconProvider = scarlet::provider::IconProvider;
using ThemeIconProvider = scarlet::provider::ThemeIconProvider;

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    QQuickStyle::setStyle("Fusion");
    AppWindow appWindow;

    QQmlApplicationEngine engine;

    // Add import path for Theme module
    engine.addImportPath("qrc:/");
    engine.addImportPath("qrc:/ScarletLauncher/qml");
    engine.addImageProvider("icons", new IconProvider);
    engine.addImageProvider("theme_icon", new ThemeIconProvider);

    // Set the icon. This only works on X11
    app.setWindowIcon(QIcon("qrc:/ScarletLauncher/resources/icon.png"));

    engine.rootContext()->setContextProperty("appWindow", &appWindow);
    engine.rootContext()->setContextProperty("gameModel", appWindow.getModel());

    // Load main.qml
    const QUrl url(QStringLiteral("qrc:/ScarletLauncher/qml/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
