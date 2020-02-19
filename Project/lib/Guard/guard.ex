defmodule GuardServer do
@moduledoc """
    This module is responsible for keeping track of all orders currently in the cluster as well as a copy of the current state of all elevators connected to the cluster.
    The state of the module is a struct with two maps: 
        One map contains a key on the form {type:, floor:} pointing to a value that contains both the guard_process of the order aswell as the name of the Node to which the order was assigned.
        The other map consists of Node names as keys, with a copy of the corresponding elevators state as value. This state is on the same format as the state in the State_machine module.

    * Communicates with one or more order servers to globally remove orders before they are redistributed
    * Communicates with the local distributer by sending orders that should be globally removed before they are redistributed
"""
    use GenServer

    @server_name :GuardServer

    defstruct orders: %{}, elevator_states: %{}

    def start() do
        start_link([{:name, @server_name}])
    end

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        state = %GuardServer{}
        {:ok, state}
    end

    ### API ---------------------------------------------------------------------------------------------------

    #Add an order on the form {type:, floor:} to the order list. This order was assigned to "node". Also spawns the guard_process of this order.
    def add_order(pid, order, node) do
        GenServer.cast(pid, {:add_order, order, node})
    end

    #Return all orders from all nodes currently in the cluster. Implemented as a multicall to handle possible error when calling another node and then going offline before receiving a reply.
    def get_orders(nodes \\ [List.first(Node.list())], pid, timeout \\ 5000) do
        GenServer.multi_call(nodes, pid, :get_orders, timeout)
    end

    #Alerts the guard_process of the order that the order has been served, meaning it can safely be discarded.
    def remove_order(pid, order) do
        GenServer.cast(pid, {:remove_order, order})
    end

    #Adds the provided "elevator_state" to the module state, storing it in a map with the key "elevator_name". If the "elevator_name" exists in the map already, the value is updated.
    def add_elevator_state(pid, elevator_state, elevator_name) do
        GenServer.cast(pid, {:add_elevator_state, elevator_state, elevator_name})
    end

    #Returns the stored elevator_state of the node "elevator_name".
    def get_elevator_state(pid, elevator_name) do
        GenServer.call(pid, {:get_elevator_state, elevator_name})
    end

    ### Helper functions -------------------------------------------------------------------------

    # Alerts the module after 25 seconds if the order has not been handled
    def guard_process(pid, order, node) do
        receive do
            {:order_done, order} ->
                GenServer.cast(pid, {:clear_order, order})
        after
            25_000 ->
                send(pid, {:check_order, order, node})
        end
    end

    ### Calls ------------------------------------------------------------------------------------

    def handle_call(:get_orders, _from, state) do
        {:reply, state.orders, state}
    end

    def handle_call({:get_elevator_state, elevator_name}, _from, state) do
        case elevator_name do
            nil ->
                {:reply, nil, state}
            _elevator ->
                {:reply, Map.get(state.elevator_states, elevator_name), state}
        end
    end

    ### Casts ---------------------------------------------------------------------------------------------------
    
    def handle_cast({:add_order, order, node}, state) do
        #Only accept the order into the guard if it does not currently exist
        if !(Map.has_key?(state.orders, order)) do
            guard_process = Process.spawn(GuardServer, :guard_process, [:GuardServer, order, node], [])
            new_state = %{state | :orders => Map.put(state.orders, order, %{guard: guard_process, node: node})}
            {:noreply, new_state}
        else
            {:noreply, state}
        end
    end

    def handle_cast({:add_elevator_state, elevator_state, elevator_name}, state) do
        new_state = %{state | :elevator_states => Map.put(state.elevator_states, elevator_name, elevator_state)}
        {:noreply, new_state}
    end

    def handle_cast({:clear_order, order}, state) do
        new_state = %{state | :orders => Map.delete(state.orders, order)}
        {:noreply, new_state}
    end

    def handle_cast({:remove_order, order}, state) do
        map = Map.get(state.orders, order)
        case map do
            nil ->
                {:noreply, state}
            _else ->
                Process.send(map.guard, {:order_done, order}, [])
                {:noreply, state}
        end
    end

    ### Handle_info ---------------------------------------------------------------------------------------------

    # Triggered if the guard_process does not receive a message within the set response time limit
    def handle_info({:check_order, order, node}, state) do
        state = %{state | :orders => Map.delete(state.orders, order)}
        Order_server.remove_order({:Order_server, node}, order.type, order.floor)
        # Clear lights globally. Also clear order from GuardServers globally.
        Distributer.remove_order(:Distributer, order)
        Distributer.redistribute_order(:Distributer, order, node)
        {:noreply, state}
    end
end