module TasksHelper
  def assignee_options
    User.alphabetical
  end

  def assignee_name(task)
    task.assignee&.name || "Unassigned"
  end
end
