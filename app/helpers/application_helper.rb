module ApplicationHelper
  def fetch_roles
    Role.all.order(:name)
  end
end
