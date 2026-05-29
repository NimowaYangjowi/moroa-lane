require "openssl"

class ChannelPayload
  def self.build(user:, plugin_key:, member_hash_secret: nil)
    new(user:, plugin_key:, member_hash_secret:).build
  end

  def initialize(user:, plugin_key:, member_hash_secret:)
    @user = user
    @plugin_key = plugin_key
    @member_hash_secret = member_hash_secret
  end

  def build
    return anonymous_payload unless user

    payload = {
      pluginKey: plugin_key,
      memberId: user.member_id,
      language: "en",
      profile: member_profile
    }

    payload[:memberHash] = member_hash if member_hash_secret.present?
    payload
  end

  private

  attr_reader :user, :plugin_key, :member_hash_secret

  def anonymous_payload
    {
      pluginKey: plugin_key,
      language: "en"
    }
  end

  def member_profile
    {
      name: user.name,
      email: user.email_address,
      signupDate: user.created_at.iso8601,
      customerTier: user.customer_tier,
      skinType: user.skin_type,
      cartItemsCount: user.cart_items_count,
      cartTotal: format_money(user.cart_total_cents),
      lastViewedProduct: last_viewed_product&.name,
      lastOrderAt: last_order&.placed_at&.iso8601
    }.compact
  end

  def last_viewed_product
    @last_viewed_product ||= user.product_views.includes(:product).order(viewed_at: :desc).first&.product
  end

  def last_order
    @last_order ||= user.orders.order(placed_at: :desc).first
  end

  def member_hash
    OpenSSL::HMAC.hexdigest("SHA256", member_hash_secret, user.member_id)
  end

  def format_money(cents)
    format("$%.2f", cents.to_i / 100.0)
  end
end
