class MakeTasksCompleteDefaultFalse < ActiveRecord::Migration[8.1]
  def change
    change_column_default :tasks, :complete, from: nil, to: false
    change_column_null :tasks, :complete, false, false
  end
end
