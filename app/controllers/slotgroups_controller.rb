class SlotgroupsController < ApplicationController
  def new(slot)
    @slotgroup = Slotgroup.new
    @slotgroup.start = slot.start_at
    @slotgroup.end = slot.end_at
    @slotgroup.role_id = slot.role_id
    @slotgroup.save
  end

  def create(slots)
    slots.each do |slot,i|
      if i == 0 # 1st iteration => create slotgroup
        @slotgroup = Slotgroup.new(slot)
      else
        # slotgroup exists already?
        if Slotgroup.find_by(start: slot.start_at, end: slot.end_at, role_id: slot.role_id).nil?
          @slotgroup = Slotgroup.new(slot)
        end
      end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def params_slotgroup
    params.require(:slotgroup).permit(:start, :end, :role_id)
  end
end
