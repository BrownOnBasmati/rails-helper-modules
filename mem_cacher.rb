class MemCacher
	@@logger = RAILS_DEFAULT_LOGGER

	# safer way to de-serialize objects from memcache
	# returns nil if object is unable to be Marshalled
	def self.marshal_safe(key)
		obj = nil
		data = CACHE.get(key)
		if(data)
			begin
				obj = Marshal.load(data)
			rescue
				@@logger.info("MemCacher (marshal_safe method) unable to marshal memcache object:" + key.to_s)
				# destroy the corrupted key
				CACHE.set(key, nil)
				obj = nil
			end
		end
		obj
	end
end
