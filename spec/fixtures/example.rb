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

6.times do |banana|
  puts banana
  puts 2 * banana
end

1.times do puts 'hello' end

# not working on right of {
1.times { puts 'hello' }

17.times { |banana| puts banana }

# TODO: doesn't unwrap well
43.times do |donkey|
  9.times { |gym| puts donkey + gym }
end

6.times { |banana|
  puts 2 * banana
}

6.times { |banana|
  puts 2 * banana
  puts 2 * banana
}

43.times do |donkey|
  9.times { |gym| puts donkey + gym }
end
