const path = require("path");
const test = require("ava");
const { Pool } = require("pg");
const { sqlModules } = require("../src");
const { postgresErrorOutput } = require("../src/sql-modules");

const pool = new Pool({
  connectionString: "postgres://postgres:postgres@localhost:5432/sql_modules"
});

test("formats postgres error", async t => {
  const dir = path.join(__dirname, "fixtures/syntaxError");
  const { files, query } = await sqlModules(dir);
  try {
    await pool.query(query);
  } catch (err) {
    const output = postgresErrorOutput(err, query, files);
    // console.log(output);
    t.snapshot(output);
  }
});
