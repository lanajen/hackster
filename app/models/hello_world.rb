class HelloWorld
  CONFIG_PATH = File.join(Rails.root, 'config', 'hello_world.yml')

  attr_reader :header, :message

  def initialize ref
    @ref = ref
    if content
      @header = content['header']
      @message = content['message']
    end
  end

  def present?
    header.present? or message.present?
  end

  def record_key
    "hello_world/#{@ref}"
  end

  private
    def content
      @content ||= config['hello_world']['default'].merge(config['hello_world'][@ref])
    end

    def config
      YAML.load File.new(CONFIG_PATH)
    end
end