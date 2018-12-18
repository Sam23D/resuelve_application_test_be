defmodule ResuelveBe.Guards do

  defguard is_string_date_range( ds, de) when is_bitstring( ds ) and is_bitstring( de )
end