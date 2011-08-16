#!/usr/bin/ruby 
require 'rubygems' 
require 'daemons' 
#Daemons.run('/home/ec2-user/local/bin/juggernaut', :dir_mode => :script, :dir => 
#"../../var/www/app/shared/pids", :ARGV =>  [ARGV[0], '--', '-c', '/var/ 
#www/app/shared/config/juggernaut.yml'], :log_output => true) 


Daemons.run('/home/ec2-user/script/redis.rb', {:app_name => 'redis', :dir_mode => :normal, :dir => '/home/ec2-user/script/pids',  :log_output => true})

