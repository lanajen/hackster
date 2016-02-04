module ActionDispatch
  module Routing
    # :stopdoc:
    class RouteSet

      # The +options+ argument must be a hash whose keys are *symbols*.
      def url_for(options, route_name = nil, url_strategy = UNKNOWN)
        options = default_url_options.merge options

        user = password = nil

        if options[:user] && options[:password]
          user     = options.delete :user
          password = options.delete :password
        end

        recall  = options.delete(:_recall) { {} }

        original_script_name = options.delete(:original_script_name)
        script_name = find_script_name options

        if original_script_name
          script_name = original_script_name + script_name
        end

        path_options = options.dup
        RESERVED_OPTIONS.each { |ro| path_options.delete ro }

        path, params = generate(route_name, path_options, recall)

        if options.key? :params
          params.merge! options[:params]
        end

        # added four lines below for path prefix
        if options[:host] == ENV['ARDUINO_INCOMING_HOST'] or options[:host] == ENV['ARDUINO_REAL_HOST']
          script_name = '/projecthub'
          path = '' if path == '/'
        end

        options[:path]        = path
        options[:script_name] = script_name
        options[:params]      = params
        options[:user]        = user
        options[:password]    = password

        url_strategy.call options
      end
    end
  end
end
