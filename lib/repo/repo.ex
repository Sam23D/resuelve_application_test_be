defmodule Repo do
  
  alias Helpers.General, as: GeneralHelpers
  alias Repo.{ Users, Movements}

  def get_users_for_year( year )do
    with  {:ok, {ds, de}} <- GeneralHelpers.year_date_range(year),
          {:ok, users} <- Users.get_users_for_span(ds, de)
    do
      users
    end
  end

  def get_movements_for_year( year )do
    with  {:ok, {ds, de}} <- GeneralHelpers.year_date_range(year),
          {:ok, users} <- Movements.get_movements_for_span(ds, de)
    do
      users
    end
  end

end