
"""

Sources:
 * https://doc.qt.io/qt-5/qmlreference.html
 * 
 * 

"""
import sys

from PyQt5.QtCore import QUrl
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQuick import QQuickView


if __name__ == '__main__':
    app = QApplication([])
    app.setOrganizationName('Christian Wichmann')
    app.setApplicationName('Schnipp!')
    view = QQuickView()
    view.setResizeMode(QQuickView.SizeRootObjectToView)
    view.setSource(QUrl.fromLocalFile('schnipp.qml'))
    if view.status() == QQuickView.Error:
        sys.exit(-1)
    view.show()
    res = app.exec_()
    del view
    sys.exit(res)
