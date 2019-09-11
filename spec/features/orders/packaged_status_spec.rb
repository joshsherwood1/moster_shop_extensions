require 'rails_helper'

describe "As a mechant employee or admin" do
  before(:each) do
    @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
    @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    @paper = @bike_shop.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
    @pencil = @bike_shop.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
    merchant_employee = User.create(  name: "alec",
                        address: "234 Main",
                        city: "Denver",
                        state: "CO",
                        zip: 80204,
                        email: "alec@gmail.com",
                        password: "password",
                        role: 1,
                        merchant_id: @bike_shop.id)

    @regular_user =  User.create!(  name: "alec",
                    address: "234 Main",
                    city: "Denver",
                    state: "CO",
                    zip: 80204,
                    email: "5@gmail.com",
                    password: "password"
                  )
    @order_1 = @regular_user.orders.create(name: "Sam Jackson", address: "234 Main St", city: "Seattle", state: "Washington", zip: 99987, status: 0)
    @itemorder = ItemOrder.create(order_id: @order_1.id, item_id: @tire.id, quantity: 2, price: 100, status: 1, merchant_id: @meg.id)
    @itemorder_2 = ItemOrder.create(order_id: @order_1.id, item_id: @paper.id, quantity: 2, price: 20, merchant_id: @bike_shop.id )
    @itemorder_3 = ItemOrder.create(order_id: @order_1.id, item_id: @pencil.id, quantity: 3, price: 2, merchant_id: @bike_shop.id )

    visit '/login'

    fill_in :email, with: merchant_employee.email
    fill_in :password, with: merchant_employee.password

    click_button "Log In"
  end

  it 'When all items in an order have been fulfilled, the order status changes from pending to packaged' do

    visit '/merchant'
    click_link "#{@order_1.id}"
    expect(current_path).to eq("/merchant/orders/#{@order_1.id}")

    expect(page).to have_content("Order status: pending")

    within "#item-#{@paper.id}" do
      click_link("Fulfill #{@paper.name}")
    end

    expect(current_path).to eq("/orders/#{@order_1.id}")

    within "#item-#{@pencil.id}" do
      click_link("Fulfill #{@pencil.name}")
    end

    expect(current_path).to eq("/orders/#{@order_1.id}")
    expect(page).to have_content("Order status: packaged")
  end
end
