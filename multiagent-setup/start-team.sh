#!/bin/bash
# start-team.sh — Avvia tutti gli agenti punto! in una sessione tmux
# Uso: bash agents/scripts/start-team.sh [--safe | --trusted]

SESSION="punto"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# ─── Scelta modalità ─────────────────────────────────────────
if [[ "$1" == "--safe" ]]; then
  MODE="safe"
elif [[ "$1" == "--trusted" ]]; then
  MODE="trusted"
else
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  punto! — Avvio team multi-agent"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  [1] SAFE     — ogni operazione richiede conferma"
  echo "  [2] TRUSTED  — autonomia completa, nessuna conferma"
  echo ""
  read -rp "  Scelta [1/2]: " choice </dev/tty
  echo ""
  case "$choice" in
    2) MODE="trusted" ;;
    *) MODE="safe" ;;
  esac
fi

if [[ "$MODE" == "trusted" ]]; then
  AGENT_CMD="claude --dangerously-skip-permissions"
  echo "  ⚡ Modalità: TRUSTED"
else
  AGENT_CMD="claude"
  echo "  🛡️  Modalità: SAFE"
fi
echo ""

# ─── Verifica tmux ───────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
  echo "❌ tmux non trovato. Installa con: brew install tmux"
  exit 1
fi

# ─── Termina sessione esistente ───────────────────────────────
tmux kill-session -t "$SESSION" 2>/dev/null

# ─── Crea tutte le finestre ───────────────────────────────────
tmux new-session -d -s "$SESSION" -n "lead"   -c "$ROOT" || { echo "❌ Errore tmux new-session. ROOT=$ROOT"; exit 1; }
tmux new-window  -t "$SESSION"   -n "alpha"   -c "$ROOT"
tmux new-window  -t "$SESSION"   -n "beta"    -c "$ROOT"
tmux new-window  -t "$SESSION"   -n "gamma"   -c "$ROOT"
tmux new-window  -t "$SESSION"   -n "w-lead"  -c "$ROOT"
tmux new-window  -t "$SESSION"   -n "w-alpha" -c "$ROOT"
tmux new-window  -t "$SESSION"   -n "w-beta"  -c "$ROOT"
tmux new-window  -t "$SESSION"   -n "w-gamma" -c "$ROOT"

# ─── Avvia watcher (tutti insieme) ───────────────────────────
tmux send-keys -t "$SESSION:w-lead"  "node agents/scripts/watch-lead.js"        Enter
tmux send-keys -t "$SESSION:w-alpha" "node agents/scripts/watch-agent.js alpha" Enter
tmux send-keys -t "$SESSION:w-beta"  "node agents/scripts/watch-agent.js beta"  Enter
tmux send-keys -t "$SESSION:w-gamma" "node agents/scripts/watch-agent.js gamma" Enter

# ─── Avvia Claude in tutti gli agenti (in parallelo) ─────────
sleep 1
tmux send-keys -t "$SESSION:alpha" "$AGENT_CMD" Enter
tmux send-keys -t "$SESSION:beta"  "$AGENT_CMD" Enter
tmux send-keys -t "$SESSION:gamma" "$AGENT_CMD" Enter
tmux send-keys -t "$SESSION:lead"  "claude"     Enter

# ─── In modalità trusted: conferma prompt sicurezza ──────────
# Claude mostra un avviso una tantum — rispondiamo "yes" su tutti
if [[ "$MODE" == "trusted" ]]; then
  sleep 5
  tmux send-keys -t "$SESSION:alpha" "yes" Enter
  tmux send-keys -t "$SESSION:beta"  "yes" Enter
  tmux send-keys -t "$SESSION:gamma" "yes" Enter
fi

# ─── Onboarding (tutti insieme dopo che Claude è partito) ─────
sleep 4
tmux send-keys -t "$SESSION:alpha" "Sei Agent Alpha. Leggi agents/context/alpha.md e dimmi quando sei pronto." Enter
tmux send-keys -t "$SESSION:beta"  "Sei Agent Beta. Leggi agents/context/beta.md e dimmi quando sei pronto."   Enter
tmux send-keys -t "$SESSION:gamma" "Sei Agent Gamma. Leggi agents/context/gamma.md e dimmi quando sei pronto." Enter
tmux send-keys -t "$SESSION:lead"  "Sei il Team Lead di punto!. Leggi agents/context/team-lead.md e dimmi quando sei pronto." Enter

# ─── Focus lead ──────────────────────────────────────────────
tmux select-window -t "$SESSION:lead"

# ─── Istruzioni ──────────────────────────────────────────────
echo "✅ Team '$SESSION' avviato in modalità $(echo $MODE | tr a-z A-Z)"
echo ""
echo "  Apri Terminal.app ed esegui:"
echo "    tmux attach -t $SESSION"
echo ""
echo "  Navigazione (Ctrl+B non funziona in VS Code):"
echo "    Ctrl+B + 0  → lead     Ctrl+B + 4  → w-lead"
echo "    Ctrl+B + 1  → alpha    Ctrl+B + 5  → w-alpha"
echo "    Ctrl+B + 2  → beta     Ctrl+B + 6  → w-beta"
echo "    Ctrl+B + 3  → gamma    Ctrl+B + 7  → w-gamma"
echo "    Ctrl+B + W  → lista    Ctrl+B + D  → esci"
echo ""
if [[ "$MODE" == "safe" ]]; then
  echo "  🛡️  SAFE: approva le operazioni in ogni finestra agente."
else
  echo "  ⚡ TRUSTED: agenti autonomi. Monitora w-lead per notifiche."
fi
echo ""
echo "  Aggancio automatico al Team Lead tra 2 secondi..."
echo "  (Ctrl+B + D per uscire senza chiudere)"
echo ""
sleep 2

# Aggancio automatico alla finestra lead
tmux attach -t "$SESSION:lead"
