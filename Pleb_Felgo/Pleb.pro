# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.stuggi.hackaton.pleb
PRODUCT_VERSION_NAME = 0.920
PRODUCT_VERSION_CODE = 20

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "CECF4497A5A5F71668481D22442CEB857D464695346789DA1FB0829910A5846D1B8B4C2FA340B8470CDB29F3D9C25A9661CCE0EF667FC787883E343DF03ABCF361186B51CF9BC75831A3CCC67D3A80DC864D739928CDB69D74BA76C80462361663525AE78EE6CD178CBC55FD67F6AFDBC5FB2AFB6F1940A5F6B067B496DA63C748259C07C39A042F66E0E48045075FCD7EFDFDF2EEC96C6BFF27C30F0DBF0ECB79CF7087086CBA4A0D16FDCDD8F6913F7275E29D79E20AD03546E27E4A50FECA0FE50E87CD8E790DA84E7311514F5948166A530B08BA6E52C0DE639E5DA82C9963BFDC4E1FD97BA8AF698BB1000B2DE6E86168FE677E1C8F13AD283921C2B863381771610E163CDDB5E28DEDBE56F4C617BAA4C6EC660C52AC15068D27A47B14C7E52FF2884B4D33D94D79FAD58ADE3059C33C0628677BB9AC7C0E748C68CA12E3679782C93AD48E780D3C5E7E88346E"
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

