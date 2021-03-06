require_relative 'test_helper'
require_relative '../lib/invoice_repository.rb'
require_relative '../lib/sales_engine.rb'

class InvoiceRepositoryTest < Minitest::Test
  attr_reader :engine

  def setup
    @engine = SalesEngine.new("./test/fixtures")
    engine.startup
  end


  def test_it_can_find_all_successful_invoices
    repo = engine.invoice_repository
    result = repo.successful_invoices

    assert_equal 14, result.size
    assert_equal Invoice, result[1].class
  end

  def test_it_can_find_pending_invoices
    repo = engine.invoice_repository
    result = repo.pending_invoices

    assert_equal 6, result.size
  end

  def test_can_create_an_invoice
    s_engine = SalesEngine.new("./test/fixtures")
    s_engine.startup
    repo = s_engine.invoice_repository
    count = repo.all.values.size
    item1 = Item.new(s_engine.item_repository, id: 99, unit_price: 1, created_at: Time.now, updated_at: Time.now )
    item2 = Item.new(s_engine.item_repository, id: 999, unit_price: 1, created_at: Time.now, updated_at: Time.now)
    customer = s_engine.customer_repository.find_by_id(1)
    merchant = s_engine.merchant_repository.find_by_id(1)

    invoice = repo.create(customer: customer, merchant: merchant, status: "shipped",
                         items: [item1, item2, item1])

    assert_equal (count + 1), repo.all.values.size

  end

  def test_it_can_charge_a_credit_card
    s_engine = SalesEngine.new("./test/fixtures")
    s_engine.startup
    repo = s_engine.invoice_repository
    count = repo.all.values.size
    item1 = Item.new(s_engine.item_repository, id: 99, unit_price: 1, created_at: Time.now, updated_at: Time.now )
    item2 = Item.new(s_engine.item_repository, id: 999, unit_price: 1, created_at: Time.now, updated_at: Time.now)
    customer = s_engine.customer_repository.find_by_id(1)
    merchant = s_engine.merchant_repository.find_by_id(1)

    invoice = repo.create(customer: customer, merchant: merchant, status: "shipped",
                         items: [item1, item2, item1])

    args = { credit_card_number: "4444333322221111",
               credit_card_expiration: "10/13", result: "success" }
    invoice.charge(args)

    assert invoice.transactions.any? { |transaction| transaction.credit_card_number == '4444333322221111' }
  end


  ##########PREVIOUS DEVELOPER########
  def test_it_is_a_repository
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    assert_kind_of Repository, invoice_repo
  end

  def test_it_knows_what_file_it_refers_to
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    assert_kind_of File, invoice_repo.location
  end

  def test_it_can_fetch_an_invoice
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    assert_kind_of Invoice, invoice_repo.id(1)
  end

  def test_it_can_fetch_using_all
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    assert_kind_of Hash, invoice_repo.all
  end

  def test_it_fetches_invoices_using_all
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    assert_kind_of Invoice, invoice_repo.all.values[0]
  end

  def test_it_fetches_a_random_instance
    # this test has a one in a quadrillion chance of accidentally failing
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = []
    50.times do
      invoices << invoice_repo.random
    end

    assert_equal 50, invoices.length
    refute_equal 1, invoices.uniq.length
  end

  def test_random_instance_is_id_attributes_pair
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    random = invoice_repo.random

    assert_kind_of Invoice, random
  end

  def test_it_can_find_by_attribute
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = invoice_repo.find_all_by(merchant_id: 1)

    assert_kind_of Array, invoices
  end

  def test_attributes_found_are_correct
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = invoice_repo.find_all_by(status: "shipped")
    invoice = invoices[1]

    assert_equal "shipped", invoice.status
  end

  def test_find_does_not_return_what_it_is_not_searching_for
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = invoice_repo.find_all_by(status: "in transit")

    assert_equal 0, invoices.length
  end

  def test_find_all_returns_all
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = invoice_repo.find_all_by(merchant_id: 1)

    assert_equal 3, invoices.length
  end

  def test_find_first_of_multiple
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = invoice_repo.find_by(customer_id: 1)

    assert_equal 1, invoices.customer_id
  end

  def test_find_all_by_returns_empty_hash_if_no_findings
    invoice_repo = InvoiceRepository.new engine, "./test/fixtures/invoices.csv"

    invoices = invoice_repo.find_all_by(customer_id: "666")

    assert_equal([], invoices)
  end
end
