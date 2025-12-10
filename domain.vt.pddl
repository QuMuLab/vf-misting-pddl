(define (domain vertical_farm_spray)

  (:requirements :equality :negative-preconditions :typing :adl :fluents :durative-actions)

  (:types
    layer nozzle pump
  )

  (:predicates
    (pump-on ?p - pump) ; Pump on or off
    (connected ?n - nozzle ?l - layer) ; Determine which nozzle is on which layer
  )

  (:functions
    (humidity ?l - layer) ; Keep track of humidity at each layer
    (pressure ?n - nozzle) ; Keep track of pressure at each nozzle (may change to be pressure at different points in the system or overall)
    (flow-rate ?n - nozzle) ; Keep track of flow rate at each nozzle (may change to be pressure at different points in the system or overall)
    (energy-use) ; Keep track of energy consumption
  )

  ; Action to activate the pump
  ; Effect: start spraying process and turn pump on, then turn it off when done
  ; In the future, consider adding time delay (because it takes a second or so for the pump to start going)
  (:durative-action activate-pump
      :parameters ()
      :duration (>= ?duration 0)
      :condition (and 
          (at start (not (pump-on)))
          (at start (not (sprayed)))
      )
      :effect (and 
          (at start (pump-on))
          (at start (spraying))
          (at end (not (spraying)))
          (at end (not (pump-on)))
          (at end (sprayed))
      )
  )

  ; Put a deactivate-pump action

  ; Process to calculate flow rate
  (:process spray-process
      :parameters (velocity area) ; Need to define these elsewhere and decide which equations will be modelled
      :precondition (spraying)
      :effect (increase (flow-rate) (* velocity area))
  )
  
  ; Event to shut pump off if pressure exceeds max pressure
  (:event pump-failure
      :parameters ()
      :precondition (> (pressure) max-pressure) ; Need to define max pressure elsewhere
      :effect (and
        (not (pump-on))
        (not (spraying))
      )
  )

  ; Process for calculating pressure at a nozzle
  ; Precondition: nozzle on
  ; Effect: should calculate pressure based on Bernoulli's equation
  (:process pressure-calc
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (increase (pressure ?n) (* #t 0.1)) ; Put Bernoulli's equation here, and elsewhere define the appropriate constants. May need multiple points/processes to calculate this correctly
  )

  ; Process for calculating flow rate at a nozzle
  ; Precondition: nozzle on
  ; Effect: should calculate flow rate based on the appropriate equation
  (:process flow-rate-calc
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (increase (flow-rate ?n) (* #t 0.1)) ; Put flow rate equation here, and elsewhere define the appropriate constants
  )

  ; Process for increasing humidity while spray is on
  ; Precondition: nozzle connected to layer and on
  ; Effect: increase humidity by 0.5% per second for now
  ; For now, this is one nozzle connected to one layer
  (:process humidity-inc
    :parameters (?l - layer ?n - nozzle)
    :precondition (and (connected ?n ?l) (nozzle-on ?n))
    :effect (increase (humidity ?l) (* #t 0.5))
  )

  ; Process for decreasing humidity
  ; Precondition: nozzle connected to layer and off
  ; Effect: decrease humidity by 0.1% per second for now
  ; For now, this is one nozzle connected to one layer
  (:process humidity-dec
    :parameters (?l - layer ?n - nozzle)
    :precondition (and (connected ?n ?l) (not (nozzle-on ?n)))
    :effect (decrease (humidity ?l) (* #t 0.1))
  )

  ; Process for calculating energy usage
  ; Precondition: nozzle on
  ; Effect: should calculate energy usage based on the appropriate equation
  (:process energy-calc
    :parameters (?n - nozzle)
    :precondition (nozzle-on ?n)
    :effect (increase (energy-use ?n) (* #t 0.1)) ; Determine correct energy usage equation and put it here, and elsewhere define the appropriate constants
  )

)
