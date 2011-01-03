module ActionController
    module Session
        class RedisStore < AbstractStore

            def initialize(app, options = {})
                require "redis"
                options[:expire_after] ||= options[:expires]

                super

                @default_options = {
                    :namespace => 'rack:session',
                    :server => 'localhost',
                    :port => '6379',
                    :db => 0,
                    :key_prefix => ""
                }.update(options)

                @pool = Redis.new(@default_options)
                @mutex = Mutex.new

                super
            end

        private
            def prefixed(sid)
                "#{@default_options[:key_prefix]}#{sid}"
            end

            def get_session(env, sid)
                sid ||= generate_sid
                begin
                    data = @pool.call_command([:get, prefixed(sid)])
                    session = data.nil? ? {} : Marshal.load(data)
                rescue Errno::ECONNREFUSED
                    session = {}
                end
                [sid, session]
            end

            def set_session(env, sid, session_data)
                options = env['rack.session.options']
                expiry  = options[:expire_after] || nil
                @pool.set(prefixed(sid), Marshal.dump(session_data), expiry)
                return true
                rescue Errno::ECONNREFUSED
                return false
            end

        end
    end
end
