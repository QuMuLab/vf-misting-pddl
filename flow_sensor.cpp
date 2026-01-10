// Starter code that theoretically should measure the flow rate when connected by Arduino to our flow rate sensor

// Constants
const float PULSES_PER_LITRE = 1.0;
// I don't think there's a manual, so this will need to be manually calibrated
// Run 1L of water through the sensor, then compare that to the number of pulses calculated by this program

// Variables
int sensorPin = 2; // Pin connected to flow sensor signal
volatile int pulses; // Pulse counter per second
float flowRate = 0; // L/min
float totalVolume = 0; // L

// Function that increases the pulse counter when a pulse is detected
void increasePulses() {
  pulses++;
}

// Initialization
void setup() {
  Serial.begin(9600);
  pinMode(sensorPin, INPUT_PULLUP); // Set signal pin as input with pullup resistor
  attachInterrupt(digitalPinToInterrupt(sensorPin), increasePulses, RISING); // When sensor detects increase in voltage, interrupt the main program and increase pulse counter
}

// Main loop
void loop() {
  // Calculate flow rate and volume every second
  delay(1000); // Wait for 1 second

  // Calculate flow rate (L/min)
  flowRate = (pulses / PULSES_PER_LITRE) * 60.0;

  // Calculate total volume (L)
  totalVolume += (pulses / PULSES_PER_LITRE);

  Serial.print("Flow Rate: ");
  Serial.print(flowRate);
  Serial.print(" L/min | Total Volume: ");
  Serial.print(totalVolume);
  Serial.println(" L");

  pulses = 0; // Reset pulse counter
}
