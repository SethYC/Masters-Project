/* 
 Uses the Adafruit MotorShield version 2 to control an Adafruit stepper motor to open a rat reach door when a button is pressed.  
 But the door must be reset manually by uncoiling the wire and placing door back (this is to prevent the door accidently closing 
 on the rat's arm). 
 
 When the switch is pressed, a signal is sent to another arduino to START playing the tone first, then an event signal is set to 
 Cheetah that the door is starting to open, while also begining to open the door. The tone will play throught the entirety of the 
 door being opened. The previous version of this script had both the sound and door opening controlled by one arduino, but due to
 some electrical issue, doing both together caused the tone to sound noisy instead of a pure 6000Hz tone. 

 Note: 
 -after 20 door openings, a signal to light an LED ("third_LED_Pin") is made, to signal the trial for the rat is over to the 
 experimenter. This LED stays lit until you reset the arduino for the next trial.
 -like the previous version, handling of the infrared beam for detecting reaching events is still handled by another scipt and
 Aruduino. 

 -reseting is done with the switch instead of the onboard reset button, which was cuasing a tone to go off due to
 electrical behaviour of the pins when doing a physical reset. 

 Seth Campbell
 June. 24, 2022
*/

//helpful tutorial: https://learn.adafruit.com/adafruit-motor-shield-v2-for-arduino/using-stepper-motors

//libraries
#include <Wire.h>
#include <Adafruit_MotorShield.h>

//declare pins
int inPin = 13;
int cheetahPin = 8;
int tonePin = 9;
int is_door_open = 0;
int third_LED_Pin = 11; 
int resetpin_out = 0;
int resetpin_in = 3;

//global var for tracking number of door open events 
int trial = 0;

Adafruit_MotorShield AFMS = Adafruit_MotorShield();

//note: our specific stepper motor has 200 steps per revolution, outputting to port 2 (M3 & M4)
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 2); //NOTE: myMotor seems to be a pointer and is not a static object or whatever that uses dot notation, use -> instead... (see https://forum.arduino.cc/index.php?topic=460384.0)

void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);

  //set pins
  pinMode(inPin, INPUT_PULLUP);
  pinMode(cheetahPin, OUTPUT);
  pinMode(third_LED_Pin, OUTPUT);
  //delay(2000);
  pinMode(tonePin, OUTPUT); //this is new
  pinMode(resetpin_out, OUTPUT);
  pinMode(resetpin_in, INPUT_PULLUP);

  digitalWrite(resetpin_out, LOW);

  //initialize motor shield and stepper motor speed
  AFMS.begin();
  myMotor->setSpeed(400); //set motor speed, this is likely beyond the max (which is not that fast anyways)
}

void loop() {
  if (digitalRead(inPin) == LOW && is_door_open == 0) { //if switch is on and door not already opened
    //*tone: let tone play for .5 sec before door starts opening, during this time the door open signal is also sent as this takes time, so the real door open time will be .5 sec ahead of the cheetah timestamps for this event
    digitalWrite(tonePin, HIGH);
    digitalWrite(cheetahPin, HIGH); //door open event is sent, which is also hardwired to the 1st LED
    delay(500);
    digitalWrite(tonePin, LOW);
    digitalWrite(cheetahPin, LOW);
    
    //digitalWrite(LED_BUILTIN, LOW);   // COMMENT THIS OUT! built in LED is connected to pin 13, so this was messing with loop checks!!
    myMotor->step(200, FORWARD, DOUBLE); //spin 1 revolution
    myMotor->release(); //maybe try commenting out later for heat issue                     
    is_door_open = 1; //indicate door is open to prevent trying to open it again before reseting, damaging the setup

    //unwind motor so door is ready to close right away after rat attempts a reach
    myMotor->step(199, BACKWARD, DOUBLE);
    myMotor->release(); //consider putting this in for heat issue
    delay(1000);
    trial = trial + 1;
  }
  
  if (digitalRead(inPin) == HIGH && is_door_open == 1) { //when switch is closed and door is currently opened
    myMotor->release(); //consider putting this in for heat issue
    is_door_open = 0; //resets it
  }

  if (trial >= 20) { //when 20 door opens have occured, trial is over. Light up 3rd LED and stop taking input.
      digitalWrite(third_LED_Pin, HIGH);
  }

  if (digitalRead(resetpin_in) == LOW) {
    trial = 0; //reset trial number

    int number;
    for (number=1;number<=10;number++){ //making a flashing pattern 
      digitalWrite(third_LED_Pin, HIGH);
      delay(100);
      digitalWrite(third_LED_Pin, LOW);
      delay(100);
    }
  }

}
