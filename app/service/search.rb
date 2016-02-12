require 'hashie/mash'
require 'will_paginate/array'

class Search
  RESULTS_PER_PAGE = 3
  RECOGNIZED_CLASSES = %w(BaseArticle Part Platform User)

  attr_accessor :params

  # example params:
  # {
  #   q: 'arduino',
  #   model_classes: [
  #     {
  #       model_class: 'BaseArticle',
  #       params: { 'platforms.id' => 424 },
  #     },
  #     'User'
  #   ]
  # }

  def hits
    return @hits if @hits
    _hits = {}

    results.each do |batch|
      out = {}
      model_class = guess_model_class_from_index batch['index']

      out[:models] = get_models_from_hits batch
      out[:paginator] = paginate_models out[:models], batch['nbHits']
      out[:offset] = get_offset batch
      out[:page_size] = get_size batch
      out[:max] = out[:offset] - 1 + out[:page_size]
      out[:total_size] = batch['nbHits']
      out[:page] = batch['page']
      _hits[model_class.underscore] = out
    end

    @hits = _hits
  end

  def initialize params
    @params = params
  end

  def search_opts
    @search_opts ||= build_search_opts
  end

  def results
    return @results if @results

    Rails.logger.info "Searching for #{search_opts}"
    response = Algolia.multiple_queries search_opts
    @results = response['results']
  end

  private
    def build_facets facet_params
      {
        facets: facet_params.keys.join(','),
        facetFilters: facet_params.map{|k,v| "#{k}:#{v}" }.join(',')
      }
    end

    def build_search_opts
      params[:per_page] ||= RESULTS_PER_PAGE
      params[:page] = params[:page] || 1

      global_opts = {
        attributesToRetrieve: 'id',
        query: params[:q] ? CGI::unescape(params[:q].to_s) : nil,
        page: params[:page] - 1,  # algolia's first page is 0
        hitsPerPage: params[:per_page],
      }.freeze

      opts = []
      params[:model_classes].each do |model_class_opts|
        _opts = {}

        case model_class_opts
        when Hash
          model_class = model_class_opts[:model_class]
          if model_class_opts[:params]
            _opts.merge! build_facets(model_class_opts[:params])
          end
        when String
          model_class = model_class_opts
        else
          raise 'Unknown model_class type'
        end

        next unless model_class.in? RECOGNIZED_CLASSES

        _opts[:index_name] = model_class.constantize.algolia_index_name

        _opts.merge! global_opts
        opts << _opts
      end

      opts
    end

    def get_offset batch
      batch['page'] * batch['hitsPerPage'] + 1
    end

    def get_models_from_hits batch
      model_class = guess_model_class_from_index batch['index']

      ids = batch['hits'].map{|o| o['id'] }
      if ids.any?
        models = model_class.constantize.where(id: ids)
        order_models models, ids
      end
    end

    def guess_model_class_from_index index_name
      index_name.match /^hackster_[a-z]+_([a-z_]+)$/ do |m|
        m[1].camelize
      end
    end

    def get_size batch
      if batch['hitsPerPage'] > batch['nbHits']
        batch['nbHits']
      elsif batch['nbPages'] > (batch['page'] + 1)
        batch['hitsPerPage']
      else
        batch['nbHits'] - (batch['page'] * batch['hitsPerPage'])
      end
    end

    def order_models models, sorted_ids
      sorted_ids.inject([]) do |mem, id|
        models.each do |model|
          if model.id == id
            mem << model
            break
          end
        end
        mem
      end
    end

    def paginate_models models, total_size
      models = models || []
      models.paginate(
        page: params[:page],
        per_page: params[:per_page],
        total_entries: total_size
      )
    end
end