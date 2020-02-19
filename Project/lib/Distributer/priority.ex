defmodule Priority do
@moduledoc """
  This submodule aims to find the order priority given either one or multiple elevators.
    * Communicates with the local state machine to get the current state
"""

  use GenServer

  @top_floor Utilities.top_floor
  @server_name :PriorityServer


  def start_link() do
    start_link([{:name, @server_name}])
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

### Init ---------------------------------------------------------------------------------  

  def init(:ok) do
      {:ok, []}
  end

### API ------------------------------------------------------------------------------------

  @doc """
    Returns the elevator priority number, where higher the number yield the better priority.

    Note: This call is defined as a multi_call, thus it returns the priority of all nodes 
    in the list nodes, which by default is all connected nodes.
  """
  def get_priority(nodes \\ [Node.self() | Node.list()], pid, order, timeout \\ 1000) do
    GenServer.multi_call(nodes, pid, {:get_priority, order}, timeout)
  end


### Server Calls ------------------------------------------------------------------------------

  def handle_call({:get_priority, order}, _from, state) do
    elevator_state = State.state(State_machine.get_state(:ElevatorServer).motor_direction, State_machine.get_state(:ElevatorServer).floor)
    priority = calculate_order_priority(order, elevator_state)
    {:reply, priority, state}
  end


### Helper functions -----------------------------------------------------------------------


  @doc """
    Returns distance from order floor to elevator state floor
  """
  def order_distance(order, elevator_state) do
    order.floor - elevator_state.floor
  end

  @doc """
    Returns order type as an int; hall up = 1, cab = 0, hall down = -1
  """
  def order_type_to_int(order) do
    %{hall_up: 1, cab: 0, hall_down: -1}[order.type]
  end

  @doc """
    Returns elevator direction as an int; up = 1, stop = 0, down = -1
  """
  def elevator_direction_to_int(elevator_state) do
    %{up: 1, stop: 0, down: -1}[elevator_state.direction]
  end

  @doc """
    Returns true if elevator moving in same direction as order type.
  """
  def coinciding_elevator_direction_and_order_type(order, elevator_state) do
    if (order_type_to_int order)*(elevator_direction_to_int elevator_state) >= 0, do: true, else: false
  end

  @doc """
    Returns true if elevator is moving towards the desired order.
  """
  def coinciding_direction(order, elevator_state) do
    if (order_distance order, elevator_state)*(elevator_direction_to_int elevator_state) > 0, do: true, else: false
  end

  @doc """
    Returns order priority value for a given state.
    The larger priority value the better
  """
  def calculate_order_priority(order, elevator_state) do
    distance = order_distance(order, elevator_state)
    idle = (elevator_state.direction == :stop)
    coinciding_direction_and_type = coinciding_elevator_direction_and_order_type(order, elevator_state)
    coinciding_direction = coinciding_direction(order, elevator_state)

    cond do
      idle -> # If elevator is idle give standard priority relative to the number of floors
        @top_floor - abs(distance) + 1
      not coinciding_direction -> # If direction of elevator and order does not coincide, return lowest value
        1
      coinciding_direction_and_type -> # If we have coinciding direction (the line above doesnt trigger), plus coinciding direction and type we can add +1 to the standard priority
        @top_floor - abs(distance) + 2
      true ->
        @top_floor - abs(distance) + 1 # If we have coinciding direction but not coinciding direction and type, give standard priority
    end
  end
end
