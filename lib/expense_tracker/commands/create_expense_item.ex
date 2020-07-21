defmodule ExpenseTracker.Commands.CreateExpenseItem do
  defstruct [:expense_item_id, :budget_id, :description, :amount]

  def assign_id(%__MODULE__{} = command, id), do: %__MODULE__{command | expense_item_id: id}

end

defimpl ExpenseTracker.Protocol.ValidCommand, for: ExpenseTracker.Commands.CreateExpenseItem do
  alias ExpenseTracker.Validators.{StringValidator, Uuid}

  def validate(%{expense_item_id: expense_item_id, budget_id: budget_id} = command) do
    expense_item_id
    |> validate_expense_item_id
    |> Kernel.++(validate_budget_id(budget_id))
    |> Kernel.++(validate_amount(command.amount))
    |> Kernel.++(validate_description(command.description))
    |> case do
      []       -> :ok
      err_list -> {:error, err_list}
    end
  end

  defp validate_expense_item_id(expense_item_id) do
    case Uuid.validate(expense_item_id) do
      :ok           -> []
      {:error, err} -> [{:expense_item_id, err}]
    end
  end

  defp validate_budget_id(budget_id) do
    case Uuid.validate(budget_id) do
      :ok           -> []
      {:error, err} -> [{:budget_id, err}]
    end
  end

  defp validate_description(nil), do: [{:description, "is not a string"}]

  defp validate_description(""), do: []

  defp validate_description(description) do
    case StringValidator.validate(description) do
      :ok           -> []
      {:error, err} -> [{:description, err}]
    end
  end

  defp validate_amount(x) when is_integer(x) and x > 0, do: []

  defp validate_amount(_), do: [{:amount, "is not a valid amount"}]

end