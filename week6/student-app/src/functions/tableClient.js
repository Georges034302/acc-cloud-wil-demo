const { TableClient } = require("@azure/data-tables");

async function getTableClient(tableName) {
    const connectionString = process.env.AzureWebJobsStorage;
    const tableClient = TableClient.fromConnectionString(connectionString, tableName);

    try {
        await tableClient.createTable();
    } catch (err) {
        if (err.statusCode !== 409) throw err;
    }

    return tableClient;
}

module.exports = { getTableClient };