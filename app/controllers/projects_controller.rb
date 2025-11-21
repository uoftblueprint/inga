class ProjectsController < ApplicationController
    def new
        @project = Project.new
    end

    def create
        @project = Project.new(new_params)
        @project.active = true

        if @project.save
            redirect_to(@project, notice: "Project was successfully created.")
        else
            flash.now[:error] = "Failed to create project."
            render :new, status: :unprocessable_entity
        end
    end

    private

    def new_params
        params.require(:project).permit(:name, :description)
    end

    def has_required_roles? = true
end
