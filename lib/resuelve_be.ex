defmodule ResuelveBe do

  def run(opts \\ [ users_year: 2017, movements_year: 2018 ]) do
    ProgramStats.set_start_time
    with  {:get_users, {:ok, users}} = {:get_users, Repo.get_users_for_year ( opts[:users_year] )},
          {:get_movements, {:ok, movements}} = {:get_movements, Repo.get_movements_for_year( opts[:movements_year] )},
          movements_summary = Resuelve.MovementSummary.summarize_movements(movements),
          final_sumary = Resuelve.MovementSummary.add_users_info_to_summary(movements_summary, users),
          report <- Resuelve.MovementSummary.format_summary_report(final_sumary),
          payload <- Jason.encode!( report ),
          url <- Service.ResuelveRequestHelpers.resumen_url!(),
          {:ok, response} <- HTTPoison.post( url, payload, [{"content-type", "application/json"}])
    do
      IO.inspect( response)
      
      ProgramStats.set_finish_time
      ProgramStats.get_stats
      |>IO.inspect
    end
    
  end

end
