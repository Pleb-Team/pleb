# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.stuggi.hackaton.pleb
PRODUCT_VERSION_NAME = 0.912
PRODUCT_VERSION_CODE = 12

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "F1EDD573D22CD7C8C63D330B6B0516B4E915E25F0CAD8674F678BCA698455B3B6F03B985D0815C64DAB1784F3738C8EA451056D2B25B477D746C806F20362CD0C2A394674877499D34EE281CCD8247DE1EFDC3ACCAEB759A4861BF3A64FE201522BF202C3F75F0BB043F21DFE96FFB1DCA485F6BFE972603484A97EBBA837078ECDA21910FC8E3EEE242629EDE83D15F64022B4D782A9DF69DD06AF133281E22D596291162F59ECAFAABF1F2A87FC4F21FA51C76367FB47F39783C057B04FD7E0816FC8BDD88C6929F9398A62732F5E1B4E3E722DFD0B0F6BF64174B58A86B0B2CBD12EE4AABBBA6380EA5DCEE81563A83E4592542DFE44505508936E7045EF594725B37E7B8481EEC1AE6D2B8D8F1CAE888B939D5D8404BA905CA304D4D36BD7528F1F1BB2A80A3BABDBA7E6D0DAC614B9CDBB02C84EF4D8F038CF64B74BCBF6855E2E5CF39E40C250D43E3376BF734"
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

