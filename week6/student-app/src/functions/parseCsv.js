const { parse } = require('csv-parse/sync');

function parseCsv(csvString) {
    return parse(csvString, {
        columns: true,
        skip_empty_lines: true
    });
}

module.exports = { parseCsv };