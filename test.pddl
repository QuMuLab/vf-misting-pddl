(define (domain vertical_farm_misting)

  (:requirements :equality :negative-preconditions :typing :adl :fluents :continuous-effects)

  (:types pump)

  (:predicates
    (pump-on ?p - pump)
    (done)
  )

  (:functions
    (sim-time)

    (pressure)
    (impulse)

    (pump-pressure)

    ;; constants
    (k)     ; pressure decay
    (d)     ; impulse decay
    (max-pressure)
  )

  ;; ---------------- ACTIONS ----------------

  (:action activate-pump
    :parameters (?p - pump)
    :precondition (not (pump-on ?p))
    :effect (and
      (pump-on ?p)
      (assign (pump-pressure) (max-pressure))
      (assign (impulse) 5)
    )
  )

  (:action deactivate-pump
    :parameters (?p - pump)
    :precondition (pump-on ?p)
    :effect (and
      (not (pump-on ?p))
      (assign (pump-pressure) 0)
      (assign (impulse) 4)
    )
  )

  (:action finish
    :parameters ()
    :precondition (>= (sim-time) 10)
    :effect (done)
  )

  ;; ---------------- PROCESSES ----------------

  (:process time-flow
    :parameters ()
    :precondition (< (sim-time) 10)
    :effect
      (increase (sim-time) (* #t 1))
  )

  ;; dP/dt = pump-pressure - k*pressure + impulse

  (:process pressure-increase-from-pump
    :parameters ()
    :precondition (> (pump-pressure) 0)
    :effect
      (increase (pressure)
        (* #t (pump-pressure)))
  )

  (:process pressure-decay
    :parameters ()
    :precondition (> (pressure) 0)
    :effect
      (decrease (pressure)
        (* #t (k)))
  )

  (:process pressure-impulse
    :parameters ()
    :precondition (> (impulse) 0)
    :effect
      (increase (pressure)
        (* #t (impulse)))
  )

  ;; impulse exponential decay (approximate linear decay)
  (:process impulse-decay
    :parameters ()
    :precondition (> (impulse) 0)
    :effect
      (decrease (impulse)
        (* #t (d)))
  )
)