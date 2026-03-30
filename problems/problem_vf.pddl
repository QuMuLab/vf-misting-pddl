(define (problem misting)

  (:domain vf-misting)

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
    (not (nozzle-clogged nozzle1))

    ; Variables
    (= (sim-time) 0)
    (= (pump-level pump1) 0)

    (= (pressure) 0)

    (= (flow-up) 0)
    (= (flow-nozzle) 0)
    (= (flow-down) 0)

    (= (humidity) 30)

    ; Constants
    (= (done-time) 10)

    (= (max-pressure) 75)

    (= (k-time) 5)
    (= (resistance-up) 288.4615)
    ; (= (k-nozzle) 0.011547) ; For ENHSP-2020
    (= (k-nozzle) 0.001333) ; For VAL

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
