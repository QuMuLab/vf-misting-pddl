(define (problem misting-spikes)

  (:domain misting_spikes)

  (:objects
    ; Medium configuration is one pump connected to 1 nozzle in a loop
    main-pump - pump
    nozzle1 - nozzle
  )

  (:init
    ; Objects
    (not (pump-on main-pump))
    (not (nozzle-on nozzle1))
    (not (pump-fault main-pump))
    (not (nozzle-fault nozzle1))
    (not (done))

    ; Start values
    (= (sim-time) 0)
    (= (pressure) 0)
    (= (humidity) 30)

    (= (flow-up) 0)
    (= (flow-nozzle) 0)
    (= (flow-down) 0)

    ; Constants
    (= (max-pressure) 75)
    (= (time-const) 5)
    (= (flow-const) 0.1)
    (= (nozzle-coeff) 0.002133) ; (= (nozzle-coeff) 0.011383) for sqrt

    (= (min-humidity) 40)
    (= (max-humidity) 60)

    (= (up-coeff) 0.08)
    (= (down-coeff) 0.15)
    
    ; Rates
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
