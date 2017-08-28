class PlanningsController < ApplicationController

  def index
    @plannings = Planning.all
    @roles = Role.all
    @users = User.all
  end

  def show
    @planning = Planning.find(params[:id])
    @roles = Role.all
    @slot = Slot.new
    @users = User.all
  end


end
