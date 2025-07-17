const { parseCsv } = require("./parseCsv");
const { getTableClient } = require("./tableClient");
const { insertStudentRecord } = require("./insertStudent");

module.exports = async function (context, myBlob) {
    context.log("📂 Function triggered by CSV upload");

    const records = parseCsv(myBlob.toString("utf8"));
    const tableClient = await getTableClient("StudentGrades");

    for (const student of records) {
        await insertStudentRecord(tableClient, student, context);
    }

    context.log("✅ All records inserted.");
};