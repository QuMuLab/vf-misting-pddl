(define (problem misting-spikes)

  (:domain vf-misting-spikes)

  ; Configuration is one pump connected to 1 nozzle in a loop
  (:init
    ; Predicates
    (not (pump-on))
    (not (nozzle-on))
    (not (nozzle-clogged))
    (not (done))
    (= (sim-time) 0)

    (= (pressure) 0)
    (= (q_up) 0)
    (= (q_down) 0)
    (= (q_nozzle) 0)

    (= (pmax) 517000)  ; Pa
    (= (rho) 1000)        ; kg/m^3
    (= (r_down) 0.0000000019)      ; hydraulic resistance
    (= (cdA) 0.0000052)        ; nozzle constant

    (= (kp) 5.0)                ; tune
    (= (kf) 100000)             ; tune
    (= (kd) 2.0)            ; decay rate

  )

  ; Run for 10 seconds, achieve done state
  (:goal (and
    (done)
  ))
)
