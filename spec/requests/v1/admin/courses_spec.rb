# frozen_string_literal: true

require "rails_helper"

RSpec.describe type: :request do
  describe "#index" do
    it "lists courses" do
      course1 = create(:course)
      course2 = create(:course)

      get v1_admin_courses_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: [
            {
              id: course1.id.to_s
            },
            {
              id: course2.id.to_s
            }
          ]
        }
      )
      json_body = JSON.parse(response.body, symbolize_names: true)
      expect(json_body[:data].size).to eq(2)
    end
  end

  describe "#show" do
    it "gets course" do
      course = create(:course)

      get v1_admin_course_url(course.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s
          }
        }
      )
    end
  end

  describe "#create" do
    it "creates course" do
      post v1_admin_courses_url(
        params: {
          name: "course name",
          teacher_name: "teacher name",
          description: "course description"
        }
      )

      course = Course.last
      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              name: "course name",
              teacher_name: "teacher name",
              description: "course description"
            }
          }
        }
      )
    end
  end

  describe "#update" do
    it "updates course" do
      course = create(
        :course,
        name: "old name", teacher_name: "old teacher name", description: "old description"
      )

      patch v1_admin_course_url(
        course.id,
        params: {
          name: "new name",
          teacher_name: "new teacher name",
          description: "new description"
        }
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              name: "new name",
              teacher_name: "new teacher name",
              description: "new description"
            }
          }
        }
      )
      expect(course.reload).to have_attributes(
        name: "new name",
        teacher_name: "new teacher name",
        description: "new description"
      )
    end
  end

  describe "#destroy" do
    it "deletes course" do
      course = create(:course)

      delete v1_admin_course_url(course.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s
          }
        }
      )
      expect(Course.find_by(id: course.id)).to eq(nil)
    end
  end
end
