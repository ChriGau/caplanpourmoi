class SlotgroupsController < ApplicationController
  def new(slot)
    @slotgroup = Slotgroup.new
    @slotgroup.save
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def params_slotgroup
    params.require(:slotgroup).permit()
  end
end
