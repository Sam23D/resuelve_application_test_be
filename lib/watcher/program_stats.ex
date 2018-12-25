
defmodule ProgramStats do
    use GenServer

    defstruct start_time: 0, finish_time: 0, total_requests: 0, total_time: 0

    def start_link(  )do
        start_time = :os.system_time
        GenServer.start_link(__MODULE__, %__MODULE__{ start_time: start_time }, name: __MODULE__)
    end

    def get_stats do
        GenServer.call(__MODULE__, :state)
    end

    def set_start_time do
        GenServer.call(__MODULE__, :start)
    end

    def set_finish_time do
        GenServer.call(__MODULE__, :finish)
    end

    def total_req_inc do
        GenServer.cast(__MODULE__, :req_inc)
    end

    def handle_call(:state, _from, state) do
        {:reply, state, state}
    end

    def handle_call(:start, _from, state) do
        start_time = DateTime.utc_now
        {:reply, start_time, %{state | start_time: start_time, total_requests: 0}}
    end
    
    def handle_call(:finish, _from, state) do
        stop_time = DateTime.utc_now
        total = DateTime.diff( stop_time, state.start_time, :milliseconds) 
        {:reply, stop_time, %{state | total_time: total, finish_time: stop_time}}
    end

    def handle_cast(:req_inc, state)do
        {:noreply, %{ state | total_requests: state.total_requests + 1}}
    end
end