#!/usr/bin/env ruby -wKU

1.times do
  puts 'hello'
end

17.times do |banana|
  puts banana
end

17.times do |banana, pineapple|
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

43.times do |donkey|







  9.times { |gym| puts donkey + gym }
end

1.times { puts 'hello' }

1.times do
  puts 'hello'
end.to eq 'world'

1.times { puts 'hello' }.to eq 'world'

1.times do puts 'hello' end

1.times { puts = 'hello' }

17.times { |banana| puts banana }

17.times { |banana, pineapple| puts banana }

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

describe "GET new" do

  context "for a guest" do
    it "redirects to root" do
      get :new, {}
      expect(response).to redirect_to root_path
    end
  end
end

43.times { |bar| 9.times { |gym| puts donkey + gym } }

it { |bob| it { expect(response).to redirect } }

it { it { expect(response).to redirect } }

it { it { expect(response).to redirect } }

1.times { var = 'noop' }

set.map {|image| image.id }

1.times {|bub| puts 'hello'}

expect { p(n) }


context "for tim" {
  it { expect(response).to redirect }
}
