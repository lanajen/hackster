class ShippingCostCalculator
  HS_TARIFF_NUMBER = 854232
  CM_TO_INCH = 0.393701
  GRAM_TO_OUNCE = 0.035274
  DISCOUNT = 0

  def cost
    # return 0  # disabling for now, more testing needed

    @shipment ||= EasyPost::Shipment.create(
      to_address: to_address,
      from_address: from_address,
      parcel: parcel,
      customs_info: customs_info,
    )
    @shipment.lowest_rate.rate.to_f * (1 - DISCOUNT)
  end

  def initialize product, address
    @product = product
    @address = address
  end

  private
    def customs_item
      EasyPost::CustomsItem.create(
        description: 'Electronic kits',
        quantity: 1,
        value: @product.real_unit_price,
        weight: @product.weight * GRAM_TO_OUNCE,
        origin_country: 'us',
        hs_tariff_number: HS_TARIFF_NUMBER
      )
    end

    def customs_info
      EasyPost::CustomsInfo.create(
        integrated_form_type: 'form_2976',
        customs_certify: true,
        customs_signer: 'Ben Larralde',
        contents_type: 'gift',
        contents_explanation: '', # only required when contents_type => 'other'
        eel_pfc: 'NOEEI 30.37(a)',
        non_delivery_option: 'return',
        restriction_type: 'none',
        restriction_comments: '',
        customs_items: [customs_item]
      )
    end

    def from_address
      EasyPost::Address.create(
        company: 'Hackster, Inc.',
        street1: '620 Folsom street',
        street2: 'Suite 100',
        city: 'San Francisco',
        state: 'CA',
        zip: '94107',
        phone: '415-967-9461'
      )
    end

    def parcel
      EasyPost::Parcel.create(
        width: @product.width * CM_TO_INCH,
        length: @product.length * CM_TO_INCH,
        height: @product.height * CM_TO_INCH,
        weight: @product.weight * GRAM_TO_OUNCE,
      )
    end

    def to_address
      EasyPost::Address.create(
        name: @address.full_name,
        street1: @address.address_line1,
        street2: @address.address_line2,
        city: @address.city,
        state: @address.state,
        zip: @address.zip,
        country: @address.country,
        phone: @address.phone,
      )
    end
end