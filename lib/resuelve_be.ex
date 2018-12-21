defmodule ResuelveBe do

  def run do
    {:ok, users} = Repo.get_users_for_year ( 2017 )
    {:ok, movements} = Repo.get_movements_for_year( 2018 )
    { users, movements }
  end

end
