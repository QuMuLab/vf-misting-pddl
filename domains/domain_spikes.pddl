(define (domain vf-misting-spikes)

  (:requirements :equality :negative-preconditions :typing :adl :fluents)

  (:types
    pump nozzle
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (pump-ramping-up ?p - pump) ; Pump is starting
    (pump-ramping-down ?p - pump) ; Pump is stopping

    (nozzle-on ?n - nozzle) ; Nozzle on or off
    
    (done) ; Special predicate for goal state
  )

  (:functions
    ; Variables
    (sim-time) ; Simulation time, s
    (pump-level ?p - pump) ; Ranges from 0 (fully off) to 1 (fully on)

    (pressure) ; Pressure, Pa
    (humidity) ; Current humidity, %

    (flow-up) ; Upstream flow rate, m^3/s
    (flow-nozzle) ; Branch flow rate, m^3/s
    (flow-down) ; Downstream flow rate, m^3/s

    ; Constants
    (done-time) ; Time for done predicate, s
    (max-pressure) ; Max pressure, Pa

    (k-pressure) ; beta / V, water resistance to compression / tube volume, Pa/m^3
    (L-up) ; 1 / upstream inertia
    (L-down) ; 1 / downstream inertia
    (R-up) ; Upstream resistance
    (R-down) ; Downstream resistance
    (k-nozzle) ; Nozzle coefficient

    (max-humidity)
    (min-humidity)

    ; Rates
    (pump-level-rate)

    (humidity-inc-rate) ; Rate of humidity increase, %/s
    (humidity-dec-rate) ; Rate of humidity decrease, %/s  
  )

  ; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on
  ; Effect: pump is on
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
  ; Precondition: pump is on
  ; Effect: pump is not on
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

  ; Action to set the done state when simulation time reaches 10 seconds
  ; Precondition: simulation time is 10 or more seconds
  ; Effect: done predicate is true
  (:action finish
    :parameters ()
    :precondition (>= (sim-time) (done-time))
    :effect (done)
  )

  ; Processes

  ; Process to increase time
  ; Precondition: simulation time is less than 10 seconds
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
  ; Effect: increase pressure over time according to dP/dt = (beta / V) * (flow-up - flow-down - flow-nozzle)
  ; where flow-nozzle = k-nozzle * sqrt(pressure)
  (:process pressure-calc
    :parameters ()
    :precondition (>= (pressure) 0)
    ; :effect (increase (pressure) (* #t (* (k-pressure) (- (flow-up) (+ (flow-down) (* (k-nozzle) (^ (pressure) 0.5))))))) ; For ENHSP-2020
    :effect (increase (pressure) (* #t (* (k-pressure) (- (flow-up) (+ (flow-down) (* (k-nozzle) (pressure))))))) ; For VAL
  )

  ; Process to calculate upstream flow rate
  ; Precondition: pressure is greater than or equal to 0
  ; Effect: increase upstream flow rate over time according to dQ-up/dt = L-up * (P-pump - P - R_up * Q_up)
  ; where P_pump = P_max * pump_level
  (:process flow-up-calc
    :parameters ()
    :precondition (>= (pressure) 0)
    :effect (increase (flow-up) (* #t (* (L-up) (- (* (max-pressure) (pump-level)) (+ (pressure) (* (R-up) (flow-up)))))))
  )

  ; Process to calculate downstream flow rate
  ; Precondition: pressure is greater than or equal to 0
  ; Effect: increase downstream flow rate over time according to dQ-down/dt = L-down * (P - R_down * Q_down)
  (:process flow-down-calc
    :parameters ()
    :precondition (>= (pressure) 0)
    :effect (increase (flow-down) (* #t (* (L-down) (- (pressure) (* (R-down) (flow-down))))))
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
