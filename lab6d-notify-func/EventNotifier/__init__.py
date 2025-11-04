import os, json, base64, logging, traceback
from azure.communication.email import EmailClient

def main(myQueueItem: str):
    logging.info("=== EventNotifier START ===")
    raw = myQueueItem

    # 🔹 Try to decode Base64 if needed
    try:
        decoded = base64.b64decode(raw).decode("utf-8")
        # verify it's JSON
        json.loads(decoded)
        myQueueItem = decoded
        logging.info("Base64 decoded successfully")
    except Exception:
        logging.info("No base64 decoding needed")

    try:
        data = json.loads(myQueueItem)
    except Exception as e:
        logging.error(f"Invalid JSON: {e}")
        logging.error(traceback.format_exc())
        return

    acs_conn = os.environ.get('ACS_CONNECTION_STRING')
    sender = os.environ.get('EMAIL_SENDER')
    recipient = os.environ.get('EMAIL_RECIPIENT')

    subject = (
        f"✅ SUCCESS in {data.get('service','unknown')}"
        if data.get('level') != 'error'
        else f"🚨 ERROR in {data.get('service','unknown')}"
    )
    body = f"{data.get('message','')}\n\nTimestamp: {__import__('datetime').datetime.utcnow()}"

    try:
        client = EmailClient.from_connection_string(acs_conn)
        message = {
            "senderAddress": sender,
            "recipients": {"to": [{"address": recipient}]},
            "content": {"subject": subject, "plainText": body}
        }
        poller = client.begin_send(message)
        result = poller.result()
        logging.info(f"Email send result: {result}")
    except Exception as e:
        logging.error(f"Email sending failed: {e}")
        logging.error(traceback.format_exc())
