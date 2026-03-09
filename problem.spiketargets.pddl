(define (problem misting-spike-targets)

  (:domain misting_spike_targets)

  (:objects
    main-pump - pump
  )

  (:init
    (not (pump-on main-pump))
    (not (done))

    (= (sim-time) 0)

    (= (pressure) 0)
    (= (pressure-target) 0)

    (= (flow-real) 0)
    (= (flow-target) 0)

    (= (flow-before) 0)
    (= (flow-after) 0)

    (= (sensor-before-target) 0)
    (= (sensor-after-target) 0)

    (= (max-pressure) 75)
    (= (pump-rate) 2)
    (= (leak-rate) 0.5)

    (= (nozzle-coeff) 0.03)

    (= (sensor-before-gain) 0.05)
    (= (sensor-after-gain) 0.1)
  )

  ; Run for 10 seconds, achieve done state
  (:goal (and
    (done)
  ))
)
