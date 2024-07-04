# frozen_string_literal: true

module V1
  module Admin
    class CoursesController < ApplicationController
      def index
        courses = Course.all.order(:id)
        render json: ::Admin::CourseSerializer.new(courses).serializable_hash
      end

      def show
        course = Course.find(params[:id])
        render json: ::Admin::CourseSerializer.new(course).serializable_hash
      end

      def create
        course = Course.create!(course_params)
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
        params.permit(:name, :teacher_name, :description)
      end
    end
  end
end
