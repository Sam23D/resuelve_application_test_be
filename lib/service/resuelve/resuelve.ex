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

  # TODO Both of this methods share a lot of logic, actually the only diference is the 
  # Helpers.get_url method, once you have to do another methor similar to this, it MUST be refactored
  # into another method, following the Rule of Three.
  # Once that method is refactored ( I propose base_resuelve_get ), it should be moved to Helpers and then
  # implemented here

  @doc """
    iex> get_movements("2017-01-12", "2017-02-01")
      {:ok, [ %Movement{} ]}
  """
  @spec get_movements( date, date ) :: {:ok, list( movement )} | {:limit_error, String.t()} | {:error, any()}
  def get_movements( date_start, date_end )do
    with  {:ok, url} <- Helpers.movements_url(date_start, date_end),
          {:ok, resp = %{ status_code: 200 }} <- HTTPoison.get(url),
          {:ok, body } <- Jason.decode(resp.body)
    do
      {:ok, body}
    else 
      {:ok, resp } ->
        {:limit_error, resp.body}
      err ->
        err
    end
  end

  @doc """
    iex> get_users("2017-01-12", "2017-02-01")
      {:ok, [ %User{} ]}
  """
  @spec get_users( date, date ) :: {:ok, list(user)} | {:limit_error, String.t()} |{:error, any()}
  def get_users( date_start, date_end )do
    with  {:ok, url} <- Helpers.users_url(date_start, date_end),
          {:ok, resp = %{ status_code: 200 }} <- HTTPoison.get(url),
          {:ok, body } <- Jason.decode(resp.body)
    do
      {:ok, body}
    else 
      {:ok, resp } ->
        {:limit_error, resp.body}
      err ->
        {:error, err}
    end
  end

end