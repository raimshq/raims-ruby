# Cursor pagination

List methods with cursor pagination return `Raims::ApiList`, with `list`,
`page`, and `last_response`. It includes Ruby's `Enumerable`. `each`, `map`,
and `to_a` process only the current page.

```ruby
page = raims.customers.list({page_size: 20})
page.each { |customer| process_customer(customer.id) }
following = page.next_page
previous = page.previous_page
```

`next_page` and `previous_page` return `nil` when no page exists in that
direction. Navigation preserves filters, page size, resource IDs, and request
options. The cursor for the opposite direction is removed. Do not supply
`after` and `before` together.

Navigation uses a snapshot of the original request parameters and resource ID.
Changing your own input strings after the call does not change that page's
resource or filters. The SDK does not freeze those input strings.

## Iterate across pages

```ruby
raims.charges.list({customer_id: customer_id}).auto_paging_each do |charge|
  process_charge(charge.id)
end

first_hundred = raims.customers.list.auto_paging_to_a(100)
```

`auto_paging_each` returns an enumerator without a block. It fetches the next
page only after the current page has been consumed and continues across empty
pages when the API supplies a continuation cursor. Stop early with `break` or
use `auto_paging_to_a(limit)` to bound collection. A zero limit returns an
empty array without fetching another page.

Missing or repeated continuation cursors raise `UnexpectedResponseError`
instead of looping indefinitely. A failed fetch does not advance the original
page; the caller can retry explicit navigation. Pagination is not a snapshot
of all records: new records and changing filters can affect the results.

## Available webhook event types

`webhook_event_types.list` returns `Raims::WebhookEventTypeListResponse`.
This catalog has a `list` array and no cursor pagination. Iterate over its
`list` field:

```ruby
catalog = raims.webhook_event_types.list
catalog.list.each do |event_type|
  puts event_type.code
end
```
