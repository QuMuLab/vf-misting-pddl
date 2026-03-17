(define (domain vertical_farm_misting)

  (:requirements :equality :negative-preconditions :typing :adl :fluents)

  (:types
    pump nozzle
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (nozzle-on ?n - nozzle) ; Nozzle on or off
    (done) ; Special predicate for goal state

    (nozzle-fault) ; Detect when there's an issue with nozzle not turning on
    (pump-fault) ; Detect when there's an issue with the pump
  )

  (:functions
    ; Variables
    (sim-time) ; Simulation time, s
    (pressure) ; Keep track of pressure, psi
    (humidity) ; Current humidity, %

    (flow-up) ; Keep track of upstream flow rate, L/min
    (flow-down) ; Keep track of downstream flow rate, L/min
    (flow-nozzle) ; Keep track of branch flow rate, L/min

    ; Constants
    (max-pressure) ; Max pressure, Mpa
    (time-const) ; Time constant, s
    (flow-const) ; Time constant, s
    (flow-coeff) ; Coefficient for flow rate calculation, units
    (nozzle-coeff) ; Coefficient for nozzle flow rate calculation, units

    (min-humidity) ; Min humidity, %
    (max-humidity) ; Max humidity, %

    ; Rates
    (humidity-inc-rate) ; Rate of humidity increase, %/s
    (humidity-dec-rate) ; Rate of humidity decrease, %/s
  )

  ;; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on, pump and nozzle are not faulty
  ; Effect: pump is on
  (:action activate-pump
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (not (pump-fault))
      (not (nozzle-fault)))
    :effect (pump-on ?p)
  )

  ; Action to deactivate the pump
  ; Precondition: pump is on
  ; Effect: pump is not on
  (:action deactivate-pump
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (not (pump-on ?p))
  )

  ; Action to activate the nozzle
  ; Precondition: nozzle is not on but pump is on
  ; Effect: pump is on
  (:action activate-nozzle
    :parameters (?n - nozzle ?p -pump)
    :precondition (and
      (not (nozzle-on ?n))
      (pump-on ?p))
    :effect (nozzle-on ?n)
  )

  ; Action to deactivate the nozzle
  ; Precondition: nozzle is on
  ; Effect: pump is on
  (:action deactivate-nozzle
    :parameters (?n - nozzle ?p -pump)
    :precondition (nozzle-on ?n)
    :effect (not (nozzle-on ?n))
  )

  ; Action to stop the pump when the target humidity is reached
  ; Precondition: pump is on, humidity is between target max and min humidity
  ; Effect: turn pump off
  (:action humidity-reached
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (> (humidity) (min-humidity))
      (< (humidity) (max-humidity)))
    :effect (not (pump-on ?p))
  )

  ; Action to set the done state when simulation time reaches 10 seconds
  ; Precondition: simulation time is 10 or more seconds
  ; Effect: done predicate is true
  (:action finish
    :parameters ()
    :precondition (>= (sim-time) 10)
    :effect (done)
  )

  ;; Processes

  ; Process to increase time
  ; Precondition: simulation time is less than 10 seconds
  ; Effect: increase simulation time over time
  (:process time-inc
    :parameters ()
    :precondition (< (sim-time) 10)
    :effect (increase (sim-time) (* #t 1))
  )

  ; Process to increase pressure while the pump is on
  ; Precondition: pump is on, pressure is less than max pressure
  ; Effect: increase pressure over time according to dP/dt = k * (Pmax - P)
  (:process pressure-inc
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (< (pressure) (max-pressure)))
    :effect (increase (pressure) (* #t (* (time-const) (- (max-pressure) (pressure)))))
  )

  ; Process to decrease pressure while the pump is off
  ; Precondition: pump is off, pressure is slightly above 0
  ; Effect: decrease pressure over time according to dP/dt = -k * P
  (:process pressure-dec
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (> (pressure) 0.001))
    :effect (decrease (pressure) (* #t (* (time-const) (pressure))))
  )

  ; Process to increase upstream flow rate while pump is on
  ; Precondition: pressure is not 0
  ; Effect: increase upstream flow rate over time according to dQ/dt = k * (Q_up - Q)
  ; where Q_up = flow-coeff * sqrt(pressure)
  (:process flow-up-inc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (increase (flow-up) (* #t (* (flow-const) (- (* (flow-coeff) (max-pressure)) (flow-up)))))  ; max-pressure for VAL to work
    ; :effect (increase (flow-up) (* #t (* (flow-const) (- (* (flow-coeff) (^ (pressure) 0.5)) (flow-up)))))  ; normal eq for ENHSP-2020
  )

  ; Process to increase nozzle flow rate while nozzle is on
  ; Precondition: nozzle is on
  ; Effect: increase nozzle flow rate over time according to dQ/dt = k * (Q_nozzle - Q)
  ; where Q_nozzle = nozzle-coeff * sqrt(pressure)
  (:process flow-nozzle-inc
    :parameters (?n - nozzle)
    :precondition (and
      (nozzle-on ?n)
      (> (flow-up) (flow-nozzle)))
    :effect (increase (flow-nozzle) (* #t (* (flow-const) (- (* (nozzle-coeff) (max-pressure)) (flow-nozzle)))))  ; max-pressure for VAL to work
    ; :effect (increase (flow-nozzle) (* #t (* (flow-const) (- (* (nozzle-coeff) (^ (pressure) 0.5)) (flow-nozzle)))))  ; normal eq for ENHSP-2020
  )

  ; Process to calculate downstream flow rate
  ; Precondition: flow-up is over 0
  ; Effect: calculate downstream flow rate over time according to dQ/dt = k * (Q_down - Q)
  ; where Q_down = Q_up - Q_nozzle
  (:process flow-down-inc
    :parameters ()
    :precondition (and
      (> (flow-up) 0.001))
    :effect (increase (flow-down) (* #t (* (flow-const) (- (- (flow-up) (flow-nozzle)) (flow-down)))))
  )

  ; Process to decrease upstream flow rate while pump is off
  ; Precondition: pump is not on, upstream flow rate is slightly above 0
  ; Effect: decrease upstream flow rate over time according to dQ/dt = -k * Q
  (:process flow-up-dec
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (> (flow-up) 0.001))
    :effect (decrease (flow-up) (* #t (* (flow-const) (flow-up))))
  )

  ; Process to decrease nozzle flow rate while nozzle is off
  ; Precondition: nozzle is not on, nozzle flow rate is slightly above 0
  ; Effect: decrease nozzle flow rate over time according to dQ/dt = -k * Q
  (:process flow-nozzle-dec
    :parameters (?n - nozzle)
    :precondition (and
      (not (nozzle-on ?n))
      (> (flow-nozzle) 0.001))
    :effect (decrease (flow-nozzle) (* #t (* (flow-const) (flow-nozzle))))
  )

  ; Process to increase humidity when nozzle is on
  ; Precondition: nozzle is on
  ; Effect: increase humidity over time
  (:process humidity-inc
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (increase (humidity) (* #t (humidity-inc-rate)))
  )

  ; Process to decrease humidity when nozzle is off
  ; Precondition: nozzle is off, humidity is above 0
  ; Effect: decrease humidity over time
  (:process humidity-dec
    :parameters (?n - nozzle)
    :precondition (and
      (not (nozzle-on ?n))
      (> (humidity) 0.001))
    :effect (decrease (humidity) (* #t (humidity-dec-rate)))
  )

  ;; Events

  ; Event to shut pump off if pressure exceeds max pressure
  ; Precondition: pressure exceeds max pressure
  ; Effect: turn pump off, flag pump fault
  (:event pump-failure
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (> (pressure) (max-pressure))
      (not (pump-fault)))
    :effect (and
      (not (pump-on ?p))
      (pump-fault))
  )

  ; Event to shut pump off if nozzle is not working
  ; Precondition: upstream flow is > 0 but nozzle flow is 0
  ; Effect: turn pump off, flag nozzle fault
  (:event nozzle-failure
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (> (flow-up) 0.2)
      (<= (flow-nozzle) 0.05)
      (not (pump-fault))
      (not (nozzle-fault)))
    :effect (and
      (not (pump-on ?p))
      (nozzle-fault))
  )
)
