module ComputeSolutionHelper

  def s_in_h(seconds)
    unless seconds.nil?
      [seconds / 3600, seconds / 60 % 60].map { |t| t.to_s.rjust(2,'0') }.join('h')
    end
  end

end
