defmodule ExpenseTracker.Aggregates.ExpenseItem do
  defstruct [:id, :budget_id, :description, :amount, deleted: false]

  alias ExpenseTracker.Commands.{CreateExpenseItem, DeleteExpenseItem}
  alias ExpenseTracker.Events.{ExpenseItemCreated, ExpenseItemDeleted}

  @behaviour Commanded.Aggregates.AggregateLifespan


  def after_event(%ExpenseItemDeleted{}), do: 5_000
  def after_event(_), do: :hibernate

  def after_command(_command), do: :infinity
  def after_error(_error), do: :stop


  def execute(%__MODULE__{}, %CreateExpenseItem{} = c) do
    %ExpenseItemCreated{
      expense_item_id: c.expense_item_id,
      budget_id: c.budget_id,
      description: c.description,
      amount: c.amount
    }
  end

  def execute(%__MODULE__{id: id}, %DeleteExpenseItem{}), do: %ExpenseItemDeleted{expense_item_id: id}


  def apply(%__MODULE__{} = expense_item, %ExpenseItemCreated{} = e) do
    %__MODULE__{expense_item |
      id: e.expense_item_id,
      budget_id: e.budget_id,
      description: e.description,
      amount: e.amount
    }
  end

  def apply(%__MODULE__{} = expense_item, %ExpenseItemDeleted{}) do
    %__MODULE__{expense_item | deleted: true}
  end
end