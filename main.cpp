#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QTranslator translator;
    // look up translations in i18n directory names like e.g. de_DE.qm
    if (translator.load(QLocale().system().name(), QLatin1String("i18n"))) {
        QCoreApplication::installTranslator(&translator);
    }

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/schnipp.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
