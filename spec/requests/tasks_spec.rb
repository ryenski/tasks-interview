require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }

  before do
    post session_path, params: {session: {email: user.email, password: user.password}}
  end

  describe "GET /tasks" do
    it "lists tasks and renders the new-task form" do
      task = create(:task)

      get tasks_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(task.title)
      expect(response.parsed_body.at("form#new_task")).to be_present
    end

    it "offers to mark an incomplete task complete" do
      task = create(:task, complete: false)

      get tasks_path

      assert_select "form[action='#{task_path(task)}']" do
        assert_select "input[name='task[complete]'][value='true']"
        assert_select "button", text: "Mark complete"
      end
    end

    it "offers to mark a complete task incomplete" do
      task = create(:task, complete: true)

      get tasks_path

      assert_select "form[action='#{task_path(task)}']" do
        assert_select "input[name='task[complete]'][value='false']"
        assert_select "button", text: "Mark incomplete"
      end
    end

    it "shows each task's assignee, or Unassigned" do
      assignee = create(:user, name: "Grace Hopper")
      create(:task, assignee:)
      create(:task, assignee: nil)

      get tasks_path

      expect(response.body).to include("Grace Hopper")
      expect(response.body).to include("Unassigned")
    end

    it "loads assignees without a query per task" do
      create(:task, assignee: create(:user))
      queries_for_one_task = count_queries { get tasks_path }

      create_list(:task, 3) { |task| task.update!(assignee: create(:user)) }
      queries_for_four_tasks = count_queries { get tasks_path }

      expect(queries_for_four_tasks).to eq(queries_for_one_task)
    end

    it "keeps tasks in the order they were created after one is marked complete" do
      first_task = create(:task, title: "Book flights", created_at: 2.days.ago)
      create(:task, title: "Book hotel", created_at: 1.day.ago)
      first_task.update!(complete: true)

      get tasks_path

      expect(response.body.index("Book flights")).to be < response.body.index("Book hotel")
    end
  end

  describe "POST /tasks" do
    it "creates the task and redirects to the index" do
      expect {
        post tasks_path, params: {task: {title: "Book flights"}}
      }.to change(Task, :count).by(1)

      expect(response).to redirect_to(tasks_path)
    end

    it "assigns the task to the chosen user" do
      assignee = create(:user)

      post tasks_path, params: {task: {title: "Book flights", assignee_id: assignee.id}}

      expect(Task.last.assignee).to eq(assignee)
    end

    it "re-renders the index with errors when the assignee does not exist" do
      expect {
        post tasks_path, params: {task: {title: "Book flights", assignee_id: 0}}
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Assignee can&#39;t be blank")
    end

    it "re-renders the index with errors when the title is blank" do
      expect {
        post tasks_path, params: {task: {title: "", description: "Aisle seats"}}
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Title can&#39;t be blank")
      expect(response.body).to include("Aisle seats")
    end
  end

  describe "PATCH /tasks/:id" do
    let(:task) { create(:task, title: "Book flights") }

    it "updates the task and redirects to the index" do
      patch task_path(task), params: {task: {title: "Book hotel"}}

      expect(task.reload.title).to eq("Book hotel")
      expect(response).to redirect_to(tasks_path)
    end

    it "reassigns the task to another user" do
      task.update!(assignee: create(:user))
      new_assignee = create(:user)

      patch task_path(task), params: {task: {assignee_id: new_assignee.id}}

      expect(task.reload.assignee).to eq(new_assignee)
    end

    it "unassigns the task" do
      task.update!(assignee: create(:user))

      patch task_path(task), params: {task: {assignee_id: ""}}

      expect(task.reload.assignee).to be_nil
    end

    it "re-renders the edit form with errors when the title is blank" do
      patch task_path(task), params: {task: {title: ""}}

      expect(task.reload.title).to eq("Book flights")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Title can&#39;t be blank")
    end
  end

  describe "marking a task complete or incomplete" do
    it "marks an incomplete task complete" do
      task = create(:task, complete: false)

      patch task_path(task), params: {task: {complete: true}}

      expect(task.reload).to be_complete
      expect(response).to redirect_to(tasks_path)
    end

    it "marks a complete task incomplete" do
      task = create(:task, complete: true)

      patch task_path(task), params: {task: {complete: false}}

      expect(task.reload).not_to be_complete
      expect(response).to redirect_to(tasks_path)
    end

    it "re-renders the edit form with errors when the task has no title" do
      task = build(:task, title: "")
      task.save!(validate: false)

      patch task_path(task), params: {task: {complete: true}}

      expect(task.reload).not_to be_complete
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Title can&#39;t be blank")
    end
  end

  def count_queries(&block)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name] == "SCHEMA" }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end
end
