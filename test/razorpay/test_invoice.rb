require 'test_helper'

module Razorpay
  # Tests for Razorpay::Invoice
  class RazorpayInvoiceTest < Minitest::Test
    def setup
      @invoice_id = 'inv_6vRZmJYFAG1mNq'

      # Any request that ends with invoices/invoice_id
      stub_get(%r{invoices/#{@invoice_id}$}, 'fake_invoice')
    end

    def test_invoice_should_be_defined
      refute_nil Razorpay::Invoice
    end

    def test_invoice_should_be_created
      stub_post(/invoices$/, 'fake_invoice', 'customer_id=cust_6vRXClWqnLhV14&'\
                'amount=100&currency=INR&description=Test%20description&type=link')
      invoice = Razorpay::Invoice.create customer_id: 'cust_6vRXClWqnLhV14',
                                         amount: 100, currency: 'INR',
                                         description: 'Test description',
                                         type: 'link'

      assert_equal 'cust_6vRXClWqnLhV14', invoice.customer_id
      assert_equal 100, invoice.amount
      assert_equal 'INR', invoice.currency
      assert_equal 'Test description', invoice.description
      assert_equal 'link', invoice.type
    end

    def test_invoices_should_be_fetched
      invoice = Razorpay::Invoice.fetch(@invoice_id)
      assert_instance_of Razorpay::Invoice, invoice, 'invoice not an instance of Razorpay::Invoice class'
      assert_equal @invoice_id, invoice.id, 'invoice IDs do not match'
    end

    def test_fetching_all_invoices
      stub_get(/invoices$/, 'invoice_collection')
      invoices = Razorpay::Invoice.all
      assert_instance_of Razorpay::Collection, invoices, 'Invoices should be an array'
      assert !invoices.items.empty?, 'invoices should be more than one'
    end

    def test_invoice_can_be_issued_by_invoice_id
      stub_post(%r{invoices\/#{@invoice_id}\/issue$}, 'issue_invoice', {})
      invoice = Razorpay::Invoice.issue(@invoice_id)

      assert_equal 'issued', invoice.status
      refute_nil invoice.issued_at

      assert_invoice_details(invoice)
    end

    def test_invoice_can_be_issued_by_invoice_instance
      stub_post(%r{invoices\/#{@invoice_id}\/issue$}, 'issue_invoice', {})
      invoice = Razorpay::Invoice.fetch(@invoice_id)

      assert_instance_of Razorpay::Invoice, invoice, 'invoice not an instance of Razorpay::Invoice class'

      invoice = invoice.issue

      assert_equal 'issued', invoice.status
      refute_nil invoice.issued_at

      assert_invoice_details(invoice)
    end

    def test_invoice_can_be_cancelled_by_invoice_id
      stub_post(%r{invoices\/#{@invoice_id}\/cancel$}, 'cancel_invoice', {})
      invoice = Razorpay::Invoice.cancel(@invoice_id)

      assert_equal 'cancelled', invoice.status
      refute_nil invoice.cancelled_at

      assert_invoice_details(invoice)
    end

    def test_invoice_can_be_cancelled_by_invoice_instance
      stub_post(%r{invoices\/#{@invoice_id}\/cancel$}, 'cancel_invoice', {})
      invoice = Razorpay::Invoice.fetch(@invoice_id)

      assert_instance_of Razorpay::Invoice, invoice, 'invoice not an instance of Razorpay::Invoice class'

      invoice = invoice.cancel

      assert_equal 'cancelled', invoice.status
      refute_nil invoice.cancelled_at

      assert_invoice_details(invoice)
    end

    def test_edit_invoice
      invoice = Razorpay::Invoice.fetch(@invoice_id)
      assert_instance_of Razorpay::Invoice, invoice, 'invoice not an instance of Razorpay::Invoice class'
      assert_nil invoice.invoice_number

      update_invoice_data = { invoice_number: '12345678' }
      stub_patch(%r{invoices/#{@invoice_id}$}, 'update_invoice', update_invoice_data)

      invoice = invoice.edit(update_invoice_data)
      assert_instance_of Razorpay::Invoice, invoice, 'invoice not an instance of Razorpay::Invoice class'
      refute_nil invoice.invoice_number
    end

    private

    def assert_invoice_details(invoice)
      assert_equal 'cust_6vRXClWqnLhV14', invoice.customer_id
      assert_equal 100, invoice.amount
      assert_equal 'INR', invoice.currency
      assert_equal 'Test description', invoice.description
      assert_equal 'invoice', invoice.type
    end
  end
end
