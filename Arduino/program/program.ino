/*
 * Arduino Due + ESP8266 + IR emitter
 *
 * created by Fabio de Albuquerque Dela Antonio
 * based on this example: http://allaboutee.com/2014/12/30/esp8266-and-arduino-webserver/
 */

/* Uses Arduino-IRremote-Due (https://github.com/enternoescape/Arduino-IRremote-Due) */
#include <IRremote2.h> 

/* IR LED on pin 7 */
IRsend irsend;

#define DEBUG true

/* Uses Serial1 for the ESP8266 */
#define esp8266 Serial1

void setup() {

  Serial.begin(115200);

  /* Using 115200 as the baud rate, yours may be different */
  esp8266.begin(115200);
  
  sendData("AT+RST\r\n",2000,DEBUG);

  /* AP mode, you'll need to connect to the ESP8266 AP to communicate with it */
  sendData("AT+CWMODE=2\r\n",1000,DEBUG);

  sendData("AT+CIFSR\r\n",1000,DEBUG);
  sendData("AT+CIPMUX=1\r\n",1000,DEBUG); 

  /* TCP/IP server on port 1337 (192.168.4.1 is the IP usually) */
  sendData("AT+CIPSERVER=1,1337\r\n",1000,DEBUG);
}
 
void loop() {

  if(esp8266.available()) {   
     
    if(esp8266.find("+IPD,")) {   
 
      delay(1000);
      char buffer[128];
      
      memset(buffer, 0, 128);
      esp8266.readBytesUntil(',', buffer, 128);
      int connectionId = atoi(buffer);

      memset(buffer, 0, 128);
      esp8266.readBytesUntil(':', buffer, 128);
      int length = atoi(buffer);

      memset(buffer, 0, 128);
      sprintf(buffer, "Connection: %d Length: %d", connectionId, length);
      Serial.println(buffer);
      
      memset(buffer, 0, 128);
      esp8266.readBytesUntil('(', buffer, 128);
      Serial.print("Command: ");
      Serial.println(buffer);

      /* sendIR(<code>) command */
      if(strcmp(buffer, "sendIR") == 0) {

        memset(buffer, 0, 128);   
        esp8266.readBytesUntil(')', buffer, 128);
        unsigned long value = strtoul(buffer, NULL, 10);

        memset(buffer, 0, 128); 
        sprintf(buffer, "OK IR %lu", value);
        Serial.println(buffer);

        /* Send this code to the IR emitter */
        irsend.sendSamsung(value, 32);

        sendConnection(connectionId, buffer);
        closeConnection(connectionId);
      }

      else {

        Serial.println("Unknown command");

        sendConnection(connectionId, "ERROR");
        closeConnection(connectionId);
      }
    }
  }
}
 
String sendData(String command, const int timeout, boolean debug) {
  
  String response = "";
  esp8266.print(command);
  long int time = millis();
  
  while((time+timeout) > millis()) {
    while(esp8266.available()) {
      
      char c = esp8266.read();
      response+=c;
    }  
  }
  
  if(debug) {
    Serial.print(response);
  }
  
  return response;
}

void sendConnection(int connectionId, char * string) {

  char buffer[128];
  memset(buffer, 0, 128);
  sprintf(buffer, "AT+CIPSEND=%d,%d\r\n", connectionId, strlen(string));
  sendData(String(buffer), 1000, DEBUG);
  sendData(String(string), 1000, DEBUG);
}

void closeConnection(int connectionId) {

  char buffer[128];
  memset(buffer, 0, 128);
  sprintf(buffer, "AT+CIPCLOSE=%d\r\n", connectionId);
  sendData(String(buffer), 1000, DEBUG);
}
