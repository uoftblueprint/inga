module Projects
  module Subprojects
    class LogEntriesController < ApplicationController
      LOG_ENTRY_NEW_FRAME_ID = "log_entry_new_form".freeze
      private_constant :LOG_ENTRY_NEW_FRAME_ID

      before_action :set_project_subproject

      def show
        @log_entry = @subproject.log_entries.find(params[:id])

        respond_to do |format|
          format.turbo_stream
        end
      end

      def new
        @log_entry = @subproject.log_entries.build

        respond_to do |format|
          format.html do
            return head :not_found unless log_entry_new_frame_request?

            render html: helpers.turbo_frame_tag(LOG_ENTRY_NEW_FRAME_ID) {
              view_context.render(LogEntries::FormComponent.new(project: @project, subproject: @subproject,
                                                                log_entry: @log_entry))
            }
          end
          format.turbo_stream
        end
      end

      def edit
        @log_entry = @subproject.log_entries.find(params[:id])

        respond_to do |format|
          format.html { head :not_found }
          format.turbo_stream
        end
      end

      def create
        raw_metadata = log_entry_params.fetch(:metadata, {})

        converted = {}

        @project.log_schema.each do |title, type|
          raw = raw_metadata[title]
          converted[title] = convert_by_type(type, raw)
        end

        @log_entry = @subproject.log_entries.build(metadata: converted)
        @log_entry.user = current_user

        if @log_entry.save
          redirect_to(log_entry_success_path, flash: { success: t(".success") })
        else
          respond_to do |format|
            format.html { head :not_found }
            format.turbo_stream do
              flash.now[:error] = @log_entry.errors.full_messages.to_sentence
              render :create, status: :unprocessable_entity
            end
          end
        end
      end

      def update
        @log_entry = @subproject.log_entries.find(params[:id])

        raw_metadata = log_entry_params.fetch(:metadata, {})

        converted = {}

        @project.log_schema.each do |title, type|
          raw = raw_metadata[title]
          converted[title] = convert_by_type(type, raw)
        end

        if @log_entry.update(metadata: converted)
          redirect_to(project_subproject_path(@project, @subproject), flash: { success: t(".success") })
        else
          respond_to do |format|
            format.html { head :not_found }
            format.turbo_stream do
              flash.now[:error] = @log_entry.errors.full_messages.to_sentence
              render :edit, status: :unprocessable_entity
            end
          end
        end
      end

      def destroy
        @log_entry = @subproject.log_entries.find(params[:id])

        if @log_entry.destroy
          redirect_to(project_subproject_path(@project, @subproject), flash: { success: t(".success") })
        else
          redirect_to(project_subproject_path(@project, @subproject),
                      flash: { error: @log_entry.errors.full_messages.to_sentence })
        end
      end

      private

      def set_project_subproject
        @project = Project.find(params[:project_id])
        @subproject = @project.subprojects.find(params[:subproject_id])
      end

      def log_entry_params
        permitted_metadata_keys = @project.log_schema.keys
        params.expect(log_entry: [metadata: permitted_metadata_keys])
      end

      def convert_by_type(type, raw)
        return nil if raw.blank?

        case type.to_s
        when "numerical"
          Float(raw)
        when "boolean"
          return true if raw == "on"
          return false if raw == "off"

          nil
        else
          raw
        end
      end

      def has_required_roles?
        return true if admin?

        reporter? && %w[new create].include?(action_name)
      end

      def log_entry_success_path
        return project_subproject_path(@project, @subproject) if admin?

        root_path
      end

      def log_entry_new_frame_request?
        request.headers["Turbo-Frame"] == LOG_ENTRY_NEW_FRAME_ID
      end
    end
  end
end
