products = [
  {
    name: "Cloud Barrier Cream",
    slug: "cloud-barrier-cream",
    category: "Moisturizer",
    description: "A rich daily cream for customers who ask support whether a product will calm dry, stressed skin without feeling heavy.",
    price_cents: 4200,
    image_url: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=1200&q=80",
    skin_type: "Dry skin",
    featured: true
  },
  {
    name: "Glass Dew Serum",
    slug: "glass-dew-serum",
    category: "Serum",
    description: "A lightweight hydrating serum that creates an easy support scenario around routine order, ingredient fit, and sensitive skin questions.",
    price_cents: 3800,
    image_url: "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?auto=format&fit=crop&w=1200&q=80",
    skin_type: "All skin",
    featured: true
  },
  {
    name: "Mineral Calm SPF 40",
    slug: "mineral-calm-spf-40",
    category: "Sunscreen",
    description: "A mineral sunscreen for customers comparing texture, white cast, and delivery timing before checkout.",
    price_cents: 3200,
    image_url: "https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=1200&q=80",
    skin_type: "Sensitive skin",
    featured: true
  },
  {
    name: "Rice Milk Cleanser",
    slug: "rice-milk-cleanser",
    category: "Cleanser",
    description: "A soft morning cleanser that helps demonstrate product detail questions before a visitor becomes a signed-in member.",
    price_cents: 2600,
    image_url: "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?auto=format&fit=crop&w=1200&q=80",
    skin_type: "Combination skin",
    featured: false
  },
  {
    name: "Night Reset Ampoule",
    slug: "night-reset-ampoule",
    category: "Treatment",
    description: "A concentrated night treatment for support conversations about usage frequency, irritation, and previous purchase history.",
    price_cents: 4600,
    image_url: "https://images.unsplash.com/photo-1598662972299-5408ddb8a3dc?auto=format&fit=crop&w=1200&q=80",
    skin_type: "Normal skin",
    featured: false
  },
  {
    name: "Soft Cotton Toner Pads",
    slug: "soft-cotton-toner-pads",
    category: "Toner",
    description: "A daily toner pad set that makes cart questions and bundle recommendations feel natural during the demo.",
    price_cents: 2900,
    image_url: "https://images.unsplash.com/photo-1617897903246-719242758050?auto=format&fit=crop&w=1200&q=80",
    skin_type: "Oily skin",
    featured: false
  }
]

products.each do |attributes|
  Product.find_or_initialize_by(slug: attributes[:slug]).tap do |product|
    product.update!(attributes)
  end
end

demo_user = User.find_or_initialize_by(email_address: "jiwoo@example.com")
demo_user.update!(
  name: "Jiwoo Kim",
  password: "password123",
  password_confirmation: "password123",
  customer_tier: "New",
  skin_type: "Combination skin"
)

demo_user.product_views.destroy_all
demo_user.cart_items.destroy_all
demo_user.orders.destroy_all

Product.featured.limit(2).each_with_index do |product, index|
  ProductView.find_or_initialize_by(
    user: demo_user,
    product: product
  ).update!(viewed_at: (index + 1).hours.ago)
end

CartItem.find_or_initialize_by(
  user: demo_user,
  product: Product.find_by!(slug: "glass-dew-serum")
).update!(quantity: 2)

past_order = Order.find_or_initialize_by(
  user: demo_user,
  placed_at: Time.zone.parse("2026-05-12 10:15:00")
)
past_order.update!(status: "delivered", total_cents: 7800)

[
  [ "rice-milk-cleanser", 1, 2600 ],
  [ "soft-cotton-toner-pads", 1, 2900 ],
  [ "mineral-calm-spf-40", 1, 2300 ]
].each do |slug, quantity, price_cents|
  OrderItem.find_or_initialize_by(
    order: past_order,
    product: Product.find_by!(slug: slug)
  ).update!(quantity: quantity, price_cents: price_cents)
end
