require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "it should verify username and host before validation" do
    order = Order.new( user_id: 1, url: "stratum+tcp://www.domain.com:3333", username: "user", password: "pass", pay: 0.01, price: 0.01 )
    assert order.save

    order = Order.new( user_id: 1, url: "stratum+tcp://user:pass@www.domain.com:3333", pay: 0.01, price: 0.01 )
    assert order.save

    order = Order.new( user_id: 1, url: "stratum+tcp://www.domain.com:3333", pay: 0.01, price: 0.01 )
    refute order.save

    order = Order.new( user_id: 1, url: "stratum+tcp://in(valid)_[host]:3333", username: "user", password: "pass", pay: 0.01, price: 0.01 )
    refute order.save
  end

  test "it should pay_miners" do
    # on crée un order
    order = Order.create!( user: users(:buyer), url: "stratum+tcp://www.domain.com:3333", username: "user", password: "pass", pay: 1, price: 0.01 )
    # on crée 3 shares pour cet order, dont deux du même utilisateur
    share1 = Share.create!( worker: workers(:two1), difficulty: 0.01, order: order,
      solution: "00000000ffff0000000000000000000000000000000000000000000000000000", our_result: true)
    share2 = Share.create!( worker: workers(:two2), difficulty: 0.01, order: order,
      solution: "00000000ffff0000000000000000000000000000000000000000000000000000", our_result: true)
    share3 = Share.create!( worker: workers(:toto1), difficulty: 0.03, order: order,
      solution: "000000007fff8000000000000000000000000000000000000000000000000000", our_result: true)
    shares = [share1, share2, share3]
    assert_equal 3, order.shares.payable.size
    # on fait le payout
    order.pay_miners!
    # on vérifie que les trois shares ont des transfers
    shares.each(&:reload)
    assert share1.paid?
    assert share2.paid?
    assert share3.paid?
    # que les shares du même utilisateur ont les mêmes transfers
    assert share1.transfer == share2.transfer
    refute share1.transfer == share3.transfer
    # qu'il n'y a plus de shares payables
    assert_equal 0, order.shares.payable.size
    # que les amounts sont corrects
    assert_equal 9743360.satoshi, share1.transfer.amount.btc
    assert_equal 14615041.satoshi, share3.transfer.amount.btc
    # qu'il existe un transfer à notre noms.
    fees_miner = Miner.find_by( address: HashFarm.config.pool.fees_address )
    refute_nil fees_miner
    fees_transfer = Transfer.find_by( miner: fees_miner )
    refute_nil fees_transfer
    assert_equal 497113.satoshi, fees_transfer.amount.btc
    assert_equal fees_miner, fees_transfer.miner
    # que la somme payée a été déduit du montant disponible du order
    assert_equal 75144486.satoshi, order.pay.btc
  end
end
