defmodule Order_logic do
@moduledoc """
This submodule asserts thruths and performs logical descisions for a single elevator. 
The outputs are computed by inspecting the orders, current direction and current floor of the elevator without ever changing any data.
"""
    
    @doc """
    Checks if an order of a specific type at a specific floor exists. 
    Returns true or false
    """
    def order_exist?(orders, type, floor) do
        orders |> Enum.at(floor) |> Map.get(type)
    end

    @doc """
    Checks if there are any orders of any type at or above the elevators location.
    Returns true or false
    """
    def orders_exist_above?(orders, from_floor) do
        cond do
            # No orders may exist above the top floor
            (from_floor >= Utilities.top_floor) ->
                false
            order_exist?(orders, :hall_up, from_floor+1)     ->
                true
            order_exist?(orders, :hall_down, from_floor+1)   ->
                true
            order_exist?(orders, :cab, from_floor+1)    ->
                true
            true ->
                orders_exist_above?(orders, from_floor+1) 
        end
    end

    @doc """
    Checks if there are any orders of any type at or below the elevators location.
    Returns true or false
    """
    def orders_exist_below?(orders, from_floor) do
        cond do
            # No orders may exist below ground floor
            from_floor <= 0 ->
                false
            order_exist?(orders, :hall_down, from_floor-1)     ->
                true
            order_exist?(orders, :hall_up, from_floor-1)   ->
                true
            order_exist?(orders, :cab, from_floor-1)    ->
                true
            true ->
                orders_exist_below?(orders, from_floor - 1)
        end
    end

    @doc """
    Evaluates if the elevator should stop at a certain floor.
    Returns true or false
    """
    def should_stop?(orders, direction, floor) do
        cond do
            order_exist?(orders, :cab, floor) -> true
            direction == :up and order_exist?(orders, :hall_up, floor) -> 
                order_exist?(orders, :hall_up, floor)
            direction == :down and order_exist?(orders, :hall_down, floor)-> 
                order_exist?(orders, :hall_down, floor)
            not exist_orders_on_direction?(orders, direction, floor) ->
                true
            direction == :stop -> true
            true -> false
        end
    end

    @doc """
    Checks if there exists any orders in accordance with the current direction.
    The checks are run from the specified starting floor.
    Returns true or false
    """
    def exist_orders_on_direction?(orders, direction, from_floor) do
        cond do
            # No orders on direction may exist if elevator is on direction down in ground floor or up in top floor
            (from_floor == 0 and direction != :up) or (from_floor == Utilities.top_floor and direction != :down) ->
                false
            direction == :up ->
                orders_exist_above?(orders, from_floor)
            direction == :down ->
                orders_exist_below?(orders, from_floor)
            true ->
                false
        end
    end

    @doc """
    Lets the elevator determine a new direction by inspecting orders below then above.
    Below is checked first since the bottom floor is realisticly most visited.
    Returns :stop, :up or :down
    """
    def choose_new_direction(orders, from_floor) do
        cond do
            # Checks for orders of any type
            order_exist?(orders, :hall_up, from_floor) or order_exist?(orders, :hall_down, from_floor) or order_exist?(orders, :down, from_floor) ->
                :stop
            orders_exist_below?(orders, from_floor) ->
                :down
            orders_exist_above?(orders, from_floor) ->
                :up
            true ->
                :stop
        end       
    end  
end