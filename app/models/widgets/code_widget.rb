# require 'filemagic'
# require 'linguist'
require 'open-uri'
require 'pygments'

class CodeWidget < Widget

  DEFAULT_EXTENSION = 'txt'
  DEFAULT_LANGUAGE = 'bash'  # pygments format
  DEFAULT_MIME_TYPE = 'text/plain'

  ACE_PYGMENTS_TRANSLATIONS = {
    'c_cpp' => 'cpp',
    'scratch' => 'text'
  }

  ACE_LANGUAGES = {
    'text' => 'Plain text',
    'abap' => 'ABAP',
    'actionscript' => 'ActionScript',
    'ada' => 'ADA',
    'apache_conf' => 'Apache Conf',
    'asciidoc' => 'AsciiDoc',
    'assembly_x86' => 'Assembly x86',
    'autohotkey' => 'AutoHotKey',
    'batchfile' => 'BatchFile',
    'c9search' => 'C9Search',
    'c_cpp' => 'C/C++',
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
    'scratch' => 'Scratch',
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
  }.freeze
  EXTRA_PYGMENTS_LANGUAGES = {
    'arduino' => 'Arduino',
  }.freeze
  ALL_LANGUAGES = ACE_LANGUAGES.merge(EXTRA_PYGMENTS_LANGUAGES).sort.to_h.freeze
  LANGUAGE_MATCHER = {
    'c' => 'c_cpp',
    'cpp' => 'c_cpp',
  }.freeze
  PYGMENTS_LEXERS_BY_ALIASES = Pygments.lexers.inject({}){|mem, k| k = k[1]; mem[k[:aliases].first] = k; mem }.freeze
  ADDITIONAL_PYGMENTS_LEXERS = {
    'c_cpp' => PYGMENTS_LEXERS_BY_ALIASES['c'],
  }
  ALL_PYGMENTS_LEXERS_BY_ALIASES = PYGMENTS_LEXERS_BY_ALIASES.merge(ADDITIONAL_PYGMENTS_LEXERS)
  BINARY_MESSAGE = "Binary file (no preview)"
  ERROR_MESSAGE = "Error opening file."

  # device only supports "Spark Core", compiles needs to be set to true
  define_attributes [:raw_code, :formatted_content, :language, :device,
    :compiles, :comment, :binary]
  has_one :document, as: :attachable

  attr_accessible :document_attributes, :document_id

  accepts_nested_attributes_for :document, allow_destroy: true
  validates :language, presence: true
  before_validation :disallow_blank_file
  before_save :format_content

  def self.model_name
    Widget.model_name
  end

  def self.is_binary? buffer
    !buffer.force_encoding("UTF-8").valid_encoding?
  end

  def self.read_from_file file
    output_file = new

    orig_file = file.respond_to?(:tempfile) ? file.tempfile : file
    output_file.raw_code = if is_binary?(file.read)
      output_file.binary = true
      BINARY_MESSAGE
    else
      begin
        file.rewind if file.eof?
        file.read.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      rescue
        ERROR_MESSAGE
      end
    end

    output_file.name = file.original_filename

    output_file
  end

  def binary?
    binary or raw_code == BINARY_MESSAGE
  end

  def document_id=(val)
    self.document = Document.find_by_id(val)
  end

  def document_id
    document.try(:id)
  end

  def document_url
    document.try(:file_url)
  end

  def default_label
    'Code'
  end

  def extension
    @extension ||= pygments_lexer ? pygments_lexer[:filenames].first.gsub(/\*\./, '') : DEFAULT_EXTENSION
  end

  def file_name
    (binary? and document and document.file_name.present?) ? document.file_name : "#{name.downcase.gsub(/[^a-z0-9_]/, '_')}.#{extension}"
  end

  def formatted_code
    formatted_content
  end

  def formatted_code=(val)
    self.formatted_content = val
  end

  def human_language
    ALL_LANGUAGES[language]
  end

  def language=(val)
    if val.present?
      unless val.in? ALL_LANGUAGES.keys
        if val.in? LANGUAGE_MATCHER.keys
          val = LANGUAGE_MATCHER[val]
        end
      end
    end
    prop = properties
    prop[:language] = val
    self.properties = prop
  end

  def mime_type
    @mime_type ||= pygments_lexer ? pygments_lexer[:mimetypes].first : DEFAULT_MIME_TYPE
  end

  def name
    super.presence || 'Untitled file'
  end

  def to_json
    {
      file_url: document.try(:file_url),
      file_name: file_name,
      id: id,
      language: language,
      name: name,
      raw_code: raw_code,
      binary: binary,
      document_id: document.try(:id),
    }#.to_json
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
    def disallow_blank_file
      if document
        if raw_code.blank?
          document.disallow_blank_file!
        else
          document.skip_file_check!
        end
      end
    end

    def force_encoding
      self.raw_code = raw_code.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') if raw_code.present? and raw_code_changed?
    end

    def format_content
      return unless raw_code_changed? or language_changed? or (raw_code.present? and formatted_content.blank?)

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

    def pygments_lexer
      @pygments_lexer ||= ALL_PYGMENTS_LEXERS_BY_ALIASES[language]
    rescue
      # not found
    end

    def read_code_from_file
      return unless document and (document.file_changed? or raw_code.blank?)

      self.raw_code = begin
        file_url = if document.file_changed?
          scheme = APP_CONFIG['use_ssl'] ? 'https' : 'http'
          "#{scheme}://#{APP_CONFIG['default_host']}:#{APP_CONFIG['default_port']}#{document.file_url}"
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
