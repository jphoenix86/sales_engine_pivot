require_relative 'data_instance'

class Invoice < DataInstance
  attr_reader :customer_id, :merchant_id, :status

  def customer
    customer_repository.id(customer_id)
  end

  def merchant
    repository.merchant_for_an_invoice(self.merchant_id)
  end

end
