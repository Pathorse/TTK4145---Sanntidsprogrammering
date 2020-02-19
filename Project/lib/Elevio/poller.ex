defmodule PollerServer do
@moduledoc """
  The Poller module is responsible for polling buttons and reading floor sensors.
    * Communicates with the driver module to read button and floor sensors
    * Communicates with the distributer module when a new button is pressed
    * Communicates with the state machine module when a new floor is reached
"""
  use GenServer

  @server_name :PollerServer


  def start_link() do
    start_link([{:name, @server_name}])
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # Init --------------------------------------------------------

  def init(:ok) do
    Enum.map(Utilities.elevator_orders, fn order -> Process.spawn(ButtonPoller, :poll, [order, :inactive_order], []) end)  # Spawn a new process for each button to poll for pushes
    Process.spawn(FloorPoller, :poll, [:idle_at_floor], []) # Spawn a process to read floor sensors
    {:ok, []}
  end


  # API ---------------------------------------------------------
  
  @doc """
    Alerts the Distributer module that a button has been pressed
  """
  def button_pressed(pid, order) do
    GenServer.cast(pid, {:button_pressed, order})
  end

  @doc """
    Alerts the Elevator module that a floor has been reached
  """
  def reached_floor(pid, floor) do
    GenServer.cast(pid, {:reached_floor, floor})
  end

  # Server casts --------------------------------------------

  def handle_cast({:button_pressed, order}, state) do
    Distributer.add_order(:Distributer, order)
    {:noreply, state}
  end

  def handle_cast({:reached_floor, floor}, state) do
    State_machine.reached_floor(:ElevatorServer, floor)
    {:noreply, state}
  end

end


defmodule ButtonPoller do
  @moduledoc """
    This module aims to implement a button poller.
    
    A state machine is introduced to avoid spamming 
    the pollingserver when a button is constantly pressed.
  """

  @doc """
    The state map is introduced to be able to use a state machine with pattern matching.
    Thus if an order is inactive and get_order_button_state returns 1 we will
    enter the activate state.
  """
  def poll(order, :inactive_order) do
    :timer.sleep(100)
    button_state = Driver.get_order_button_state(:DriverServer, order.floor, order.type)
    state_map = %{1 => :activate_order, 0 => :inactive_order}
    poll(order, state_map[button_state])
  end

  @doc """
    Notifies the PollingServer that a button is pressed, then proceeds to enter the active order
    state.
  """
  def poll(order, :activate_order) do
    PollerServer.button_pressed(:PollerServer, order)
    poll(order, :active_order)
  end

  @doc """
    If the button still is pressed we remain in the active order state, 
    whereas if the button is let go we will enter inactive order state again.
  """
  def poll(order, :active_order) do
    :timer.sleep(100)
    button_state = Driver.get_order_button_state(:DriverServer, order.floor, order.type)
    state_map = %{1 => :active_order, 0 => :inactive_order}
    poll(order, state_map[button_state])
  end

end


defmodule FloorPoller do
@moduledoc """
  This module aims to poll floor sensors and alert pollerserver when a new floor is reached
"""


  @doc """
    Listens to floor sensors, if the sensors return between floors we utilize 
    pattern matching by recalling the function with :between_floors
  """
  def poll(:idle_at_floor) do
    :timer.sleep(100)
    case Driver.get_floor_sensor_state(:DriverServer) do 
      :between_floors->
        poll(:between_floors)
      _else ->
        poll(:idle_at_floor)
    end

  end

  @doc """
    If between floors, keep listening to sensor state.
  """
  def poll(:between_floors) do
    :timer.sleep(100)
    poll(Driver.get_floor_sensor_state(:DriverServer))
  end


  @doc """
    If a floor is reached alert PollerServer, then return to idle
  """
  def poll(floor) do
    PollerServer.reached_floor(:PollerServer, floor)
    poll(:idle_at_floor)
  end

end
