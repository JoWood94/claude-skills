#!/usr/bin/env node
/**
 * watch-lead.js — Watcher per il Team Lead
 *
 * - Guarda agents/inbox/*.response.md per stato iniezione prompt
 * - Guarda agents/state/*.md per completamento reale dei task
 * - Quando un agente aggiorna uno stato, notifica il Team Lead
 */

const fs   = require('fs');
const path = require('path');

const ROOT  = path.resolve(__dirname, '../..');
const INBOX = path.join(ROOT, 'agents/inbox');
const STATE = path.join(ROOT, 'agents/state');

function log(msg) {
  const ts = new Date().toISOString().slice(11, 19);
  console.log(`[${ts}] [LEAD] ${msg}`);
}

const seenMtimes = {};

function checkDir(dir, fileFilter, handler) {
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir).filter(fileFilter);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const mtime = String(fs.statSync(fullPath).mtimeMs);
    const key = path.join(dir, file);
    if (seenMtimes[key] === mtime) continue;
    seenMtimes[key] = mtime;
    const content = fs.readFileSync(fullPath, 'utf8');
    handler(file, content);
  }
}

function checkInbox() {
  checkDir(INBOX, f => f.endsWith('.response.md'), (file, content) => {
    const statusLine = content.split('\n')[0];
    const agentName = file.replace('.response.md', '').toUpperCase();
    if (statusLine.includes('in_progress')) {
      log(`⏳ ${agentName} sta lavorando...`);
    } else if (statusLine.includes('error')) {
      log(`❌ ${agentName} errore — leggi agents/inbox/${file}`);
    }
  });
}

function checkState() {
  checkDir(STATE, f => f.endsWith('.md'), (file, content) => {
    const lines = content.split('\n');
    const statusLine = lines.find(l => l.startsWith('status:')) || '';
    const agentLine  = lines.find(l => l.startsWith('agent:')) || '';
    const taskLine   = lines.find(l => l.startsWith('task:')) || '';
    const agent = agentLine.replace('agent:', '').trim().toUpperCase();
    const task  = taskLine.replace('task:', '').trim();

    if (statusLine.includes('done')) {
      log(`✅ ${agent} — DONE: ${file}`);
      if (task) log(`   "${task}"`);
    } else if (statusLine.includes('cancelled')) {
      log(`🚫 ${agent} — CANCELLED: ${file}`);
    } else if (statusLine.includes('blocked')) {
      const blockedLine = lines.find(l => l.startsWith('bloccato_da:')) || '';
      log(`🔴 ${agent} — BLOCKED: ${file} — ${blockedLine.replace('bloccato_da:', '').trim()}`);
    } else if (statusLine.includes('in_progress')) {
      log(`⏳ ${agent} — in progress: ${file}`);
    }
  });
}

log('Team Lead watcher avviato');
log('Ascolto: agents/inbox/*.response.md + agents/state/*.md');
log('Premi Ctrl+C per fermare.');

checkInbox();
checkState();

fs.watch(INBOX, (_, filename) => {
  if (filename && filename.endsWith('.response.md')) {
    setTimeout(checkInbox, 200);
  }
});

fs.watch(STATE, (_, filename) => {
  if (filename && filename.endsWith('.md')) {
    setTimeout(checkState, 200);
  }
});
