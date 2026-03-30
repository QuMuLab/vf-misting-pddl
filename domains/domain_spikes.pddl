(define (domain vf-misting-spikes)

  (:requirements :equality :negative-preconditions :typing :adl :fluents)

  (:types
    pump nozzle
  )

  (:predicates
    (done) ; Special predicate for goal state

    (pump-on ?p - pump) ; Pump on or off
    (pump-ramping-up ?p - pump) ; Pump is starting
    (pump-ramping-down ?p - pump) ; Pump is stopping

    (nozzle-on ?n - nozzle) ; Nozzle on or off
  )

  (:functions
    ; Variables
    (sim-time) ; Simulation time, s
    (pump-level ?p - pump) ; Ranges from 0 (fully off) to 1 (fully on)

    (pressure) ; Pressure, Pa

    (flow-up) ; Upstream flow rate, m^3/s
    (flow-down) ; Downstream flow rate, m^3/s

    (humidity) ; Current humidity, %

    ; Constants
    (done-time) ; Time for done predicate, s

    (max-pressure) ; Max pressure, Pa

    (k-pressure) ; beta/V, water resistance to compression/tube volume
    (inertia-up) ; 1/upstream inertia
    (inertia-down) ; 1/downstream inertia
    (resistance-up) ; Upstream resistance
    (resistance-down) ; Downstream resistance
    (k-nozzle) ; Nozzle coefficient

    (max-humidity) ; Minimum humidity level for the goal state, %
    (min-humidity) ; Maximum humidity level for the goal state, %

    ; Rates
    (pump-level-rate) ; Rate of pump level increase

    (humidity-inc-rate) ; Rate of humidity increase, %/s
    (humidity-dec-rate) ; Rate of humidity decrease, %/s  
  )

  ; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on, pump level is not fully on
  ; Effect: pump is ramping up and on
  (:action activate-pump
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (< (pump-level ?p) 1))
    :effect (and
      (pump-ramping-up ?p)
      (pump-on ?p))
  )

  ; Action to deactivate the pump
  ; Precondition: pump is on, pump level is not fully off
  ; Effect: pump is ramping down and not on
  (:action deactivate-pump
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (> (pump-level ?p) 0))
    :effect (and
      (pump-ramping-down ?p)
      (not (pump-on ?p)))
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
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (not (nozzle-on ?n))
  )

  ; Action to set the done state when simulation time reaches a set time
  ; Precondition: simulation time is equal to or more than the set time
  ; Effect: done predicate is true
  (:action finish
    :parameters ()
    :precondition (>= (sim-time) (done-time))
    :effect (done)
  )

  ; Processes

  ; Process to increase time
  ; Precondition: simulation time is less than the set time
  ; Effect: increase simulation time over time
  (:process time-inc
    :parameters ()
    :precondition (< (sim-time) (done-time))
    :effect (increase (sim-time) (* #t 1))
  )

  ; Process to increase pump level as it's turning on
  ; Precondition: pump is on and ramping up, but not fully on
  ; Effect: increase pump level by pump level rate
  (:process pump-ramp-up
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (pump-ramping-up ?p)
      (< (pump-level ?p) 1))
    :effect
      (increase (pump-level ?p)
        (* #t  (pump-level-rate)))
  )

  ; Process to decrease pump level as it's turning off
  ; Precondition: pump is off and ramping down, but not fully off
  ; Effect: decrease pump level by pump level rate
  (:process pump-ramp-down
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (pump-ramping-down ?p)
      (> (pump-level ?p) 0.001))
    :effect
      (decrease (pump-level ?p)
        (* #t (pump-level-rate)))
  )

  ; Process to calculate pressure
  ; Precondition: pressure is greater than or equal to 0
  ; Effect: increase pressure over time according to dP/dt = k-pressure * (flow-up - flow-down - flow-nozzle)
  ; where flow-nozzle = k-nozzle * sqrt(P), or k-nozzle * P if linearized
  (:process pressure-calc
    :parameters ()
    :precondition (>= (pressure) 0)
    ; :effect (increase (pressure) (* #t (* (k-pressure) (- (flow-up) (+ (flow-down) (* (k-nozzle) (^ (pressure) 0.5))))))) ; For ENHSP-2020
    :effect (increase (pressure) (* #t (* (k-pressure) (- (flow-up) (+ (flow-down) (* (k-nozzle) (pressure))))))) ; For VAL
  )

  ; Process to calculate upstream flow rate
  ; Precondition: pressure is greater than or equal to 0
  ; Effect: increase upstream flow rate over time according to dQ-up/dt = inertia-up * (P-pump - P - resistance-up * Q-up)
  ; where P-pump = max-pressure * pump-level
  (:process flow-up-calc
    :parameters ()
    :precondition (>= (pressure) 0)
    :effect (increase (flow-up) (* #t (* (inertia-up) (- (* (max-pressure) (pump-level)) (+ (pressure) (* (resistance-up) (flow-up)))))))
  )

  ; Process to calculate downstream flow rate
  ; Precondition: pressure is greater than or equal to 0
  ; Effect: increase downstream flow rate over time according to dQ-down/dt = inertia-down * (P - resistance-down * Q-down)
  (:process flow-down-calc
    :parameters ()
    :precondition (>= (pressure) 0)
    :effect (increase (flow-down) (* #t (* (inertia-down) (- (pressure) (* (resistance-down) (flow-down))))))
  )

  ; Process to increase humidity when nozzle is on
  ; Precondition: nozzle is on
  ; Effect: increase humidity over time by humidity increase rate
  (:process humidity-inc
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (increase (humidity) (* #t (humidity-inc-rate)))
  )

  ; Process to decrease humidity when nozzle is off
  ; Precondition: nozzle is off, humidity is above 0
  ; Effect: decrease humidity over time by humidity decrease rate
  (:process humidity-dec
    :parameters (?n - nozzle)
    :precondition (and
      (not (nozzle-on ?n))
      (> (humidity) 0.001))
    :effect (decrease (humidity) (* #t (humidity-dec-rate)))
  )

  ; Events

  ; Event to stop pump level increase when it reaches 1
  ; Precondition: pump ramps up to 1
  ; Effect: stop pump ramping up
  (:event stop-ramp-up
    :parameters (?p - pump)
    :precondition (and
      (pump-ramping-up ?p)
      (>= (pump-level ?p) 1))
    :effect (not (pump-ramping-up ?p))
  )

  ; Event to stop pump level decrease when is reaches 0
  ; Precondition: pump ramps down to 0
  ; Effect: stop pump ramping down
  (:event stop-ramp-down
    :parameters (?p - pump)
    :precondition (and
      (pump-ramping-down ?p)
      (<= (pump-level ?p) 0))
    :effect (not (pump-ramping-down ?p))
  )
)
