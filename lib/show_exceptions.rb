require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    app.call(env)
  rescue Exception => e
    render_exception(e)
  end

  private

  def render_exception(e)
    dir_path = File.dirname(__FILE__)
    path = "#{dir_path}/templates/rescue.html.erb"
    template = File.read(path)
    source = render_source(e)

    final = ERB.new(template).result(binding)

    ['500', {'Content-type' => 'text/html'}, [final]]
  end

  def render_source(e)
    error = e.backtrace.first

    dir_path = File.dirname(__FILE__)
    dir_path.slice!("/lib")
    root_path = Regexp.new("([^:]+)").match(error).to_s
    full_path = "#{dir_path}/#{root_path}"

    line = error.split(":")[1].to_i

    raw_source = File.readlines(full_path)[line - 2 .. line + 4]
    format_source(raw_source)
  end

  def format_source(raw)
    raw.each {|l| l.slice!("\n")}

    final = ""
    raw.each_with_index do |line, idx|
      if idx == 4
        final += "<p style='background: yellow; width: 100%; height:10pt;'>#{line}</p>"
      else
        final += "<p>#{line}</p>"
      end
    end
    final
  end

end
