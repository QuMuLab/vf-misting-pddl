(define (problem misting-spikes)

  (:domain vf-misting-spikes)

  (:objects
    ; Configuration is one pump connected to 1 nozzle in a loop
    pump1 - pump
    nozzle1 - nozzle
  )

  (:init
    ; Predicates
    (not (done))

    (not (pump-on pump1))
    (not (pump-ramping-up pump1))
    (not (pump-ramping-down pump1))

    (not (nozzle-on nozzle1))

    ; Variables
    (= (sim-time) 0)
    (= (pump-level pump1) 0)

    (= (pressure) 0)

    (= (flow-up) 0)
    (= (flow-down) 0)

    (= (humidity) 30)

    ; Constants
    (= (done-time) 10)

    (= (max-pressure) 517000)

    (= (k-pressure) 20500000000000)
    (= (inertia-up) 0.0000002)
    (= (inertia-down) 0.00000002)
    (= (resistance-up) 10000000000)
    (= (resistance-down) 194000000000)
    ; (= (k-nozzle) 0.0000000023) ; For ENHSP-2020
    (= (k-nozzle) 0.0000000000032) ; For VAL

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
