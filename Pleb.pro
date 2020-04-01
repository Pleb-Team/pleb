# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.stuggi.hackaton.pleb
PRODUCT_VERSION_NAME = 0.0.1
PRODUCT_VERSION_CODE = 1

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "065E29B6BAE2B7392216C5CFFCFD92B6D994CBA522164FF7F68A43EAE17F0B0D4C4744FA50779E4C5A904765762499EF5B2CE6A680EF69B702419CB6E0DD8D6FCDD47F012092E977986A65B0F71CE043E9E825BDAC0249F7F9368C922D10AB86CBBFD8D58DEBE3966C3B08B1D6A0BAE68C409AC660D061C4D6557F99E9DDB6430E8851F9173DADBF8B38AD44407ADD6AC806747572995F5146948C2FAFCAA6CE52237DD8BDFECD1CEECAC0E78FBA86A2E0B9073F3C404B4ACC3AA3242734852F53B5CDB5305C7ACA57FF9AF9FE711F8B642B98A20C57EB454958C9CD5BBAC48EC8D17BF57D0AEB559E87BA31F0B63425251C69E84FF4C894B8B8545E08979E6BF6CEBBB6546A7C8F9FCDFA49E9D1DE3BF3D0BA2C8E5DCB5FE187A2AFBB2DBF26BD868F4EC5A6AD3313E5AA1B03407001D474D9000DBD995DD22627006359B9AC6A494DFE63D57130B3D93868358EE650325C1776AC9670F746C13D764776E98F05FF76AD27BBE728732D510CB10614FED89F4DD40333C7E27880E8ADBE0AF07C6FB749DC153AC17AD4DF534DEF212349"

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
SOURCES += main.cpp


android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml \
      android/build.gradle

}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST

    # Uncomment for using iOS plugin libraries
    # FELGO_PLUGINS += facebook onesignal flurry admob chartboost soomla
}

DISTFILES += \
    qml/game/blatt52/Card_52.qml \
    qml/game/blatt52/Deck_52.qml
