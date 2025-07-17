const { v4: uuidv4 } = require("uuid");

async function insertStudentRecord(tableClient, student, context) {
    const partitionKey = `group${Math.floor(parseInt(student.ID) / 5) + 1}`;

    const entity = {
        partitionKey,
        rowKey: uuidv4(),
        id: student.ID,
        name: student.Name,
        mark: parseInt(student.Mark),
        grade: student.Grade
    };

    context.log(`📊 Inserting: ${JSON.stringify(entity)}`);
    await tableClient.createEntity(entity);
}

module.exports = { insertStudentRecord };