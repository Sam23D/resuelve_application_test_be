defmodule ResuelveBe do

  def run do
    with  {:get_users, {:ok, users}} = {:get_users, Repo.get_users_for_year ( 2017 )},
          {:get_movements, {:ok, movements}} = {:get_movements, Repo.get_movements_for_year( 2018 )},
          movements_summary = Resuelve.MovementSummary.summarize_movements(movements),
          final_sumary = Resuelve.MovementSummary.add_users_info_to_summary(movements_summary, users)
    do
      final_sumary
    end
  end

end
