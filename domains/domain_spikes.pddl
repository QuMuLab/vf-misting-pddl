(define (domain vf-misting-spikes)

  (:requirements :negative-preconditions :typing :fluents)

  (:predicates
    (pump-on) ; Pump on or off
    (nozzle-on) ; Nozzle on or off
    (nozzle-clogged) ; Issue with nozzle
    (done) ; Special predicate for goal state
  )

  (:functions
    (pressure)
    (q_up)
    (q_down)
    (q_nozzle)

    (sim-time)

    (pmax)        ; Pa
    (rho)           ; kg/m^3
    (r_down)        ; hydraulic resistance
    (cdA)        ; nozzle constant

    (kp)            ; tune
    (kf)         ; tune
    (kd)          ; decay rate
  )

  ; Actions

  ; Action to activate the pump
  ; Precondition: pump is not on
  ; Effect: pump is on
  (:action activate-pump
    :parameters ()
    :precondition (not (pump-on))
    :effect (pump-on)
  )

  ; Action to deactivate the pump
  ; Precondition: pump is on
  ; Effect: pump is not on
  (:action deactivate-pump
    :parameters ()
    :precondition (pump-on)
    :effect (not (pump-on ))
  )

  ; Action to activate the nozzle
  ; Precondition: nozzle is not on but pump is on
  ; Effect: nozzle is on
  (:action activate-nozzle
    :parameters ()
    :precondition (and
      (not (nozzle-on))
      (pump-on))
    :effect (nozzle-on)
  )

  ; Action to deactivate the nozzle
  ; Precondition: nozzle is on
  ; Effect: nozzle is not on
  (:action deactivate-nozzle
    :parameters ()
    :precondition (nozzle-on)
    :effect (not (nozzle-on ))
  )

  ; Action to set the done state when simulation time reaches 10 seconds
  ; Precondition: simulation time is 10 or more seconds
  ; Effect: done predicate is true
  (:action finish
    :parameters ()
    :precondition (>= (sim-time) 10)
    :effect (done)
  )

  ; Processes

  ; Process to increase time
  ; Precondition: simulation time is less than 10 seconds
  ; Effect: increase simulation time over time
  (:process time-inc
    :parameters ()
    :precondition (< (sim-time) 10)
    :effect (increase (sim-time) (* #t 1))
  )

  (:process pump-on
    :parameters ()
    :precondition (pump-on)
    :effect (and
        (increase (pressure)
            (* #t (* kp (- pmax (pressure)))))

        ;; downstream tube (linear)
        (increase (q_down)
            (* #t (- (/ pmax r_down)
                     (q_down))))

        ;; nozzle (nonlinear)
        (increase (q_nozzle)
            (* #t (- (* cdA (* 2 (/ pmax rho)))
                     (q_nozzle))))


    )
  )

  (:process pump-off
    :parameters ()
    :precondition (not (pump-on))
    :effect (and
        (decrease (pressure)
            (* #t (* kd (pressure))))

        (increase (q_down)
            (* #t (- (/ 0 r_down)
                     (q_down))))

        (increase (q_nozzle)
            (* #t (- (* cdA (* 2 (/ 0 rho)))
                     (q_nozzle))))


    )
  )
)
