# frozen_string_literal: true

module V1
  module Admin
    class CoursesController < ApplicationController
      def index
        courses = Course.includes(chapters: :units)
                        .all
                        .order(id: :desc)
                        .page(params[:page]).per(params[:per_page])
        options = {
          meta: { total_pages: courses.total_pages },
          params: { hide_detail: true }
        }
        render json: ::Admin::CourseSerializer.new(courses, options).serializable_hash
      end

      def show
        course = Course.find(params[:id])
        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      def create
        course = Course.new
        course.assign_attributes(course_params)
        course.check_chapters_and_units_num
        course.set_chapters_and_units_position
        course.save!

        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      def update
        course = Course.find(params[:id])
        course.update!(course_params)
        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      def destroy
        course = Course.find(params[:id])
        course.destroy!
        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      private

      def course_params
        params.permit(
          :name, :teacher_name, :description,
          chapters_attributes: [
            :name,
            { units_attributes: %i[name description content] }
          ]
        )
      end
    end
  end
end
