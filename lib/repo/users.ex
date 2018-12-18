defmodule Repo.Users do
  alias Service.Resuelve, as: Service
  alias Helpers.General, as: GeneralHelpers

  import ResuelveBe.Guards

  @type date :: %Date{}
  @type user :: %Resuelve.User{}
  @type movement :: %Resuelve.Movement{}

  @doc """
    iex> get_users("2017-01-12", "2017-02-01")
      {:ok, [ %User{} ]}
  """
  @spec get_users( date, date ) :: {:ok, list(user)} | {:error, String.t()}
  defdelegate get_users(date_start, date_end), to: Service

  @spec get_users_for_span(date | String.t(), date | String.t()) :: {:ok, list(user)} | {:error, String.t()}
  def get_users_for_span( date_start \\ "2017-01-01", date_end \\ "2017-02-01")  when is_string_date_range( date_start, date_end ) do
    with  {:ok, {ds, de}} <- GeneralHelpers.is_valid_date_range( date_start, date_end )
    do
      get_users_for_span(ds, de)  
    end
  end
  
  def get_users_for_span( ds = %Date{}, de = %Date{}), do: _get_users_for_span(ds, de)
  
  defp _get_users_for_span({ds, de}), do: _get_users_for_span(ds, de)

  defp _get_users_for_span( ds, de )do
    case get_users(ds, de)do
      {:ok, users} ->
        {:ok, users}
      {:limit_error, _} ->
        # when we face a limit in records per range we will fallback to a binary search,
        # continiously splitting the date ranges, down to an acceptable date

        # BUG there is an error in this implementation, when there are more than 50 entries
        # in one single day, that day will be skiped due to the Resuelve's endpoint receiving
        # a Date instead of a DateTime, there is no actuall way of fetching a day with more than
        # 50 entries in it

        # WORKAROUND this aproach of using binary search will reduce API requests as much as posible
        # but there is a small bug where sometimes you retrieve a repeated record
        # if I fetch 2017-01-01 -> 2017-01-15  and 2017-01-15 -> 2017-01-31, it will have one or two
        # repeated records, it might have something to do with the query in the API be something like
        #   where record.date >= start_date and record.date <= start_date
        # instead of
        #   where record.date >= start_date and record.date < start_date
        # this is just a suposition
        # that us the reason for the line 52, it asures there will be no repeated values, 
        # it diminishes performance but it also guarantees that there will
        # be no duplicates, there is room for performance there
        {:ok, new_ranges } = GeneralHelpers.split_date_range(ds, de)
        new_ranges
        |> IO.inspect
        # We intend to fetch all the ranges in parallel, this is a quick solution, best aproach
        # is to use Task.Supervisor, or even Flow
        |> Enum.map( &( Task.async( fn -> _get_users_for_span(&1) end)))
        |> Enum.map( fn task -> Task.await(task, 10_000)end )
        |> Enum.reduce( fn 
            {:ok, users }, {:ok, acc} -> {:ok, acc ++ users}
            _, acc -> acc
          end)
        |> ( fn {:ok, users} -> {:ok, MapSet.new(users) |> MapSet.to_list }end ).()
      {:error, err} ->
        {:error, err}
    end
  end

end