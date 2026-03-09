(define (problem misting-spikes)

  (:domain misting_spikes)

  (:objects
    main-pump - pump
  )

  (:init
    (not (pump-on main-pump))
    (not (done))

    (= (sim-time) 0)

    (= (pressure) 0)
    ; (= (pressure-rate) 0)

    (= (flow-real) 0)
    (= (flow-before) 0)
    (= (flow-after) 0)

    (= (max-pressure) 75)
    (= (pump-gain) 1.5)

    (= (nozzle-coeff) 0.03)

    (= (sensor-before-gain) 0.08)
    (= (sensor-after-gain) 0.15)
  )

  ; Run for 10 seconds, achieve done state
  (:goal (and
    (done)
  ))
)
