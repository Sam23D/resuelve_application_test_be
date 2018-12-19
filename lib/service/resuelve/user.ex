defmodule Resuelve.User do
  
  alias Helpers.General, as: GeneralHelpers
  
  @enforce_keys [ :nombre, :apellido, :segundo_nombre, :segundo_apellido, :uid, :email, :active, :created_at]
  defstruct [ :nombre, :apellido, :segundo_nombre, :segundo_apellido, :uid, :email, :active, :created_at]
  
  def parse_record( params ), do: GeneralHelpers.to_struct( __MODULE__, params)
end

defmodule Resuelve.UserMovementSummary do
  defstruct name: "", uid: "", records: 0, resumen: %{ balance: 0, credit: 0, debit: 0 }

  def new_from_initial_movement( movement )do
    add_user_movement_to_summary(movement, %__MODULE__{})
  end

  def add_user_details(user_summary, user)do
    %{ user_summary |
      name: user.nombre 
    }
  end

  def add_user_movement_to_summary( movement, %{ uid: "" } = user_summary )do
    %{ user_summary | 
      uid: movement.account,
      records: user_summary.records + 1,
      resumen: add_user_movement_to_user_resumen( movement, user_summary.resumen )
    }
  end

  def add_user_movement_to_summary( movement, user_summary )do
    %{ user_summary | 
      records: user_summary.records + 1,
      resumen: add_user_movement_to_user_resumen( movement, user_summary.resumen )
    }
  end

  def add_user_movement_to_user_resumen( movement = %{ type: "debit" }, resumen )do
    resumen
    |> Map.update( :balance, 0, &(&1 - movement.amount ))
    |> Map.update( :debit, 0, &(&1 + movement.amount ))
  end

  def add_user_movement_to_user_resumen( movement = %{ type: "credit" }, resumen )do
    resumen
    |> Map.update( :balance, 0, &(&1 + movement.amount ))
    |> Map.update( :credit, 0, &(&1 + movement.amount ))
  end
  
end