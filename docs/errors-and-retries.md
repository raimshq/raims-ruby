# Errors, idempotency, and retries

Catch `Raims::RaimsError` for SDK failures. Invalid local configuration or
arguments raise `ArgumentError` before sending HTTP.

| Error | Meaning |
| --- | --- |
| `AuthenticationError` | HTTP 401 |
| `PermissionError` | HTTP 403 |
| `NotFoundError` | HTTP 404 |
| `ConflictError` | HTTP 409 |
| `RateLimitError` | HTTP 429 |
| `InvalidRequestError` | HTTP 400, 405, 413, 415, or 422 |
| `ApiError` | Other unsuccessful HTTP statuses |
| `ConnectionError` | Connection, TLS, timeout, or closed-client failure |
| `UnexpectedResponseError` | Redirect, oversized or incomplete response, invalid HTTP framing, compression or JSON, or incompatible success response |
| `SignatureVerificationError` | Invalid webhook authentication or authenticated JSON |

HTTP errors expose `http_status` (also `status_code`), `request_id`,
`retry_after`, `code`, `details`, `api_error`, and `last_response` when
available. `details` contains the field validation failures returned by the
API, as hashes with `field`, `code`, and `message`. It is `nil` when no field
details are present. Use codes to decide how your integration handles an error.
`api_error` preserves the complete structured error. The error's default
message and representation omit payload data.

The existing `param` and `errors` readers remain available for compatibility;
the public API uses `details` for field validation failures.

```ruby
begin
  customer = raims.customers.retrieve(customer_id)
rescue Raims::RateLimitError => error
  record_rate_limit(error.request_id, error.retry_after)
rescue Raims::ApiError => error
  handle_api_failure(error.http_status, error.code, error.request_id)
end
```

The example's handlers belong to your application. Avoid logging complete
error objects, error fields, or HTTP headers when they contain private data.

## Read retries

Set `max_network_retries` on the client or in request options. It defaults to
zero and accepts integers from zero to five. Only GET and HEAD requests can
be repeated automatically, after a connection failure or HTTP 408, 429, 500,
502, 503, or 504. Malformed success responses are not retried.

Backoff uses jitter with a maximum of two seconds before server hints.
`Retry-After` accepts seconds or an HTTP date. A valid hint above 30 seconds
stops automatic retry and returns the error to the application. The SDK does
not sleep for a shorter period than a valid hint. Each attempt has its own
timeout; the entire retry sequence can take longer.

## Writes and pending results

POST, PATCH, PUT, and DELETE are never repeated automatically, even with an
idempotency key or a positive retry setting. The SDK does not generate keys.
Define and persist an operation key before sending a write and pass it only
to endpoints that accept it.

A network error does not establish whether a write was processed. Reconcile
the operation before creating another one. If the endpoint permits a retry,
reuse the same key and all original parameters, including timestamps. Do not
use a new key solely because a response was lost.

HTTP `202` remains a pending response with its original metadata. It does not
confirm payment, cancellation, withdrawal, or refund completion. Retrieve
the resource or process the relevant webhook to follow the outcome.
