# Configuration and responses

## Client configuration

```ruby
raims = Raims::RaimsClient.new(
  ENV.fetch('RAIMS_API_KEY'),
  timeout: 80,
  connect_timeout: 10,
  max_network_retries: 2
)
```

Timeouts use seconds. `timeout` defaults to 80 seconds per attempt and covers
connection, sending, and receiving with the built-in transport. The connection
timeout defaults to 10 seconds and cannot exceed the attempt timeout. Read
retries add their own attempt time and backoff. Timeouts must be positive and
at most 300 seconds. Read retries default to zero and accept values from zero
to five. Writes are never retried automatically.

Reuse a client in your application. It has no global credentials or mutable
global configuration. `close` is idempotent, stops waiting read retries, and
rejects subsequent calls. An HTTP attempt already in progress can finish;
the built-in transport closes its connection after that attempt. Use
`RaimsClient.open` with a block for automatic closure.

`api_base` defaults to `https://api.raims.com`. Custom bases require an HTTPS
origin without credentials, a path, a query, or a fragment. HTTP is accepted
only on loopback for local integration. The transport validates TLS, ignores
proxy environment variables, and does not follow redirects.

## Parameters and options

Pass parameters as the first hash, after a resource ID when required. String
and symbol keys are accepted and retain their public JSON names. Strings and
keys are converted from their declared Ruby encoding to UTF-8. Binary strings
must already contain valid UTF-8 bytes. Invalid text and duplicate field names
after conversion are rejected before sending HTTP. Input strings remain
unchanged. Omitted fields remain absent; `nil` becomes JSON `null`. Whether
null clears a field depends on the endpoint.

```ruby
customer = raims.customers.update(customer_id, {full_name: nil})
charge = raims.charges.retrieve(charge_id, {}, {timeout: 30})
```

Request options are a separate hash or a `Raims::RequestOptions` instance:

```ruby
options = Raims::RequestOptions.new(
  idempotency_key: order_idempotency_key,
  timeout: 80
)
charge = raims.charges.create(charge_params, options)
```

Options support `api_key`, `idempotency_key`, `timeout`, and
`max_network_retries`. A per-request key also determines company, environment,
and permissions for that request and subsequent pages. There is no environment
selector, OAuth configuration, or arbitrary-header option. Use a Sandbox key
for simulations. Sandbox email requests can still send real email.

## Response objects

Responses have generated resource classes such as `Raims::Charge`, field
readers such as `charge.id`, and string or symbol lookup such as
`charge[:amount_cents]`. Unknown future fields remain available through `[]`
and `to_h`. An omitted field and a null field both read as `nil`; use
`key?` to distinguish them.

Objects and nested values are read-only. `to_h` returns a copy that the
application can edit. Response enums accept future values. Integer cents and
timestamps retain integer precision, including integers beyond JavaScript's
safe range. Fractional JSON numbers are represented as `BigDecimal`.
Decimals outside the supported exponent range are rejected rather than
rounded to zero or converted to infinity.

`last_response` on the top-level result exposes `status_code`, `request_id`,
`retry_after`, `idempotency_replayed?`, and HTTP `headers`. An empty success
response returns `nil`. Default object representations hide response data;
explicitly reading fields, `to_h`, error details, or headers can expose sensitive
information and needs your application's logging controls.

## Documents and uploads

Document methods return metadata and temporary URLs. The SDK does not download
these URLs or attach the API key to other hosts. Upload methods prepare a
temporary upload URL and the required headers; your application sends the
bytes separately and associates the resulting asset as described by the API.
Keep temporary URLs private and respect expiry and required headers.

## Request diagnostics

```ruby
raims = Raims::RaimsClient.new(
  ENV.fetch('RAIMS_API_KEY'),
  request_observer: ->(event) { record_duration(event.operation_id, event.duration_ms) }
)
```

`record_duration` represents your metrics function. An observer receives one
`RequestDiagnostics` per attempt, including the operation, HTTP method, path
template, attempt number, duration in milliseconds, HTTP status, request ID,
and planned retry delay. It receives no resource IDs, query parameters,
credentials, or request and response bodies. Observer exceptions do not alter
the request result. Recursive notifications for the same client within one
Fiber are suppressed.
Independent Fibers receive their own events, including when an observer yields.

Successful bodies are checked against the published response structure.
Invalid HTTP response headers, JSON or compression, undocumented success
statuses, redirects, and incompatible structures raise `UnexpectedResponseError`.
The transport also rejects conflicting body lengths, unsupported or ambiguous
transfer framing, and responses that end before the declared body is complete.
Repeated length values are accepted only when they agree. Response bodies are
limited to 16 MiB after decompression. A declared length above 16 MiB is rejected
for responses that carry a body. Responses with no body retain their HTTP
semantics. Request body limits follow the pinned contract.
