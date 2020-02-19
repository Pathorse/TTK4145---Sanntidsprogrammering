defmodule Elevator do
@moduledoc """
    Starts up GenServers across nodes and calls necessary init functions.
"""
    def start do
        Driver.start
        Utilities.init_lights
        NetworkServer.start
        Priority.start_link
        PollerServer.start_link
        Distributer.start_link
        GuardServer.start
        State_machine.start
        :timer.sleep(1000)
        State_machine.initialize(:ElevatorServer)
        :timer.sleep(5000)
        State_machine.reboot(:ElevatorServer)
    end
end
