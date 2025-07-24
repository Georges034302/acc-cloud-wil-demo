const { app } = require('@azure/functions');

app.storageQueue('ProcessTask', {
    queueName: 'taskqueue', // <-- match your queue name
    connection: 'AzureWebJobsStorage', // <-- use your storage connection setting
    handler: (queueItem, context) => {
        context.log('✅ Processing task:', queueItem);
    }
});
