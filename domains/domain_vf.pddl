(define (domain vf-misting)

  (:requirements :equality :negative-preconditions :typing :adl :fluents)

  (:types
    pump nozzle
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (pump-ramping-up ?p - pump) ; Pump is starting
    (pump-ramping-down ?p - pump) ; Pump is stopping

    (nozzle-on ?n - nozzle) ; Nozzle on or off
    (nozzle-clogged ?n - nozzle) ; Issue with nozzle
    
    (done) ; Special predicate for goal state
  )

  (:functions
    ; Variables
    (sim-time) ; Simulation time, s
    (pump-level ?p - pump) ; Ranges from 0 (fully off) to 1 (fully on)

    (pressure) ; Pressure, psi
    (humidity) ; Current humidity, %

    (flow-up) ; Upstream flow rate, L/min
    (flow-down) ; Downstream flow rate, L/min
    (flow-nozzle) ; Branch flow rate, L/min

    ; Constants
    (done-time) ; Time for done predicate, s
    (max-pressure) ; Max pressure, psi

    (time-const) ; Time constant for calculations
    (sensor-coeff) ; Upstream sensor coefficient
    (nozzle-coeff) ; Nozzle coefficient

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

  ; Process to increase pressure while the pump is on
  ; Precondition: pump is on, pressure is less than max pressure
  ; Effect: increase pressure over time according to dP/dt = k_time * pump_level * (Pmax - P)
  (:process pressure-inc
    :parameters (?p - pump)
    :precondition (and
      (pump-on ?p)
      (< (pressure) (max-pressure)))
    :effect (increase (pressure)
      (* #t (* (* (time-const) (pump-level ?p))
        (- (max-pressure) (pressure)))))
  )

  ; Process to decrease pressure while the pump is off
  ; Precondition: pump is off, pressure is over 0
  ; Effect: decrease pressure over time according to dP/dt = -k_time * (1 - pump_level) * P
  (:process pressure-dec
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (> (pressure) 0.001))
    :effect (decrease (pressure) (* #t
      (* (* (time-const) (- 1 (pump-level ?p)))
        (pressure))))
  )

  ; Process to increase upstream flow rate while pump is on
  ; Precondition: pump is on
  ; Effect: increase upstream flow rate over time according to dQ/dt = k_time * pump_level * (Q_target - Q_up)
  ; where Q_target = k_sensor * sqrt(pressure) or k_sensor * pressure
  (:process flow-up-inc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    ; :effect (increase (flow-up) (* #t (* (* (time-const) (pump-level ?p)) (- (* (sensor-coeff) (^ (pressure) 0.5)) (flow-up)))))  ; Equation for ENHSP-2020
    :effect (increase (flow-up) (* #t (* (* (time-const) (pump-level ?p)) (- (* (sensor-coeff) (max-pressure)) (flow-up)))))  ; Equation for VAL
  )

  ; Process to decrease upstream flow rate while pump is off
  ; Precondition: pump is not on, upstream flow rate is slightly above 0
  ; Effect: decrease upstream flow rate over time according to dQ/dt = -k_time * (1 - pump_level) * Q_up
  (:process flow-up-dec
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (> (flow-up) 0.001))
    :effect (decrease (flow-up) (* #t (* (* (time-const) (- 1 (pump-level ?p))) (flow-up))))
  )

  ; Process to increase nozzle flow rate while nozzle is on
  ; Precondition: nozzle is on, upstream flow is larger than nozzle flow
  ; Effect: increase nozzle flow rate over time according to dQ/dt = k_time * pump_level * (Q_target - Q_nozzle)
  ; where Q_target = k_nozzle * sqrt(pressure) or k_sensor * pressure
  (:process flow-nozzle-inc
    :parameters (?n - nozzle ?p - pump)
    :precondition (and
      (pump-on ?p)
      (nozzle-on ?n)
      (not (nozzle-clogged ?n))
      (> (flow-up) (flow-nozzle)))
    ; :effect (increase (flow-nozzle) (* #t (* (time-const) (pump-level ?p)) (- (* (nozzle-coeff) (^ (pressure) 0.5)) (flow-nozzle)))))  ; Equation for ENHSP-2020
    :effect (increase (flow-nozzle) (* #t (* (* (time-const) (pump-level ?p)) (- (* (nozzle-coeff) (max-pressure)) (flow-nozzle)))))  ; Equation for VAL
  )

  ; Process to decrease nozzle flow rate while nozzle is off
  ; Precondition: nozzle is not on, nozzle flow rate is above 0
  ; Effect: decrease nozzle flow rate over time according to dQ/dt = -k_time * (1 - pump_level) * Q_nozzle
  (:process flow-nozzle-dec
    :parameters (?n - nozzle ?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (not (nozzle-on ?n))
      (not (nozzle-clogged ?n))
      (> (flow-nozzle) 0.001))
    :effect (decrease (flow-nozzle) (* #t (* (* (time-const) (- 1 (pump-level ?p))) (flow-nozzle))))
  )

  ; Process to increase downstream flow rate
  ; Precondition: pump is on
  ; Effect: calculate downstream flow rate over time according to dQ/dt = k_time * pump_level * (Q_target - Q_down)
  ; where Q_target = Q_up - Q_nozzle
  (:process flow-down-inc
    :parameters (?n - nozzle ?p - pump)
    :precondition (and
      (pump-on ?p)
      (nozzle-on ?n)
      (not (nozzle-clogged ?n)))
    ; :effect (increase (flow-down) (* #t (* (time-const) (pump-level ?p)) (- (* (- (sensor-coeff) (nozzle-coeff)) (^ (pressure) 0.5)) (flow-down)))))  ; Equation for ENHSP-2020
    :effect (increase (flow-down) (* #t (* (* (time-const) (pump-level ?p)) (- (* (- (sensor-coeff) (nozzle-coeff)) (max-pressure)) (flow-down)))))  ; Equation for VAL
  )

  ; Process to increase downstream flow rate
  ; Precondition: pump is on
  ; Effect: calculate downstream flow rate over time according to dQ/dt = k_time * pump_level * (Q_target - Q_down)
  ; where Q_target = Q_up
  (:process flow-down-inc-clogged
    :parameters (?n - nozzle ?p - pump)
    :precondition (and
      (pump-on ?p)
      (nozzle-clogged ?n))
    ; :effect (increase (flow-down) (* #t (* (time-const) (pump-level ?p)) (- (* (sensor-coeff) (^ (pressure) 0.5)) (flow-down)))))  ; Equation for ENHSP-2020
    :effect (increase (flow-down) (* #t (* (* (time-const) (pump-level ?p)) (- (* (sensor-coeff) (max-pressure)) (flow-down)))))  ; Equation for VAL
  )

  ; Process to decrease downstream flow rate
  ; Precondition: upstream flow is over 0
  ; Effect: calculate downstream flow rate over time according to dQ/dt = -k_time * (1 - pump_level) * Q_down
  (:process flow-down-dec
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (> (flow-down) 0.001))
    :effect (decrease (flow-down) (* #t (* (* (time-const) (- 1 (pump-level ?p))) (flow-down))))
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
