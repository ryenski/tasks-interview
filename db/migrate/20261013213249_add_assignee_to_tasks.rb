class AddAssigneeToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :assignee, foreign_key: {to_table: :users, on_delete: :nullify}
  end
end
