
# Schnipp

Schnipp is a simple GUI to clip letterbox bars and mark broadcaster logos in video files.

## Build

To update the localisation and create translation files:

    lupdate schnipp.qml -ts i18n/de_DE.ts
    linguist i18n/de_DE.ts
    lrelease i18n/*.ts

To build the standalone C++ programm:

    qmake -makefile
    make

To start the program as Python script:

    python3 schnipp.py

## Third Party

* Icon from [Tango icon](http://tango-project.org/) set under Public Domain.
