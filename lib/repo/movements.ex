defmodule Repo.Movements do
  alias Service.Resuelve, as: Service
  alias Helpers.General, as: GeneralHelpers

  import ResuelveBe.Guards

  @moduledoc """

    Extra:  
    In some places you will find varibles named 
      date_start, date_end
    An in other places you will find them again named
      ds, de
    We sacrifice a little of redability for keeping shorter lines of code 
    so they can be a little bit asier to read
  """

  @type date :: %Date{}
  @type movement :: %Resuelve.Movement{}
  @type date_range :: {date, date}

  @doc """
    iex> get_movements("2017-01-12", "2017-02-01")
      {:ok, [ %Movement{} ]}
  """
  @spec get_movements( date, date ) :: {:ok, list(movement)} | {:error, String.t()}
  defdelegate get_movements(date_start, date_end), to: Service

  @doc """
    Will return a list of movements for the two given dates
    iex> get_movements_for_span("2017-01-01", "2018-01-01")
      {:ok, [ %Movement{} ]}
  """
  @spec get_movements_for_span(date | String.t(), date | String.t()) :: {:ok, list(movement)} | {:error, String.t()}
  def get_movements_for_span( date_start \\ "2017-01-01", date_end \\ "2017-02-01")  when is_string_date_range( date_start, date_end ) do
    with  {:ok, {ds, de}} <- GeneralHelpers.is_valid_date_range( date_start, date_end )
    do
      get_movements_for_span(ds, de)  
    end
  end

  def get_movements_for_span( ds = %Date{}, de = %Date{}), do: _get_movements_for_span(ds, de)

  @spec _get_movements_for_span(date_range) :: {:ok, list(movement)} | {:error, any()}
  defp _get_movements_for_span({ds, de}), do: _get_movements_for_span(ds, de)

  @spec _get_movements_for_span(date, date) :: {:ok, list(movement)} | {:error, any()}
  defp _get_movements_for_span( ds, de )do
    case get_movements(ds, de)do
      {:ok, movements} ->
        {:ok, movements}
      {:limit_error, _} -> #this is the case when we are returned more than 50 records
        {:ok, new_ranges } = GeneralHelpers.split_date_range(ds, de)
        new_ranges
        |> IO.inspect
        |> Enum.map( &( Task.async( fn -> _get_movements_for_span(&1) end)))
        |> Enum.map( fn task -> Task.await(task, 10_000)end )
        |> Enum.reduce( fn 
            {:ok, movements }, {:ok, acc} -> {:ok, acc ++ movements}
            _, acc -> acc
          end)
        |> ( fn {:ok, movements} -> {:ok, MapSet.new(movements) |> MapSet.to_list }end ).()
      {:error, err} ->
        {:error, err}
    end
  end

end