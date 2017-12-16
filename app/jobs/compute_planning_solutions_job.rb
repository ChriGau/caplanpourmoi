class ComputePlanningSolutionsJob < ApplicationJob
  queue_as :default

  def perform(planning)
    puts "prout #{planning}"
  end
end
