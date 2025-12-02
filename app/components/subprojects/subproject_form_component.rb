module Subprojects
  class SubprojectFormComponent < ViewComponent::Base
    attr_reader :project, :subproject

    def initialize(project:, subproject:)
      super()
      @project = project
      @subproject = subproject
    end
  end
end
