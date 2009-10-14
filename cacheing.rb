module Cacheing
	def cache_grab(*params)
		key = build_key(*params)
		ret_obj = MemCacher.marshal_safe(key)
		if ret_obj.nil?
			ret_obj = yield
			cache_set(key, ret_obj)
		end
		ret_obj
	end

	private

	def cache_get(key)
		RAILS_DEFAULT_LOGGER.debug("Fetching from cache - " + key)
		CACHE.get(key)
	end

	def cache_set(key, data)
		obj = Marshal.dump(data)
		RAILS_DEFAULT_LOGGER.debug("Caching - " + key + ": " + data.to_s)
		CACHE.set(key, obj) unless obj.nil?
	end

	def build_key(*params)
		type,obj=*params
        if obj.methods.include?("updated_at")
            attrs = [type,obj.class,obj.object_id,obj.updated_at.strftime('%Y%m%d%H%M%S')]
        else
            attrs = [type,obj.class,obj.object_id]
        end
		attrs.join('_').gsub(' ','_').downcase unless attrs.nil?
	end
end
