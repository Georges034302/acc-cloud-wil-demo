import logging
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="ProcessOrder")
@app.queue_trigger(arg_name="msg", queue_name="orders", connection="AzureWebJobsStorage")
def process_order(msg: func.QueueMessage):
    logging.warning("🚨 Triggered: ProcessOrder function")

    try:
        body_raw = msg.get_body()
        body = body_raw.decode("utf-8")
        logging.info(f"✅ Processing order: {body}")
    except UnicodeDecodeError:
        logging.error(f"❌ Could not decode message body: {body_raw!r}", exc_info=True)
    except Exception as e:
        logging.error(f"❌ Unexpected error: {str(e)}", exc_info=True)
        raise