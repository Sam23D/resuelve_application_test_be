defmodule ResuelveBe do

  def build_report(opts \\ [ users_year: 2017, movements_year: 2018 ]) do
    with  {:get_users, {:ok, users}} = {:get_users, Repo.get_users_for_year ( opts[:users_year] )},
          {:get_movements, {:ok, movements}} = {:get_movements, Repo.get_movements_for_year( opts[:movements_year] )},
          movements_summary = Resuelve.MovementSummary.summarize_movements(movements),
          final_sumary = Resuelve.MovementSummary.add_users_info_to_summary(movements_summary, users)
    do
      final_sumary
      |> Resuelve.MovementSummary.format_summary_report
    end
  end

end
