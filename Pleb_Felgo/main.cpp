#include <QApplication>
#include <FelgoApplication>

#include <QQmlApplicationEngine>
//#include <QtQml>

#include "../Pleb_GameLogic_QtWrapper/BackEnd.h"

int main(int argc, char *argv[])
{

    QApplication app(argc, argv);
	
    // Add this line to match your application identifier:
    //app.setOrganizationDomain("de.stuggi.hackaton.pleb");
    // Set your app's current version number here:
    //app.setApplicationVersion("0.0.1");

    FelgoApplication felgo;

    // QQmlApplicationEngine is the preferred way to start qml projects since Qt 5.2
    // if you have older projects using Qt App wizards from previous QtCreator versions than 3.1, please change them to QQmlApplicationEngine
    QQmlApplicationEngine engine;
    felgo.initialize(&engine);

    // Set an optional license key from project file
    // This does not work if using Felgo Live, only for Felgo Cloud Builds and local builds
    felgo.setLicenseKey(PRODUCT_LICENSE_KEY);

    // use this during development
    // for PUBLISHING, use the entry point below
    felgo.setMainQmlFileName(QStringLiteral("qml/Main.qml"));

    // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
    // this is the preferred deployment option for publishing games to the app stores, because then your qml files and js files are protected
    // to avoid deployment of your qml files and images, also comment the DEPLOYMENTFOLDERS command in the .pro file
    // also see the .pro file for more details
    //  felgo.setMainQmlFileName(QStringLiteral("qrc:/qml/Main.qml"));

    qmlRegisterType<BackEnd>("io.qt.examples.backend", 1, 0, "BackEnd");
    engine.load(QUrl(felgo.mainQmlFileName()));

    return app.exec();
}


