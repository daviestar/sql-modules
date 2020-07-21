#!/usr/bin/env node
const path = require('path')
const fs = require('fs')
const { promisify } = require('util')
const parseArgs = require('minimist')
const { joinFiles } = require('topo-files')
const { sqlModules } = require('../src/index')
const writeFile = promisify(fs.writeFile)

async function run(directory, options) {
  try {
    const { files } = await sqlModules(directory, options)
    const output = joinFiles(files)
    if (options.outFile) {
      await writeFileToDisk(options.outFile, output)
    } else {
      console.log(output)
    }
    process.exit(0)
  } catch (err) {
    console.log(err)
  }
}

async function writeFileToDisk(filePath, output) {
  try {
    await writeFile(path.join(process.cwd(), filePath), output)
  } catch (err) {
    console.error(`[topo-files]: Error writing to file "${filePath}" ${err.message}`)
  }
}

const { _: [directory], ...options } = parseArgs(process.argv.slice(2))

// TODO: whitelist of valid options

run(directory, options)
