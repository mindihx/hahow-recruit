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

    it "raises error when no chapters" do
      expect { subject }.to raise_error(ArgumentError, "Chapters can't be empty")
    end

    it "raises error when too many chapters" do
      stub_const("Course::MAX_CHAPTERS_NUM", 2)
      (Course::MAX_CHAPTERS_NUM + 1).times do
        create(:chapter, course:)
      end

      expect { subject }.to raise_error(ArgumentError, "Number of chapters is at most #{Course::MAX_CHAPTERS_NUM}")
    end

    it "raises error when no units" do
      create(:chapter, course:)

      expect { subject }.to raise_error(ArgumentError, "Chapters units can't be empty")
    end

    it "raises error when too many units" do
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
end
