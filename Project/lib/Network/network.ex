defmodule NetworkServer do
    @moduledoc """
        This module creates a node for the local elevator and is responsible for creating and maintaining a connected cluster of Nodes. The module broadcasts its own
        IP-address once every second, using the udp-library in Elixir. Also, an IP-poller is created to listen for other Nodes broadcasting as well.
            
        * Communicates with the local guard to update hall order list after reconnecting to cluster
        * Communicates with the local driver to update hall order lights after reconnecting to cluster
    """

    use GenServer

    @server_name :NetworkServer
    #Every Node is given the name "Heis@IP", where IP is the IP-address of the Node
    @computer_name "Heis"

    def start do
        start_node(@computer_name)
        start_link()
    end

    def start_link do
        start_link([{:name, @server_name}])
    end

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok, port \\ 2019) do
        {:ok, socket} = :gen_udp.open(port, [active: true, broadcast: true])
        ip = get_my_ip()
        state = %{socket: socket, connected: false, ip: ip}
        Process.send_after(self(), :broadcast_ip, 1000)
        Process.send_after(self(), :update_status, 1000)
        Process.spawn(IpPoller, :init, [self()], [])
        {:ok, state}
    end

    # API -----------------------------------------------------------
    
    def is_connected?(pid) do
        GenServer.call(pid, :is_connected?, 60000)
    end

    # Callbacks -------------------------------------------------------

    def handle_call(:is_connected?, _from, state) do
        {:reply, state.connected, state}
    end

    ### Broadcast ip every second
    def handle_info(:broadcast_ip, state) do
        {:ok, socket} = :gen_udp.open(2020, [active: false, broadcast: true]) #Send ip
        case :gen_udp.send(socket, {255,255,255,255}, 2021, ip_to_string(state.ip)) do
            :ok ->
                _nothing_to_be_done = 0
            {:error, any_error} ->
                IO.puts("Could not broadcast IP")
                IO.inspect(any_error)
        end
        :gen_udp.close(socket)
        Process.send_after(self(), :broadcast_ip, 1000)
        {:noreply, state}
    end 

    #Try to connect to a node every time an IP-address is received
    def handle_info({:ok, ip}, state) do
        connect_to_node(@computer_name, ip)
        {:noreply, state}
    end

    #Error while listening for IP-addresses
    def handle_info(:error, state) do
        {:noreply, state}
    end

    def handle_info(:anything, state) do
        {:noreply, state}
    end

    #Loops every 100ms to update state of local node
    def handle_info(:update_status, state) do
        case length(Node.list) do
            0 ->
                state = %{state | :connected => false}
                Process.send_after(self(), :update_status, 100)
                {:noreply, state}
            _any_length ->
                #Update hall orders when state.connected transitions from false to true
                if state.connected == false do
                    case GuardServer.get_orders(:GuardServer) |> elem(0) |> List.first |> elem(1) do
                        orders ->
                            Enum.each(orders, fn {order, map} -> if order.type != :cab, do: Driver.set_order_button_light(:DriverServer, order.type, order.floor, :on)
                                                                                            GuardServer.add_order(:GuardServer, order, map.node) end)
                    end
                end             
                state = %{state | :connected => true}
                Process.send_after(self(), :update_status, 100)
                {:noreply, state}
        end
    end

    # Helper functions ----------------------------------------------------------------------------------------

    #Send and receive a message using the same socket to acquire own IP-address
    def get_my_ip() do
        {:ok, socket} = :gen_udp.open(6790, [active: false, broadcast: true])
        :ok = :gen_udp.send(socket, {255,255,255,255}, 6790, "test packet")
        ip = case :gen_udp.recv(socket, 100, 1000) do
            {:ok, {ip, _port, _data}} -> ip
            {:error, _} -> {:error, :could_not_get_ip}
        end
        :gen_udp.close(socket)
        ip
    end

    def ip_to_string(ip) do
        :inet.ntoa(ip) |> to_string()
    end

    def start_node(node_name, tick_time \\ 2000) do
        ip = get_my_ip() |> ip_to_string
        node_name_w_ip = node_name <> "@" <> ip
        Node.start(String.to_atom(node_name_w_ip),:longnames,tick_time)
        Node.set_cookie(Node.self, :gr52)
    end

    def connect_to_node(node_name, ip) do
        ip_string = ip_to_string ip
        node_name_w_ip = node_name <> "@" <> ip_string
        Node.ping(String.to_atom(node_name_w_ip))
    end

    def get_all_nodes() do
        List.insert_at(Node.list,0,Node.self)
    end

end

defmodule IpPoller do
    @moduledoc """
        This module contains a poller listening for IP-addresses using the udp-library in Elixir. 
        It is initialized with a server to which it sends every IP that is received.
    """

    def init(networkServer) do
        {:ok, socket} = :gen_udp.open(2021, [active: false, broadcast: true])
        listen(socket, networkServer)
    end

    def listen(socket, networkServer) do
        case :gen_udp.recv(socket, 10, 5000) do
            {:ok, {ip, _port, _data}} ->
                send(networkServer, {:ok, ip})
            {:error, :etimedout} ->
                send(networkServer, :no_response)
            {:error, _e} ->
                send(networkServer, :error)
            _anything ->
                send(networkServer, :anything)
        end
        listen(socket, networkServer)
    end
end
