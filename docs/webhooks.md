# Receiving webhooks

Authenticate the original request body with `Raims::Webhook` before parsing
or processing the event. Use the `secret_key` returned when creating or
rotating the webhook, not an API Bearer key.

```ruby
require 'raims'

payload = request.body.read
headers = {
  'webhook-id' => request.env['HTTP_WEBHOOK_ID'],
  'webhook-timestamp' => request.env['HTTP_WEBHOOK_TIMESTAMP'],
  'webhook-signature' => request.env['HTTP_WEBHOOK_SIGNATURE']
}

begin
  event = Raims::Webhook.construct_event(
    payload, headers, ENV.fetch('RAIMS_WEBHOOK_SECRET')
  )
rescue Raims::SignatureVerificationError
  # Return an HTTP failure using your application's HTTP framework.
end
```

`request` represents your framework's incoming request. Do not reconstruct,
normalize, or reserialize the body: whitespace, Unicode, and line breaks are
part of the signed bytes. Preserve duplicate-header information at the HTTP
boundary so ambiguous signing headers can be rejected. Header names are
case-insensitive; values must be strings or arrays containing one string.

`construct_event` verifies the signature, checks the timestamp, and returns a
hash for an object-shaped JSON body. It does not validate the event's business
meaning. `verify_signature` performs the same authentication without JSON
parsing and returns `nil` on success.

The default tolerance is 300 seconds into the past or future. Override it
with `tolerance:`. Zero requires the same second and does not disable time
protection; negative values are invalid. `now:` accepts Unix seconds for an
injected clock. Keep the server clock synchronized.

The verifier decodes the Raims `whsec_` secret and checks the HMAC-SHA256
signature for `webhook-id.webhook-timestamp.body` with constant-time
comparison. During rotation, it accepts a matching `v1=` signature from a
comma-separated list. Coordinate your secret updates with
`previous_secret_expires_at` and keep secrets out of logs.

Before acknowledging the delivery successfully:

1. Validate the event's type, environment, and resource for your integration.
2. Deduplicate the body's event `id` in durable storage. The `webhook-id`
   header identifies a delivery and does not replace the event ID.
3. Store the work atomically and process its business effects idempotently.
   Return an HTTP failure if durable storage fails.

A valid signature does not prevent duplicate processing within tolerance.
Event `created_at` fields use ISO 8601; the signing timestamp uses Unix seconds.
See the [receiving guide](https://docs.raims.com/en/integracoes/webhooks/receber-eventos)
for delivery conditions.
