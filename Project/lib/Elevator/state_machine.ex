defmodule State_machine do
@moduledoc """
Initializes and updates elevator state by responding to external events.
    * Receives meassages from the poller module to react to floor sensor hits
    * Receives messages from the distributer module to react to new order events
    * Receives messages from the door submodule to react to a door closed event

    * Sends messages to the driver to control motor direction and local floor and button lights
    * Sends messages to the distributer module upon request to supply information about state variables
    * Sends messages to the distributer to inform when an order has been served
    * Sends messages to the door submodule to open doors and start the door timer
    * Sends messages to the guard module for saving the state in case of system failure

    * Communicates exclusively with a corresponding order server to keep track of local orders
    * Uses methods from order logic for descision making
    
"""
    use GenServer
    @server_name :ElevatorServer

    ## Init

    @doc """
    Starts the elevator state machine
    """
    def start() do
        Order_server.start()
        Doors.start()
        start([{:name, @server_name}])
    end

    def start(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Initiates the state machine with initial state
    """
    def init(:ok) do
        state = %{  direction:           :stop,
                    motor_direction:     :stop,
                    floor:               -1,
                    behavior:            :idle,
                    motor_working:       true,
                    orders:              Order_server.get_orders(:OrderServer)}
        {:ok, state}
    end

    ### API ----------------------------------------------------------------------

    @doc """
    Returns the state of the elevator
    """
    def get_state(pid) do
        GenServer.call(pid, :get_state, 15000)
    end

    @doc """
    Returns the state motor_working
    """
    def is_motor_working?(pid) do
        GenServer.call(pid, :is_motor_working?, 15000)
    end

    @doc """
    This cast is applied whenever the elevator is rebooted after a power failure.
    The cast checks if the guard module of other nodes have a saved state for the local elevator, 
    in which case the elevator restores its state from the guard.
    """
    def reboot(pid) do
        GenServer.cast(pid, :reboot)
    end

    @doc """
    This cast is applied whenever the elevator is powered on, either for the first time, or after power failure.
    The cast drives the elevator up until a floor is reached.
    If the elevator happened to be on a floor upon initialization, the elevator is immediately considered initialized.
    """
    def initialize(pid) do
        GenServer.cast(pid, :initialize)
    end

    @doc """
    This cast is applied whenever the elevator doors are closed after an order is served at a floor.
    The cast determines a state transition based on the elevators current orders.
    If there are more orders, the elevator selects an appropriate direction and goes to a moving state.
    If there are no more orders, the elevator transitions to an idle state.
    """
    def doors_closed do
        GenServer.cast(@server_name, :doors_closed)
    end

    @doc """
    This cast is apllied whenever the elevator reaches a floor.
    The cast determines if the elevator should stop at the floor, in which a state transition to at floor is made,
    or simply drive past it, in which case no state transition is made.
    Stopping at a floor occurs upon completed initialization or whenever an order should be served.
    """
    def reached_floor(pid, floor) do
        GenServer.cast(pid, {:reached_floor, floor})
    end

    @doc """
    This cast is applied whenever the elevator is assigned a new order.
    The cast adds the order to the order list if the elevator is running normally, or ignored if the elevator is initializing. 
    Aditionally, the current state of the elevator is sent to the guard module of all other available nodes.
    If the elevator is not idle, no state transition is made.
    If the elevator is idle, a state transition is made based on the floor of the elevator and the order.
    """
    def new_order(pid, type, floor) do
        GenServer.cast(pid, {:new_order, type, floor})
    end

    @doc """
    Sets the is_motor_working variable in state. Can be true or fasle
    """
    def set_motor_status(pid, motor_status) do
        GenServer.cast(pid, {:set_motor_status, motor_status})
    end

    ### Calls ----------------------------------------------------------------------------

    def handle_call(:get_state, _from, state) do
        {:reply, state, state}
    end

    def handle_call(:is_motor_working?, _from, state) do
        {:reply, state.motor_working, state}
    end

    ### Casts -----------------------------------------------------------------------------

    def handle_cast(:doors_closed, state) do
        cond do
            Order_logic.exist_orders_on_direction?(state.orders, state.direction, state.floor) ->
                Driver.set_motor_direction(:DriverServer, state.direction)
                state = %{state | :behavior => :moving}
                state = %{state | :motor_direction => state.direction}
                {:noreply, state}

            Order_logic.orders_exist_below?(state.orders, state.floor) ->
                Driver.set_motor_direction(:DriverServer, :down)
                state = %{state | :motor_direction => :down}
                state = %{state | :behavior => :moving}
                state = %{state | :direction     => :down}
                {:noreply, state}
            Order_logic.orders_exist_above?(state.orders, state.floor) ->
                Driver.set_motor_direction(:DriverServer, :up)
                state = %{state | :motor_direction => :up}
                state = %{state | :behavior => :moving}
                state = %{state | :direction     => :up}
                {:noreply, state}
            true ->
                Driver.set_motor_direction(:DriverServer, :stop)
                state = %{state | :motor_direction => :stop}
                state = %{state | :behavior => :idle}
                state = %{state | :direction     => :stop}
                {:noreply, state}
        end
    end

    def handle_cast({:reached_floor, floor}, state) do
        case state.floor do 
            # Special case when initializing elevator
            -1 ->
                state = %{state | :motor_working => true}
                state = %{state | :floor => floor}
                Driver.set_floor_indicator(:DriverServer, floor)
                Driver.set_motor_direction(:DriverServer, :stop)
                state = %{state | :motor_direction => :stop}
                state = %{state | :behavior => :idle}
                Doors.open_doors(:DoorServer)
                {:noreply, state}
            _any_floor ->
                state = %{state | :motor_working => true}
                state = %{state | :floor => floor}
                Driver.set_floor_indicator(:DriverServer, floor)
                Enum.each(NetworkServer.get_all_nodes, fn node -> GuardServer.add_elevator_state({:GuardServer, node}, state, Node.self()) end)
                if Order_logic.should_stop?(state.orders, state.direction, floor) do
                    Driver.set_motor_direction(:DriverServer, :stop)
                    state = %{state | :motor_direction => :stop}
                    state = %{state | :behavior => :at_floor}
                    Order_server.remove_order(:OrderServer, :cab, floor)
                    Distributer.remove_order :Distributer, Order.order(:cab,floor)
                    # Removes :hall_up orders if and when they should be served
                    if not Order_logic.exist_orders_on_direction?(state.orders, state.direction, state.floor) or state.direction == :up do
                        Order_server.remove_order(:OrderServer, :hall_up, floor)
                        Distributer.remove_order :Distributer, Order.order(:hall_up,floor)
                    end
                    # Removes :hall_down orders if and when they should be served
                    if not Order_logic.exist_orders_on_direction?(state.orders, state.direction, state.floor) or state.direction == :down do
                        Order_server.remove_order(:OrderServer, :hall_down, floor)
                        Distributer.remove_order :Distributer, Order.order(:hall_down,floor)
                    end
                    state = %{state | :orders => Order_server.get_orders(:OrderServer)}
                    Doors.open_doors(:DoorServer)
                    {:noreply, state}
                else
                    {:noreply, state}
                end
        end
    end

    def handle_cast({:new_order, type, floor}, state) do
        # Special case when initializing elevator
        if state.floor == -1 do
            {:noreply, state}
        else
            Driver.set_order_button_light(:DriverServer, type, floor, :on)
            Order_server.add_order(:OrderServer, type, floor)
            # Adds the order to the guard of each node
            Enum.each(NetworkServer.get_all_nodes, fn node -> GuardServer.add_elevator_state({:GuardServer, node}, state, Node.self()) end)
            state = %{state | :orders => Order_server.get_orders(:OrderServer) }
            cond do
                # This statement checks if the new order is on the elevators current floor, while other orders are still being served
                floor == state.floor and state.behavior != :moving and Order_logic.should_stop?(state.orders, state.direction, floor) ->
                    state = %{state | :behavior => :at_floor}
                    Order_server.remove_order(:OrderServer, type, floor)
                    Distributer.remove_order :Distributer, Order.order(type,floor)
                    Order_server.remove_order(:OrderServer, :cab, floor)
                    Distributer.remove_order :Distributer, Order.order(:cab,floor)
                    state = %{state | :orders => Order_server.get_orders(:OrderServer)}
                    Doors.open_doors(:DoorServer)
                    {:noreply, state}
                state.behavior == :idle ->
                    case Order_logic.choose_new_direction(state.orders, state.floor) do
                        :up ->
                            Driver.set_motor_direction(:DriverServer, :up)
                            state = %{state | :motor_direction => :up}
                            state = %{state | :behavior => :moving}
                            state = %{state | :direction     => :up}
                            {:noreply, state}
                        :down ->
                            Driver.set_motor_direction(:DriverServer, :down)
                            state = %{state | :motor_direction => :down}
                            state = %{state | :behavior => :moving}
                            state = %{state | :direction     => :down}
                            {:noreply, state}
                        :stop ->
                            Driver.set_motor_direction(:DriverServer, :stop)
                            state = %{state | :motor_direction => :stop}
                            state = %{state | :behavior => :idle}
                            state = %{state | :direction     => :stop}
                            Process.spawn(fn -> GenServer.cast(:ElevatorServer, {:reached_floor, floor}) end, [])
                            {:noreply, state}
                    end
                true ->
                    {:noreply, state}
            end
        end

    end

    def handle_cast(:initialize, state) do
        case Driver.get_floor_sensor_state(:DriverServer) do
            :between_floors ->
                Driver.set_motor_direction(:DriverServer, :up)
                state = %{state | :motor_direction => :up}
                state = %{state | :floor => -1}
                {:noreply, state}
            floor ->
                Driver.set_floor_indicator(:DriverServer, floor)
                Driver.set_motor_direction(:DriverServer, :stop)
                state = %{state | :motor_direction => :stop}
                state = %{state | :floor => floor}
                Doors.open_doors(:DoorServer)
                {:noreply, state}
        end
    end

    def handle_cast(:reboot, state) do
        # Reboot cab orders from before shutdown if any
        cond do
            # There exists a backup
            NetworkServer.is_connected?(:NetworkServer) and GuardServer.get_elevator_state({:GuardServer, List.first(Node.list)}, Node.self()) != nil -> 
                backup_state = GuardServer.get_elevator_state({:GuardServer, List.first(Node.list)}, Node.self())
                backup_state.orders |> Enum.with_index |> 
                    Enum.each(fn {buttons,floor} -> if buttons.cab == true and floor != state.floor, do: Distributer.add_order(:Distributer, Order.order(:cab, floor)) end)
                {:noreply, state}

            true ->
                {:noreply, state}
        end 
    end

    def handle_cast({:set_motor_status, motor_status}, state) do
        state = %{state | :motor_working => motor_status}
        {:noreply, state}
    end
end

defmodule Doors do
@moduledoc """
This submodule opens the door of a single elevator at the request of the state machine, and closes it after a set time.
The timer is tracked so that it might be interrupted and restarted in the case of a new request to open the door.
"""
    use GenServer
    @server_name :DoorServer
    @door_open_duration 3000 #milli-seconds

    ### API

    @doc """
    Starts the door state machine
    """
    def start() do
        start([{:name, @server_name}])
    end

    def start(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Initiates the state machine with initial state
    """
    def init(:ok) do
        state = %{  door_state: :closed, 
                    door_process: :initial}
        {:ok, state}
    end

    @doc """
    Opens the door of the elevator, then closes them after a set time.
    If the door was already open, the timer is reset
    """
    def open_doors(pid) do
        GenServer.cast(pid, :open_doors)
    end

    ### Cast
    def handle_cast(:open_doors, state) do
        # Special case to avoid attempting to exit a non-existing process
        if state.door_process != :initial do
            Process.exit(state.door_process, :new_door_request)
        end
        alive_door_timer = Process.spawn fn -> door_timer() end, []
        state = %{state | :door_process => alive_door_timer}
        {:noreply, state}
    end   

    @doc """
    The door timer function. Upon time-out, the function casts to the
    Elevator server, triggering a door_closed event.
    """
    def door_timer() do
        Driver.set_door_open_light(:DriverServer, :on)
        :timer.sleep(@door_open_duration)
        Driver.set_door_open_light(:DriverServer, :off)
        State_machine.doors_closed()
    end
end