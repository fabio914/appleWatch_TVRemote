# Apple Watch as a TV Remote

<img src="/2.jpg?raw=true" width="200">

This is a demo that shows that it is possible to control a normal TV with an Apple Watch.

## Video
[![VIDEO](http://img.youtube.com/vi/9AzIApuXMI8/0.jpg)](http://www.youtube.com/watch?v=Y9AzIApuXMI8)

## What you will need:
* Arduino Due (if you edit the code you'll be able to use an Arduino UNO, Pro Mini, etc...)
* ESP8266 Wifi
* Infrared LED
* Apple iPhone + Apple Watch
* Samsung TV (again, if you edit the code you'll be able to send IR Codes from other manufacturers)

## How does it work?

The Arduino sets up the ESP8266 as a Wifi Access Point, and then runs a TCP/IP server on port 1337. Whenever a connection is made and a command `sendIR(code)` is received, the Arduino sends this `code` to the TV through the infrared LED.

So, whenever you tap a button on the Apple Watch app, it communicates with the iPhone app that then connects to the Arduino through TCP/IP and then sends the command related to that button.

## Hookup

<img src="/1.jpg?raw=true" width="400">

| Arduino | Device |
|:------------|:-------|
| 7 | IR LED signal |
| 18 (TX1) | ESP8266 RX |
| 19 (RX1) | ESP8266 TX |

## IR Codes (for a Samsung TV)

| Command | IR code |
|:---------|:---------|
| Power   | 3772793023 |
| Ch + | 3772795063 |
| Ch - | 3772778743 |
| Vol + | 3772833823 |
| Vol - | 3772829743 |

## TCP/IP Protocol

Port `1337`

### Request
``
sendIR(123456789)
``

(`123456789` must be replaced by the desired IR code)

### Response
``
OK IR 123456789
``

or

``
ERROR
``

## Observations
* I could have used the ESP8266 to directly control the Infrared LED, thus removing the Arduino from the equation.

* As of watchOS 2.0, an Apple Watch app cannot open TCP/IP sockets, it has to use the "Watch Connectivity" framework to talk to the iPhone. Thus the iPhone is the one that communicates with the Arduino + ESP8266 via TCP/IP socket.

* You will have to leave the iPhone app running to use the Apple Watch app. You will also have to connect your iPhone to the ESP8266 Wifi Access Point before using the app.

* The App will attempt to connect to IP 192.168.4.1 on port 1337, your ESP8266 might have a different IP address.

* The Arduino will attempt to communicate with the ESP8266 via Serial using a baud rate of 115200, however yours might be different.

* THIS PROJECT IS JUST A **DEMO**! DO NOT EXPECT IT TO REPLACE YOUR TV REMOTE!

## Developer
[Fabio de Albuquerque Dela Antonio](http://fabio914.blogspot.com)
