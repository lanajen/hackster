class HelloWorldController < ApplicationController
  def show

    hello_world = HelloWorld.new params[:ref]

    surrogate_keys = [hello_world.record_key, 'hello_world']
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers 3600

    hello_world = HelloWorld.new 'default' unless hello_world.present?

    if hello_world.present?
      message = ERB.new hello_world.message
      message = message.result(binding)
      tpl = render_to_string partial: 'shared/hello_world', locals: { header: hello_world.header, message: message }
      render json: { content: tpl }
    else
      render status: :not_found, nothing: true
    end
  end
end