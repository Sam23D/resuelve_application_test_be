defmodule Repo do
  
  alias Helpers.General, as: GeneralHelpers
  alias Repo.Users, as: UsersRepo

  def get_users_for_year( year )do
    with  {:ok, {ds, de}} <- GeneralHelpers.year_date_range(year),
          {:ok, users} <- UsersRepo.get_users_for_span(ds, de)
    do
      users
    end
  end

end