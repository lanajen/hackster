class SearchController < ApplicationController

  def search
    @facets = terms = {}
    @hacker_space_label = 'Hacker spaces'
    @people_label = 'People'
    @projects_label = 'Projects'
    @platforms_label = 'Platforms'

    if params[:q].present?
      title "Results for #{params[:q]}"
      meta_desc "Browse results for #{params[:q]}. Find platforms, projects and hackers on hackster.io."
      begin
        @results = SearchRepository.new(params).search.results

        @offset = @results.offset + 1
        @max = @results.offset + @results.size
        unless @results.total_count.zero?
          title "Results for #{params[:q]} - Showing #{@offset} to #{@max} out of #{@results.total_count}"
          meta_desc = "Browse #{@results.total_count} results for #{params[:q]}. Find platforms, projects and hackers on #{site_name}."
          meta_desc += " Page #{safe_page_params}" if safe_page_params and safe_page_params.to_i > 1
          meta_desc meta_desc
        end

        @results.facets['type']['terms'].each do |term|
          terms[term['term']] = term['count']
        end
        @hacker_space_label += " <span class='badge pull-right'>#{terms['hackerspace']}</span>" if terms['hackerspace']
        @people_label += " <span class='badge pull-right'>#{terms['user']}</span>" if terms['user']
        @projects_label += " <span class='badge pull-right'>#{terms['project']}</span>" if terms['project']
        @platforms_label += " <span class='badge pull-right'>#{terms['platform']}</span>" if terms['platform']

        track_event 'Searched projects', { query: params[:q], result_count: @results.total_count, type: params[:type] }
      rescue => e
        logger.error "Error while searching for #{params[:q]}: #{e.message}"
        @results = []
      end
    end
  end

  def tags
    redirect_to projects_path and return unless params[:tag].present?

    begin
      @tag = CGI::unescape params[:tag]
      params[:q] = @tag
      params[:type] = 'project'
      # params[:platform_id] = current_platform.id if current_platform
      params[:per_page] = Project.per_page
      @results = SearchRepository.new(params).search.results
      # raise @results.inspect
      params[:per_page] = nil  # so that it doesn't appear in the URL
      params[:type] = nil

      title "#{@results.total} #{@tag} Projects"
      meta_desc "Interested in #{@tag}? Explore #{@results.total} projects tagged with '#{@tag}'. Find these and other hardware projects on #{site_name}."

      # track_event 'Searched projects by tag', { tag: @tag, result_count: @results.size, type: params[:type] }
    # rescue => e
    #   logger.error "Error while searching for #{params[:q]}: #{e.message}"
    #   @results = []
    end
  end
end