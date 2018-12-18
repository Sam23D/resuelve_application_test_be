defmodule Repo.Users do
  alias Service.Resuelve, as: Service

  @type date :: %Date{}
  @type user :: %Resuelve.User{}
  @type movement :: %Resuelve.Movement{}

  @doc """
    iex> get_users("2017-01-12", "2017-02-01")
      {:ok, [ %User{} ]}
  """
  @spec get_users( date, date ) :: {:ok, list(user)} | {:error, String.t()}
  defdelegate get_users(date_start, date_end), to: Service

end