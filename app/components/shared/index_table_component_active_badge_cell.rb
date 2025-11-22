module Shared
  class IndexTableComponentActiveBadgeCell < IndexTableComponentCell
    erb_template <<-ERB
      <%= render ::BadgeComponent.new(text: active? ? 'Active' : 'Inactive', colour: active? ? :success : :error) %>
    ERB

    delegate :active?, to: :record
  end
end
