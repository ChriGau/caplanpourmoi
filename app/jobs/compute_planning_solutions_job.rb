class ComputePlanningSolutionsJob < ApplicationJob
  queue_as :default

  def perform(planning)
    # Do something later

  end
end
