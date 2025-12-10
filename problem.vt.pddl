(define (problem spray_control)

  (:domain vertical_farm_spray)

  (:objects
    ; Objects: layers of the vertical farm, nozzles in the vertical farm

    layer1 - layer
    nozzle1 - nozzle
    pump1 - pump
  )

  (:init
    ; Objective: planner should decide when to spray mist to maintain humidity
    ; Optimization goal: energy use
    ; Constraints: upper/lower humidity bounds (confirm the numbers) maybe between 40-60%
    ; Final goal: maintain the humidity of each layer of the vertical farm between 40% and 60% while minimizing energy usage

    ; Can be modified based on actual starting configuration
    (= (humidity layer1) 0.5)
    (connected nozzle1 layer1)
  )

  ; Modify to include all layers, and to minimize energy use
  (:goal (and
    (>= (humidity layer1) 0.4)
    (<= (humidity layer1) 0.6)
  ))

  ; Run and val with enhsp
)
