#include "model/ListModel.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    // Create the game model
    ListModel gameModel;

    // Add some sample games
    gameModel.addItem("Sample Game 1", "/path/to/game1");
    gameModel.addItem("Sample Game 2", "/path/to/game2");
    gameModel.addItem("Another Game", "/path/to/game3");

    QQmlApplicationEngine engine;

    // Add import path for Theme module
    engine.addImportPath("qrc:/");
    engine.addImportPath("qrc:/ScarletLauncher/qml");

    // Register the model with QML
    engine.rootContext()->setContextProperty("gameModel", &gameModel);

    // Load QML
    const QUrl url(QStringLiteral("qrc:/ScarletLauncher/qml/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
