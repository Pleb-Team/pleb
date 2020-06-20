# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.stuggi.hackaton.pleb
PRODUCT_VERSION_NAME = 0.913
PRODUCT_VERSION_CODE = 13

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "988A2CDEA894AA6275E104B9C3C85B46289DC9CA368E6096F1423EF1DFEB98C0A444F19BF9225B724ECE6B08E3EF6956393A9E4E7F62B03D1C4785CF3F98AB9D22F26D14E90C983DD618605C928F8B86C913A0CB51DF1595B5F2BE7951D078FE24FD3AB9D43B8D8A125047E9485A78BB93868791F35F016E28ADD21AFF3C652551A8FF77425181324B0919ECFDDA416AF7914991EFDF2E5F32B97C8854B24872EA82A72D4A67D508A2A15FEBF6891123AE6138DB0B953334F17E4AC7E95000D906A0C8B67E3F6EAD18A5C96CB4C05D89EB8F9062F0DB92F55876C4054EEFCE6B0588FBA8F5FBE7C953AB082006BE585D32E33AC3034488F9BDD185C123C4DA10FD97B8EE206DE821753EC03B692C65BF8C570BA13C1F84E9F3D22D5B276376B1EFB2F26C50292121915E0FA87D1080B296AA8CE6B9A9F1589F491DF225B0C9CBA0BE5481C3220B5E252230B66C9BC852"
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

