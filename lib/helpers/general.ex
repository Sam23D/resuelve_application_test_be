defmodule Helpers.General do
  
  import ResuelveBe.Guards

  @type date :: %Date{}

  @doc """
    Accepts 2 dates as either String in YYYY-MM-DD format or as %Date{} Structs,
    the returns if the strings are valid, if so they are casted to Dates, if they
    are in reverse order, older first, then it swaps the date order to be
      { earlier, later }
    
    iex> is_valid_date_range("1999-12-12", "2000-12-12")
      {:ok, {~D[1999-12-12], ~D[2000-12-12]}}
    
    iex> Helpers.General.is_valid_date_range("2999-12-12", "2000-12")
      {:error, "invalid_format 2999-12-12, 2000-12, should be YYYY-MM-DD"}
  """
  def is_valid_date_range( ds, de ) when is_string_date_range(ds, de) do
    case { Date.from_iso8601(ds), Date.from_iso8601(de)} do
      {{:ok, parsed_start}, {:ok, parsed_end} }->
        is_valid_date_range( parsed_start, parsed_end)
      _ ->
        {:error, "invalid_format #{ ds }, #{ de }, should be YYYY-MM-DD"}
    end
  end

  def is_valid_date_range(ds = %Date{}, de = %Date{})do
    case Date.compare(ds, de) do
      :eq ->
        {:ok, {ds, de}}
      :lt ->
        {:ok, {ds, de}}
      :gt ->
        {:ok, {de, ds}}
    end
  end
  
  @doc """
    Takes two dates, date_start and date_end, calculates de diference in days and returns 
    two ranges in the form of { date_start, date_middle }, {date_middle, date_end}. If the 
    difference is less than a day, it will error with: 
      {:error, "cannot split less than a day"}
    
    iex> split_date_range(~D[2017-01-01], ~D[2017-01-03])
      {:ok, [{~D[2017-01-01], ~D[2017-01-02]}, {~D[2017-01-02], ~D[2017-01-03]}]}
  """
  @spec split_date_range(date, date ) :: {:ok, list({date, date})} | {:error, String.t()}
  def split_date_range( ds, de)do
    case abs Date.diff(ds, de) do
      diff when diff <= 1 ->
        {:error, "cannot split less than a day"}
      diff_no_floor ->
        diff = Integer.floor_div( diff_no_floor, 2 )
        middle = Date.add( de, - diff )
        {:ok, [{ ds, middle }, {middle, de}]}
    end
  end

end