module Seeds
  class Projects
    class << self
      ProjectStruct = Struct.new(:name, :description, :active, :subprojects)
      SubprojectStruct = Struct.new(:name, :description, :region)
      RegionStruct = Struct.new(:name, :latitude, :longitude)

      def run
        ActiveRecord::Base.connection.truncate_tables("projects", "subprojects", "regions")
        puts "Seeding projects, subprojects, and regions..."
        projects_data.each do |project_struct|
          create_project(project_struct)
        end
      end

      private

      def projects_data
        madagascar = RegionStruct.new("Madagascar", -18.766947, 46.869107)
        congo = RegionStruct.new("Congo", -0.228021, 15.827659)
        honduras = RegionStruct.new("Honduras", 15.200000, -86.241905)
        central_america = RegionStruct.new("Central America", 14.538829, -90.579514)

        [
          ProjectStruct.new(
            "The Homaray Project",
            "The Homaray Project, Madagascar",
            true,
            [
              SubprojectStruct.new("The Homaray Project", "The Homaray Project, Madagascar", madagascar)
            ]
          ),

          ProjectStruct.new(
            "The Chaillu Massif",
            "The Chaillu Massif, Congo",
            true,
            [
              SubprojectStruct.new("The Chaillu Massif", "The Chaillu Massif, Congo", congo)
            ]
          ),

          ProjectStruct.new(
            "Scientific Research",
            "CURLA University Demonstration Plots, Honduras",
            true,
            [
              SubprojectStruct.new("The Biological Corridor", "Long Term Research Project", honduras)
            ]
          ),

          ProjectStruct.new(
            "Land For Life Project",
            "The Cuero Valley, Honduras",
            true,
            [
              SubprojectStruct.new("Land For Life Project", "The Cuero Valley, Honduras", honduras)
            ]
          ),

          ProjectStruct.new(
            "Collaborator Projects",
            "Collaborator Projects",
            true,
            [
              SubprojectStruct.new("The Royal Botanic Gardens, Kew",
                                   "Collaborative tropical research and legume species screening", central_america),
              SubprojectStruct.new("MOPAWI", "Local collaboration in forest and agroforestry work", honduras),
              SubprojectStruct.new("EcoLogic", "Regional environmental projects and conservation", honduras)
            ]
          )
        ]
      end

      def create_project(project_struct)
        ActiveRecord::Base.transaction do
          project = Project.create!(
            name: project_struct.name,
            description: project_struct.description,
            active: project_struct.active
          )
          project_struct.subprojects.each do |subproject|
            create_subproject(project, subproject)
          end
        end
      end

      def create_subproject(project, subproject_struct)
        Subproject.create!(
          project: project,
          name: subproject_struct.name,
          description: subproject_struct.description,
          region: create_region(subproject_struct.region)
        )
      end

      def create_region(region_struct)
        Region.find_or_create_by!(name: region_struct.name) do |region|
          region.latitude = region_struct.latitude
          region.longitude = region_struct.longitude
        end
      end
    end
  end
end
