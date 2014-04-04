# When you're using Rails 2 console, show queries in the console
extend_console 'rails2', (ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')), false do
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

# When you're using Rails 3 console, show queries in the console
extend_console 'rails3', defined?(ActiveSupport::Notifications), false do
  rails_prompt = "#{Rails.application.class.parent_name.downcase}:#{Rails.env.first(3)}-#{RUBY_VERSION}"
  Pry.prompt = [
    proc { |obj, nest_level| "#{rails_prompt} (#{obj})#{":#{nest_level}" if nest_level > 0}> " },
    proc { |obj, nest_level| "#{rails_prompt} (#{obj})#{":#{nest_level}" if nest_level > 0}* " }
  ]

  $odd_or_even_queries = false
  ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
    $odd_or_even_queries = !$odd_or_even_queries
    color = $odd_or_even_queries ? ANSI[:CYAN] : ANSI[:MAGENTA]
    event = ActiveSupport::Notifications::Event.new(*args)
    time  = "%.1fms" % event.duration
    name  = event.payload[:name]
    sql   = event.payload[:sql].gsub("\n", " ").squeeze(" ")
    puts "  #{ANSI[:UNDERLINE]}#{color}#{name} (#{time})#{ANSI[:RESET]}  #{sql}"
  end

  extend Rails::ConsoleMethods if defined? Rails::ConsoleMethods

  extend_console 'routes', defined?(Hirb) && defined?(Journey::Route), false do
    # hirb view for a route
    class Hirb::Helpers::Route < Hirb::Helpers::AutoTable
      def self.render(route, options = {})
        if route.is_a? Array
          route.each_with_index {|r,i| puts render(r, options.merge(:index => i))}
        else
          output = route.requirements.map {|k,v| [k, v.inspect]}
          index = options.delete :index
          super output, options.merge({
            :headers     => [
              "#{"##{index} " if index}#{route.name if route.name}",
              "#{route.verb ? route.verb.source[/\w+/] : 'ANY'} #{route.path.spec}"
            ],
            :unicode     => true,
            :description => nil
          })
        end
      end
    end
    Hirb.add_view Journey::Route, :class => Hirb::Helpers::Route

    # short and long route list
    def routes(long_output = false)
      if long_output
        Hirb::Helpers::Route.render Rails.application.routes.routes.to_a
        true
      else
        output = Rails.application.routes.routes.each_with_index.map do |route, i|
          verb = route.verb ? route.verb.source[/\w+/] : 'ANY'
          [i, route.name || '', verb, route.path.spec]
        end
        Hirb::Console.render_output output,
          :class   => Hirb::Helpers::AutoTable,
          :headers => %w(# name verb path)
      end
    end

    # get a specific route via index or name
    def route(index_or_name)
      route = case index_or_name
      when Integer
        Rails.application.routes.routes.to_a[index_or_name]
      when Symbol # named route
        Rails.application.routes.named_routes.get index_or_name
      end
    end

    include Rails.application.routes.url_helpers
    default_url_options[:host] = "#{Rails.application.class.parent_name.downcase}.#{Rails.env.first(3)}"
  end

  extend_console 'helpers', defined?(ActionView::Helpers), false do
    include ApplicationController._helpers # Your own helpers

    include ActionView::Helpers::DebugHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TranslationHelper
  end
end
