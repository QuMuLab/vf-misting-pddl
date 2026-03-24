(define (problem misting)

  (:domain vf-misting)

  (:objects
    ; Configuration is one pump connected to 1 nozzle in a loop
    pump1 - pump
    nozzle1 - nozzle
  )

  (:init
    ; Predicates
    (not (pump-on pump1))
    (not (pump-ramping-up pump1))
    (not (pump-ramping-down pump1))

    (not (nozzle-on nozzle1))
    (not (nozzle-clogged nozzle1))

    (not (done))

    ; Variables
    (= (sim-time) 0)
    (= (pump-level pump1) 0)

    (= (pressure) 0)
    (= (humidity) 30)

    (= (flow-up) 0)
    (= (flow-nozzle) 0)
    (= (flow-down) 0)

    ; Constants
    (= (done-time) 10)
    (= (max-pressure) 75)

    (= (time-const) 5)

    ; Coeffs for ENHSP-2020
    ; (= (sensor-coeff) 0.022766)
    ; (= (nozzle-coeff) 0.011383)

    ; Coeffs for VAL
    (= (sensor-coeff) 0.003467)
    (= (nozzle-coeff) 0.002133)

    (= (min-humidity) 40)
    (= (max-humidity) 60)
    
    ; Rates
    (= (pump-level-rate) 0.5)

    (= (humidity-inc-rate) 2)
    (= (humidity-dec-rate) 0.2)
  )

  ; Primary goal: run for 10 seconds, achieve done state
  ; Secondary goal: maintain humidity within range
  (:goal (and
    (done)
    (>= (humidity) (min-humidity))
    (<= (humidity) (max-humidity))
  ))
)
