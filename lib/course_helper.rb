module CourseHelper
  def self.fitted_completion_from_real( real_completion )
    x = real_completion/4.0
    # y = = -0.106x2 + 6.3576x + 7.1264
    y = [7, (-0.106*(x**2) + 6.3576*x + 7.1264).ceil].max
    # Do not go over 100
    [100, y].min
  end
end