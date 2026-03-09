(define (domain misting_spike_targets)

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
    (pressure-target); Target pressure, psi

    ; Flow
    (flow-real) ; True nozzle flow rate, L/min
    (flow-target) ; Target flow rate, L/min

    ; Sensors
    (flow-before) ; Sensor before nozzle, L/min
    (flow-after) ; Sensor after nozzle, L/min

    (sensor-before-target)
    (sensor-after-target)

    ; Constants
    (max-pressure) ; Max pressure, psi
    (pump-rate)
    (leak-rate)

    (nozzle-coeff)

    (sensor-before-gain)
    (sensor-after-gain)
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

  ; ; Process to increase target pressure
  ; dP/dt = k_pump * (Pmax - P) - k_flow * Q to represent pressure drop due to flow through the nozzle
  ; Pressure rises toward pump max, but drops when water exits nozzle
  (:process pressure-target-on
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect
      (increase (pressure-target)
        (* #t
          (* (pump-rate) (- (max-pressure) (pressure-target)))))
  )

  ; Process to decrease target pressure
  ; dP/dt = -k_leak * P
  ; Pressure exponentially decays
  (:process pressure-target-off
    :parameters (?p - pump)
    :precondition (not (pump-on ?p))
    :effect
      (decrease (pressure-target)
        (* #t
            (* (leak-rate) (pressure-target))))
  )

  ; Process to calculate pressure
  ; dP/dt = Ptarget - P
  (:process pressure-dynamics
    :parameters ()
    :precondition (> (pressure-target) 0)
    :effect
      (increase (pressure)
        (* #t
          (- (pressure-target)
            (pressure))))
  )

  ; Process to calculate flow target
  ; dQ/dt = k_sensor * (Q_target - Q), Qtarget = flow-coeff * pressure (linear instead of square root)
  (:process flow-target-update
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (flow-target)
        (* #t
          (- (* (nozzle-coeff) (pressure))
              (flow-target))))
  )

  ; Process to calculate nozzle flow rate
  ; dP/dt = Qtarget - Q
  (:process real-flow
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (flow-real)
        (* #t
          (- (flow-target)
              (flow-real))))
  )

  ; Process to calculate flow rate target of the sensor before the nozzle
  ; Q_sensor = Q_real + C * dP/dt, C = hydraulic capacitance of the tubing
  ; flow_before = flow_real + spike_coeff * pressure_rate
  ; Pump ON - big positive pressure-rate - spike, pump OFF - small effect
  (:process sensor-before-target-update
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (sensor-before-target)
        (* #t
          (- (+ (flow-real)
                (* (sensor-before-gain) (pressure)))
              (sensor-before-target))))
  )

  ; Process to calculate flow rate of the sensor before the nozzle
  ; Q_sensor = Q_real + C * dP/dt, C = hydraulic capacitance of the tubing
  ; flow_after = flow_real + spike_coeff2 * pressure_rate
  ; Pump ON - pressure-rate positive, spike; pump OFF - pressure-rate negative, spike
  (:process sensor-after-target-update
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (increase (sensor-after-target)
        (* #t
          (- (+ (flow-real)
                (* (sensor-after-gain) (pressure)))
              (sensor-after-target))))
  )

  ; Process to calculate sensor before flow rate
  ; dP/dt = Qtarget - Q
  (:process sensor-before-dynamics
    :parameters ()
    :precondition (> (sensor-before-target) 0)
    :effect
      (increase (flow-before)
        (* #t
          (- (sensor-before-target)
              (flow-before))))
  )

  ; Process to calculate sensor after flow rate
  ; dP/dt = Qtarget - Q
  (:process sensor-after-dynamics
    :parameters ()
    :precondition (> (sensor-after-target) 0)
    :effect
      (increase (flow-after)
        (* #t
          (- (sensor-after-target)
              (flow-after))))
  )
)
