defmodule Utilities do
  @moduledoc """
    This module serve as an utility feature for other modules
      * Communicating with the driver module when initialzing lights
  """

  # Elevator properties
  @top_floor 3
  @valid_floors 0..@top_floor
  @valid_button_types [:hall_up, :hall_down, :cab]
  @valid_elevator_directions [:up, :down, :stop]
  @floor_map %{hall_up: 0..@top_floor - 1, hall_down: 1..@top_floor, cab: 0..@top_floor}

  @doc """
    Return top floor
  """
  def top_floor() do
    @top_floor
  end

  @doc """
    Return valid floors
  """
  def valid_floors() do
    @valid_floors
  end

  @doc """
    Return valid button types
  """
  def valid_button_types() do
    @valid_button_types
  end

  @doc """
    Return valid elevator directions
  """
  def valid_elevator_directions() do
    @valid_elevator_directions
  end

  @doc """
    Return floor map
  """
  def floor_map() do
    @floor_map
  end

   @doc """
    Create a list of all possible orders
  """
  def elevator_orders() do
    Enum.map(valid_button_types(), fn type -> elevator_orders(type) end) |> List.flatten
  end

  @doc """
    Create a map of all possible orders for a specific button type
  """
  def elevator_orders(type) do
    Enum.map(floor_map[type], fn floor -> Order.order(type, floor) end)
  end

  @doc """
    Initialize buttons // turn every button light off
  """
  def init_lights() do
    for order <- Utilities.elevator_orders do
      Driver.set_order_button_light(:DriverServer, order.type, order.floor, :off)
    end
    Driver.set_door_open_light(:DriverServer, :off)
  end

  @doc """
    Returns the optimal node from a get_priority multi_call reply
  """
  def extract_optimal_node(multi_call_tuple) do
    # Extracts a list of tuples {node,priority} from responses from multi_call
    list_of_tuples = elem(multi_call_tuple, 0) 
    # Turns the list of tuples into a map with keys node and priority, then sorts based on prio, at last name is extracted
    List.first(Enum.map(list_of_tuples, fn {node,pri} -> %{name: node, priority: pri} end) |>
    Enum.sort(fn node1, node2 -> node1.priority > node2.priority end)).name 
  end

end

defmodule State do

  defstruct direction: :stop, floor: 0

  @doc """
    Create state map
  """
  def state(direction, floor) do
    %State{direction: direction, floor: floor}
  end

end


defmodule Order do
  
  defstruct [:type, :floor]

  @doc """
    Create order map
  """
  def order(type, floor) do
    %Order{type: type, floor: floor}
  end

end

