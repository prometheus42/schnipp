
# Schnipp

Schnipp is a simple GUI to clip letterbox bars and mark broadcaster logos in video files.

## Build

To update the localisation and create translation files:

    lupdate schnipp.qml -ts i18n/schnipp.ts
    linguist i18n/schnipp.ts
    lrelease i18n/*.ts

To build the standalone C++ programm:

    qmake -makefile
    make

To start the program as Python script:

    python3 schnipp.py
