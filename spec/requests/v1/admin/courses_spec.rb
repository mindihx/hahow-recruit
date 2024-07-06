# frozen_string_literal: true

require "rails_helper"
require "support/common_helper"

RSpec.describe type: :request do
  include CommonHelper

  describe "#index" do
    let(:index_path) { "/api/v1/admin/courses" }

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

      get index_path

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

      get index_path, params: { per_page: 2 }

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

      get index_path, params: { page: 2, per_page: 3 }

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
    let(:show_path) { "/api/v1/admin/courses/#{course_id}" }
    let(:course) do
      create(
        :course,
        name: "course name", teacher_name: "teacher name", description: "course description"
      )
    end
    let(:course_id) { course.id }

    it "gets course" do
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

      get show_path

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

    context "when course id is invalid" do
      let(:course_id) { next_id(Course) }

      it "responds error when course not found" do
        get show_path

        expect(response).to have_http_status(:not_found)
        expect(response_error_message).to include("Couldn't find Course")
      end
    end
  end

  describe "#create" do
    let(:create_path) { "/api/v1/admin/courses" }

    it "creates course, chapters and units" do
      post_as_json create_path, params: {
        name: "course name",
        teacher_name: "teacher name",
        description: "course description",
        chapters_attributes: [
          {
            name: "chapter 1",
            units_attributes: [
              {
                name: "unit 1",
                description: "unit 1 description",
                content: "unit 1 content"
              },
              {
                name: "unit 2",
                description: "unit 2 description",
                content: "unit 2 content"
              }
            ]
          },
          {
            name: "chapter 2",
            units_attributes: [
              {
                name: "unit 1",
                content: "unit 1 content"
              }
            ]
          }
        ]
      }

      course = Course.last
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
                  id: course.chapters[0].id.to_s,
                  attributes: {
                    name: "chapter 1",
                    units: [
                      {
                        id: course.chapters[0].units[0].id.to_s,
                        attributes: {
                          name: "unit 1",
                          description: "unit 1 description",
                          content: "unit 1 content"
                        }
                      },
                      {
                        id: course.chapters[0].units[1].id.to_s,
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
                  id: course.chapters[1].id.to_s,
                  attributes: {
                    name: "chapter 2",
                    units: [
                      {
                        id: course.chapters[1].units[0].id.to_s,
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
      expect(course.chapters[0].position).to eq(0)
      expect(course.chapters[1].position).to eq(1)
      expect(course.chapters[0].units[0].position).to eq(0)
      expect(course.chapters[0].units[1].position).to eq(1)
    end

    it "responds error when name is blank" do
      post_as_json create_path, params: {
        teacher_name: "teacher name",
        chapters_attributes: [
          {
            units_attributes: [
              {
                content: "unit 1 content"
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:bad_request)
      error_message = response_error_message
      expect(error_message).to include("Name can't be blank")
      expect(error_message).to include("Chapters name can't be blank")
      expect(error_message).to include("Chapters units name can't be blank")
    end

    it "responds error when chapters is empty" do
      post_as_json create_path, params: {
        name: "course name",
        teacher_name: "teacher name",
        description: "course description"
      }

      expect(response).to have_http_status(:bad_request)
      expect(response_error_message).to include("Chapters can't be empty")
    end
  end

  describe "#update" do
    let(:update_path) { "/api/v1/admin/courses/#{course.id}" }
    let(:course) { create(:course, name: "course 1") }

    it "updates course, chapters and units" do
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit1_of_chapter1 = create(:unit, chapter: chapter1, position: 0, name: "unit 1")
      unit2_of_chapter1 = create(:unit, chapter: chapter1, position: 1, name: "unit 2")
      chapter2 = create(:chapter, course:, position: 1, name: "chapter 2")
      unit1_of_chapter2 = create(:unit, chapter: chapter2, name: "unit 1")

      patch_as_json update_path, params: {
        name: "new course 1",
        chapters_attributes: [
          {
            id: chapter1.id,
            name: "new chapter 1",
            units_attributes: [
              {
                id: unit1_of_chapter1.id,
                name: "unit 1"
              },
              {
                id: unit2_of_chapter1.id,
                name: "new unit 2"
              }
            ]
          },
          {
            id: chapter2.id,
            name: "chapter 2",
            units_attributes: [
              {
                id: unit1_of_chapter2.id,
                name: "new unit 1"
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              name: "new course 1",
              chapters: [
                {
                  id: chapter1.id.to_s,
                  attributes: {
                    name: "new chapter 1",
                    units: [
                      {
                        id: unit1_of_chapter1.id.to_s,
                        attributes: {
                          name: "unit 1"
                        }
                      },
                      {
                        id: unit2_of_chapter1.id.to_s,
                        attributes: {
                          name: "new unit 2"
                        }
                      }
                    ]
                  }
                },
                {
                  id: chapter2.id.to_s,
                  attributes: {
                    name: "chapter 2",
                    units: [
                      {
                        id: unit1_of_chapter2.id.to_s,
                        attributes: {
                          name: "new unit 1"
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
      expect(course.reload.name).to eq("new course 1")
      expect(chapter1.reload.name).to eq("new chapter 1")
      expect(unit2_of_chapter1.reload.name).to eq("new unit 2")
      expect(unit1_of_chapter2.reload.name).to eq("new unit 1")
    end

    it "adds chapters and units" do
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit2_of_chapter1 = create(:unit, chapter: chapter1, position: 0, name: "unit 2")
      unit4_of_chapter1 = create(:unit, chapter: chapter1, position: 1, name: "unit 4")
      chapter3 = create(:chapter, course:, position: 1, name: "chapter 3")
      unit1_of_chapter3 = create(:unit, chapter: chapter3, name: "unit 1")

      patch_as_json update_path, params: {
        chapters_attributes: [
          {
            id: chapter1.id,
            units_attributes: [
              {
                name: "unit 1",
                content: "unit 1 content"
              },
              {
                id: unit2_of_chapter1.id
              },
              {
                name: "unit 3",
                content: "unit 3 content"
              },
              {
                id: unit4_of_chapter1.id
              },
              {
                name: "unit 5",
                content: "unit 5 content"
              }
            ]
          },
          {
            name: "chapter 2",
            units_attributes: [
              {
                name: "unit 1",
                content: "unit 1 content"
              }
            ]
          },
          {
            id: chapter3.id,
            units_attributes: [
              {
                id: unit1_of_chapter3.id
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              chapters: [
                {
                  id: chapter1.id.to_s,
                  attributes: {
                    units: [
                      {
                        attributes: {
                          name: "unit 1"
                        }
                      },
                      {
                        id: unit2_of_chapter1.id.to_s,
                        attributes: {
                          name: "unit 2"
                        }
                      },
                      {
                        attributes: {
                          name: "unit 3"
                        }
                      },
                      {
                        id: unit4_of_chapter1.id.to_s,
                        attributes: {
                          name: "unit 4"
                        }
                      },
                      {
                        attributes: {
                          name: "unit 5"
                        }
                      }
                    ]
                  }
                },
                {
                  attributes: {
                    name: "chapter 2",
                    units: [
                      {
                        attributes: {
                          name: "unit 1"
                        }
                      }
                    ]
                  }
                },
                {
                  id: chapter3.id.to_s,
                  attributes: {
                    name: "chapter 3",
                    units: [
                      {
                        id: unit1_of_chapter3.id.to_s,
                        attributes: {
                          name: "unit 1"
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
      expect(course.chapters.size).to eq(3)
      expect(course.chapters[0].units.size).to eq(5)
      expect(chapter3.reload.position).to eq(2)
      expect(unit2_of_chapter1.reload.position).to eq(1)
      expect(unit4_of_chapter1.reload.position).to eq(3)
    end

    it "deletes chapters and units" do
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit1_of_chapter1 = create(:unit, chapter: chapter1, position: 0, name: "unit 1")
      unit2_of_chapter1 = create(:unit, chapter: chapter1, position: 1, name: "unit 2")
      chapter2 = create(:chapter, course:, position: 1, name: "chapter 2")
      unit1_of_chapter2 = create(:unit, chapter: chapter2, name: "unit 1")
      chapter3 = create(:chapter, course:, position: 2, name: "chapter 3")
      unit1_of_chapter3 = create(:unit, chapter: chapter3, name: "unit 1")

      patch_as_json update_path, params: {
        chapters_attributes: [
          {
            id: chapter1.id,
            units_attributes: [
              {
                id: unit1_of_chapter1.id,
                _destroy: true
              },
              {
                id: unit2_of_chapter1.id
              }
            ]
          },
          {
            id: chapter2.id,
            _destroy: true,
            units_attributes: [
              {
                id: unit1_of_chapter2.id
              }
            ]
          },
          {
            id: chapter3.id,
            units_attributes: [
              {
                id: unit1_of_chapter3.id
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              chapters: [
                {
                  id: chapter1.id.to_s,
                  attributes: {
                    units: [
                      {
                        id: unit2_of_chapter1.id.to_s
                      }
                    ]
                  }
                },
                {
                  id: chapter3.id.to_s,
                  attributes: {
                    units: [
                      {
                        id: unit1_of_chapter3.id.to_s
                      }
                    ]
                  }
                }
              ]
            }
          }
        }
      )
      expect(course.chapters.size).to eq(2)
      expect(course.chapters[0].units.size).to eq(1)
      expect(Chapter.find_by(id: chapter2.id)).to eq(nil)
      expect(Unit.find_by(id: unit1_of_chapter1.id)).to eq(nil)
      expect(Unit.find_by(id: unit1_of_chapter2.id)).to eq(nil)
      expect(chapter3.reload.position).to eq(1)
      expect(unit2_of_chapter1.reload.position).to eq(0)
    end

    it "updates, adds, deletes chapters and units" do
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit1_of_chapter1 = create(:unit, chapter: chapter1, position: 0, name: "unit 1")
      unit2_of_chapter1 = create(:unit, chapter: chapter1, position: 1, name: "unit 2")

      patch_as_json update_path, params: {
        chapters_attributes: [
          {
            id: chapter1.id,
            name: "new chapter 1",
            units_attributes: [
              {
                id: unit1_of_chapter1.id,
                _destroy: true
              },
              {
                id: unit2_of_chapter1.id,
                name: "new unit 2"
              },
              {
                name: "unit 3",
                content: "unit 3 content"
              }
            ]
          },
          {
            name: "chapter 2",
            units_attributes: [
              {
                name: "unit 1",
                content: "unit 1 content"
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s,
            attributes: {
              chapters: [
                {
                  id: chapter1.id.to_s,
                  attributes: {
                    name: "new chapter 1",
                    units: [
                      {
                        id: unit2_of_chapter1.id.to_s,
                        attributes: {
                          name: "new unit 2"
                        }
                      },
                      {
                        attributes: {
                          name: "unit 3"
                        }
                      }
                    ]
                  }
                },
                {
                  attributes: {
                    name: "chapter 2",
                    units: [
                      {
                        attributes: {
                          name: "unit 1"
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
      expect(chapter1.reload.name).to eq("new chapter 1")
      expect(unit2_of_chapter1.reload).to have_attributes(
        name: "new unit 2",
        position: 0
      )
      expect(course.chapters.size).to eq(2)
      expect(course.chapters[0].units.size).to eq(2)
    end

    it "responds error when add too much chapters" do
      stub_const("Course::MAX_CHAPTERS_NUM", 2)
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit1_of_chapter1 = create(:unit, chapter: chapter1, position: 0, name: "unit 1")

      patch_as_json update_path, params: {
        chapters_attributes: [
          {
            id: chapter1.id,
            units_attributes: [
              {
                id: unit1_of_chapter1.id
              }
            ]
          },
          {
            name: "chapter 2",
            units_attributes: [
              {
                name: "unit 1",
                content: "unit 1 content"
              }
            ]
          },
          {
            name: "chapter 3",
            units_attributes: [
              {
                name: "unit 1",
                content: "unit 1 content"
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:bad_request)
      expect(response_error_message).to include("Number of chapters is at most 2")
    end

    it "responds error when delete all units in chapter" do
      chapter1 = create(:chapter, course:, position: 0, name: "chapter 1")
      unit1_of_chapter1 = create(:unit, chapter: chapter1, position: 0, name: "unit 1")
      unit2_of_chapter1 = create(:unit, chapter: chapter1, position: 1, name: "unit 2")

      patch_as_json update_path, params: {
        chapters_attributes: [
          {
            id: chapter1.id,
            units_attributes: [
              {
                id: unit1_of_chapter1.id,
                _destroy: true
              },
              {
                id: unit2_of_chapter1.id,
                _destroy: true
              }
            ]
          }
        ]
      }

      expect(response).to have_http_status(:bad_request)
      expect(response_error_message).to include("Chapters units can't be empty")
    end
  end

  describe "#destroy" do
    let(:destroy_path) { "/api/v1/admin/courses/#{course_id}" }
    let(:course) { create(:course) }
    let(:course_id) { course.id }

    it "deletes course" do
      chapter = create(:chapter, course:)
      unit = create(:unit, chapter:)

      delete destroy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include_json(
        {
          data: {
            id: course.id.to_s
          }
        }
      )
      expect(Course.find_by(id: course.id)).to eq(nil)
      expect(Chapter.find_by(id: chapter.id)).to eq(nil)
      expect(Unit.find_by(id: unit.id)).to eq(nil)
    end

    context "when course id is invalid" do
      let(:course_id) { next_id(Course) }

      it "responds error when course not found" do
        delete destroy_path

        expect(response).to have_http_status(:not_found)
        expect(response_error_message).to include("Couldn't find Course")
      end
    end
  end
end
