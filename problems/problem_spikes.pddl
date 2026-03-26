(define (problem misting-spikes)

  (:domain vf-misting-spikes)

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
    (= (max-pressure) 517000)

    (= (k-pressure) 20500000000000)
    (= (L-up) 0.0000002)
    (= (L-down) 0.00000002)
    (= (R-up) 10000000000)
    (= (R-down) 194000000000)

    ; Coeffs for ENHSP-2020
    ; (= (k-nozzle) 0.0000000023)
    ; Coeffs for VAL
    (= (k-nozzle) 0.0000000000032)

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
