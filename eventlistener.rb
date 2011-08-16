#!/usr/bin/ruby 
require 'juggernaut'
require 'redis'

redis = Redis.new
#Juggernaut.url = "redis://184.73.222.141:6379"

def broadcast_user_list(redis,channel)
	members = redis.smembers channel
	list = Array.new
	members.each do |m|
		member = Hash.new
		member["user_name"] = redis.hget m, "user_name"
		member["session_id"] = m
		list << member
	end
	Juggernaut.publish(channel,
		{
			:type => "users",
			:data => list
		}
	)
end

Juggernaut.subscribe do |event, data|
	channel = data["channel"]
	session_id = data["session_id"]
	user_name = data["meta"] && data["meta"]["user_name"]
	next unless user_name
	
	case event
	when :subscribe
		p user_name + " is connected "
		redis.multi do
			redis.hset channel+":"+session_id, "user_name", user_name 
			redis.sadd channel, channel+":"+session_id
		end
		broadcast_user_list(redis,channel)
		
		Juggernaut.publish(channel,
			{
				:type => "message",
				:data => user_name + " is connected."
			}
		)
	when :unsubscribe
		p user_name + " is disconnected"
		redis.multi do
			redis.srem channel, channel+":"+session_id
			redis.del channel+":"+session_id
		end
		broadcast_user_list(redis,channel)

                Juggernaut.publish(channel,
                        {
                                :type => "message",
                                :data => user_name + " is disconnected."
                        }
                )
	end
end
