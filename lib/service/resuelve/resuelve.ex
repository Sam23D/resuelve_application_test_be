defmodule Service.Resuelve do
  
  @moduledoc """
    This endpoint aims to abstract Resuelve's API into methods simple methods
  """

  alias Service.ResuelveRequestHelpers, as: Helpers
  alias Resuelve.User
  alias Resuelve.Movement

  @type date :: %Date{}
  @type user :: %User{}
  @type movement :: %Movement{}

  @default_max_retry 2

  # TODO Both of this methods share a lot of logic, actually the only diference is preatty much the 
  # Helpers.get_url method, once you have to do another methor similar to this, it MUST be refactored
  # into another method, following the Rule of Three.
  # Once that method is refactored ( I propose base_resuelve_get ), it should be moved to Helpers and then
  # implemented here

  # As we intend to do parallel request, and the server times_out when it does not have
  # cached responses and we send too many requests, we set up a simple retry mechanism
  

  @doc """
    iex> get_movements("2017-01-12", "2017-02-01")
      {:ok, [ %Movement{} ]}
  """
  @spec get_movements( date, date ) :: {:ok, list( movement )} | {:limit_error, String.t()} | {:error, any()}
  def get_movements( date_start, date_end, retry_acc \\ 0, max_retry \\ @default_max_retry )do
    with  {:ok, url} <- Helpers.movements_url(date_start, date_end),
          {:request, true, {:ok, resp = %{ status_code: 200 }}}  <- {:request, retry_acc < max_retry, HTTPoison.get(url)},
          {:program_stats, :ok} <- {:program_stats, ProgramStats.total_req_inc},
          {:decode, {:ok, body }} <- {:decode, Jason.decode(resp.body)}
    do
      {:ok, body}
    else 
      {:request, true, {:ok, resp }} ->
        {:limit_error, resp.body}
      {:request, true, {:error, %HTTPoison.Error{reason: :timeout} }} ->
        IO.inspect "TIMEOUT RETRY"
        Process.sleep( retry_acc * 1000 )
        get_movements(date_start, date_end, retry_acc + 1 )
      {:request, false, {:error, %HTTPoison.Error{reason: :timeout}} = err } ->
        err
      {:program_stats, _} ->
        IO.inspect "Execution statistics not being recorded correctly"
        {:error, :program_stats_error}
      {:decode, err} -> 
        # this is left as is in case we need to do something when we fail to parse the response
        err
      err ->
        {:error, err}
    end
  end

  @doc """
    iex> get_users("2017-01-12", "2017-02-01")
      {:ok, [ %User{} ]}
  """
  @spec get_users( date, date ) :: {:ok, list(user)} | {:limit_error, String.t()} | {:error, any()}
  def get_users( date_start, date_end, retry_acc \\ 0, max_retry \\ @default_max_retry )do
    with  {:ok, url} <- Helpers.users_url(date_start, date_end),
          {:request, true, {:ok, resp = %{ status_code: 200 }}}  <- {:request, retry_acc < max_retry, HTTPoison.get(url)},
          {:decode, {:ok, body }} <- {:decode, Jason.decode(resp.body)}
    do
      {:ok, body}
    else 
      {:request, true, {:ok, resp }} ->
        {:limit_error, resp.body}
      {:request, true, {:error, %HTTPoison.Error{reason: :timeout} }} ->
        IO.inspect "TIMEOUT RETRY NUM"
        Process.sleep( retry_acc * 1000 )
        get_users(date_start, date_end, retry_acc + 1 )
      {:request, false, {:error, %HTTPoison.Error{reason: :timeout}} = err} ->
        err
      {:program_stats, _} ->
        IO.inspect "Execution statistics not being recorded correctly"
        {:error, :program_stats_error}
      {:decode, err} ->
        err
      err ->
        {:error, err}
    end
  end

end