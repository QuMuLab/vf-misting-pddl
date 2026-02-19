(define (problem misting)

  (:domain vertical_farm_misting)

  (:objects
    ; Easy configuration is one pump connected to a tube in a loop
    main-pump - pump
  )

  (:init
    ; TODO: modify based on actual starting configuration
    ; TODO: For any values that are currently placeholders, calculate them and plug them in

    ; Objects
    (not (pump-on main-pump))

    ; Start values
    (= (sim-time) 0)
    (= (humidity) 30)
    (= (pressure) 0.1)
    (= (flow-rate) 0.1)
    (= (energy-use) 0.1)

    ; Constants
    (= (min-humidity) 40)
    (= (max-humidity) 60)
    (= (max-pressure) 0.8)
    (= (flow-coeff) 1.0)
    (= (max-energy) 10)

    ; Rates
    (= (humidity-inc-rate) 1.2) ; Search how to calculate
    (= (humidity-dec-rate) 0.1)
    (= (pressure-inc-rate) 0.05) ; Compute with Bernoulli's equation
    (= (pressure-dec-rate) 0.05)
    (= (energy-inc-rate) 0.05) ; Search how to calculate
  )

  ; Primary goal: run for 10 seconds, achieve done state
  ; Secondary goal: maintain humidity within range
  (:goal (and
    (done)
    ; (>= (humidity) (min-humidity))
    ; (<= (humidity) (max-humidity))
  ))
)
