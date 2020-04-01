
"""

Sources:
 * https://doc.qt.io/qt-5/qmlreference.html
 * 
 * 

"""

import sys

from PyQt5.QtCore import QUrl
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import QIcon

 
if __name__ == '__main__':
    app =QApplication(sys.argv)
    app.setOrganizationName('Christian Wichmann')
    app.setApplicationName('Schnipp!')
    engine = QQmlApplicationEngine()
    app.setWindowIcon(QIcon("images/icon.png"))
    engine.load('schnipp.qml')
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
