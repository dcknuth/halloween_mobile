/*
 Sense motion and then turn on the stepper motor for 10 seconds and keep
  repeating that
*/
#include <AccelStepper.h>
#include <SD.h>
#include <TMRpcm.h>
#include <RCSwitch.h>

#define SD_ChipSelectPin 53
/* These are preset by the SD library
#define SCKPin 50 // aka CLK pin?
#define MOSIPin 51
#define MISOPin 52
*/
#define AudioOutPin 46

// RF send pin
#define RFpin 2

// Define step constants
#define FULLSTEP 4
#define HALFSTEP 8

// Define Motor Pins
#define motorPin1  8     // 28BYJ48 pin 1
#define motorPin2  9     // 28BYJ48 pin 2
#define motorPin3  10    // 28BYJ48 pin 3
#define motorPin4  11    // 28BYJ48 pin 4

// The sequence 1-3-2-4 is required for proper sequencing of 28BYJ48
AccelStepper stepper(HALFSTEP, motorPin1, motorPin3, motorPin2, motorPin4);

// RF object
RCSwitch mySwitch = RCSwitch();

TMRpcm music; //Lib object is named "music"
// Time for the sensor to calibrate (10-60 secs according to the datasheet)
int calibrationTime = 20;
// Time when the sensor outputs a low impulse
long unsigned int lowIn;
// Minimum time we want the motor to run
long unsigned int holdMotorTime = 20000; // 20 sec
// Time motor was turned on
long unsigned int mOnTime;
// The amount of milliseconds the sensor has to be low
//  before we assume all motion has stopped
long unsigned int myPause = 8000; // 8 sec
 
boolean detectMotion = true; // Toggle to detect motion again
boolean recordLowTime = false;    // Record no motion detected time
boolean holdOn = false; // To keep motor running a minimum time
 
int pirPin = 3;    //the digital pin connected to the PIR (motion) sensor's output

////////////////// SETUP ////////////
void setup() {
  Serial.begin(9600);
  pinMode(pirPin, INPUT);
  digitalWrite(pirPin, LOW);
 
  //give the sensor some time to calibrate
  Serial.print("calibrating sensor ");
  for(int i = 0; i < calibrationTime; i++){
    Serial.print(".");
    delay(1000);
  }
  Serial.println(" done");
  Serial.println("SENSOR ACTIVE");

  // Setup stepper
  stepper.setMaxSpeed(1000);
  stepper.setSpeed(1000);

  // Setup RF
  // Transmitter connected to Arduino Pin #2  
  mySwitch.enableTransmit(2);
  // Optional set pulse length.
  mySwitch.setPulseLength(314);

  // Music setup
  music.speakerPin = AudioOutPin;
  if (!SD.begin(SD_ChipSelectPin)) {
    Serial.println("SD fail");
    return;
  }
}

void loop() {
  // if we are in a motion state, run the motor
  if(digitalRead(pirPin) == HIGH){
    // Turn off the wait timer for new motion if set
    if(detectMotion){ 
      //makes sure we wait for a transition to LOW before any further output is made:
      detectMotion = false;           
      Serial.println("---");
      Serial.print("motion detected at ");
      Serial.print(millis()/1000);
      Serial.println(" sec");
      // Send RF signal for fog
      mySwitch.send("010001010101010111000000");
      mySwitch.send("010001010101010111000000");
      // Start the music
      music.play("spooky.wav");
    }        
    recordLowTime = true;
    holdOn = true; // Keep the motor running for a minimum time
    mOnTime = millis();
  }

  if(holdOn) {
    stepper.runSpeed();
  }

  // When there is no motion
  if(digitalRead(pirPin) == LOW) {      
    if(recordLowTime) { // We freashly transitioned to no motion
      lowIn = millis();          //save the time of the transition from high to LOW
      recordLowTime = false;       //make sure this is only done at the start of a LOW phase
    }
    //if the sensor is low for more than the given pause,
    //we assume that no more motion is going to happen
    if(!recordLowTime && millis() - lowIn > myPause){ 
      //makes sure this block of code is only executed again after
      //a new motion sequence has been detected
      recordLowTime = true;
      Serial.print("No motion for pause length at ");      //output
      Serial.print((millis()-myPause)/1000);
      Serial.println(" sec");
      if (holdOn && millis() - mOnTime > holdMotorTime) {
        holdOn = false;
        // Stop music
        music.pause();
        detectMotion = true;
      }
    }
  }
}