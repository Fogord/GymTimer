TEMPLATE = app

TARGET = GymTimer

QT += qml quick sql multimedia core bluetooth

#PATH =

CONFIG += c++11 qml_debug disable-desktop
CONFIG -= bitcode

HEADERS +=

SOURCES += main.cpp

RESOURCES += \
    js.qrc \
    img.qrc \
    qml.qrc \
    sound.qrc \
    qtquickcontrols2.conf


QT_IM_MODULE = qtvirtualkeyboard

#SQUISH_PREFIX = /Users/a.yerko/Qt/squish-6.4.0-qt59x-ios

# Include Squish/Qt if a Squish installation prefix was provided to qmake
#!isEmpty(SQUISH_PREFIX) {
#    message("Including Squish/Qt files")
#    android {
#        SQUISH_ATTACH_PORT=4711
#    }s
#    include($$SQUISH_PREFIX/qtbuiltinhook.pri)
#}
#files for ios app
ios {
    QMAKE_INFO_PLIST = $$PWD/info.plist
    ios_icon.files = $$files($$PWD/iconApp/Icon-App-*.png)
    QMAKE_BUNDLE_DATA += ios_icon
}

#QT_LOGGING_RULES=qt.network.ssl.warning=false

#macx: LIBS += -L$$PWD/../../../../../../../usr/local/Cellar/openssl/1.0.2j/lib/ -lcrypto -lssl
#INCLUDEPATH += $$PWD/../../../../../../../usr/local/Cellar/openssl/1.0.2j/include
#DEPENDPATH += $$PWD/../../../../../../../usr/local/Cellar/openssl/1.0.2j/include

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =
#sqldrivers.libqsqlite.dylib

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


