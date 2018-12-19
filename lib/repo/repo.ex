defmodule Repo do
  
  alias Helpers.General, as: GeneralHelpers
  alias Repo.{ Users, Movements}
  alias Resuelve.{ Movement, User }

  def get_users_for_year( year )do
    with  {:ok, {ds, de}} <- GeneralHelpers.year_date_range(year),
          {:ok, users} <- Users.get_users_for_span(ds, de)
    do
      {:ok, Enum.map(users, &User.parse_record/1 )}
    end
  end

  def get_movements_for_year( year )do
    with  {:ok, {ds, de}} <- GeneralHelpers.year_date_range(year),
          {:ok, movements} <- Movements.get_movements_for_span(ds, de)
    do
      {:ok, Enum.map(movements, &Movement.parse_record/1 )}
    end
  end

end