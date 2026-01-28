(define (problem misting)

  (:domain vertical_farm_misting)

  (:objects
    ; Easy configuration is one pump connected to a tube in a loop
    main-pump - pump
    ; tube1 - tube
  )

  (:init
    ; TODO: modify based on actual starting configuration
    ; TODO: For any values that are currently placeholders, calculate them and plug them in

    ; Objects
    (not (pump-on main-pump))
    ; (connected main-pump main-pump tube1)

    ; Start values
    (= (sim-time) 0)
    (= (humidity) 30)
    (= (pressure) 0)
    (= (flow-rate) 0)
    (= (energy-use) 0)

    ; Constants
    ; (= (tube-area) 0.018) ; Assume tube is 0.25" outer diameter, 0.049" wall thickness
    (= (min-humidity) 40)
    (= (max-humidity) 60)
    (= (max-pressure) 1.2) ; 0.8 for actual farm
    (= (max-energy) 10)

    ; Rates
    (= (humidity-inc-rate) 1.2) ; Search how to calculate
    (= (humidity-dec-rate) 0.1)
    (= (pressure-inc-rate) 0.3) ; Compute with Bernoulli's equation
    (= (pressure-dec-rate) 0.05)
    (= (flow-inc-rate) 0.2) ; Compute with flow rate equation
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
