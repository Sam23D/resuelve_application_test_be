defmodule Resuelve.Movement do

  alias Helpers.General, as: GeneralHelpers

  @enforce_keys [ :uid, :account, :amount, :type, :description, :created_at ]
  defstruct [ :uid, :account, :amount, :type, :description, :created_at ]

  def parse_record( params ), do: GeneralHelpers.to_struct( __MODULE__, params)

end

defmodule Resuelve.MovementSummary do

  alias Resuelve.UserMovementSummary, as: UserSummary

  defstruct total_credit: 0, total_debit: 0, total_records: 0, balance: 0, by_user: %{}

  def add_user_info_to_summary(summary, user_list)do
    user_list
    |> Enum.reduce( summary, &add_user_info_to_summary/2)
  end

  def summarize_movements( list )do
    Enum.reduce( list, %__MODULE__{}, &add_movement_to_summary/2 )
  end

  def add_movement_to_summary(movement = %{ type: "credit" }, sumary)do
    %{ sumary | 
      total_credit:  sumary.total_credit + movement.amount,
      total_records: sumary.total_records + 1,
      balance: sumary.balance + movement.amount,
      by_user: add_movement_by_user_to_summary( movement, sumary.by_user )
    }
  end

  def add_movement_to_summary(movement = %{ type: "debit" }, sumary)do
    %{ sumary | 
      total_debit:  sumary.total_debit + movement.amount,
      total_records: sumary.total_records + 1,
      balance: sumary.balance - movement.amount,
      by_user: add_movement_by_user_to_summary( movement, sumary.by_user )
    }
  end

  def add_movement_by_user_to_summary( movement, by_user )do
    by_user
    |> Map.update( movement.account, 
      UserSummary.new_from_initial_movement(movement),
      fn user_summary -> UserSummary.add_user_movement_to_summary( movement, user_summary ) end
       )
  end
  # THIS SHIT DOES NOT WORK FIX IT
  def add_user_info_to_summary( user, %{ by_user: by_user } = summary )do
    Map.update!( by_user, user.uid, &UserSummary.add_user_details/2 )
  end

end