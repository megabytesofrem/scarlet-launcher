#include "app_window.h"
#include "icon_provider.h"
#include "model/list_model.h"
#include "theme_icon_provider.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

using ListModel = scarlet::model::ListModel;

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    QQuickStyle::setStyle("Fusion");

    AppWindow appWindow;

    // Create the game model
    ListModel gameModel;

    QQmlApplicationEngine engine;

    // Add import path for Theme module
    engine.addImportPath("qrc:/");
    engine.addImportPath("qrc:/ScarletLauncher/qml");
    engine.addImageProvider("icons", new IconProvider);
    engine.addImageProvider("theme_icon", new ThemeIconProvider);

    // Register the model with QML
    appWindow.setModel(&gameModel);

    // Set the icon
    app.setWindowIcon(QIcon("qrc:/ScarletLauncher/resources/icon.png"));

    engine.rootContext()->setContextProperty("appWindow", &appWindow);
    engine.rootContext()->setContextProperty("gameModel", &gameModel);

    // Load QML
    const QUrl url(QStringLiteral("qrc:/ScarletLauncher/qml/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
