# Ruby SDK reference

Generated from the public contract pinned in `contracts/source.json`.

Access these services through `Raims::RaimsClient`. Methods accept parameter hashes followed by request options. Methods for a single resource take its ID first.

| Service and method | HTTP operation | Input | Response |
| --- | --- | --- | --- |
| `accounts.retrieve_fees` | `GET /v1/accounts/fees` | - | `Raims::AccountFees` |
| `accounts.retrieve_number` | `GET /v1/accounts/account_number` | - | `Raims::AccountNumber` |
| `accounts.retrieve_checkout_settings` | `GET /v1/accounts/checkout_settings` | - | `Raims::CheckoutSettings` |
| `accounts.update_checkout_settings` | `PATCH /v1/accounts/checkout_settings` | [`UpdateCheckoutSettingsParams`](#updatecheckoutsettingsparams) | `Raims::CheckoutSettings` |
| `accounts.create_checkout_logo_upload` | `POST /v1/accounts/checkout_settings/logo_uploads` | [`CreateCheckoutLogoUploadParams`](#createcheckoutlogouploadparams) | `Raims::CheckoutAssetUpload` |
| `accounts.create_checkout_favicon_upload` | `POST /v1/accounts/checkout_settings/favicon_uploads` | [`CreateCheckoutFaviconUploadParams`](#createcheckoutfaviconuploadparams) | `Raims::CheckoutAssetUpload` |
| `accounts.delete_checkout_asset_upload` | `DELETE /v1/accounts/checkout_settings/uploads/{id}` | - | `Raims::CheckoutAssetUploadDeleted` |
| `accounts.retrieve_context` | `GET /v1/accounts/context` | - | `Raims::AccountContext` |
| `balances.retrieve` | `GET /v1/balances` | - | `Raims::Balance` |
| `balances.forecast` | `GET /v1/balances/forecast` | [`GetBalanceForecastParams`](#getbalanceforecastparams) | `Raims::BalanceForecast` |
| `charges.create` | `POST /v1/charges` | [`CreateChargeParams`](#createchargeparams) | `Raims::ChargeCreated` |
| `charges.list` | `GET /v1/charges` | [`ListChargesParams`](#listchargesparams) | `Raims::ApiList` |
| `charges.retrieve` | `GET /v1/charges/{id}` | - | `Raims::Charge` |
| `charges.update` | `PATCH /v1/charges/{id}` | [`UpdateChargeParams`](#updatechargeparams) | `Raims::Charge` |
| `charges.revoke` | `DELETE /v1/charges/{id}` | - | `Raims::ChargeRevoked or Raims::ChargeRevocationPending` |
| `charges.retrieve_payment` | `GET /v1/charges/{id}/payment` | - | `Raims::PaymentReceipt` |
| `charges.retrieve_receipt` | `GET /v1/charges/{id}/receipt` | - | `Raims::FinancialDocument` |
| `charges.retrieve_boleto` | `GET /v1/charges/{id}/boleto` | - | `Raims::FinancialDocument` |
| `charges.create_refund` | `POST /v1/charges/{id}/refunds` | [`CreateRefundParams`](#createrefundparams) | `Raims::Refund` |
| `charges.list_refunds` | `GET /v1/charges/{id}/refunds` | [`ListChargeRefundsParams`](#listchargerefundsparams) | `Raims::ApiList` |
| `charges.retrieve_refund_eligibility` | `GET /v1/charges/{id}/refund_eligibility` | - | `Raims::RefundEligibility` |
| `charges.statistics` | `GET /v1/charges/statistics` | [`GetChargeStatisticsParams`](#getchargestatisticsparams) | `Raims::ChargeStatistics` |
| `customers.create` | `POST /v1/customers` | [`CreateCustomerParams`](#createcustomerparams) | `Raims::CustomerCreated` |
| `customers.list` | `GET /v1/customers` | [`ListCustomersParams`](#listcustomersparams) | `Raims::ApiList` |
| `customers.retrieve` | `GET /v1/customers/{id}` | - | `Raims::CustomerListItem` |
| `customers.update` | `PATCH /v1/customers/{id}` | [`UpdateCustomerParams`](#updatecustomerparams) | `Raims::CustomerListItem` |
| `customers.delete` | `DELETE /v1/customers/{id}` | - | `Raims::CustomerDeleted` |
| `customers.delete_batch` | `DELETE /v1/customers` | [`DeleteCustomersBatchParams`](#deletecustomersbatchparams) | `Raims::CustomerBatchDeleted` |
| `disputes.list` | `GET /v1/disputes` | [`ListDisputesParams`](#listdisputesparams) | `Raims::ApiList` |
| `disputes.retrieve` | `GET /v1/disputes/{id}` | - | `Raims::Dispute` |
| `payment_links.create` | `POST /v1/payment_links` | [`CreatePaymentLinkParams`](#createpaymentlinkparams) | `Raims::PaymentLink` |
| `payment_links.list` | `GET /v1/payment_links` | [`ListPaymentLinksParams`](#listpaymentlinksparams) | `Raims::ApiList` |
| `payment_links.retrieve` | `GET /v1/payment_links/{id}` | - | `Raims::PaymentLinkDetails` |
| `payment_links.update` | `PATCH /v1/payment_links/{id}` | [`UpdatePaymentLinkParams`](#updatepaymentlinkparams) | `Raims::PaymentLink` |
| `payment_links.send_email` | `POST /v1/payment_links/{id}/send_email` | - | `Raims::PaymentLinkEmailRequestAccepted` |
| `refunds.list` | `GET /v1/refunds` | [`ListRefundsParams`](#listrefundsparams) | `Raims::ApiList` |
| `refunds.retrieve` | `GET /v1/refunds/{id}` | - | `Raims::Refund` |
| `refunds.retrieve_receipt` | `GET /v1/refunds/{id}/receipt` | - | `Raims::FinancialDocument` |
| `statements.list` | `GET /v1/statements` | [`ListStatementsParams`](#liststatementsparams) | `Raims::ApiList` |
| `statements.retrieve` | `GET /v1/statements/{id}` | - | `Raims::Statement` |
| `webhook_event_types.list` | `GET /v1/webhook_event_types` | - | `Raims::WebhookEventTypeListResponse` |
| `webhooks.create` | `POST /v1/webhooks` | [`CreateWebhookParams`](#createwebhookparams) | `Raims::WebhookCreated` |
| `webhooks.list` | `GET /v1/webhooks` | [`ListWebhooksParams`](#listwebhooksparams) | `Raims::ApiList` |
| `webhooks.retrieve` | `GET /v1/webhooks/{webhook_id}` | - | `Raims::Webhook` |
| `webhooks.update` | `PATCH /v1/webhooks/{webhook_id}` | [`UpdateWebhookParams`](#updatewebhookparams) | `Raims::Webhook` |
| `webhooks.delete` | `DELETE /v1/webhooks/{webhook_id}` | - | `nil` |
| `webhooks.retrieve_health` | `GET /v1/webhooks/{webhook_id}/health` | - | `Raims::WebhookHealth` |
| `webhooks.set_pause` | `PATCH /v1/webhooks/{webhook_id}/pause` | [`SetWebhookPauseParams`](#setwebhookpauseparams) | `Raims::WebhookPause` |
| `webhooks.rotate_secret` | `POST /v1/webhooks/{webhook_id}/rotate_secret` | [`RotateWebhookSecretParams`](#rotatewebhooksecretparams) | `Raims::WebhookSecretRotation` |
| `webhooks.test` | `POST /v1/webhooks/{webhook_id}/test` | - | `Raims::WebhookTestAccepted` |
| `withdrawal_destinations.list` | `GET /v1/withdrawal_destinations` | [`ListWithdrawalDestinationsParams`](#listwithdrawaldestinationsparams) | `Raims::ApiList` |
| `withdrawal_destinations.retrieve` | `GET /v1/withdrawal_destinations/{id}` | - | `Raims::WithdrawalDestination` |
| `withdrawals.create` | `POST /v1/withdrawals` | [`CreateWithdrawalParams`](#createwithdrawalparams) | `Raims::Withdrawal` |
| `withdrawals.list` | `GET /v1/withdrawals` | [`ListWithdrawalsParams`](#listwithdrawalsparams) | `Raims::ApiList` |
| `withdrawals.retrieve` | `GET /v1/withdrawals/{id}` | - | `Raims::Withdrawal` |
| `withdrawals.retrieve_limits` | `GET /v1/withdrawals/limits` | - | `Raims::WithdrawalLimits` |
| `withdrawals.retrieve_summary` | `GET /v1/withdrawals/summary` | - | `Raims::WithdrawalSummary` |
| `withdrawals.retrieve_automatic_settings` | `GET /v1/withdrawals/automatic_settings` | - | `Raims::AutomaticWithdrawalSettings` |
| `withdrawals.update_automatic_settings` | `PATCH /v1/withdrawals/automatic_settings` | [`UpdateAutomaticWithdrawalSettingsParams`](#updateautomaticwithdrawalsettingsparams) | `Raims::AutomaticWithdrawalSettings` |
| `simulations.charges.confirm_payment` | `POST /v1/simulations/charges/{id}/confirm_payment` | - | `Raims::ChargeSimulation` |
| `simulations.charges.fail_payment` | `POST /v1/simulations/charges/{id}/fail_payment` | - | `Raims::ChargeSimulation` |
| `simulations.charges.configure_scenario` | `POST /v1/simulations/charges/{id}/scenario` | [`ConfigureSimulationScenarioParams`](#configuresimulationscenarioparams) | `Raims::ChargeScenario` |
| `simulations.charges.resolve_scenario` | `POST /v1/simulations/charges/{id}/resolve` | [`ResolveSimulationScenarioParams`](#resolvesimulationscenarioparams) | `Raims::ChargeScenario` |
| `simulations.charges.issue_payment` | `POST /v1/simulations/charges/{id}/issue_payment` | [`IssueSimulationPaymentParams`](#issuesimulationpaymentparams) | `Raims::Charge` |
| `simulations.charges.compensate_boleto` | `POST /v1/simulations/charges/{id}/compensate_boleto` | - | `Raims::ChargeBoletoCompensation` |
| `simulations.charges.create_refund` | `POST /v1/simulations/charges/{id}/refunds` | [`CreateSimulationRefundParams`](#createsimulationrefundparams) | `Raims::Refund` |
| `simulations.refunds.complete` | `POST /v1/simulations/refunds/{id}/complete` | - | `Raims::Refund` |
| `simulations.refunds.fail` | `POST /v1/simulations/refunds/{id}/fail` | - | `Raims::Refund` |

`ApiList#each` visits only the items already received. Use `auto_paging_each` to fetch subsequent pages. `next_page` and `previous_page` provide explicit navigation.

Inputs use the API's JSON names as string or symbol keys. Omitting a field and sending `nil` are distinct actions. Responses preserve new fields and values. Monetary amounts remain integer cents, and resource dates use Unix seconds UTC. HTTP `202` indicates a pending result.

## Input parameters

The names below identify parameter hashes, not separate Ruby classes. `nil` corresponds to JSON `null`; optional fields may be omitted. Required fields and business rules are enforced by the API.

### UpdateChargeParams

Update an existing charge.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `title` | `String or nil` | No | Charge title. Omit it to keep the current title; send null or empty text to remove it. |
| `description` | `String or nil` | No | Charge description. Omit it to keep the current description; send null or empty text to remove it. |
| `external_reference` | `String or nil` | No | Order or charge reference in your system. Omit it to keep the current value; send null or empty text to remove it. It may be repeated on other charges and is independent of the customer reference. |
| `metadata` | `Hash or nil` | No | Integration data associated with the resource. Supply key and text pairs. Keys are case-sensitive. Omission or {} preserves the data; null removes all pairs, and null for a key removes only that key. Empty text is a valid value. |

### ListChargesParams

List charges.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Charges per page. Positive integers above the maximum use the maximum. Omitted, empty, zero, negative, or invalid values use 10. |
| `after` | `String` | No | Copy page.next_after from the previous response to move forward. Keep the same filters and sort order; do not send before as well. Leave it empty to start the list. |
| `before` | `String` | No | Copy page.previous_before from the previous response to move backward. Keep the same filters and sort order; do not send after as well. Leave it empty if you do not want to go backward. |
| `identifier` | `String` | No | Filter by the complete charge ID. If there is no match, list is empty. |
| `customer_id` | `String` | No | Filter by the customer's complete public ID returned when creating or retrieving the customer. The relationship remains unchanged if the name or email changes. It can be combined with other filters; keep the same customer_id when changing pages. A valid ID with no charges in the authenticated company and environment returns an empty list. An empty or omitted value does not apply the filter. |
| `external_reference` | `String` | No | Filter by the charge's current reference in your system, matching the complete value, including case and accents. An empty or omitted value does not apply the filter. It can be combined with other filters; preserve the value when navigating by cursor. After creating or editing a charge, it may take a few seconds for search to reflect the reference. |
| `email` | `String` | No | Filter by the complete email address recorded on the charge. Editing the customer record does not change that email address. |
| `status` | `String` | No | Filter by one or more comma-separated codes, such as 0,1. 0 created, 1 awaiting payment, 2 authorized, 3 processing, 4 paid, 5 partially refunded, 6 refunded, 7 cancelled, 8 expired, 9 failed, 10 chargeback, 11 chargeback under review, 12 chargeback lost, and 13 chargeback won. Changes may take a few seconds to appear. |
| `payment_method` | `String` | No | Filter by the charge's payment method: 1 for Pix and 2 for boleto. To combine them, send 1,2. A charge with an undefined method may switch to Pix or boleto when the Pix code or boleto is generated in checkout. Selecting a method on the page alone does not change the filter. |
| `created_gte` | `Integer` | No | Filter charges created at or after this instant, inclusive, in Unix seconds UTC. If created_lte is supplied, this value must be less than or equal to it. |
| `created_lte` | `Integer` | No | Filter charges created at or before this instant, inclusive, in Unix seconds UTC. |
| `due_gte` | `Integer` | No | Filter charges due at or after this instant, inclusive, in Unix seconds UTC. It can be combined with due_lte and other filters; preserve the value when changing pages. |
| `due_lte` | `Integer` | No | Filter charges due at or before this instant, inclusive, in Unix seconds UTC. If due_gte is supplied, this value must be greater than or equal to it. It can be used alone or with other filters. |
| `paid_gte` | `Integer` | No | Filter charges paid at or after this instant, inclusive, in Unix seconds UTC. Uses the confirmed payment date, even if a refund occurred later. Charges without a confirmed payment are excluded. Preserve the value when changing pages. |
| `paid_lte` | `Integer` | No | Filter charges paid at or before this instant, inclusive, in Unix seconds UTC. If paid_gte is supplied, this value must be greater than or equal to it. It can be combined with other filters. |
| `sort_key` | `String` | No | Sort by the amount in cents or creation date. If omitted, uses registration order; with a creation-date filter, uses created_at. Keep the same sort order when changing pages. |
| `sort_order` | `String` | No | Set the sort direction. With desc, the default order shows the newest charges first. |

### CreateChargeParams

Create a new charge.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `customer_id` | `String` | Yes | ID of a customer in the authenticated company and environment. Copy the id returned when creating or retrieving the customer. Direct Pix requires a valid CPF/CNPJ. Direct boleto requires a name, valid email address, CPF/CNPJ, and address including CEP and street number; complete those fields on the customer record. |
| `amount_cents` | `Integer` | Yes | Charge amount in Brazilian real cents. For example, 10000 represents BRL 100.00. |
| `payment_method` | `Integer` | No | Charge payment method. Omit it or send 0 to allow selection in checkout. Without payment_method_types, 1 requests Pix and 2 requests boleto at creation, subject to enabled methods. Boleto uses the customer's address and fills missing fields from the CEP when available. With a custom list, send 0 or omit this field; issuance occurs after the checkout selection. |
| `due_date` | `Integer` | Yes | Due date in Unix seconds UTC, at least five minutes in the future. The latest date is today plus ten years, using the São Paulo calendar. |
| `title` | `String or nil` | No | Charge title. You may leave this field empty. |
| `description` | `String or nil` | No | Charge description. You may leave this field empty. |
| `send_email` | `Boolean` | No | With true, requests delivery of the charge to the customer's email address and generates checkout_url. For pending accounts, the customer must use the account's primary email address. Outside that condition, a missing or invalid email prevents delivery but still allows charge creation when there is no direct boleto issuance. Direct boleto requires a valid email even with false. The response does not confirm message delivery. |
| `create_checkout` | `Boolean` | No | With true, generates the link returned in checkout_url without requiring a return URL or requesting email delivery. With false, the link is still generated when send_email is true or a return URL is supplied. |
| `success_redirect_url` | `String or nil` | No | HTTPS URL on your website for returning after confirmed payment. Redirection does not prove payment; retrieve the charge to confirm it. Credentials in the address, literal IPs, localhost, and Raims domains are not accepted. When supplied, generates checkout_url even with send_email false. If omitted, empty, or null, no return destination is set. |
| `cancel_redirect_url` | `String or nil` | No | HTTPS URL on your website for the payer to return from checkout. Returning does not cancel the charge, Pix, or boleto. Credentials in the address, literal IPs, localhost, and Raims domains are not accepted. When supplied, generates checkout_url even with send_email false. If omitted, empty, or null, no return destination is set. |
| `payment_method_types` | `Array<Integer> or nil` | No | Allowed methods for the charge: 1 for Pix and 2 for boleto. Omission or null uses the inherited checkout settings. Supply a list without duplicates. A custom configuration replaces the account default; a link configuration can only restrict that list. Combine with payment_method omitted or set to 0. |
| `external_reference` | `String or nil` | No | Order or charge reference in your system. Null, empty text, or whitespace leaves it without a reference. It may be repeated and does not prevent duplicate charges. It differs from the reference on the customer record. |
| `metadata` | `Hash or nil` | No | Integration data associated with the charge, as key and text pairs. Keys are case-sensitive. Omission, null, or {} creates the charge without this data; pairs with a null value are not included. Empty text is a valid value. |

### CreateCustomerParams

Create a customer.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `full_name` | `String or nil` | No | Payer's full name. |
| `tax_id` | `String` | Yes | Valid CPF or CNPJ, with or without periods, slash, hyphen, and spaces. |
| `email` | `String or nil` | No | Payer's email address. Recording an email address does not send a message. |
| `dial_code` | `String or nil` | No | International dialing code. It may be supplied without phone_local. |
| `phone_local` | `String or nil` | No | Phone number without the dialing code, with or without punctuation. It may be supplied without dial_code. |
| `zip_code` | `String or nil` | No | Address CEP, with or without a hyphen. If street, neigh, city, uf, street_number, and complement are empty, the CEP may populate street, neighborhood, city, and state. It does not populate the street number or address complement. |
| `street` | `String or nil` | No | Address street. |
| `street_number` | `String or nil` | No | Address street number. |
| `complement` | `String or nil` | No | Address complement. |
| `neigh` | `String or nil` | No | Address neighborhood. |
| `city` | `String or nil` | No | Address city. |
| `uf` | `String or nil` | No | State abbreviation, such as SP. |
| `external_reference` | `String or nil` | No | Customer identifier in your system. For an existing customer, omit it to keep the reference, or send null or empty text to remove it. Use external_reference in the customer list to search for this value. |
| `metadata` | `Hash or nil` | No | Integration data associated with the resource. Supply key and text pairs. Keys are case-sensitive. Omission or {} preserves the data; null removes all pairs, and null for a key removes only that key. Empty text is a valid value. |

### ListCustomersParams

List customers.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Customers per page. Positive integers above the maximum use the maximum. Omitted, empty, zero, negative, or invalid values use 10. |
| `after` | `String` | No | Copy page.next_after from the previous response to move forward. Use the cursor unchanged, keep the same filters, and do not send before as well. |
| `before` | `String` | No | Copy page.previous_before from the previous response to go back one page. Keep the same filters and do not send after as well. |
| `identifier` | `String` | No | Customer's public identifier, with the cus_ prefix. |
| `name` | `String` | No | Search by customer name, with the newest records first. Leave it empty to ignore this filter. |
| `email` | `String` | No | Filter by the customer's complete email address. |
| `document` | `String` | No | Filter by the customer's complete CPF or CNPJ, with or without periods, slash, hyphen, and spaces. |
| `external_reference` | `String` | No | Filter by the customer's current reference in your system, matching the complete value, including case and accents. It can be combined with other filters. After creating or editing the customer, search may take a few seconds to reflect the reference. Preserve the value when navigating by cursor. |

### DeleteCustomersBatchParams

Delete customers in a batch.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `identifiers` | `Array<String or nil>` | Yes | IDs of customers to delete. Repeated IDs do not cause more than one deletion. Invalid IDs and IDs of customers the key cannot access appear in invalid. |

### UpdateCustomerParams

Update an existing customer.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `full_name` | `String or nil` | No | Payer's full name. Omit it to keep the current value; send null or empty text to remove it. |
| `email` | `String or nil` | No | Payer's email address. Updating the email address does not send a message. Omit it to keep the current value; send null or empty text to remove it. |
| `dial_code` | `String or nil` | No | International dialing code. It may be supplied without phone_local. Omit it to keep the current value; send null or empty text to remove it. |
| `phone_local` | `String or nil` | No | Phone number without the dialing code, with or without punctuation. It may be supplied without dial_code. Omit it to keep the current value; send null or empty text to remove it. |
| `zip_code` | `String or nil` | No | Address CEP, with or without a hyphen. Updating the CEP does not fill other address fields. Omit it to keep the current value; send null or empty text to remove it. |
| `street` | `String or nil` | No | Address street. Omit it to keep the current value; send null or empty text to remove it. |
| `street_number` | `String or nil` | No | Address street number. Omit it to keep the current value; send null or empty text to remove it. |
| `complement` | `String or nil` | No | Address complement. Omit it to keep the current value; send null or empty text to remove it. |
| `neigh` | `String or nil` | No | Address neighborhood. Omit it to keep the current value; send null or empty text to remove it. |
| `city` | `String or nil` | No | Address city. Omit it to keep the current value; send null or empty text to remove it. |
| `uf` | `String or nil` | No | State abbreviation, such as SP. Omit it to keep the current value; send null or empty text to remove it. |
| `external_reference` | `String or nil` | No | Customer identifier in your system. Omit it to keep the current reference; send null or empty text to remove it. Use external_reference in the customer list to search for this value. |
| `metadata` | `Hash or nil` | No | Integration data associated with the resource. Supply key and text pairs. Keys are case-sensitive. Omission or {} preserves the data; null removes all pairs, and null for a key removes only that key. Empty text is a valid value. |

### UpdateAutomaticWithdrawalSettingsParams

Update automatic withdrawals.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `enabled` | `Boolean` | No | Enable or disable new withdrawal attempts. Disabling does not cancel withdrawals already requested. |
| `minimum_amount_cents` | `Integer` | No | Minimum balance for attempting a withdrawal, in Brazilian real cents. The amount withdrawn depends on the available balance and remaining Pix limit. |
| `time` | `String` | No | Daily time in HH:mm format, using the São Paulo time zone. |

### GetBalanceForecastParams

Retrieve expected receipts.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `period` | `String` | No | Period of expected receipt dates, using the São Paulo calendar. Includes today and prior days according to the option. Does not query due dates or project upcoming days. |

### CreateRefundParams

Request a refund.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `amount_cents` | `Integer` | Yes | Amount requested for refund, in Brazilian real cents. To refund everything, supply the remaining amount shown by the eligibility query. |
| `description` | `String or nil` | No | Refund request description. You may leave this field empty. |

### ListChargeRefundsParams

List refunds for a charge.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Refunds per page. Values above the maximum use the maximum; omitted, empty, text, zero, or negative values use the default. |
| `after` | `String` | No | Cursor received in page.next_after to move forward. Copy the complete value and keep the same charge. Do not send it together with before. |
| `before` | `String` | No | Cursor received in page.previous_before to move backward. Copy the complete value and keep the same charge. Do not send it together with after. |
| `created_gte` | `Integer` | No | Filter refunds requested at or after this instant, inclusive, in Unix seconds UTC. Uses the request creation date, regardless of completion. Preserve the value when changing pages. |
| `created_lte` | `Integer` | No | Filter refunds requested at or before this instant, inclusive, in Unix seconds UTC. If created_gte is supplied, this value must be greater than or equal to it. |

### GetChargeStatisticsParams

Retrieve charge statistics.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `period` | `String` | No | Query period using the São Paulo calendar. today covers today; last_7_days, last_15_days, and last_30_days include today and prior days. Only those periods are accepted. start_at and end_at are response fields, not custom date filters. |

### CreateCheckoutLogoUploadParams

Prepare a logo upload.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `content_type` | `String` | Yes | File content type: image/png or image/jpeg. |
| `file_size` | `Integer` | Yes | File size in bytes. |
| `width` | `Integer` | Yes | Image width in pixels. |
| `height` | `Integer` | Yes | Image height in pixels. |

### CreateCheckoutFaviconUploadParams

Prepare an icon upload.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `content_type` | `String` | Yes | File content type: image/png or image/jpeg. |
| `file_size` | `Integer` | Yes | File size in bytes. |
| `width` | `Integer` | Yes | Icon width in pixels. Must equal its height. |
| `height` | `Integer` | Yes | Icon height in pixels. Must equal its width. |

### UpdateCheckoutSettingsParams

Update checkout customization.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `support_email` | `String or nil` | No | Support email displayed in checkout. Omission preserves the value; null or empty text removes the contact. |
| `hex_primary_color` | `String` | No | Primary checkout color in #RRGGBB format. Omission preserves the value; null or empty text is not accepted. |
| `hex_secondary_color` | `String` | No | Checkout background color in #RRGGBB format. Omission preserves the value; null or empty text is not accepted. |
| `logo_upload_id` | `String or nil` | No | ID returned when preparing the logo upload. Upload the file before associating it. Omission preserves the current image; null removes it. |
| `favicon_upload_id` | `String or nil` | No | ID returned when preparing the icon upload. Upload the file before associating it. Omission preserves the current image; null removes it. |

### ListDisputesParams

List disputes.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Disputes per page. Invalid values use the default; values above the maximum use the limit. |
| `after` | `String` | No | Cursor from page.next_after in the previous response. Preserve filters and sort order; do not send it together with before. |
| `before` | `String` | No | Cursor from page.previous_before to move backward. Preserve filters and sort order; do not send it together with after. |
| `stage` | `String` | No | Comma-separated case stages: open, in_analysis, refund_in_analysis, closed, cancelled, rejected, or failed. Closed means the review has ended without confirming a favorable decision or refund. |
| `charge_id` | `String` | No | Filter by the linked charge, using its complete public identifier. A valid ID without accessible cases returns an empty list. |
| `disputed_amount_cents` | `Integer` | No | Filter by the exact disputed amount, in Brazilian real cents. It does not represent the amount currently held. |
| `created_gte` | `Integer` | No | Include disputes created at or after this instant, in Unix seconds UTC. The boundary is inclusive. |
| `created_lte` | `Integer` | No | Include disputes created at or before this instant, in Unix seconds UTC. The boundary is inclusive and must be equal to or later than created_gte. |
| `sort_key` | `String` | No | Field used to sort the list: creation date or disputed amount. |
| `sort_order` | `String` | No | Ascending or descending order for the selected field. |

### CreatePaymentLinkParams

Create or retrieve a payment link.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `charge_id` | `String` | Yes | Identifier of the existing charge. The link uses that charge's customer, amount, and due date. |
| `success_redirect_url` | `String or nil` | No | HTTPS return URL after confirmed payment. Omission, null, or empty text preserves the existing URL. |
| `cancel_redirect_url` | `String or nil` | No | HTTPS URL for returning to your website. Returning does not cancel the charge. Omission, null, or empty text preserves the existing URL. |
| `payment_method_types` | `Array<Integer> or nil` | No | Allowed methods for the link. Omission preserves the configuration; null removes the custom configuration. A list restricts checkout methods and cannot expand the methods allowed by the charge. |

### ListPaymentLinksParams

List payment links.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Links per page. |
| `after` | `String` | No | Cursor received in page.next_after. Keep the same charge_id filter. |
| `before` | `String` | No | Cursor received in page.previous_before. Do not send it together with after. |
| `charge_id` | `String` | No | Identifier of the charge whose link you want to retrieve. |

### UpdatePaymentLinkParams

Update a payment link.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `is_active` | `Boolean` | No | Send false to pause checkout and true to reactivate the same URL. Omission preserves the current state. Pausing does not cancel an issued Pix or boleto or extend the due date. |
| `success_redirect_url` | `String or nil` | No | HTTPS return URL after confirmed payment. Omission, null, or empty text preserves the existing URL. To remove it, set clear_success_redirect_url to true without supplying a nonempty URL. |
| `cancel_redirect_url` | `String or nil` | No | HTTPS URL for returning to your website. Returning does not cancel the charge. Omission, null, or empty text preserves the existing URL. To remove it, set clear_cancel_redirect_url to true without supplying a nonempty URL. |
| `clear_success_redirect_url` | `Boolean` | No | Send true to remove the return destination after payment. False or omission does not request removal. Do not send true with a nonempty success_redirect_url. |
| `clear_cancel_redirect_url` | `Boolean` | No | Send true to remove the return destination for your website. False or omission does not request removal. Do not send true with a nonempty cancel_redirect_url. |
| `payment_method_types` | `Array<Integer> or nil` | No | Allowed methods for the link. Omission preserves the configuration; null removes the custom configuration. A list restricts checkout methods and cannot expand the methods allowed by the charge. |

### ListRefundsParams

List refunds.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Refunds per page. Values above the maximum use the maximum; omitted, empty, text, zero, or negative values use the default. |
| `after` | `String` | No | Cursor received in page.next_after to move forward in this list. Copy the complete value. Do not use a charge-specific list cursor or send it together with before. |
| `before` | `String` | No | Cursor received in page.previous_before to move backward in this list. Copy the complete value. Do not use a charge-specific list cursor or send it together with after. |
| `created_gte` | `Integer` | No | Filter refunds requested at or after this instant, inclusive, in Unix seconds UTC. Uses the request creation date, regardless of completion. Preserve the value when changing pages. |
| `created_lte` | `Integer` | No | Filter refunds requested at or before this instant, inclusive, in Unix seconds UTC. If created_gte is supplied, this value must be greater than or equal to it. |

### ConfigureSimulationScenarioParams

Prepare a scenario.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `action` | `String` | Yes | Action to test: pix_issuance for Pix issuance, boleto_issuance for boleto issuance, or cancellation for cancellation. For cancellation, keep the charge open with Pix or boleto already issued, without confirming payment. |
| `outcome` | `String` | Yes | Action result: pending leaves confirmation open; failed presents a failure. |

### ResolveSimulationScenarioParams

Resolve a pending scenario.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `action` | `String` | Yes | Action to test: pix_issuance for Pix issuance, boleto_issuance for boleto issuance, or cancellation for cancellation. |
| `outcome` | `String` | Yes | Result for the pending action: completed finishes the action; failed confirms failure. |

### IssueSimulationPaymentParams

Issue a test payment.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `payment_method` | `Integer` | Yes | Method to issue: 1 for Pix or 2 for boleto. It must be enabled on the charge. |

### CreateSimulationRefundParams

Simulate a pending refund.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `amount_cents` | `Integer` | Yes | Amount requested for refund, in Brazilian real cents. To refund everything, supply the remaining amount shown by the eligibility query. |
| `description` | `String or nil` | No | Refund request description. You may leave this field empty. |

### ListStatementsParams

Retrieve statements.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Entries per page. |
| `after` | `String` | No | Cursor received in page.next_after to move forward. Keep the same filters and sort order. Use only after or before. |
| `before` | `String` | No | Cursor received in page.previous_before to move backward. Keep the same filters and sort order. Use only after or before. |
| `statement_type` | `String` | No | Comma-separated entry types: 1 receipt of funds; 2 fee; 3 service fee; 4 withdrawal; 5 refund; 6 partial refund; 7 adjustment credit; 8 adjustment debit; 9 hold; 10 release. |
| `reference_id` | `String` | No | Identifier of the charge, dispute, withdrawal, or adjustment associated with the entry. Use the complete ID returned by Raims. |
| `created_gte` | `Integer` | No | Inclusive start of the period, in Unix seconds UTC. The filter uses the entry timestamp. |
| `created_lte` | `Integer` | No | Inclusive end of the period, in Unix seconds UTC. The supplied instant is the exact boundary; fractions later than the supplied second are outside the period. |
| `sort_order` | `String` | No | Entry order by date: desc shows the newest first; asc shows the oldest first. |

### SetWebhookPauseParams

Pause or resume deliveries.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `is_paused` | `Boolean` | Yes | Send true to pause deliveries or false to resume them. Repeating the same value preserves the state and pause timestamp. |

### ListWebhooksParams

List webhooks.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Records per page. The response reports the effective size in page.page_size. |
| `after` | `String` | No | To move forward, copy page.next_after from the previous response. Use only after or before. |
| `before` | `String` | No | To move backward, copy page.previous_before from the previous response. Use only after or before. |

### CreateWebhookParams

Create a webhook.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `name` | `String` | Yes | Name identifying the destination. |
| `url` | `String` | Yes | HTTPS URL receiving events. Use the default port 443 and a public address outside Raims. |
| `events` | `Array<String>` | Yes | Event codes this destination should receive. Consult the available event catalog. |
| `is_active` | `Boolean` | No | Set whether the destination can receive events after registration. |

### UpdateWebhookParams

Update a webhook.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `name` | `String` | No | New webhook name. |
| `url` | `String` | No | New HTTPS URL receiving events, on the default port 443. |
| `events` | `Array<String>` | No | Complete list of events the destination should receive. Replaces the previous selection. |
| `is_active` | `Boolean` | No | Use true to allow deliveries or false to disable the destination. |

### RotateWebhookSecretParams

Rotate the signing secret.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `grace_period_seconds` | `Integer` | No | Period during which the previous secret can continue signing deliveries. Zero generates a new signature and ends the validity of previous secrets, including during an active transition. Requests already authorized or in progress may arrive with the previous signature. |

### ListWithdrawalDestinationsParams

List withdrawal destinations.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Records considered for the page. The list may contain fewer destinations and still indicate a next page; continue while page.has_next is true. |
| `after` | `String` | No | Cursor received in page.next_after to move forward. Copy the entire value and keep the same API key. Do not send it together with before. |
| `before` | `String` | No | Cursor received in page.previous_before to move backward. Copy the entire value and keep the same API key. Do not send it together with after. |

### CreateWithdrawalParams

Request a withdrawal.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `amount_cents` | `Integer` | Yes | Total amount to withdraw, in Brazilian real cents, including the fee. Consult withdrawal conditions to check the balance, fee, and limits before requesting. |
| `expected_destination_id` | `String or nil` | No | ID of the account's own destination that must remain selected as the default. Copy the id returned when retrieving destinations. If the destination changes or becomes invalid, the withdrawal is rejected. Omission or null uses the current default destination. |

### ListWithdrawalsParams

List withdrawals.

| Field | Ruby value | Required | Description |
| --- | --- | --- | --- |
| `page_size` | `Integer` | No | Withdrawals per page. |
| `after` | `String` | No | next_after cursor returned on the previous page. Keep the same filters and query sort order. |
| `before` | `String` | No | previous_before cursor returned on the next page. Keep the same filters and query sort order. |
| `status` | `String` | No | Filter by one or more comma-separated states: PENDING, PROCESSING, COMPLETED, FAILED, or CANCELED. |
| `requested_gte` | `Integer` | No | Return withdrawals requested at or after this instant, inclusive. Supply Unix seconds UTC. |
| `requested_lte` | `Integer` | No | Return withdrawals requested at or before this instant, inclusive. Supply Unix seconds UTC. |
| `sort_order` | `String` | No | Sort by request date: desc shows the newest first; asc shows the oldest first. |

## Named public values

Constants in `Raims::EnumValues` come from the public contract's enums. Numeric values receive names only when the contract publishes explicit labels. String constants are frozen.

| Constant | Value |
| --- | --- |
| `ACCOUNT_CONTEXT_AMOUNT_UNIT_CENTS` | `cents` |
| `ACCOUNT_CONTEXT_BUSINESS_TIMEZONE_AMERICA_SAO_PAULO` | `America/Sao_Paulo` |
| `ACCOUNT_CONTEXT_COMPANY_STATUS_ACTIVE` | `active` |
| `ACCOUNT_CONTEXT_COMPANY_STATUS_LIMITED` | `limited` |
| `ACCOUNT_CONTEXT_COMPANY_STATUS_PENDING` | `pending` |
| `ACCOUNT_CONTEXT_CURRENCY_BRL` | `BRL` |
| `ACCOUNT_CONTEXT_DATA_ENVIRONMENT_PRODUCTION` | `production` |
| `ACCOUNT_CONTEXT_DATA_ENVIRONMENT_SANDBOX` | `sandbox` |
| `ACCOUNT_CONTEXT_TIMESTAMP_UNIT_UNIX_SECONDS` | `unix_seconds` |
| `BALANCE_FORECAST_PERIOD_LAST_15_DAYS` | `last_15_days` |
| `BALANCE_FORECAST_PERIOD_LAST_30_DAYS` | `last_30_days` |
| `BALANCE_FORECAST_PERIOD_LAST_7_DAYS` | `last_7_days` |
| `BALANCE_FORECAST_PERIOD_TODAY` | `today` |
| `CHARGE_CREATED_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `CHARGE_CREATED_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `CHARGE_LIST_ITEM_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `CHARGE_LIST_ITEM_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_PAYMENT_STATUS_AWAITING_PAYMENT` | `awaiting_payment` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_PAYMENT_STATUS_COMPENSATED` | `compensated` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_PAYMENT_STATUS_SETTLED` | `settled` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_STATUS_AVAILABLE` | `available` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_STATUS_FAILED` | `failed` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_STATUS_NOT_GENERATED` | `not_generated` |
| `CHARGE_PAYMENT_INFORMATION_BOLETO_STATUS_PENDING` | `pending` |
| `CHARGE_PAYMENT_INFORMATION_PIX_STATUS_AVAILABLE` | `available` |
| `CHARGE_PAYMENT_INFORMATION_PIX_STATUS_FAILED` | `failed` |
| `CHARGE_PAYMENT_INFORMATION_PIX_STATUS_NOT_GENERATED` | `not_generated` |
| `CHARGE_PAYMENT_INFORMATION_PIX_STATUS_PENDING` | `pending` |
| `CHARGE_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `CHARGE_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `CHARGE_SCENARIO_ACTION_BOLETO_ISSUANCE` | `boleto_issuance` |
| `CHARGE_SCENARIO_ACTION_CANCELLATION` | `cancellation` |
| `CHARGE_SCENARIO_ACTION_PIX_ISSUANCE` | `pix_issuance` |
| `CHARGE_SCENARIO_OUTCOME_COMPLETED` | `completed` |
| `CHARGE_SCENARIO_OUTCOME_FAILED` | `failed` |
| `CHARGE_SCENARIO_OUTCOME_PENDING` | `pending` |
| `CHARGE_SCENARIO_REQUEST_ACTION_BOLETO_ISSUANCE` | `boleto_issuance` |
| `CHARGE_SCENARIO_REQUEST_ACTION_CANCELLATION` | `cancellation` |
| `CHARGE_SCENARIO_REQUEST_ACTION_PIX_ISSUANCE` | `pix_issuance` |
| `CHARGE_SCENARIO_REQUEST_OUTCOME_FAILED` | `failed` |
| `CHARGE_SCENARIO_REQUEST_OUTCOME_PENDING` | `pending` |
| `CHARGE_SCENARIO_STATE_COMPLETED` | `completed` |
| `CHARGE_SCENARIO_STATE_CONFIGURED` | `configured` |
| `CHARGE_SCENARIO_STATE_FAILED` | `failed` |
| `CHARGE_SCENARIO_STATE_PENDING` | `pending` |
| `CHARGE_STATISTICS_PERIOD_LAST_15_DAYS` | `last_15_days` |
| `CHARGE_STATISTICS_PERIOD_LAST_30_DAYS` | `last_30_days` |
| `CHARGE_STATISTICS_PERIOD_LAST_7_DAYS` | `last_7_days` |
| `CHARGE_STATISTICS_PERIOD_TODAY` | `today` |
| `CHECKOUT_ASSET_ERROR_CODE_CHECKOUT_ASSET_INVALID_IMAGE` | `CHECKOUT_ASSET_INVALID_IMAGE` |
| `CHECKOUT_ASSET_ERROR_CODE_CHECKOUT_ASSET_PROCESSING_FAILED` | `CHECKOUT_ASSET_PROCESSING_FAILED` |
| `CHECKOUT_ASSET_ERROR_CODE_CHECKOUT_ASSET_UPLOAD_NOT_FOUND` | `CHECKOUT_ASSET_UPLOAD_NOT_FOUND` |
| `CHECKOUT_ASSET_STATUS_ABSENT` | `absent` |
| `CHECKOUT_ASSET_STATUS_FAILED` | `failed` |
| `CHECKOUT_ASSET_STATUS_PENDING` | `pending` |
| `CHECKOUT_ASSET_STATUS_READY` | `ready` |
| `CHECKOUT_ASSET_UPLOAD_CONTENT_TYPE_IMAGE_JPEG` | `image/jpeg` |
| `CHECKOUT_ASSET_UPLOAD_CONTENT_TYPE_IMAGE_PNG` | `image/png` |
| `CREATE_CHARGE_REQUEST_PAYMENT_METHOD_BOLETO` | `2` |
| `CREATE_CHARGE_REQUEST_PAYMENT_METHOD_INDEFINIDO` | `0` |
| `CREATE_CHARGE_REQUEST_PAYMENT_METHOD_PIX` | `1` |
| `CREATE_CHARGE_REQUEST_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `CREATE_CHARGE_REQUEST_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `CREATE_CHECKOUT_FAVICON_UPLOAD_REQUEST_CONTENT_TYPE_IMAGE_JPEG` | `image/jpeg` |
| `CREATE_CHECKOUT_FAVICON_UPLOAD_REQUEST_CONTENT_TYPE_IMAGE_PNG` | `image/png` |
| `CREATE_CHECKOUT_LOGO_UPLOAD_REQUEST_CONTENT_TYPE_IMAGE_JPEG` | `image/jpeg` |
| `CREATE_CHECKOUT_LOGO_UPLOAD_REQUEST_CONTENT_TYPE_IMAGE_PNG` | `image/png` |
| `CREATE_PAYMENT_LINK_REQUEST_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `CREATE_PAYMENT_LINK_REQUEST_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_CHARGE_CANCELED` | `charge.canceled` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_CHARGE_CREATED` | `charge.created` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_CHARGE_FAILED` | `charge.failed` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_CHARGE_PAID` | `charge.paid` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_REFUND_COMPLETED` | `refund.completed` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_REFUND_FAILED` | `refund.failed` |
| `CREATE_WEBHOOK_REQUEST_EVENTS_ITEM_REFUND_REQUESTED` | `refund.requested` |
| `CUSTOMER_CREATED_TAX_ID_TYPE_CNPJ` | `cnpj` |
| `CUSTOMER_CREATED_TAX_ID_TYPE_CPF` | `cpf` |
| `CUSTOMER_LIST_ITEM_TAX_ID_TYPE_CNPJ` | `cnpj` |
| `CUSTOMER_LIST_ITEM_TAX_ID_TYPE_CPF` | `cpf` |
| `DISPUTE_INFRACTION_RESULT_AGREED` | `agreed` |
| `DISPUTE_INFRACTION_RESULT_DISAGREED` | `disagreed` |
| `DISPUTE_KIND_CHARGEBACK` | `chargeback` |
| `DISPUTE_KIND_MED` | `med` |
| `DISPUTE_LIST_ITEM_KIND_CHARGEBACK` | `chargeback` |
| `DISPUTE_LIST_ITEM_KIND_MED` | `med` |
| `DISPUTE_LIST_ITEM_STAGE_CANCELLED` | `cancelled` |
| `DISPUTE_LIST_ITEM_STAGE_CLOSED` | `closed` |
| `DISPUTE_LIST_ITEM_STAGE_FAILED` | `failed` |
| `DISPUTE_LIST_ITEM_STAGE_IN_ANALYSIS` | `in_analysis` |
| `DISPUTE_LIST_ITEM_STAGE_OPEN` | `open` |
| `DISPUTE_LIST_ITEM_STAGE_REFUND_IN_ANALYSIS` | `refund_in_analysis` |
| `DISPUTE_LIST_ITEM_STAGE_REJECTED` | `rejected` |
| `DISPUTE_REFUND_RESULT_PARTIALLY_ACCEPTED` | `partially_accepted` |
| `DISPUTE_REFUND_RESULT_REJECTED` | `rejected` |
| `DISPUTE_REFUND_RESULT_TOTALLY_ACCEPTED` | `totally_accepted` |
| `DISPUTE_STAGE_CANCELLED` | `cancelled` |
| `DISPUTE_STAGE_CLOSED` | `closed` |
| `DISPUTE_STAGE_FAILED` | `failed` |
| `DISPUTE_STAGE_IN_ANALYSIS` | `in_analysis` |
| `DISPUTE_STAGE_OPEN` | `open` |
| `DISPUTE_STAGE_REFUND_IN_ANALYSIS` | `refund_in_analysis` |
| `DISPUTE_STAGE_REJECTED` | `rejected` |
| `PAYMENT_LINK_DETAILS_EFFECTIVE_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `PAYMENT_LINK_DETAILS_EFFECTIVE_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `PAYMENT_LINK_DETAILS_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `PAYMENT_LINK_DETAILS_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `PAYMENT_LINK_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `PAYMENT_LINK_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_BOLETO_AWAITING_SETTLEMENT` | `BOLETO_AWAITING_SETTLEMENT` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_CHARGE_EXPIRED` | `CHARGE_EXPIRED` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_CHARGE_NOT_OPEN` | `CHARGE_NOT_OPEN` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_PAYMENT_LINK_PAUSED` | `PAYMENT_LINK_PAUSED` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_PAYMENT_METHODS_UNAVAILABLE` | `PAYMENT_METHODS_UNAVAILABLE` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_PIX_CANCELLATION_PENDING` | `PIX_CANCELLATION_PENDING` |
| `PAYMENT_LINK_UNAVAILABLE_REASON_CODE_PIX_CANCELLED` | `PIX_CANCELLED` |
| `REFUND_FAILURE_REASON_CODE_REFUND_FAILURE_REASON_UNAVAILABLE` | `REFUND_FAILURE_REASON_UNAVAILABLE` |
| `REFUND_FAILURE_REASON_CODE_REFUND_NOT_SUBMITTED` | `REFUND_NOT_SUBMITTED` |
| `REFUND_FAILURE_REASON_CODE_REFUND_PROCESSING_FAILED` | `REFUND_PROCESSING_FAILED` |
| `REFUND_FAILURE_REASON_CODE_REFUND_PROCESSING_UNAVAILABLE` | `REFUND_PROCESSING_UNAVAILABLE` |
| `REFUND_FAILURE_REASON_CODE_REFUND_REJECTED` | `REFUND_REJECTED` |
| `REFUND_STATUS_ACCEPTED` | `accepted` |
| `REFUND_STATUS_COMPLETED` | `completed` |
| `REFUND_STATUS_FAILED` | `failed` |
| `REFUND_STATUS_RESERVED` | `reserved` |
| `REFUND_STATUS_UNKNOWN` | `unknown` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_ALREADY_COMPLETED` | `PIX_REFUND_ALREADY_COMPLETED` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_CASHIN_NOT_FOUND` | `PIX_REFUND_CASHIN_NOT_FOUND` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_INSUFFICIENT_BALANCE` | `PIX_REFUND_INSUFFICIENT_BALANCE` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_IN_PROGRESS` | `PIX_REFUND_IN_PROGRESS` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_NOT_AVAILABLE` | `PIX_REFUND_NOT_AVAILABLE` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_PROVIDER_ACCOUNT_NOT_READY` | `PIX_REFUND_PROVIDER_ACCOUNT_NOT_READY` |
| `REFUND_UNAVAILABLE_REASON_CODE_PIX_REFUND_PROVIDER_UNAVAILABLE` | `PIX_REFUND_PROVIDER_UNAVAILABLE` |
| `RESOLVE_CHARGE_SCENARIO_REQUEST_ACTION_BOLETO_ISSUANCE` | `boleto_issuance` |
| `RESOLVE_CHARGE_SCENARIO_REQUEST_ACTION_CANCELLATION` | `cancellation` |
| `RESOLVE_CHARGE_SCENARIO_REQUEST_ACTION_PIX_ISSUANCE` | `pix_issuance` |
| `RESOLVE_CHARGE_SCENARIO_REQUEST_OUTCOME_COMPLETED` | `completed` |
| `RESOLVE_CHARGE_SCENARIO_REQUEST_OUTCOME_FAILED` | `failed` |
| `STATEMENT_REFERENCE_TYPE_AJUSTE` | `4` |
| `STATEMENT_REFERENCE_TYPE_COBRAN_A` | `1` |
| `STATEMENT_REFERENCE_TYPE_CONTESTA_O` | `2` |
| `STATEMENT_REFERENCE_TYPE_MANUAL` | `5` |
| `STATEMENT_REFERENCE_TYPE_SAQUE` | `3` |
| `STATEMENT_REFERENCE_TYPE_SEM_REFER_NCIA` | `nil` |
| `STATEMENT_STATEMENT_TYPE_BLOQUEIO` | `9` |
| `STATEMENT_STATEMENT_TYPE_CR_DITO_POR_AJUSTE` | `7` |
| `STATEMENT_STATEMENT_TYPE_DEVOLU_O` | `5` |
| `STATEMENT_STATEMENT_TYPE_DEVOLU_O_PARCIAL` | `6` |
| `STATEMENT_STATEMENT_TYPE_D_BITO_POR_AJUSTE` | `8` |
| `STATEMENT_STATEMENT_TYPE_LIBERA_O` | `10` |
| `STATEMENT_STATEMENT_TYPE_RECEBIMENTO` | `1` |
| `STATEMENT_STATEMENT_TYPE_SAQUE` | `4` |
| `STATEMENT_STATEMENT_TYPE_TARIFA` | `2` |
| `STATEMENT_STATEMENT_TYPE_TARIFA_DE_SERVI_O` | `3` |
| `UPDATE_PAYMENT_LINK_REQUEST_PAYMENT_METHOD_TYPES_ITEM_BOLETO` | `2` |
| `UPDATE_PAYMENT_LINK_REQUEST_PAYMENT_METHOD_TYPES_ITEM_PIX` | `1` |
| `WEBHOOK_CREATED_DISABLED_REASON_CONTINUOUS_FAILURE` | `continuous_failure` |
| `WEBHOOK_CREATED_DISABLED_REASON_MANUAL` | `manual` |
| `WEBHOOK_DISABLED_REASON_CONTINUOUS_FAILURE` | `continuous_failure` |
| `WEBHOOK_DISABLED_REASON_MANUAL` | `manual` |
| `WEBHOOK_EVENT_TYPE_CODE_CHARGE_CANCELED` | `charge.canceled` |
| `WEBHOOK_EVENT_TYPE_CODE_CHARGE_CREATED` | `charge.created` |
| `WEBHOOK_EVENT_TYPE_CODE_CHARGE_FAILED` | `charge.failed` |
| `WEBHOOK_EVENT_TYPE_CODE_CHARGE_PAID` | `charge.paid` |
| `WEBHOOK_EVENT_TYPE_CODE_REFUND_COMPLETED` | `refund.completed` |
| `WEBHOOK_EVENT_TYPE_CODE_REFUND_FAILED` | `refund.failed` |
| `WEBHOOK_EVENT_TYPE_CODE_REFUND_REQUESTED` | `refund.requested` |
| `WEBHOOK_HEALTH_STATUS_DISABLED` | `disabled` |
| `WEBHOOK_HEALTH_STATUS_FAILING` | `failing` |
| `WEBHOOK_HEALTH_STATUS_HEALTHY` | `healthy` |
| `WEBHOOK_HEALTH_STATUS_UNKNOWN` | `unknown` |
| `WITHDRAWAL_DESTINATION_KEY_TYPE_CNPJ` | `CNPJ` |
| `WITHDRAWAL_DESTINATION_KEY_TYPE_EMAIL` | `EMAIL` |
| `WITHDRAWAL_DESTINATION_KEY_TYPE_EVP` | `EVP` |
| `WITHDRAWAL_DESTINATION_KEY_TYPE_PHONE` | `PHONE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_ABOVE_MAXIMUM_WITHDRAWAL` | `ABOVE_MAXIMUM_WITHDRAWAL` |
| `WITHDRAWAL_FAILURE_REASON_CODE_BANK_ACCOUNT_UNAVAILABLE` | `BANK_ACCOUNT_UNAVAILABLE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_BANK_PROCESSING_FAILURE` | `BANK_PROCESSING_FAILURE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_BANK_TIMEOUT` | `BANK_TIMEOUT` |
| `WITHDRAWAL_FAILURE_REASON_CODE_BANK_UNSUPPORTED` | `BANK_UNSUPPORTED` |
| `WITHDRAWAL_FAILURE_REASON_CODE_BELOW_MINIMUM_WITHDRAWAL` | `BELOW_MINIMUM_WITHDRAWAL` |
| `WITHDRAWAL_FAILURE_REASON_CODE_BLOCKED_BALANCE` | `BLOCKED_BALANCE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_DUPLICATED_REQUEST` | `DUPLICATED_REQUEST` |
| `WITHDRAWAL_FAILURE_REASON_CODE_INSUFFICIENT_BALANCE` | `INSUFFICIENT_BALANCE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_INTERNAL_ERROR` | `INTERNAL_ERROR` |
| `WITHDRAWAL_FAILURE_REASON_CODE_INVALID_ACCOUNT_TYPE` | `INVALID_ACCOUNT_TYPE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_INVALID_BANK_ACCOUNT` | `INVALID_BANK_ACCOUNT` |
| `WITHDRAWAL_FAILURE_REASON_CODE_RISK_POLICY_REJECTED` | `RISK_POLICY_REJECTED` |
| `WITHDRAWAL_FAILURE_REASON_CODE_WITHDRAWAL_FAILURE_REASON_UNAVAILABLE` | `WITHDRAWAL_FAILURE_REASON_UNAVAILABLE` |
| `WITHDRAWAL_FAILURE_REASON_CODE_WITHDRAWAL_LIMIT_REACHED` | `WITHDRAWAL_LIMIT_REACHED` |
| `WITHDRAWAL_FAILURE_REASON_CODE_WITHDRAWAL_TEMPORARILY_UNAVAILABLE` | `WITHDRAWAL_TEMPORARILY_UNAVAILABLE` |
| `WITHDRAWAL_PIX_DESTINATION_KEY_TYPE_CNPJ` | `CNPJ` |
| `WITHDRAWAL_PIX_DESTINATION_KEY_TYPE_EMAIL` | `EMAIL` |
| `WITHDRAWAL_PIX_DESTINATION_KEY_TYPE_EVP` | `EVP` |
| `WITHDRAWAL_PIX_DESTINATION_KEY_TYPE_PHONE` | `PHONE` |
| `WITHDRAWAL_STATUS_CANCELED` | `CANCELED` |
| `WITHDRAWAL_STATUS_COMPLETED` | `COMPLETED` |
| `WITHDRAWAL_STATUS_FAILED` | `FAILED` |
| `WITHDRAWAL_STATUS_PENDING` | `PENDING` |
| `WITHDRAWAL_STATUS_PROCESSING` | `PROCESSING` |
| `WITHDRAWAL_STATUS_UNKNOWN` | `UNKNOWN` |
