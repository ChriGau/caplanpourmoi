class ComputePlanningSolutionsJob < ApplicationJob
  queue_as :default

  def perform(planning, compute_solution)
    calcul_instance = CalculSolutionV1.create(planning)
    calcul_instance.compute_solution = compute_solution
    calcul_instance.perform(compute_solution)
    compute_solution.ready!
    rescue StandardError => e
    compute_solution.error!
    raise e
  end
end
