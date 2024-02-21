# When you're using Rails console, show queries in the console
extend_console "rails", defined?(ActiveSupport::Notifications), false do
  Pry.config.prompt_name = "#{Rails.application.class.module_parent_name.downcase}:#{Rails.env.first(3)}"

  extend Rails::ConsoleMethods if defined? Rails::ConsoleMethods

  extend_console 'routes', defined?(Hirb) && defined?(ActionDispatch::Journey::Route), false do
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
              "#{route.verb.presence || "ANY"} #{route.path.spec}"
            ],
            :unicode     => true,
            :description => nil
          })
        end
      end
    end
    Hirb.add_view ActionDispatch::Journey::Route, :class => Hirb::Helpers::Route

    # short and long route list
    def routes(long_output = false)
      if long_output
        Hirb::Helpers::Route.render Rails.application.routes.routes.to_a
        true
      else
        output = Rails.application.routes.routes.each_with_index.map do |route, i|
          verb = route.verb.presence || "ANY"
          [i, route.name || '', verb, route.path.spec.to_s]
        end
        Hirb::Console.render_output output,
          :class   => Hirb::Helpers::AutoTable,
          :headers => %w(# name verb path)
      end
    end

    # get a specific route via index or name
    def route(index_or_name)
      case index_or_name
      when Integer
        Rails.application.routes.routes.to_a[index_or_name]
      when Symbol # named route
        Rails.application.routes.named_routes.get index_or_name
      end
    end
  end
end
