# Raims Ruby

Official Ruby SDK for the Raims public API.

Use resource services, read-only response objects, cursor pagination, structured
errors, and webhook signature verification in server applications. Requires
Ruby 3.3 or later.

## Install from GitHub

Source code and the packaged gem are available in the
[current stable release](https://github.com/raimshq/raims-ruby/releases/latest).
The SDK is not yet published on RubyGems. Download the gem and its checksums:

```sh
gh release download --repo raimshq/raims-ruby --pattern raims.gem --pattern SHA256SUMS --dir raims-ruby-release
```

Verify `raims.gem` against `SHA256SUMS`, following the
[installation guide](docs/installation.md#verify-the-download), then install it:

```sh
gem install ./raims-ruby-release/raims.gem
```

Installation resolves the gem's declared runtime dependencies. Load the SDK
with `require 'raims'`. See [installation and updates](docs/installation.md)
for Bundler and updating an existing installation.

## First request

```ruby
require 'raims'

Raims::RaimsClient.open(ENV.fetch('RAIMS_API_KEY')) do |raims|
  customers = raims.customers.list({page_size: 20})
  customers.each do |customer|
    process_customer(customer.id)
  end
end
```

`process_customer` represents your application's processing. The base URL is
`https://api.raims.com` for both Sandbox and Production. The key determines
the company, environment, and permissions. Keep it on the server, outside
source control and logs.

## Create a charge

Define and persist `customer_id`, `due_date`, and `order_idempotency_key` for
the order before sending the request. Amounts use integer cents: `15000`
represents BRL 150.00. The due date uses UTC Unix seconds.

```ruby
raims = Raims::RaimsClient.new(ENV.fetch('RAIMS_API_KEY'))

begin
  charge = raims.charges.create(
    {customer_id: customer_id, amount_cents: 15000, due_date: due_date,
     title: 'Order 1234'},
    {idempotency_key: order_idempotency_key}
  )
  request_id = charge.last_response.request_id
ensure
  raims.close
end
```

The SDK does not generate idempotency keys or retry writes automatically.
After losing a response, keep the same key and parameters and follow the
endpoint's recovery rules. HTTP `202` means processing is pending; retrieve
the resource to follow the result.

## Pagination

```ruby
Raims::RaimsClient.open(ENV.fetch('RAIMS_API_KEY')) do |raims|
  raims.customers.list({page_size: 50}).auto_paging_each do |customer|
    process_customer(customer.id)
  end
end
```

`each` reads only the current page. `auto_paging_each` fetches further pages
as needed and preserves filters and request options. `next_page` and
`previous_page` provide explicit navigation. Use `auto_paging_to_a(limit)`
to collect a bounded number of items.

## Services

| Property | Resources |
| --- | --- |
| `accounts` | Account context, number, fees, and checkout settings |
| `balances` | Balance and forecast |
| `customers` | Customer creation, retrieval, updates, and deletion |
| `charges` | Charges, payment details, documents, and charge refunds |
| `payment_links` | Payment links and email delivery requests |
| `refunds` | Refunds and receipts |
| `disputes` | Disputes |
| `statements` | Account statements |
| `withdrawals` | Withdrawals, limits, summary, and automatic settings |
| `withdrawal_destinations` | Withdrawal destinations |
| `webhooks` | Registration, health, pause, test, and secret rotation |
| `webhook_event_types` | Available event types |
| `simulations.charges` | Charge simulations with a Sandbox key |
| `simulations.refunds` | Refund simulations with a Sandbox key |

Services expose methods such as `create`, `retrieve`, `update`, `delete`, and
`list` according to the public contract. See the [method reference](docs/reference.md).

## Documentation

- [Installation and updates](docs/installation.md)
- [Configuration, responses, and documents](docs/usage.md)
- [Pagination](docs/pagination.md)
- [Errors, idempotency, and retries](docs/errors-and-retries.md)
- [Receiving webhooks](docs/webhooks.md)
- [Maintenance and contract](docs/maintenance.md)
- [Contributing](CONTRIBUTING.md) and [security](SECURITY.md)
- [Public API](https://docs.raims.com/en/api)

Distributed under the [MIT license](LICENSE).
