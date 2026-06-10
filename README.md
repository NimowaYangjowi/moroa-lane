# Acme Corp

Acme Corp is a Rails commerce demo for a realistic skincare shop. It uses SQLite locally and PostgreSQL on Railway.

The goal is to look like a realistic DTC skincare shop while staying intentionally small. The app is not a full commerce platform. It shows how ChannelTalk can identify a visitor, attach member data after login, and give a support team useful shopping context.

## What This Demonstrates

- Anonymous visitor browsing products before login
- Native Rails signup and login
- Stable `memberId` based on the local shop user
- Customer profile fields: name, email, signup date, customer tier, skin type
- Product browsing context
- Cart context: item count and cart total
- Seeded order history
- ChannelTalk tags for non-sensitive customer segmentation
- ChannelTalk Web SDK boot options
- `/debug/channel` payload inspection page

## Tech Stack

- Ruby 3.3.6
- Rails 8.1
- SQLite for local development and tests
- PostgreSQL for Railway production
- Rails native authentication
- ERB views
- ChannelTalk Web SDK

## Setup

```sh
bundle install
bin/rails db:setup
bin/dev
```

Open `http://localhost:3001`.

`bin/dev` uses port 3001 by default because port 3000 is often already occupied during local development.

## GitHub Pages

The static preview is published from `docs/`:

https://nimowayangjowi.github.io/acme-corp/

To refresh the static preview after changing Rails views, run the Rails server and export again:

```sh
bin/dev
script/export_static_pages
```

GitHub Pages can show the storefront screens, but it cannot run Rails actions such as real login, signup, cart updates, or SQLite-backed account pages. Those flows run in the local Rails app.

To use another port:

```sh
PORT=3002 bin/dev
# or
bin/dev -p 4000
```

If the database already exists, run:

```sh
bin/rails db:migrate db:seed
```

## Demo Account

```text
Email: jiwoo@example.com
Password: password123
```

## ChannelTalk Settings

The app works without a real ChannelTalk plugin key. In that case, it shows a local floating "ChannelTalk demo" button that opens `/debug/channel`.

To boot the real SDK locally, copy the example environment file and fill in your values:

```sh
cp .env.example .env
```

```env
CHANNELTALK_PLUGIN_KEY=your_plugin_key
CHANNELTALK_MEMBER_HASH_SECRET=your_member_hash_secret
```

Then restart the development server:

```sh
bin/dev
```

You can still set the values directly in the shell if you prefer:

```sh
export CHANNELTALK_PLUGIN_KEY="your_plugin_key"
export CHANNELTALK_MEMBER_HASH_SECRET="your_member_hash_secret"
bin/dev
```

`CHANNELTALK_PLUGIN_KEY` connects the Web SDK to a ChannelTalk channel. `CHANNELTALK_MEMBER_HASH_SECRET` is optional in this local simulator, but the official docs recommend member hash when `memberId` values are predictable.

## Demo Flow

1. Open the home page and show that this looks like a real skincare shop.
2. Open `Shop` and click a product.
3. Point out that a product page is where a customer naturally asks support questions.
4. Open `Channel Debug` before login. The payload has no `memberId`, so this is an anonymous visitor.
5. Log in with the demo account.
6. Open a few product pages to create recent browsing context.
7. Add a product to the cart.
8. Open `My page` and show member fields, recent views, cart summary, and seeded order history.
9. Open `Channel Debug` again. The payload now includes `memberId`, profile fields, cart context, and order context.

## Interview Talking Points

`memberId` is the stable ID ChannelTalk uses to recognize the same member user. In this app, it is built from the local user's UUID as `shop_user_#{uuid}`. Email is useful profile data, but it can change, so it should not be the primary identity key.

The customer-facing account page only shows details a shopper expects to see, such as name, email, signup date, customer tier, skin type, cart summary, recent products, and order history. Internal identifiers stay out of the customer UI and are used only for integration.

Anonymous, Lead, and Member can be explained from the UI:

- Anonymous: a visitor browsing the shop before the app knows who they are.
- Lead: a visitor who leaves contact information during a conversation. This simulator does not deeply implement Lead conversion, but the concept fits the pre-login support flow.
- Member: a logged-in shop user with a stable `memberId` and profile fields.

The `/debug/channel` page is the developer troubleshooting view. It answers the first integration questions: Which plugin key is being used? Is `memberId` present? Which profile fields are being sent? Is member hash enabled?

## Not In Scope

- Real payment processing
- Shipping integration
- Admin product management
- Inventory management
- Coupons, points, or reviews
- Full Channel Open API implementation
- Production deployment

## Tests

```sh
bin/rails test
```

## Planning Docs

The phase plan and review log live in `tasks/channel-talk-commerce-simulator`.
