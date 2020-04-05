#!/usr/bin/env python3

"""

Sources:
 * https://doc.qt.io/qt-5/qmlreference.html
 * 
 * 

"""

import sys
import argparse

from PyQt5.QtCore import QTranslator, QLocale, QObject, pyqtSlot
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtGui import QIcon, QGuiApplication


class FileIO(QObject):
    """
    Provides functions to read and write files from QML GUI.

    Sources:
     - https://www.riverbankcomputing.com/static/Docs/PyQt5/signals_slots.html 
     - https://www.riverbankcomputing.com/static/Docs/PyQt5/qml.html
    """
    def __init__(self):
        QObject.__init__(self)

    @pyqtSlot(str, str)
    def writeFile(self, filename, content):
        # TODO: Handle URL parameter better.
        with open(filename.replace('file://',''), 'w') as f:
            f.write(content)

    @pyqtSlot(str, result=str)
    def readFile(self, filename):
        try:
            with open(filename.replace('file://',''), 'r') as f:
                temp = f.read()
                return temp
        except FileNotFoundError as e:
            print(f'Could not open config file: {e}')
        return ''


if __name__ == '__main__':
    # handle command line arguments
    sys_argv = sys.argv
    parser = argparse.ArgumentParser(description='Schnipp is a simple GUI to clip letterbox bars and mark broadcaster logos in video files.')
    parser.add_argument('-p', '--path', help='path to directory with recordings without trailing slash, e.g. file:///home/bob/video')
    args = parser.parse_args()
    # setup Qt application
    style_argv = ['--style', 'Fusion']
    app = QGuiApplication(style_argv)
    app.setWindowIcon(QIcon("images/icon.png"))
    app.setOrganizationName('Christian Wichmann')
    app.setApplicationName('Schnipp!')
    # handle translations
    translator = QTranslator()
    translator.load('i18n/{}.qm'.format(QLocale.system().name()))
    app.installTranslator(translator)
    # start application
    engine = QQmlApplicationEngine()
    fileIO = FileIO()
    engine.rootContext().setContextProperty('FileIO', fileIO)
    if args.path:
        engine.rootContext().setContextProperty('args', args.path)
    engine.load('schnipp.qml')
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
