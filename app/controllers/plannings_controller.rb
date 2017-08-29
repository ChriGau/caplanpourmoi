class PlanningsController < ApplicationController
  def index
    @plannings = Planning.all
    @roles = Role.all
    @users = User.all
  end

  def show
    @planning = Planning.find(params[:id])
    @slots = @planning.slots
    @slot = Slot.new
    @slot_templates = Slot.slot_templates
  end
end
