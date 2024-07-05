# frozen_string_literal: true

require "rails_helper"

RSpec.describe Course, type: :model do
  describe "#check_chapters_and_units_num" do
    subject { course.check_chapters_and_units_num }
    let(:course) { create(:course) }

    it "doesn't raise error when valid" do
      chapter = create(:chapter, course:)
      _unit = create(:unit, chapter:)

      expect { subject }.not_to raise_error
    end

    it "raises error when chapters is empty" do
      expect { subject }.to raise_error(ArgumentError, "Chapters can't be empty")
    end

    it "raises error when chapters is too much" do
      stub_const("Course::MAX_CHAPTERS_NUM", 2)
      (Course::MAX_CHAPTERS_NUM + 1).times do
        create(:chapter, course:)
      end

      expect { subject }.to raise_error(ArgumentError, "Number of chapters is at most #{Course::MAX_CHAPTERS_NUM}")
    end

    it "raises error when units is empty" do
      create(:chapter, course:)

      expect { subject }.to raise_error(ArgumentError, "Chapters units can't be empty")
    end

    it "raises error when chapters is too much" do
      stub_const("Course::MAX_UNITS_NUM", 2)
      chapter = create(:chapter, course:)
      (Course::MAX_UNITS_NUM + 1).times do
        create(:unit, chapter:)
      end

      expect do
        subject
      end.to raise_error(ArgumentError, "Number of chapters units is at most #{Course::MAX_UNITS_NUM}")
    end
  end

  describe "#set_chapters_and_units_position" do
    subject { course.set_chapters_and_units_position }
    let(:course) { create(:course) }

    it "set position of chapters and units" do
      chapter1 = course.chapters.new(name: "chapter 1")
      chapter1.units.new(name: "unit 1", content: "unit 1 content")
      chapter1.units.new(name: "unit 2", content: "unit 2 content")
      course.chapters.new(name: "chapter 2")

      subject

      expect(course.chapters[0].position).to eq(0)
      expect(course.chapters[1].position).to eq(1)
      expect(course.chapters[0].units[0].position).to eq(0)
      expect(course.chapters[0].units[1].position).to eq(1)
    end
  end
end
