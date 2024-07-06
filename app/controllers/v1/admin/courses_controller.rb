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
        course.assign_attributes(create_params)
        course.check_chapters_and_units_num
        course.save!

        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      def update
        course = Course.find(params[:id])
        course.assign_attributes(update_params)
        course.check_chapters_and_units_num
        course.save!

        course = Course.includes(chapters: :units).find(params[:id])
        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      def destroy
        course = Course.find(params[:id])
        course.destroy!
        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      private

      def create_params
        to_create = params.permit(
          :name, :teacher_name, :description,
          chapters_attributes: [
            :name,
            { units_attributes: %i[name description content] }
          ]
        )
        update_position(to_create)
        to_create
      end

      def update_params
        to_update = params.permit(
          :name, :teacher_name, :description,
          chapters_attributes: [
            :id, :name, :_destroy,
            { units_attributes: %i[id name description content _destroy] }
          ]
        )
        update_position(to_update)
        to_update
      end

      # rubocop:disable Metrics/MethodLength
      def update_position(attributes)
        return unless attributes[:chapters_attributes]

        chapter_idx = 0
        attributes[:chapters_attributes].each do |chapter_attributes|
          next if chapter_attributes[:_destroy]

          chapter_attributes[:position] = chapter_idx
          chapter_idx += 1
          next unless chapter_attributes[:units_attributes]

          unit_idx = 0
          chapter_attributes[:units_attributes].each do |unit_attributes|
            next if unit_attributes[:_destroy]

            unit_attributes[:position] = unit_idx
            unit_idx += 1
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
