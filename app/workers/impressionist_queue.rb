module ImpressionistController::InstanceMethods
  def self.included(base)
  end
end

class ImpressionistQueue < BaseWorker
  include ImpressionistController::InstanceMethods
  extend ::NewRelic::Agent::MethodTracer
  sidekiq_options queue: :low, retry: false

  def action_name
    @action_name
  end

  def count env, action_name, controller_name, params, obj_id, obj_type, message=nil, tmp_opts={}
    # request:
    # - remote_ip
    # - referer
    # - user_agent
    # - session_options[:id]
    @action_name = action_name
    @controller_name = controller_name
    @params = params
    @session_hash = env['session_hash']
    @request = ActionDispatch::Request.new(env)
    opts = {}
    tmp_opts.each{|k,v| opts[:"#{k}"] = v }
    obj = obj_type.constantize.find obj_id
    self.class.trace_execution_scoped(['Custom/ImpressionistQueue/count']) do
      impressionist(obj, message, opts)
    end
  rescue => e
    # debugging
    raise "Error in ImpressionistQueue: #{e.message} // action_name: #{action_name} // controller_name: #{controller_name} // params: #{params} // obj_id: #{obj_id} // obj_type: #{obj_type}"
  end

  def controller_name
    @controller_name
  end

  def params
    @params
  end

  def request
    @request
  end

  def session_hash
    @session_hash
  end

  def unique_query(unique_opts)
    super unique_opts.map{|o| o.to_sym }
  end
end
