current_valuation = 0

Dashing.scheduler.every '2s' do
  last_valuation = current_valuation
  current_valuation = rand(100)

  Dashing.send_event('ios',   { value: rand(50) })
end
