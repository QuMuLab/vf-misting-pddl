(define (problem misting-easy)

  (:domain vertical_farm_misting)

  (:objects
    ; Medium configuration is one pump connected to 1 nozzle in a loop
    main-pump - pump
    nozzle1 - nozzle
  )

  (:init
    ; Objects
    (not (pump-on main-pump))
    (not (nozzle-on nozzle1))
    (not (pump-fault))
    (not (nozzle-fault))

    ; Start values
    (= (sim-time) 0)
    (= (humidity) 30)
    (= (pressure) 0)

    (= (flow-up) 0)
    (= (flow-nozzle) 0)
    (= (flow-down) 0)

    ; Constants
    (= (max-pressure) 75)
    (= (time-const) 5)
    (= (flow-const) 5)
    (= (flow-coeff) 0.003467) ; (= (flow-coeff) 0.022766) for sqrt
    (= (nozzle-coeff) 0.002133) ; (= (nozzle-coeff) 0.011383) for sqrt

    (= (min-humidity) 40)
    (= (max-humidity) 60)
    
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
