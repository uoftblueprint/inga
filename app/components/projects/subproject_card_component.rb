module Projects
  class SubprojectCardComponent < ViewComponent::Base
    attr_reader :subproject

    def initialize(subproject:)
      super()
      @subproject = subproject
    end

    def subproject_path = project_subproject_path(@subproject.project, @subproject)
  end
end
