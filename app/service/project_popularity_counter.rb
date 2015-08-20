class ProjectPopularityCounter
  BOOST_FACTOR = 1_000
  DEFAULT_TIME_PERIOD = 45  # hours

  def adjusted_score
    return 0 if @project.age < 0  # for projects that are approved in the future

    @adjusted_score ||= (total_score * boost).round(4)
  end

  def boost
    @boost ||= BOOST_FACTOR * [1 - [Math.log(@project.age, @defaults[:time_period]), 1].min, 0.01].max * respects_per_impressions_penalty
  end

  def initialize project, defaults={}
    @project = project
    @defaults = defaults
    @defaults[:median_impressions] ||= Project.median_impressions
    @defaults[:median_respects] ||= Project.median_respects
    @defaults[:time_period] ||= DEFAULT_TIME_PERIOD
  end

  def impressions_score
    @impressions_score ||= Math.log([@project.impressions_count, 1].max, @defaults[:median_impressions])
  end

  def respects_score
    @respects_score ||= Math.log([@project.real_respects_count, 1].max, @defaults[:median_respects])
  end

  def comments_score
    @comments_score ||= Math.log([@project.comments_count, 1].max, 5)
  end

  def respects_per_impressions
    @respects_per_impressions ||= @project.real_respects_count.to_f / @project.impressions_count
  end

  def respects_per_impressions_penalty
    baseline = @defaults[:median_respects].to_f / @defaults[:median_impressions]
    @respects_per_impressions_penalty ||= [1 - [Math.log(respects_per_impressions, baseline), 1].min, 0.1].max
  end

  def total_score
    @total_score ||= respects_score + impressions_score + comments_score # + @project.featured.to_i * 10
  end
end