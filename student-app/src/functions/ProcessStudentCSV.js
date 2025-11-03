const { app } = require('@azure/functions');

app.storageBlob('ProcessStudentCSV', {
    // Use environment variable for container name
    path: `${process.env.CONTAINER_NAME || 'student-files'}/{name}`,
    // Use default AzureWebJobsStorage connection
    connection: 'AzureWebJobsStorage',
    handler: async (blob, context) => {
        context.log("Processing CSV upload...");

        const csvContent = blob.toString("utf8");
        const parse = require("csv-parse/sync").parse;
        const { TableClient, AzureNamedKeyCredential } = require("@azure/data-tables");
        const { v4: uuidv4 } = require("uuid");

        const records = parse(csvContent, { columns: true, skip_empty_lines: true });

        const account = process.env.STORAGE_ACCOUNT_NAME;
        const accountKey = process.env.STORAGE_ACCOUNT_KEY;
        const tableName = process.env.TABLE_NAME || "StudentGrades";

        const credential = new AzureNamedKeyCredential(account, accountKey);
        const client = new TableClient(`https://${account}.table.core.windows.net`, tableName, credential);

        await client.createTable();

        for (const record of records) {
            const entity = {
                partitionKey: "Grades",
                rowKey: uuidv4(),
                Name: record.Name,
                Subject: record.Subject,
                Grade: record.Grade
            };
            await client.createEntity(entity);
        }

        context.log(`✅ Inserted ${records.length} records.`);
    }
});
