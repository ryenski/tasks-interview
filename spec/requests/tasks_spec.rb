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
  end

  describe "POST /tasks" do
    it "creates the task and redirects to the index" do
      expect {
        post tasks_path, params: {task: {title: "Book flights"}}
      }.to change(Task, :count).by(1)

      expect(response).to redirect_to(tasks_path)
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

  describe "GET /tasks" do
    it "offers to mark each task complete or incomplete" do
      create(:task, complete: false)
      create(:task, complete: true)

      get tasks_path

      expect(response.body).to include("Mark complete")
      expect(response.body).to include("Mark incomplete")
    end
  end
end
