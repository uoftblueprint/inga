require "redcarpet"

module Seeds
  class Journals
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("journals")
        seed_journals
      end

      private

      def seed_journals
        puts "Seeding journals..."
        return if user.nil? || subprojects.empty?

        renderer = Redcarpet::Render::HTML.new(prettify: true)
        markdown = Redcarpet::Markdown.new(renderer)

        subprojects.cycle(2) do |subproject|
          Journal.create!(
            user: user,
            subproject: subproject,
            title: Faker::Lorem.sentence,
            markdown_content: markdown.render(Faker::Markdown.sandwich(sentences: 6, repeat: 3))
          )
        end
      end

      def user = User.first
      def subprojects = Subproject.all
    end
  end
end
