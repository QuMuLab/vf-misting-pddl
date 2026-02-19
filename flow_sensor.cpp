#include <Arduino.h>
// Arduino code that measures flow rate and volume of two flow rate sensors

// Constants
const int sensorPin1 = 2; // Pin connected to first flow sensor signal
const int sensorPin2 = 3; // Pin connected to second flow sensor signal
const float calibrationFactor = 1380.0; // Calibration factor using F = 23Q, specified on the sensor

// Variables
volatile unsigned long pulseCount1 = 0; // Pulse counter per second for first sensor
volatile unsigned long pulseCount2 = 0; // Pulse counter per second for second sensor

unsigned long lastMillis = 0; // Time tracker

float flowRate1 = 0.0; // L/min for first sensor
float flowRate2 = 0.0; // L/min for second sensor

float totalVolume1 = 0.0; // L for first sensor
float totalVolume2 = 0.0; // L for second sensor

// Increase first pulse counter when a pulse is detected
void increasePulses1() {
  pulseCount1++;
}

// Increase second pulse counter when a pulse is detected
void increasePulses2() {
  pulseCount2++;
}

// Initialization
void setup() {
  Serial.begin(9600);
  
  // Set signal pins as input with pullup resistor
  pinMode(sensorPin1, INPUT_PULLUP);
  pinMode(sensorPin2, INPUT_PULLUP);

  // When sensor detects increase in voltage, interrupt the main program and increase pulse counter
  attachInterrupt(digitalPinToInterrupt(sensorPin1), increasePulses1, RISING);
  attachInterrupt(digitalPinToInterrupt(sensorPin2), increasePulses2, RISING);
}

// Main loop
void loop() {
  unsigned long currentMillis = millis();

  // Run once every second
  if (currentMillis - lastMillis >= 1000) {
    lastMillis = currentMillis;

    // Copy and reset counters safely
    noInterrupts();
    unsigned long pulses1 = pulseCount1;
    unsigned long pulses2 = pulseCount2;
    // Reset pulses for next second
    pulseCount1 = 0;
    pulseCount2 = 0;
    interrupts();

    // Calculate flow rate (L/min)
    flowRate1 = (pulses1 / calibrationFactor) * 60.0;
    flowRate2 = (pulses2 / calibrationFactor) * 60.0;

    // Calculate total volume (L)
    totalVolume1 += (pulses1 / calibrationFactor);
    totalVolume2 += (pulses2 / calibrationFactor);

    // Output
    Serial.print("Sensor 1 (before nozzle) | ");
    Serial.print("Pulses: ");
    Serial.print(pulses1);
    Serial.print(" | Flow Rate: ");
    Serial.print(flowRate1);
    Serial.print(" L/min | Volume: ");
    Serial.print(totalVolume1);
    Serial.println(" L");

    Serial.print("Sensor 2 (after nozzle) | ");
    Serial.print("Pulses: ");
    Serial.print(pulses2);
    Serial.print(" | Flow Rate: ");
    Serial.print(flowRate2);
    Serial.print(" L/min | Volume: ");
    Serial.print(totalVolume2);
    Serial.println(" L");
  }
}