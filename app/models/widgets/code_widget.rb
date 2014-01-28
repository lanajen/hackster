require 'open-uri'
require 'pygments'

class CodeWidget < Widget

  LANGUAGES = {
    'Assembly' => '',
    'C' => 'c',
    'C++' => 'cpp',
    'C#' => 'csharp',
    'Console' => 'console',
    'HTML' => 'html',
    'Java' => 'java',
    'JavaScript' => 'js',
    'Objective-C' => 'objective-c',
    'Python' => 'python',
    'Perl' => 'perl',
    'Ruby' => 'rb',
    'Scala' => 'scala',
    'Verilog' => 'verilog',
    'VHDL' => 'vhdl',
    'XML' => 'xml',
  }
  ERROR_MESSAGE = "Error opening file."

  def self.model_name
    Widget.model_name
  end

  define_attributes [:raw_code, :formatted_content, :language]
  has_one :document, as: :attachable

  attr_accessible :document_attributes
  accepts_nested_attributes_for :document, allow_destroy: true
  before_validation :disallow_blank_file
  before_validation :guess_language_from_extension
  before_save :check_changes
  before_save :format_content

  def extension_list
    return @extension_list if @extension_list
    @extension_list = {}
    Pygments.lexers.each{|k,v| v[:filenames].each{|f| @extension_list[f] = k }}
    @extension_list
  end

  def file_name
    (document and document.file_name.present?) ? document.file_name : "#{name.downcase.gsub(/[^a-z0-9_]/, '_')}.#{language}"
  end

  def to_tracker
    super.merge({
      code_length: (raw_code.present? ? raw_code.length : 0),
      language: language,
    })
  end

  private
    def check_changes
      if document and (document.file_changed? or raw_code.blank?)
        read_code_from_file
      elsif raw_code_changed?
        read_code_from_text
      end
    end

    def disallow_blank_file
      if document
        if raw_code.blank?
          document.disallow_blank_file!
        else
          document.skip_file_check!
        end
      end
    end

    def guess_language_from_extension
    end

    def format_content
      return unless raw_code_changed? or language_changed?

      self.formatted_content = if raw_code == ERROR_MESSAGE
        ERROR_MESSAGE
      else
        Pygments.highlight(raw_code, lexer: language, options: {linespans: 'line'})
      end
    end

    def read_code_from_file
      return unless document and (document.file_changed? or raw_code.blank?)

      self.raw_code = begin
        file_url = if document.file_changed?
          "http://#{APP_CONFIG['default_host']}:#{APP_CONFIG['default_port']}#{document.file_url}"
        else
          if Rails.env == 'development'
            File.join(Rails.root, 'public', document.file_url)
          else
            document.file_url
          end
        end

        open(file_url).read
      rescue
        ERROR_MESSAGE
      end
    end

    def read_code_from_text
      build_document unless document

      file = StringIO.new raw_code
      file.class_eval { attr_accessor :original_filename }
      file.original_filename = file_name

      document.file.cache! file
    end
end
