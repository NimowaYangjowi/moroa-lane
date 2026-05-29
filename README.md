# Luma & Leaf

Luma & Leaf is a Rails + SQLite commerce simulator for a ChannelTalk technical interview.

The app is intentionally scoped as a realistic example shop, not a full commerce platform. It will look and feel like a small skincare store while focusing on the ChannelTalk integration story: anonymous visitors, signed-in members, customer attributes, cart context, and seeded order history.

## Current Scope

- Rails 8.1
- SQLite
- Native Rails authentication
- Product browsing
- Customer profile context
- Cart and seeded order history
- ChannelTalk Web SDK boot data
- Debug panel for the payload sent to ChannelTalk

## Setup

```sh
bundle install
bin/rails db:setup
bin/rails server
```

Open `http://localhost:3000`.

## Interview Goal

Use this app to explain how a customer moves from an anonymous visitor to a known member, and how ChannelTalk can receive useful support context such as name, email, signup date, recently viewed product, cart value, and previous orders.

## Not In Scope

- Real payment processing
- Shipping integration
- Admin product management
- Inventory management
- Coupons, points, or reviews
- Full Channel Open API implementation
