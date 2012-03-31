mint.rb
=======

Wrote this small bit of code to gather some information from Mint.com's "API." It's pretty minimal at this point but all I needed was something to capture the current month's budget info--hopefully it can save someone else some time!

A simple driver
---------------

```ruby
require 'mint'

include ActionView::Helpers::NumberHelper

Mint::Base.username = ''
Mint::Base.password = ''

Mint::API.connect!

Mint::API.budgets( '03/01/2012', '03/31/2012' )['data']['spending'].each_pair do |budget_id,budget_period|

  # if your start/end window is large enough, you will get all budgets for previous months
  # not really sure how to parse these yet, though

  budget_period['bu'].each do |budget|
    amount   = budget['amt']
    max      = budget['bgt']
    category = Mint::API.category_name( budget['cat'] )
    puts "Spent #{amount} out of #{max} on: #{category}"
  end

end
```

