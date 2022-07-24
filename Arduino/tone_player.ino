
/*
 Receives a signal from door_opener running on another arduino, and then plays a tone through a connected speaker.
 
 Seth Campbell 
 Mar. 21, 2022
*/

//declare pins
int inPin = 13;
int tonePin = 9;

void setup() {
  //set pins
  pinMode(inPin, INPUT_PULLUP);
  pinMode(tonePin, OUTPUT); 
}

void loop() {
  if (digitalRead(inPin) == HIGH) { //if input pin detects a high voltage (from other arduino)
    tone(tonePin,6000,1500); //play 6000 Hz tone for 1.5 sec.
    delay(500);
  }
}
