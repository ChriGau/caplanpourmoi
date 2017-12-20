class ComputePlanningSolutionsJob < ApplicationJob
  queue_as :default

  def perform(planning, compute_solutions)
    calcul_instance = CalculSolutionV1.create(planning)
    calcul_instance.perform
    compute_solutions.ready!
    rescue StandardError => e
    compute_solutions.error!
    raise e
  end
end
