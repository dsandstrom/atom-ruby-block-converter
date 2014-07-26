#!/usr/bin/env ruby -wKU

1.times do
  puts 'hello'
end

17.times do |banana|
  puts banana
end

43.times do |donkey|
  9.times do |gym|
    puts donkey + gym
  end
end

1.times { puts 'hello' }

17.times { |banana| puts banana }

43.times do |donkey|
  9.times { |gym| puts donkey + gym }
end
