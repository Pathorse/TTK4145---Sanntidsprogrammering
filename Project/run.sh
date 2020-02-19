#!/bin/bash

#Fix bug in Erlang
epmd -kill
epmd -daemon

#Kill possible existing ElevatorServer
pkill ElevatorServer

#Start new ElevatorServer
gnome-terminal -e ElevatorServer


#Compile with mix
mix compile
iex -S mix run -e Elevator.start