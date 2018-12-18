defmodule Resuelve.Movement do
  @enforce_keys [ :uid, :accounnt, :amount, :type, :description, :created_at ]
  defstruct [ :uid, :accounnt, :amount, :type, :description, :created_at ]
end