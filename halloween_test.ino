/*
 Sense motion and then turn on the stepper motor for 10 seconds and keep
  repeating that
*/
#include <Stepper.h>

// Time for the sensor to calibrate (10-60 secs according to the datasheet)
int calibrationTime = 11;
// Time when the sensor outputs a low impulse
long unsigned int lowIn;
// Minimum time we want the motor to run
long unsigned int holdMotorTime = 10000; // 10 sec
// Time motor was turned on
long unsigned int mOnTime;
// The amount of milliseconds the sensor has to be low
//  before we assume all motion has stopped
long unsigned int pause = 5000; // 5 sec
 
boolean lockLow = true; // Toggle to detect motion again
boolean takeLowTime;    // When we moved to low
boolean holdMotorOn = false; // To keep motor running a minimum time
 
int pirPin = 3;    //the digital pin connected to the PIR sensor's output

const int stepsPerRevolution = 2048;
// Set stepper speed 0 - 100;
const int motorSpeed = 10; // Higher than 10 may not work with our motor

// initialize the stepper library on pins 8 through 11:
//  ordering for our moter needs to be 1-3-2-4 so
//  use 8-10-9-11
Stepper myStepper(stepsPerRevolution, 8, 10, 9, 11);
int stepCount = 0;  // number of steps the motor has taken

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
  delay(50);
}

void loop() {
  // if we are in a motion state, run the motor
  if(digitalRead(pirPin) == HIGH){
    if (motorSpeed > 0) { // set the motor speed:
      myStepper.setSpeed(motorSpeed);
      // step 1/100 of a revolution:
      myStepper.step(stepsPerRevolution / 100);
      stepCount = stepCount + motorSpeed * (stepsPerRevolution / 100);
    }
    Serial.println(stepCount);
    // Turn off the wait timer for new motion if set
    if(lockLow){ 
      //makes sure we wait for a transition to LOW before any further output is made:
      lockLow = false;           
      Serial.println("---");
      Serial.print("motion detected at ");
      Serial.print(millis()/1000);
      Serial.println(" sec");
    }        
    takeLowTime = true;
    holdMotorOn = true; // Keep the motor running for a minimum time
    mOnTime = millis();
    delay(2);
  }

  // Keep the motor running for a minimum amount of time
  if(holdMotorOn && millis()- mOnTime < holdMotorTime) {
    myStepper.setSpeed(motorSpeed);
    // step 1/100 of a revolution:
    myStepper.step(stepsPerRevolution / 100);
    stepCount = stepCount + motorSpeed * (stepsPerRevolution / 100);
    Serial.println(stepCount);
    delay(2);
  }

  // When there is no motion
  if(digitalRead(pirPin) == LOW) {      
    if(takeLowTime) { // We freashly transitioned to no motion
      lowIn = millis();          //save the time of the transition from high to LOW
      takeLowTime = false;       //make sure this is only done at the start of a LOW phase
    }
    //if the sensor is low for more than the given pause,
    //we assume that no more motion is going to happen
    if(!lockLow && millis() - lowIn > pause){ 
      //makes sure this block of code is only executed again after
      //a new motion sequence has been detected
      lockLow = true;                       
      Serial.print("motion ended at ");      //output
      Serial.print((millis()-pause)/1000);
      Serial.println(" sec");
      delay(2);
    }
  }
}