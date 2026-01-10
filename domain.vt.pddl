(define (domain vertical_farm_misting)

  (:requirements :equality :negative-preconditions :typing :adl :fluents)

  (:types
    pump
  )

  (:predicates
    (pump-on) ; Pump on or off
  )

  (:functions
    (pressure) ; Keep track of pressure, Mpa
    (flow-rate) ; Keep track of flow rate, L/min
    (humidity) ; Keep track of humidity, %
    (energy-use) ; Keep track of energy consumption, kWh
  )

  ;; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on
  ; Effect: pump is on
  ; Consider adding time delay (because it takes a second or so for the pump to start going)
  (:action activate-pump
    :precondition (not (pump-on))
    :effect (pump-on)
  )

  ; Action to activate the pump
  ; Precondition: pump is not on
  ; Effect: pump is on
  (:action deactivate-pump
    :precondition (pump-on)
    :effect (not (pump-on))
  )

  ; Action to stop the pump when the target humidity is reached
  ; Precondition: pump is on and target humidity is reached
  ; Effect: turn pump off
  (:action humidity-reached
    :precondition (and
      (pump-on)
      (>= (humidity) TARGET_HUMIDITY)) ; Need to define TARGET_HUMIDITY elsewhere
    :effect (not (pump-on))
  )

  ; Action to stop the pump when the maximum energy is exceeded
  ; Precondition: pump is on and energy use exceeds max energy
  ; Effect: turn pump off
  (:action energy-exceeded
    :precondition (and
      (pump-on)
      (> (energy-use) MAX_ENERGY)) ; Need to define MAX_ENERGY elsewhere
    :effect (not (pump-on))
  )

  ;; Processes

  ; Process to increase pressure while the pump is on
  ; Precondition: pump is on
  ; Effect: increase pressure over time
  (:process pressure-inc
    :precondition (pump-on)
    :effect (increase (pressure) (* #t PRESSURE_INC_RATE)) ; Define PRESSURE_INC_RATE constant elsewhere
  )

  ; Process to decrease pressure while the pump is off
  ; Precondition: pump is off
  ; Effect: decrease pressure over time
  (:process pressure-dec
    :precondition (not (pump-on))
    :effect (decrease (pressure) (* #t PRESSURE_DEC_RATE)) ; Define PRESSURE_DEC_RATE constant elsewhere
  )

  ; Process to calculate flow rate during misting
  ; Precondition: pump is on
  ; Effect: calculate flow rate
  (:process flow-calc
    :precondition (pump-on)
    :effect (assign (flow-rate) FLOW_RATE) ; Define FLOW_RATE constant elsewhere
  )

  ; Process to increase humidity when pump is on
  ; Precondition: pump is on
  ; Effect: increase humidity over time
  (:process humidity-inc
    :precondition (pump-on)
    :effect (increase (humidity) (* #t HUMIDITY_INC_RATE)) ; Define HUMIDITY_INC_RATE constant elsewhere
  )

  ; Process to decrease humidifity when pump is off
  ; Precondition: pump is off
  ; Effect: decrease humidity over time
  (:process humidity-dec
    :precondition (not (pump-on))
    :effect (decrease (humidity) (* #t HUMIDITY_DEC_RATE)) ; Define HUMIDITY_DEC_RATE constant elsewhere
  )

  ; Process to calculate energy usage when pump is on
  ; Precondition: pump is on
  ; Effect: calculate energy usage over time
  (:process energy-calc
    :precondition (pump-on)
    :effect (increase (energy-use) (* #t ENERGY_RATE)) ; Define ENERGY_RATE constant elsewhere
  )

  ;; Events

  ; Event to shut pump off if pressure exceeds max pressure
  ; Precondition: pressure exceeds max pressure
  ; Effect: turn pump off
  (:event pump-failure
    :precondition (> (pressure) MAX_PRESSURE) ; Need to define MAX_PRESSURE elsewhere
    :effect (not (pump-on))
  )
)
