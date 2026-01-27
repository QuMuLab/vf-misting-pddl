#include <Arduino.h>
// Arduino code that measures flow rate and volume of our flow rate sensor

// Constants
const int SENSOR_PIN = 3; // Pin connected to flow sensor signal
const float PULSES_PER_LITRE = 1380.0; // Calibration factor using F = 23Q, specified on the sensor

// Variables
volatile unsigned long pulseCount = 0; // Pulse counter per second

unsigned long lastMillis = 0; // Time tracker
float flowRate = 0.0; // L/min
float totalVolume = 0.0; // L

// Function that increases the pulse counter when a pulse is detected
void increasePulses() {
  pulseCount++;
}

// Initialization
void setup() {
  Serial.begin(9600);
  
  pinMode(SENSOR_PIN, INPUT_PULLUP); // Set signal pin as input with pullup resistor
  attachInterrupt(digitalPinToInterrupt(SENSOR_PIN), increasePulses, RISING); // When sensor detects increase in voltage, interrupt the main program and increase pulse counter
}

// Main loop
void loop() {
  unsigned long currentMillis = millis();

  // Run once every second
  if (currentMillis - lastMillis >= 1000) {
    lastMillis = currentMillis;

    // Safely copy pulse count
    noInterrupts();
    unsigned long pulses = pulseCount;
    pulseCount = 0; // Reset for next second
    interrupts();

    // Calculate flow rate (L/min)
    flowRate = (pulses / PULSES_PER_LITRE) * 60.0;

    // Calculate total volume (L)
    totalVolume += (pulses / PULSES_PER_LITRE);

    // Output
    Serial.print("Pulses: ");
    Serial.print(pulses);

    Serial.print(" | Flow Rate: ");
    Serial.print(flowRate);
    Serial.print(" L/min");

    Serial.print(" | Total Volume: ");
    Serial.print(totalVolume);
    Serial.println(" L");
  }
}