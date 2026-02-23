module Reports
  class MarqueeComponent < ViewComponent::Base
    renders_many :slides
  end
end
