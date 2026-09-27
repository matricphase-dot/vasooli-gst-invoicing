/// Named message-central channels. Every invoice mutation anywhere in the
/// app posts the updated row here; the `watchInvoices` endpoint streams from
/// the same channel, which is how every open device stays live.
const String invoicesUpdatesChannel = 'invoices:updates';
