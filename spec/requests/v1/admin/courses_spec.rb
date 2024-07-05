# frozen_string_literal: true

require "rails_helper"
require "support/common_helper"

RSpec.describe type: :request do
  include CommonHelper

  describe "#index" do
    it "lists courses" do
      course1 = create(:course)
      chapter1_of_course1 = create(:chapter, course: course1, position: 0)
      unit1_of_chapter1 = create(:unit, chapter: chapter1_of_course1, position: 0)
      unit2_of_chapter1 = create(:unit, chapter: chapter1_of_course1, position: 1)
      chapter2_of_course1 = create(:chapter, course: course1, position: 1)
      unit1_of_chapter2 = create(:unit, chapter: chapter2_of_course1)
      course2 = create(:course, description: "course2 description")
      chapter3_of_course2 = create(:chapter, course: course2)
      unit1_of_chapter3 = create(:unit, chapter: chapter3_of_course2)

      get v1_admin_courses_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: [
            {
              id: course2.id.to_s,
              attributes: {
                name: course2.name,
                chapters: [
                  {
                    id: chapter3_of_course2.id.to_s,
                    attributes: {
                      name: chapter3_of_course2.name,
                      units: [
                        {
                          id: unit1_of_chapter3.id.to_s,
                          attributes: {
                            name: unit1_of_chapter3.name
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            },
            {
              id: course1.id.to_s,
              attributes: {
                name: course1.name,
                chapters: [
                  {
                    id: chapter1_of_course1.id.to_s,
                    attributes: {
                      name: chapter1_of_course1.name,
                      units: [
                        {
                          id: unit1_of_chapter1.id.to_s,
                          attributes: {
                            name: unit1_of_chapter1.name
                          }
                        },
                        {
                          id: unit2_of_chapter1.id.to_s,
                          attributes: {
                            name: unit2_of_chapter1.name
                          }
                        }
                      ]
                    }
                  },
                  {
                    id: chapter2_of_course1.id.to_s,
                    attributes: {
                      name: chapter2_of_course1.name,
                      units: [
                        {
                          id: unit1_of_chapter2.id.to_s,
                          attributes: {
                            name: unit1_of_chapter2.name
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ]
        }
      )
      json_body = json_body()
      expect(json_body[:data].size).to eq(2)
      expect(json_body.dig(:data, 0, :attributes).key?(:description)).to eq(false)
    end

    it "paginates courses with per_page" do
      courses = 5.times.map { create(:course) }

      get v1_admin_courses_url(params: { per_page: 2 })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: [
            {
              id: courses[4].id.to_s
            },
            {
              id: courses[3].id.to_s
            }
          ],
          meta: {
            total_pages: 3
          }
        }
      )
      expect(json_body[:data].size).to eq(2)
    end

    it "paginates courses with page and per_page" do
      courses = 5.times.map { create(:course) }

      get v1_admin_courses_url(params: { page: 2, per_page: 3 })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: [
            {
              id: courses[1].id.to_s
            },
            {
              id: courses[0].id.to_s
            }
          ],
          meta: {
            total_pages: 2
          }
        }
      )
      expect(json_body[:data].size).to eq(2)
    end
  end

  describe "#show" do
    it "gets course" do
      course = create(
        :course,
        name: "course name", teacher_name: "teacher name", description: "course description"
      )
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit1_of_chapter1 = create(
        :unit,
        chapter: chapter1, position: 0,
        name: "unit 1", description: "unit 1 description", content: "unit 1 content"
      )
      unit2_of_chapter1 = create(
        :unit,
        chapter: chapter1, position: 1,
        name: "unit 2", description: "unit 2 description", content: "unit 2 content"
      )
      chapter2 = create(:chapter, course:, position: 1, name: "chapter 2")
      unit1_of_chapter2 = create(
        :unit,
        chapter: chapter2,
        name: "unit 1", content: "unit 1 content"
      )

      get v1_admin_course_url(course.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              name: "course name",
              teacher_name: "teacher name",
              description: "course description",
              chapters: [
                {
                  id: chapter1.id.to_s,
                  attributes: {
                    name: "chapter 1",
                    units: [
                      {
                        id: unit1_of_chapter1.id.to_s,
                        attributes: {
                          name: "unit 1",
                          description: "unit 1 description",
                          content: "unit 1 content"
                        }
                      },
                      {
                        id: unit2_of_chapter1.id.to_s,
                        attributes: {
                          name: "unit 2",
                          description: "unit 2 description",
                          content: "unit 2 content"
                        }
                      }
                    ]
                  }
                },
                {
                  id: chapter2.id.to_s,
                  attributes: {
                    name: chapter2.name,
                    units: [
                      {
                        id: unit1_of_chapter2.id.to_s,
                        attributes: {
                          name: "unit 1",
                          description: nil,
                          content: "unit 1 content"
                        }
                      }
                    ]
                  }
                }
              ]
            }
          }
        }
      )
    end

    it "responds error when course not found" do
      get v1_admin_course_url(next_id(Course))

      expect(response).to have_http_status(:not_found)
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
