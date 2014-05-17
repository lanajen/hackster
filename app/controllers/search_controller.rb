class SearchController < ApplicationController

  def search
    @facets = terms = {}
    @people_label = 'People'
    @projects_label = 'Projects'
    @tools_label = 'Tools'

    if params[:q].present?
      title "Results for #{params[:q]}"
      meta_desc "Browse results for #{params[:q]}. Find tools, projects and hackers on hackster.io."
      begin
        @results = SearchRepository.new(params).search.results

        @offset = @results.offset + 1
        @max = @results.offset + @results.size
        unless @results.total_count.zero?
          title "Results for #{params[:q]} - Showing #{@offset} to #{@max} out of #{@results.total_count}"
          meta_desc = "Browse #{@results.total_count} results for #{params[:q]}. Find tools, projects and hackers on hackster.io."
          meta_desc += " Page #{params[:page]}" if params[:page] and params[:page].to_i > 1
          meta_desc meta_desc
        end

        @results.facets['type']['terms'].each do |term|
          terms[term['term']] = term['count']
        end
        @people_label += " <span class='badge pull-right'>#{terms['user']}</span>" if terms['user']
        @projects_label += " <span class='badge pull-right'>#{terms['project']}</span>" if terms['project']
        @tools_label += " <span class='badge pull-right'>#{terms['tech']}</span>" if terms['tech']

        track_event 'Searched projects', { query: params[:q], result_count: @results.total_count, type: params[:type] }
      rescue => e
        logger.error "Error while searching for #{params[:q]}: #{e.message}"
        @results = []
      end
    end
  end

  def tags
    redirect_to projects_path and return unless params[:tag].present?

    @tag = CGI::unescape params[:tag]
    title "Projects in '#{@tag}'"
    meta_desc "Explore projects tagged '#{@tag}'. Find these and other hardware projects on Hackster.io."
    params[:q] = params[:tag]
    params[:type] = 'project'
    params[:per_page] = Project.per_page
    @results = SearchRepository.new(params).search.results
    params[:per_page] = nil  # so that it doesn't appear in the URL

    track_event 'Searched projects by tag', { tag: @tag, result_count: @results.size, type: params[:type] }
  end
end