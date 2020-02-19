defmodule Order_server do
@moduledoc """
This submodule keeps track of a single elevators orders. Each state machine has a corresponding order server.
Only the state machine may access its associated order server
"""
    use GenServer
    @server_name :OrderServer

    @doc """
    Starts the order server
    """
    def start() do
        start([{:name, @server_name}])
    end

    def start(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Initializes the orders of a single elevator as a list where each entry represent a floor.
    Each floor is represented by a mapping from a certain order type (:hall_up, :hall_down or :cab)
    to a boolean value representing whether or not an order exists of a certain type
    """
    def init(:ok) do
        all_orders = get_init_orders
        {:ok, all_orders}
    end

    # Private functions used by the init function for generating a list of maps as described above
    defp get_init_orders do
        initial_orders_at_single_floor  = %{hall_up: false, hall_down: false, cab: false}
        all_orders                      = fill_order_list([], initial_orders_at_single_floor, 0)
    end

    defp fill_order_list(all_orders, orders_at_single_floor, at_floor) when at_floor >= 3 do
        all_orders = List.insert_at(all_orders, 0, orders_at_single_floor)
    end

    defp fill_order_list(all_orders, orders_at_single_floor, at_floor) do
        all_orders = List.insert_at(all_orders, 0, orders_at_single_floor)
        fill_order_list(all_orders, orders_at_single_floor, (at_floor+1))
    end

    ### API
   
    @doc """
    Returns the order list of an order server associated with a state machine
    """
    def get_orders(all_orders) do
        GenServer.call(all_orders, :get_orders, 15000)
    end

    @doc """
    Adds an order of a specific type at a specific floor to the order list by remapping the appropriate value to true
    """
    def add_order(all_orders, type, floor) do
        GenServer.cast(all_orders, {:add_order, type, floor})
    end

    @doc """
    Removes an order of a specific type at a specific floor by remapping the appropriate value to false
    """
    def remove_order(all_orders, type, floor) do
        GenServer.cast(all_orders, {:remove_order, type, floor})
    end

    ### Casts and calls
    
    def handle_call(:get_orders, _from, all_orders) do
        {:reply, all_orders, all_orders}
    end

    def handle_cast({:add_order, type, floor}, all_orders) do
        updated_orders_at_floor     = all_orders |> Enum.at(floor) |> Map.replace!(type, true)
        all_orders                  = List.replace_at(all_orders, floor, updated_orders_at_floor)
        {:noreply, all_orders}
    end

    def handle_cast({:remove_order, type, floor}, all_orders) do
        updated_orders_at_floor     = all_orders |> Enum.at(floor) |> Map.replace!(type, false)
        all_orders                  = List.replace_at(all_orders, floor, updated_orders_at_floor)
        {:noreply, all_orders}
    end
end
