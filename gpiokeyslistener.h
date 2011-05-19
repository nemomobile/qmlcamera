/*!
 * @file GpioKeysListener.h
 * @brief GpioKeysListener

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Yang Yang <ext-yang.25.yang@nokia.com>

   This file is part of SystemSW QtAPI.

   SystemSW QtAPI is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License
   version 2.1 as published by the Free Software Foundation.

   SystemSW QtAPI is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with SystemSW QtAPI.  If not, see <http://www.gnu.org/licenses/>.
   </p>
 */
#ifndef GpioKeysListener_H
#define GpioKeysListener_H


#include <QObject>
#include <QLocalServer>
#include <QSocketNotifier>
#include <QLocalSocket>
#include <QProcess>
#include <linux/input.h>
#include <stdint.h>
#include <QtDeclarative/QDeclarativeView>
#include <policy/resource-set.h>

#include "qmlcamerasettings.h"

#define SERVER_NAME "/tmp/meegocamera"

class GpioKeysListener : public QObject
{
    Q_OBJECT

public:
    GpioKeysListener(bool visible);
    ~GpioKeysListener();


signals:

    void quit();

private slots:
    void didReceiveKeyEventFromFile(int);
    void hideUI();
    void newConnection();
    void disconnected();
private:
    void HandleGpioKeyEvent(struct input_event &ev);
    void openHandles();
    void cleanSocket();
    bool createCamera();
    void showUI(bool show);


    bool uiVisible;
    int gpioFile;
    QSocketNotifier *gpioNotifier;
    QLocalServer *server;
    QVector<QLocalSocket*> connections;

    QDeclarativeView *m_view;
    QmlCameraSettings m_settings;

    ResourcePolicy::ResourceSet* m_volumeKeyResource;
};

#endif // GpioKeysListener_H
