class SimilarProjectsFinder
  def initialize project
    @project = project
  end

  def results
    return @results if @results

    # same platforms + components
    # joins = []
    # @project.visible_platforms.pluck(:id).each_with_index do |id, i|
    #   joins << "INNER JOIN project_collections AS pc#{i} ON projects.id = pc#{i}.project_id AND pc#{i}.collectable_type = 'Group' AND pc#{i}.collectable_id = #{id}"
    # end
    # @results = @results.joins(joins.join(' '))

    # same skill level
    # same author
    # same tags
    # respected by same people

    # base
    @results = Project.where.not(id: @project.id)

    # filter
    @results = @results.joins(:project_collections).where(project_collections: { collectable_id: @project.visible_platforms.pluck(:id), collectable_type: 'Group' })
    @results = @results.where(difficulty: @project.difficulty)

    # sort
    @results = @results.uniq.magic_sort.limit(6)
  end
end