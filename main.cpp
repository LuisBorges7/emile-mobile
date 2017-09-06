#include <QFile>
#include <QVariant>
#include <QJsonObject>
#include <QQmlContext>
#include <QJsonDocument>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

QVariantMap loadjson()
{
    QFile file;
    file.setFileName(":/matriz-curricular.json");
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString settings(file.readAll());
    file.close();
    QJsonDocument jsonDocument = QJsonDocument::fromJson(settings.toUtf8());
    return jsonDocument.object().toVariantMap();
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("jsonData", loadjson());
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
