defmodule Distributer do
@doc """
  This module aims to distribute and remove orders across multiple elevators in an effective way.
    * Communicates with the priority module to get priorities
    * Communicates with the network module to get all connected nodes
    * Communicates with the state machine of the elevator with highest priority to add order
    * Communicates with the local state machine to set motor status, if broken
    * Communicates with one or multiple guards to add or remove orders, if necessary
    * Communicates with one or multiple drivers to set lights on or off, if necessary
"""
  use GenServer

  @server_name :Distributer

  def start_link() do
    start_link([{:name, @server_name}])
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ### Init --------------------------------------------------------

  def init(:ok) do
    {:ok, []}
  end

  ### API ---------------------------------------------------------

  @doc """
    Distributes a new order to the best suited node w.r.t. priority // cast new order to
    the state machine module and set lights on, as well as cast add order to the guard module
  """
  def add_order(pid, order, nodes \\ Node.list, remove_self \\ false) do
    GenServer.cast(pid, {:add_order, order, nodes, remove_self})
  end
  
  @doc """
    Redistributes orders that have timed out
  """
  def redistribute_order(pid, order, node) do
    GenServer.cast(pid, {:redistribute_order, order, node})
  end

  @doc """
    Removes order across locally or globally // set order lights off and 
    cast remove order to the guard module
  """
  def remove_order(pid, order) do
    GenServer.cast(pid, {:remove_order, order})
  end

  ### Server Casts -------------------------------------------------

  def handle_cast({:add_order, order, nodes, remove_self}, state) do
    cond do
      # If no network connection or cab order -> distribute locally
      not NetworkServer.is_connected?(:NetworkServer) or order.type == :cab -> 
        Driver.set_order_button_light(:DriverServer, order.type, order.floor, :on)
        State_machine.new_order(:ElevatorServer, order.type, order.floor)
        GuardServer.add_order(:GuardServer, order, Node.self())
      
      # If motor NOT working or remove_self == true -> remove own node from nodes when distributing
      not State_machine.is_motor_working?(:ElevatorServer) or remove_self -> 
        multi_call_priorities = Priority.get_priority(List.delete(nodes,Node.self()), :PriorityServer, order)
        optimal_node = Utilities.extract_optimal_node(multi_call_priorities)        
        State_machine.new_order({:ElevatorServer, optimal_node}, order.type, order.floor)
        Enum.each(NetworkServer.get_all_nodes,fn node -> Driver.set_order_button_light({:DriverServer, node}, order.type, order.floor, :on) end)
        Enum.each(NetworkServer.get_all_nodes,fn node -> GuardServer.add_order({:GuardServer, node}, order, optimal_node) end)
      
      # None of the above triggers -> distribute across nodes
      true -> 
        multi_call_priorities = Priority.get_priority(:PriorityServer, order)
        optimal_node = Utilities.extract_optimal_node(multi_call_priorities)        
        State_machine.new_order({:ElevatorServer, optimal_node}, order.type, order.floor)
        Enum.each(NetworkServer.get_all_nodes,fn node -> Driver.set_order_button_light({:DriverServer, node}, order.type, order.floor, :on) end)
        Enum.each(NetworkServer.get_all_nodes,fn node -> GuardServer.add_order({:GuardServer, node}, order, optimal_node) end)
    end
    {:noreply, state}
  end

  def handle_cast({:redistribute_order, order, node}, state) do
    # Remove node that failed to serve order from node list
    nodes = List.delete(Node.list, node)

    # If a local order needs redistribution, update motor status to false (broken) and cast add order with nodes and remove_self set true. 
    if node == Node.self() do
      State_machine.set_motor_status(:ElevatorServer, false)
      Process.spawn(fn -> add_order(:Distributer, order, nodes,  true) end, [])
  
    # Else cast add order with nodes
    else 
      Process.spawn(fn -> add_order(:Distributer, order, nodes) end, [])
    end
    {:noreply, state}
  end

  def handle_cast({:remove_order, order}, state) do
    case order.type do
      # If cab order type, remove locally
      :cab ->
        Driver.set_order_button_light(:DriverServer, order.type, order.floor, :off)
        GuardServer.remove_order(:GuardServer, order)
      
      # If hall order type, remove globally
      _hall ->
        Enum.each(NetworkServer.get_all_nodes,fn node -> Driver.set_order_button_light({:DriverServer, node}, order.type , order.floor, :off) end)
        Enum.each(NetworkServer.get_all_nodes,fn node -> GuardServer.remove_order({:GuardServer, node}, order) end)
    end
    {:noreply, state}
  end
end

