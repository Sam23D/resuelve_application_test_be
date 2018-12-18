defmodule Resuelve.User do
  @enforce_keys [ :nombre, :apellido, :segundo_nombre, :segundo_apellido, :uid, :email, :active, :created_at]
  defstruct [ :nombre, :apellido, :segundo_nombre, :segundo_apellido, :uid, :email, :active, :created_at]
end