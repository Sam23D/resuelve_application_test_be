defmodule Service.ResuelveRequestHelpers do
  @api_url "https://us-central1-prueba-resuelve.cloudfunctions.net"

  alias Service.Resuelve.BaseResponse

  @type date :: %Date{}

  def users_url!( date_start, date_end )do
    case users_url( date_start, date_end ) do
      {:ok, url} ->
        url
      _ ->
        raise "invalid arguments"
    end
  end

  @doc """
    Returns Resuelve's users endpoint acording to the given dates

    iex> users_url( "1999-12-12", "2000-12-12", "mydomain.com")
      {:ok, "mydomain.com/1999-12-12/2000-12-12"}
  """
  @spec users_url( String.t() | date, String.t() | date, String.t() ) :: {:ok, String.t()} | {:error, String.t()}
  def users_url(date_start, date_end, url \\ @api_url )

  def users_url( %Date{} = date_start, %Date{} = date_end, url )do
    {:ok,  "#{url}/users/#{Date.to_string(date_start)}/#{Date.to_string(date_end)}"}
  end

  def users_url( date_start, date_end, url ) when is_bitstring( date_start ) and is_bitstring( date_start ) do
    case { Date.from_iso8601(date_start), Date.from_iso8601(date_end)} do
      {{:ok, parsed_start}, {:ok, parsed_end} }->
        users_url( parsed_start, parsed_end, url)
      _ ->
        {:error, "invalid date format start: #{ date_start }, end: #{ date_end}, format should be YYYY-MM-DD"}
    end
  end

  def users_url(_, _, date), do: {:error, "invalid date params"}

  @doc """
    Returns Resuelve's users endpoint acording to the given dates

    iex> users_url( "1999-12-12", "2000-12-12", "mydomain.com")
      {:ok, "mydomain.com/1999-12-12/2000-12-12"}
  """
  @spec movements_url( String.t() | date, String.t() | date, String.t() ) :: {:ok, String.t()} | {:error, String.t()}
  def movements_url(date_start, date_end, url \\ @api_url )

  def movements_url( %Date{} = date_start, %Date{} = date_end, url )do
    {:ok,  "#{url}/movements/#{Date.to_string(date_start)}/#{Date.to_string(date_end)}"}
  end

  def movements_url( date_start, date_end, url ) when is_bitstring( date_start ) and is_bitstring( date_start ) do
    case { Date.from_iso8601(date_start), Date.from_iso8601(date_end)} do
      {{:ok, parsed_start}, {:ok, parsed_end} }->
        movements_url( parsed_start, parsed_end, url)
      _ ->
        {:error, "invalid date format start: #{ date_start }, end: #{ date_end}, format should be YYYY-MM-DD"}
    end
  end

  def movements_url(_, _, date), do: {:error, "invalid date params"}

end