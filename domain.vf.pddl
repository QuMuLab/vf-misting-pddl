(define (domain vertical_farm_misting)

  (:requirements :typing :negative-preconditions :numeric-fluents :time)

  (:types
    nozzle pump tube
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (connected ?from ?to ?tube - tube); Objects are connected by tubes
  )

  (:functions
    ; Variables
    (humidity) ; Current humidity, %
    (pressure) ; Keep track of pressure, Mpa
    (flow-rate) ; Keep track of flow rate, L/min
    (energy-use) ; Keep track of energy consumption, kWh

    ; Constants
    (tube-area); Area of tube, in^2
    (min-humidity) ; Min humidity, %
    (max-humidity) ; Max humidity, %
    (max-pressure); Max pressure, Mpa
    (max-energy); Max energy, kWh

    ; Rates
    (humidity-inc-rate); Rate of humidity increase, %/s
    (humidity-dec-rate); Rate of humidity decrease, %/s
    (pressure-inc-rate); Rate of pressure increase, Mpa/s
    (pressure-dec-rate); Rate of pressure decrease, Mpa/s
    (flow-inc-rate); Rate of flow rate increase, L/min/s
    (energy-inc-rate); Rate of energy consumption, kWh/s
  )

  ;; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on
  ; Effect: pump is on
  ; Consider adding time delay (because it takes a second or so for the pump to start going)
  (:action activate-pump
    :parameters (?p - pump)
    :precondition (not (pump-on ?p))
    :effect (pump-on ?p)
  )

  ; Action to activate the pump
  ; Precondition: pump is not on
  ; Effect: pump is on
  (:action deactivate-pump
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (not (pump-on ?p))
  )

  ; Action to stop the pump when the target humidity is reached
  ; Precondition: pump is on and target humidity is reached
  ; Effect: turn pump off
  (:action humidity-reached
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (>= (humidity) (min-humidity))
      (<= (humidity) (max-humidity)))
    :effect (not (pump-on ?p))
  )

  ; Action to stop the pump when the maximum energy is exceeded
  ; Precondition: pump is on and energy use exceeds max energy
  ; Effect: turn pump off
  (:action energy-exceeded
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (> (energy-use) (max-energy)))
    :effect (not (pump-on ?p))
  )

  ;; Processes

  ; Process to increase pressure while the pump is on
  ; Precondition: pump is on
  ; Effect: increase pressure over time
  (:process pressure-inc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (increase (pressure) (* #t (pressure-inc-rate)))
  )

  ; Process to decrease pressure while the pump is off
  ; Precondition: pump is off
  ; Effect: decrease pressure over time
  (:process pressure-dec
    :parameters (?p - pump)
    :precondition (not (pump-on ?p))
    :effect (decrease (pressure) (* #t (pressure-dec-rate)))
  )

  ; Process to calculate flow rate during misting
  ; Precondition: pump is on
  ; Effect: calculate flow rate
  (:process flow-calc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (increase (flow-rate) (* #t (flow-inc-rate)))
  )

  ; Process to increase humidity when pump is on
  ; Precondition: pump is on
  ; Effect: increase humidity over time
  (:process humidity-inc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (increase (humidity) (* #t (humidity-inc-rate)))
  )

  ; Process to decrease humidifity when pump is off
  ; Precondition: pump is off
  ; Effect: decrease humidity over time
  (:process humidity-dec
    :parameters (?p - pump)
    :precondition (not (pump-on ?p))
    :effect (decrease (humidity) (* #t (humidity-dec-rate)))
  )

  ; Process to calculate energy usage when pump is on
  ; Precondition: pump is on
  ; Effect: calculate energy usage over time
  (:process energy-calc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (increase (energy-use) (* #t (energy-inc-rate)))
  )

  ;; Events

  ; Event to shut pump off if pressure exceeds max pressure
  ; Precondition: pressure exceeds max pressure
  ; Effect: turn pump off
  (:event pump-failure
    :parameters (?p - pump)
    :precondition (> (pressure) (max-pressure))
    :effect (not (pump-on))
  )
)
