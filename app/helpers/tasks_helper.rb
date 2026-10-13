module TasksHelper
  def assignee_options
    User.order(:name)
  end
end
