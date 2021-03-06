defmodule Resuelve.Movement do

  alias Helpers.General, as: GeneralHelpers

  @enforce_keys [ :uid, :account, :amount, :type, :description, :created_at ]
  defstruct [ :uid, :account, :amount, :type, :description, :created_at ]

  def parse_record( params ), do: GeneralHelpers.to_struct( __MODULE__, params)

end

defmodule Resuelve.MovementSummary do

  alias Resuelve.UserMovementSummary, as: UserSummary

  defstruct total_credit: 0, total_debit: 0, total_records: 0, balance: 0, by_user: %{}

  @type movement_summary :: %__MODULE__{}
  @type movement :: %Resuelve.Movement{}
  @type user :: %Resuelve.User{}
  @type user_summary :: %Resuelve.UserMovementSummary{}

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts)do
      Jason.Encode.map(Map.take(value, [:total_credit, :total_debit, :total_records, :balance, :by_user]), opts)
    end
  end

  @spec add_users_info_to_summary(movement_summary, list(user)) :: movement_summary
  def add_users_info_to_summary(summary, user_list)do
    user_list
    |> Enum.reduce( summary, &add_user_info_to_its_summary/2)
  end

  @spec has_user_summary?( movement_summary, user ) :: boolean()
  def has_user_summary?(summary, %{ uid: user_uid})do
    Map.has_key?( summary.by_user, user_uid )
  end

  @spec get_user_summary(movement_summary, user) :: user_summary
  def get_user_summary( summary, %{ uid: user_uid})do
    Map.get(summary.by_user, user_uid)
  end

  @spec add_user_info_to_its_summary( user, movement_summary ) :: movement_summary
  def add_user_info_to_its_summary( user = %{ uid: user_uid}, summary )do
    if has_user_summary?( summary, user ) do
      %{ summary | #add user info if its exits
        by_user: Map.update!( summary.by_user, user_uid, ( fn user_summary -> UserSummary.add_user_details(user_summary, user) end )) 
      }
    else 
      summary
    end
  end

  @spec summarize_movements( list(movement)) :: movement_summary
  def summarize_movements( list )do
    Enum.reduce( list, %__MODULE__{}, &add_movement_to_summary/2 )
  end

  @spec add_movement_to_summary( movement, movement_summary) :: movement_summary
  def add_movement_to_summary(movement = %{ type: "credit" }, sumary)do
    %{ sumary | 
      total_credit:  sumary.total_credit + movement.amount,
      total_records: sumary.total_records + 1,
      balance: sumary.balance + movement.amount,
      by_user: add_movement_by_user_to_summary( movement, sumary.by_user )
    }
  end

  @spec add_users_info_to_summary( movement, movement_summary ) :: movement_summary
  def add_movement_to_summary(movement = %{ type: "debit" }, sumary)do
    %{ sumary | 
      total_debit:  sumary.total_debit + movement.amount,
      total_records: sumary.total_records + 1,
      balance: sumary.balance - movement.amount,
      by_user: add_movement_by_user_to_summary( movement, sumary.by_user )
    }
  end

  @spec add_movement_by_user_to_summary( movement, map()) :: map()
  def add_movement_by_user_to_summary( movement, by_user )do
    by_user
    |> Map.update( movement.account, 
      UserSummary.new_from_initial_movement(movement),
      fn user_summary -> UserSummary.add_user_movement_to_summary( movement, user_summary ) end
       )
  end

  @spec format_summary_report( movement_summary ) :: map()
  def format_summary_report(summary)do
    %{  totalRecords: summary.total_records,
        totalCredit: summary.total_credit,
        totalDebit: summary.total_debit,
        balance: summary.balance,
        byUser: Enum.map( summary.by_user, fn {_, val} -> val end )
    }
  end

end