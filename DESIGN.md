Design Presentation
=====================

# First thoughts:


State machine -> Distributer -> Execute -> Driver

## State machine

En state machine som har kontroll på states
States:
- Running
- Idle
- Emergency State (stop button pushed)
Variables:
- Lastfloor
- Currentfloor

## Distributer

Har kontroll på og deler ut ordrer



## Execute 

Utfører ordre


## Driver

Utdelt
- Kjør opp/ned osv..



## Spørsmål

- Hall buttons are not shared between elevators. How should we interpret the third point under "Unspecified behaviour", as an elevator without network can not send out its hall orders?

- Hvordan fungerer driveren mtp button pushes?

- Hvordan blir kommunikasjon i Elixir

- Hvordan kjører vi programmet fra fleire heiser?

- Hvordan fungerer deling av moduler? Hvordan kan vi si til en maskin kjør til en etasje?