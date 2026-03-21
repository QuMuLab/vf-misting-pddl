(define (domain vf-misting-spikes)

  (:requirements :negative-preconditions :typing :fluents)

  (:types
    pump nozzle
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (nozzle-on ?n - nozzle) ; Nozzle on or off
    (done) ; Special predicate for goal state

    (nozzle-fault ?n - nozzle) ; Issue with nozzle
    (pump-fault ?p - pump) ; Issue with pump
  )

  (:functions
    ; Variables
    (sim-time) ; Simulation time, s
    (pressure) ; Pressure, psi
    (humidity) ; Current humidity, %

    (flow-up) ; Upstream flow rate, L/min
    (flow-down) ; Downstream flow rate, L/min
    (flow-nozzle) ; Branch flow rate, L/min

    ; Constants
    (max-pressure) ; Max pressure, psi

    (time-const) ; Time constant for calculations
    (flow-const) ; Flow constant for calculations

    (up-coeff) ; Upstream tube coefficient
    (nozzle-coeff) ; Nozzle coefficient
    (down-coeff) ; Downstream tube coefficient

    (min-humidity) ; Min humidity, %
    (max-humidity) ; Max humidity, %

     ; Rates
    (humidity-inc-rate) ; Rate of humidity increase, %/s
    (humidity-dec-rate) ; Rate of humidity decrease, %/s
  )

  ; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on, pump and nozzle are not faulty
  ; Effect: pump is on
  (:action activate-pump
    :parameters (?p - pump ?n - nozzle)
    :precondition (and
      (not (pump-on ?p))
      (not (pump-fault ?p))
      (not (nozzle-fault ?n)))
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
  ; Effect: nozzle is on
  (:action activate-nozzle
    :parameters (?n - nozzle ?p - pump)
    :precondition (and
      (not (nozzle-on ?n))
      (pump-on ?p))
    :effect (nozzle-on ?n)
  )

  ; Action to deactivate the nozzle
  ; Precondition: nozzle is on
  ; Effect: nozzle is not on
  (:action deactivate-nozzle
    :parameters (?n - nozzle ?p - pump)
    :precondition (nozzle-on ?n)
    :effect (not (nozzle-on ?n))
  )

  ; Action to set the done state when simulation time reaches 10 seconds
  ; Precondition: simulation time is 10 or more seconds
  ; Effect: done predicate is true
  (:action finish
    :parameters ()
    :precondition (>= (sim-time) 10)
    :effect (done)
  )

  ; Processes

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
  ; Effect: increase pressure over time according to dP/dt = k_time * (Pmax - P) - k_flow * Q_nozzle
  (:process pressure-inc
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (< (pressure) (max-pressure)))
    :effect
      (increase (pressure) (* #t (- (* (time-const) (- (max-pressure) (pressure))) (* (flow-const) (flow-nozzle)))))
  )

  ; Process to decrease pressure while the pump is off
  ; Precondition: pump is off, pressure is over 0
  ; Effect: decrease pressure over time according to dP/dt = -k_time * P
  (:process pressure-dec
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (> (pressure) 0.001))
    :effect (decrease (pressure) (* #t (* (time-const) (pressure))))
  )

  ; Process to calculate upstream flow rate
  ; Precondition: pressure is over 0
  ; Effect: increase upstream flow rate over time according to dQ/dt = k_time * (Q_target - Q_up)
  ; where Q_target = Q_nozzle + c_up * dP/dt
  (:process flow-up-inc
    :parameters ()
    :precondition (> (pressure) 0.001)
    :effect (increase (flow-up) (* #t (* (time-const) (- (+ (flow-nozzle) (* (up-coeff) (pressure))) (flow-up)))))
  )

  ; Process to calculate nozzle flow rate while nozzle is on
  ; Precondition: nozzle is on, upstream flow is larger than nozzle flow
  ; Effect: increase nozzle flow rate over time according to dQ/dt = k * (Q_target - Q_nozzle)
  ; where Q_target = k_nozzle * sqrt(pressure)
  (:process flow-nozzle-inc
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (increase (flow-nozzle) (* #t (* (time-const) (- (* (nozzle-coeff) (max-pressure)) (flow-nozzle)))))  ; Equation for VAL
    ; :effect (increase (flow-nozzle) (* #t (* (time-const) (- (* (nozzle-coeff) (^ (pressure) 0.5)) (flow-nozzle)))))  ; Equation for ENHSP-2020
  )

  ; Process to calculate downstream flow rate
  ; Precondition: pressure is over 0
  ; Effect: increase downstream flow rate over time according to dQ/dt = k_time * (Q_target - Q_down)
  ; where Q_target = Q_nozzle + c_down * dP/dt
  (:process flow-down-inc
    :parameters ()
    :precondition (> (pressure) 0.001)
    :effect (increase (flow-down) (* #t (* (time-const) (- (+ (flow-nozzle) (* (down-coeff) (pressure))) (flow-down)))))
  )

  ; Process to decrease nozzle flow rate while nozzle is off
  ; Precondition: nozzle is not on, nozzle flow rate is above 0
  ; Effect: decrease nozzle flow rate over time according to dQ/dt = -k_time * Q_nozzle
  (:process flow-nozzle-dec
    :parameters (?n - nozzle)
    :precondition (and
      (not (nozzle-on ?n))
      (> (flow-nozzle) 0.001))
    :effect (decrease (flow-nozzle) (* #t (* (time-const) (flow-nozzle))))
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

  ; Events for VAL

  ; Event to shut pump off if pressure exceeds max pressure
  ; Precondition: pressure exceeds max pressure
  ; Effect: turn pump off, flag pump fault
  (:event pump-failure
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (> (pressure) (max-pressure))
      (not (pump-fault ?p)))
    :effect (and
      (not (pump-on ?p))
      (pump-fault ?p))
  )

  ; Event to shut pump off if nozzle is not working
  ; Precondition: upstream flow is > 0 but nozzle flow is 0
  ; Effect: turn pump off, flag nozzle fault
  (:event nozzle-failure
    :parameters (?p - pump ?n - nozzle)
    :precondition (and
      (pump-on ?p)
      (> (flow-up) 0.2)
      (<= (flow-nozzle) 0.05)
      (not (nozzle-fault ?n)))
    :effect (and
      (not (pump-on ?p))
      (nozzle-fault ?n))
  )
)
