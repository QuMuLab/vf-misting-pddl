(define (problem misting)

  (:domain vertical_farm_misting)

  (:objects
    ; Hard configuration is one pump connected to 4 nozzles in a loop
    ; TODO: might add different heights for this. also in order to model the whole growbox should probably take into account that there's nested tube loops
    main-pump - pump
    nozzle1 nozzle2 nozzle3 nozzle4 - nozzle
    tube1 tube2 tube3 tube4 - tube
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
    (connected main-pump nozzle1 tube1)
    (connected nozzle1 nozzle2 tube2)
    (connected nozzle2 nozzle3 tube3)
    (connected nozzle3 nozzle4 tube4)
    (connected nozzle4 main-pump tube1)

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

  ; TODO: Add pressure constraint potentially
  (:goal (and
    (>= (humidity) (min-humidity))
    (<= (humidity) (max-humidity))
    (<= (energy-use) (max-energy))
  ))
)
