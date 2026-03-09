(define (domain misting_spikes)

  (:requirements :negative-preconditions :typing :fluents)

  (:types
    pump
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (done) ; Special predicate for goal state
  )

  (:functions
    ; Time
    (sim-time) ; Simulation time, s

    ; Pressure
    (pressure) ; Tube pressure, psi
    ; (pressure-rate) ; dP/dt

    ; Flow
    (flow-real) ; True nozzle flow rate, L/min
    (flow-before) ; Sensor before nozzle, L/min
    (flow-after) ; Sensor after nozzle, L/min

    ; Constants
    (max-pressure) ; Max pressure, psi
    (pump-gain) ; k_pump coefficient
    ; Add a k-leak if I want to make the k_leak = 0.5 into a var
    ; Add a k-flow if I want to make the k_flow = 0.1 into a var

    (nozzle-coeff) ; k_sensor coefficient

    (sensor-before-gain) ; Q_sensor coefficient (before)
    (sensor-after-gain) ; Q_sensor coefficient (after)
  )

  ; Action to activate the pump
  (:action activate-pump
    :parameters (?p - pump)
    :precondition (and
      (not (pump-on ?p))
      (< (pressure) (max-pressure)))
    :effect (pump-on ?p)
  )

  ; Action to activate the pump
  (:action deactivate-pump
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (not (pump-on ?p))
  )

  ; Action to set the done state when simulation time reaches 10 seconds
  (:action finish
    :parameters ()
    :precondition (>= (sim-time) 10)
    :effect (done)
  )

  ; Process to increase time
  (:process time-inc
    :parameters ()
    :precondition (< (sim-time) 10)
    :effect (increase (sim-time) (* #t 1))
  )

  ; ; Process to increase pressure
  ; dP/dt = k_pump * (Pmax - P) - k_flow * Q to represent pressure drop due to flow through the nozzle
  ; Pressure rises toward pump max, but drops when water exits nozzle
  (:process pressure-inc
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect
      (increase (pressure)
        (* #t
          (- (* (pump-gain) (- (max-pressure) (pressure)))
            (* 0.1 (flow-real)))))
  )

  ; Process to decrease pressure
  ; dP/dt = -k_leak * P
  ; Pressure exponentially decays
  (:process pressure-dec
    :parameters (?p - pump)
    :precondition (not (pump-on ?p))
    :effect
      (decrease (pressure)
        (* #t (* 0.5 (pressure))))
  )

  ; Process to calculate nozzle flow rate
  ; dQ/dt = k_sensor * (Q_target - Q), Qtarget = flow-coeff * sqrt(pressure)
  (:process nozzle-flow
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (flow-real)
        (* #t
          (- (* (nozzle-coeff) (^ (pressure) 0.5))
            (flow-real))))
  )

  ; Process to calculate flow rate target of the sensor before the nozzle
  ; Q_sensor = Q_real + C * dP/dt, C = hydraulic capacitance of the tubing
  ; flow_before = flow_real + spike_coeff * pressure_rate
  ; Pump ON - big positive pressure-rate - spike, pump OFF - small effect
  (:process sensor-before
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (flow-before)
        (* #t
          (- (+ (flow-real)
                (* (sensor-before-gain) (pressure)))
              (flow-before))))
  )

  ; Process to calculate flow rate of the sensor after the nozzle
  ; Q_sensor = Q_real + C * dP/dt, C = hydraulic capacitance of the tubing
  ; flow_after = flow_real + spike_coeff2 * pressure_rate
  ; Pump ON - pressure-rate positive, spike; pump OFF - pressure-rate negative, spike
  (:process sensor-after
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (flow-after)
        (* #t
          (- (+ (flow-real)
                (* (sensor-after-gain) (pressure)))
              (flow-after))))
  )
)
