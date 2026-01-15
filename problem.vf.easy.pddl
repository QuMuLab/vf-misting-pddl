(define (problem misting)

  (:domain vertical_farm_misting)

  (:objects
    ; Easy configuration is one pump connected to a tube in a loop
    main-pump - pump
    tube1 - tube
  )

  (:init
    ; Objective: planner should decide when to spray mist to maintain humidity
    ; Optimization goal: energy use
    ; Constraints: upper/lower humidity bounds of 40-60%
    ; Final goal: maintain the humidity of each layer of the vertical farm between 40% and 60% while minimizing energy usage

    ; TODO: modify based on actual starting configuration
    ; TODO: For any values that are currently placeholders, calculate them and plug them in
    ; Objects
    (not (pump-on main-pump))
    (connected main-pump main-pump tube1)

    ; Start values
    (= (humidity) 50)
    (= (pressure) 0.0)
    (= (flow-rate) 0.0)
    (= (energy-use) 0.0)

    ; Constants
    (= (tube-area) 0.018) ; Assume tube is 0.25" outer diameter, 0.049" wall thickness
    (= (min-humidity) 40.0)
    (= (max-humidity) 60.0)
    (= (max-pressure) 0.8) ; Set based on system
    (= (max-energy) 1.0)

    ; Rates
    (= (humidity-inc-rate) 0.1) ; Search how to calculate
    (= (humidity-dec-rate) 0.1)
    (= (pressure-inc-rate) 0.1) ; Compute with Bernoulli's equation
    (= (pressure-dec-rate) 0.1)
    (= (flow-inc-rate) 0.1) ; Compute with flow rate equation
    (= (energy-inc-rate) 0.1) ; Search how to calculate
  )

  ; TODO: Add energy and pressure constraint potentially
  (:goal (and
    (>= (humidity) (min-humidity))
    (<= (humidity) (max-humidity))
  ))
)
