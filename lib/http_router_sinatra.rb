require 'http_router'
require 'sinatra'

class HttpRouter
  class Sinatra

    def initialize
      ::Sinatra.send(:include, Extension)
    end

    module Extension

      def self.registered(app)
        app.send(:include, Extension)
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def generate(name, *params)
        self.class.generate(name, *params)
      end

      private
        def route!(base=self.class, pass_block=nil)
          request.env['sinatra.instance'] = self
          if base.router and match = base.router.recognize(request.env)
            if match.respond_to?(:path)
              throw :halt, @_response_buffer
            elsif match.is_a?(Array)
              route_eval { 
                match[1].each{|k,v| response[k] = v}
                status match[0]
              }
            end
          end

          # Run routes defined in superclass.
          if base.superclass.respond_to?(:router)
            route! base.superclass, pass_block
            return
          end

          route_eval(&pass_block) if pass_block

          route_missing
        ensure
          @_response_buffer = nil
        end

      module ClassMethods

        def new(*args, &bk)
          configure! unless @_configured
          super(*args, &bk)
        end

        def get(path, *args, &block)
          conditions = @conditions.dup
          route('GET', path, *args, &block)

          @conditions = conditions
          route('HEAD', path, *args, &block)
        end

        def put(path, *args, &bk);    route 'PUT',    path, *args, &bk end
        def post(path, *args, &bk);   route 'POST',   path, *args, &bk end
        def delete(path, *args, &bk); route 'DELETE', path, *args, &bk end
        def head(path, *args, &bk);   route 'HEAD',   path, *args, &bk end

        def route(verb, path, options={}, &block)
          name = options.delete(:name)

          path = transform_path(path)

          define_method "#{verb} #{path}", &block
          unbound_method = instance_method("#{verb} #{path}")
          block = block.arity.zero? ?
            proc { unbound_method.bind(self).call } :
            proc { unbound_method.bind(self).call(*@block_params) }

          invoke_hook(:route_added, verb, path, block)

          route = router.add(path)

          route.matching(options[:matching]) if options.key?(:matching)

          route.send(verb.downcase.to_sym)
          route.host(options[:host]) if options.key?(:host)
          
          route.name(name) if name

          route.arbitrary_with_continue do |req, params|
            if req.testing_405?
              req.continue[true]
            else
              req.rack_request.env['sinatra.instance'].instance_eval do
                handled = false
                @block_params = req.params
                (@params ||= {}).merge!(params)
                pass_block = catch(:pass) do
                  route_eval(&block)
                  handled = true
                end
                req.continue[handled]
              end
            end
          end

          route.to(block)
          route
        end

        def router
          @router ||= HttpRouter.new
          yield(@router) if block_given?
          @router
        end

        def generate(name, *params)
          router.url(name, *params)
        end

        def reset!
          router.reset!
          super
        end

        def configure!
          configure :development do
            error 404 do
              content_type 'text/html'

              (<<-HTML).gsub(/^ {17}/, '')
              <!DOCTYPE html>
              <html>
              <head>
                <style type="text/css">
                body { text-align:center;font-family:helvetica,arial;font-size:22px;
                  color:#888;margin:20px}
                #c {margin:0 auto;width:500px;text-align:left}
                </style>
              </head>
              <body>
                <h2>Sinatra doesn't know this ditty.</h2>
                <div id="c">
                  Try this:
                  <pre>#{request.request_method.downcase} '#{request.path_info}' do\n  "Hello World"\nend</pre>
                </div>
              </body>
              </html>
              HTML
            end
            error 405 do
              content_type 'text/html'

              (<<-HTML).gsub(/^ {17}/, '')
              <!DOCTYPE html>
              <html>
              <head>
                <style type="text/css">
                body { text-align:center;font-family:helvetica,arial;font-size:22px;
                  color:#888;margin:20px}
                #c {margin:0 auto;width:500px;text-align:left}
                </style>
              </head>
              <body>
                <h2>Sinatra sorta knows this ditty, but the request method is not allowed.</h2>
              </body>
              </html>
              HTML
            end
          end

          @_configured = true
        end

        private
        def transform_path(path)
          if path.is_a?(String)
            path.gsub!(/\/\?$/, '(/)')
          end
          path
        end
      end # ClassMethods
    end # Extension
  end # Sinatra
end # HttpRouter