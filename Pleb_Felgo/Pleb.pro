# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.stuggi.hackaton.pleb
PRODUCT_VERSION_NAME = 0.915
PRODUCT_VERSION_CODE = 15

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "1F3C19EFFEA94C5E8BD3479499D02094F83F03F4489D2FC29D040C9C7EB1E462CAB499251FFEF3AEBB3B6DAD2C1F41F6E98A2D323938F4AEDF016A3221A7C0901B8251854D27D7C943670F928EB5F6F74D5916871DE6212775A5665E536762D418C4ED08124BCF74815C5D66234D68105DF647993B1960CD80DBB7923D7D2BB7207E8B035941107FD3057064A37272EE4B789B8D0DA0C7685D4DFF95A3F1690ADFF4FF8C9C7A70C9D6578C5EFE24AC192EEBF4475ADCC513FA2D09DB829EBAEF115A43CECFF64DD5A8B5109C7D8930352049B684E1784D7516FCDE9547EBA498BBA9188717A084395FBC4B620737EC734F39912A9E2ED0833450738467559DFA469FC2FC803288582BA4E3CB8EE5EDF8F22305E972295C0AC7E24A49399D811DBA69C69FBAF481ED1167FCBEA2F88758781DEBCF801A1C2BDC7A9D614D56865D3462031E51FE33427D7B1A287A443EB9"
QT += websockets

qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder

# Add more folders to ship with the application here

RESOURCES += #    resources.qrc # uncomment for publishing

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the Felgo Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    ../Pleb_GameLogic_QtWrapper/Backend.cpp \
    ../Pleb_GameLogic_QtWrapper/Game/AI/PlayerAI.cpp \
    ../Pleb_GameLogic_QtWrapper/Game/AI/PlayerSimpleAI2.cpp \
    ../Pleb_GameLogic_QtWrapper/Game/Game/Game.cpp \
    ../Pleb_GameLogic_QtWrapper/Game/Game/GameStatistics.cpp \
    ../Pleb_GameLogic_QtWrapper/Game/Konfiguration.cpp


android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml \
      android/build.gradle

}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
#    QMAKE_IOS_DEPLOYMENT_TARGET = 9.3

    # Entitlements for Apple Push Notification service - not yet actively used, but theoretically accessible by
    # the Felgo Multiplayer / OneSignal plugin, so AppStore Connect complains without this entitlement.
    MY_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    MY_ENTITLEMENTS.value = ../Pleb_Felgo/ios/Pleb.entitlements
    QMAKE_MAC_XCODE_SETTINGS += MY_ENTITLEMENTS
}


# from here added to integrate C++ game logic and AI component

QT += quick widgets

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


# Additional import path used to resolve QML modules in Qt Creator's code model
#QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
#QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

HEADERS += \
    ../Pleb_GameLogic_QtWrapper/BackEnd.h \
    ../Pleb_GameLogic_QtWrapper/Game/AI/PlayerAI.h \
    ../Pleb_GameLogic_QtWrapper/Game/AI/PlayerSimpleAI2.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/Game.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/GameResult.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/GameState.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/GameStatistics.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/Move.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/MoveSimple.h \
    ../Pleb_GameLogic_QtWrapper/Game/Game/MoveSimpleResults.h \
    ../Pleb_GameLogic_QtWrapper/Game/Global.h \
    ../Pleb_GameLogic_QtWrapper/Game/GlobalConstants.h \
    ../Pleb_GameLogic_QtWrapper/Game/Konfiguration.h

