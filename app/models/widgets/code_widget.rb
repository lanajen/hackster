require 'linguist'
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

  DEFAULT_LANGUAGE = 'bash'  # pygments format

  ACE_PYGMENTS_TRANSLATIONS = {
    'c_cpp' => 'cpp',
  }

  ACE_LANGUAGES = {
    'abap' => 'ABAP',
    'actionscript' => 'ActionScript',
    'ada' => 'ADA',
    'apache_conf' => 'Apache Conf',
    'asciidoc' => 'AsciiDoc',
    'assembly_x86' => 'Assembly x86',
    'autohotkey' => 'AutoHotKey',
    'batchfile' => 'BatchFile',
    'c9search' => 'C9Search',
    'c_cpp' => 'C/C++ (incl. Arduino)',
    'cirru' => 'Cirru',
    'clojure' => 'Clojure',
    'cobol' => 'Cobol',
    'coffee' => 'CoffeeScript',
    'coldfusion' => 'ColdFusion',
    'csharp' => 'C#',
    'css' => 'CSS',
    'curly' => 'Curly',
    'd' => 'D',
    'dart' => 'Dart',
    'diff' => 'Diff',
    'dockerfile' => 'Dockerfile',
    'dot' => 'Dot',
    'erlang' => 'Erlang',
    'ejs' => 'EJS',
    'forth' => 'Forth',
    'ftl' => 'FreeMarker',
    'gherkin' => 'Gherkin',
    'gitignore' => 'Gitignore',
    'glsl' => 'Glsl',
    'golang' => 'Go',
    'groovy' => 'Groovy',
    'haml' => 'HAML',
    'handlebars' => 'Handlebars',
    'haskell' => 'Haskell',
    'haxe' => 'haXe',
    'html' => 'HTML',
    'html_ruby' => 'HTML (Ruby)',
    'ini' => 'INI',
    'jack' => 'Jack',
    'jade' => 'Jade',
    'java' => 'Java',
    'javascript' => 'JavaScript',
    'json' => 'JSON',
    'jsoniq' => 'JSONiq',
    'jsp' => 'JSP',
    'jsx' => 'JSX',
    'julia' => 'Julia',
    'latex' => 'LaTeX',
    'less' => 'LESS',
    'liquid' => 'Liquid',
    'lisp' => 'Lisp',
    'livescript' => 'LiveScript',
    'logiql' => 'LogiQL',
    'lsl' => 'LSL',
    'lua' => 'Lua',
    'luapage' => 'LuaPage',
    'lucene' => 'Lucene',
    'makefile' => 'Makefile',
    'matlab' => 'MATLAB',
    'markdown' => 'Markdown',
    'mel' => 'MEL',
    'mysql' => 'MySQL',
    'mushcode' => 'MUSHCode',
    'nix' => 'Nix',
    'objectivec' => 'Objective-C',
    'ocaml' => 'OCaml',
    'pascal' => 'Pascal',
    'perl' => 'Perl',
    'pgsql' => 'pgSQL',
    'php' => 'PHP',
    'powershell' => 'Powershell',
    'prolog' => 'Prolog',
    'properties' => 'Properties',
    'protobuf' => 'Protobuf',
    'python' => 'Python',
    'r' => 'R',
    'rdoc' => 'RDoc',
    'rhtml' => 'RHTML',
    'ruby' => 'Ruby',
    'rust' => 'Rust',
    'sass' => 'SASS',
    'scad' => 'SCAD',
    'scala' => 'Scala',
    'smarty' => 'Smarty',
    'scheme' => 'Scheme',
    'scss' => 'SCSS',
    'sh' => 'SH',
    'sjs' => 'SJS',
    'space' => 'Space',
    'snippets' => 'snippets',
    'soy_template' => 'Soy Template',
    'sql' => 'SQL',
    'stylus' => 'Stylus',
    'svg' => 'SVG',
    'tcl' => 'Tcl',
    'tex' => 'Tex',
    'text' => 'Text',
    'textile' => 'Textile',
    'toml' => 'Toml',
    'twig' => 'Twig',
    'typescript' => 'Typescript',
    'vala' => 'Vala',
    'vbscript' => 'VBScript',
    'velocity' => 'Velocity',
    'verilog' => 'Verilog',
    'xml' => 'XML',
    'xquery' => 'XQuery',
    'yaml' => 'YAML',
  }
  ERROR_MESSAGE = "Error opening file."

  # device only supports "Spark Core", compiles needs to be set to true
  define_attributes [:raw_code, :formatted_content, :language, :device,
    :compiles]
  has_one :document, as: :attachable

  attr_accessible :document_attributes
  accepts_nested_attributes_for :document, allow_destroy: true
  before_validation :force_encoding
  before_validation :disallow_blank_file
  before_save :check_changes
  before_save :guess_language_from_document, if: proc{|w| w.language.nil? || w.document.try(:file_changed?) }
  before_save :format_content

  def self.model_name
    Widget.model_name
  end

  def default_label
    'Code'
  end

  def extension
    return @extension if @extension
    @extension = Pygments.lexers[ACE_LANGUAGES[language]][:aliases].first
  rescue
    'txt'
  end

  def extension_list
    return @extension_list if @extension_list
    @extension_list = {}
    Pygments.lexers.each{|k,v| v[:filenames].each{|f| @extension_list[f] = k }}
    @extension_list
  end

  def file_name
    (document and document.file_name.present?) ? document.file_name : "#{name.downcase.gsub(/[^a-z0-9_]/, '_')}.#{extension}"
  end

  def language
    properties[:language] || 'text'
  end

  def name
    super || "file_#{id}"
  end

  # def raw_code
  #   val = read_attribute :raw_code
  #   val.try(:force_encoding, "UTF-8")
  # rescue
  #   ERROR_MESSAGE
  # end

  def to_json
    {
      file_url: document.try(:file_url),
      file_name: file_name,
      id: id,
      language: language,
      name: name,
      raw_code: raw_code,
    }.to_json
  end

  def to_text
    "<h3>#{name}</h3><div contenteditable='false' class='embed-frame' data-type='widget' data-widget-id='#{id}' data-caption='#{document.try(:file_name)}'></div>"
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

    def guess_language_from_document
      return unless document and document.file_url

      if language = Linguist::FileBlob.new(document.real_file_url).language
        self.language = Hash[ACE_LANGUAGES.to_a.collect(&:reverse)][language.name]
      end
    rescue => e
      puts "rescued error while guessing language: #{e.message}"
      self.language = nil
    end

    def force_encoding
      self.raw_code = raw_code.force_encoding "UTF-8" if raw_code.present? and raw_code_changed?
    end

    def format_content
      return unless raw_code_changed? or language_changed?

      self.formatted_content = if raw_code == ERROR_MESSAGE
        ERROR_MESSAGE
      else
        translated_lang = ACE_PYGMENTS_TRANSLATIONS[language].presence || language
        translated_lang = DEFAULT_LANGUAGE unless translated_lang.in? Pygments.lexers.map{|k,v| v[:aliases] }.flatten
        Pygments.highlight(raw_code, lexer: translated_lang, options: {linespans: 'line'})
      end

    rescue
      self.formatted_content = ERROR_MESSAGE
    end

    def read_code_from_file
      return unless document and (document.file_changed? or raw_code.blank?)

      self.raw_code = begin
        file_url = if document.file_changed?
          "http://#{APP_CONFIG['default_host']}:#{APP_CONFIG['default_port']}#{document.file_url}"
        else
          document.real_file_url
        end

        open(file_url).read.try(:force_encoding, "UTF-8")
      rescue
        ERROR_MESSAGE
      end
    end

    def read_code_from_text
      build_document unless document

      text = raw_code.try(:force_encoding, "UTF-8") || ''
      file = StringIO.new text
      file.class_eval { attr_accessor :original_filename }
      file.original_filename = file_name

      document.file.cache! file
    end
end
