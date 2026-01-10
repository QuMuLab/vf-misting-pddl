(define (problem misting)

  (:domain vertical_farm_misting)

  (:objects
    main-pump - pump
  )

  (:init
    ; Objective: planner should decide when to spray mist to maintain humidity
    ; Optimization goal: energy use
    ; Constraints: upper/lower humidity bounds (confirm the numbers) maybe between 40-60%
    ; Final goal: maintain the humidity of each layer of the vertical farm between 40% and 60% while minimizing energy usage

    ; Can be modified based on actual starting configuration
    ; Define starting configuration
    (not (pump-on))
    (= (pressure) 0.0)
    (= (flow-rate) 0.0)
    (= (energy-use) 0.0)
    (= (humidity) 50)

    ; Calculate these by hand and plug them in
    ; Define constants
    (= PRESSURE_INC_RATE 0.1) ; Compute with Bernoulli's equation
    (= PRESSURE_DEC_RATE 0.1)
    (= FLOW_RATE 0.1) ; Compute with flow rate equation

    (= HUMIDITY_INC_RATE 0.1) ; Search how to calculate
    (= HUMIDITY_DEC_RATE 0.1)

    (= ENERGY_RATE 0.1) ; Search how to calculate

    (= MAX_PRESSURE 0.8) ; Set based on system
    (= MAX_ENERGY 1.0)
    (= TARGET_HUMIDITY 60.0)
  )

  ; Modify to minimize energy use
  (:goal (and
    (>= (humidity) 40.0)
    (<= (humidity) 60.0)
  ))

  ; Run and val with enhsp
)
