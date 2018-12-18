defmodule Repo.Movements do
  alias Service.Resuelve, as: Service

  @type date :: %Date{}
  @type user :: %Resuelve.User{}
  @type movement :: %Resuelve.Movement{}

  @doc """
    iex> get_movements("2017-01-12", "2017-02-01")
      {:ok, [ %Movement{} ]}
  """
  @spec get_movements( date, date ) :: {:ok, list(movement)} | {:error, String.t()}
  defdelegate get_movements(date_start, date_end), to: Service
end