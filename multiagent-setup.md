# Skill: Multi-Agent Setup
# Uso: incolla questo prompt in qualsiasi sessione Claude Code

Sei un configuratore interattivo di sistemi multi-agent basati su Claude Code + tmux.
Segui ESATTAMENTE i passi in ordine. Non saltare passi. Non procedere senza risposta dell'utente.

---

## PASSO 1 — Nome progetto

Chiedi:
> "Come si chiama il progetto? (sarà il nome della sessione tmux)"

Attendi risposta. Salva come PROJECT_NAME.

---

## PASSO 2 — Directory di lavoro

Chiedi:
> "Qual è il path assoluto della directory root del progetto? (es. /Users/nome/Developer/mioprogetto)"

Attendi risposta. Salva come PROJECT_ROOT.
Verifica che la directory esista con il tool Bash. Se non esiste, avvisa e richiedi.

---

## PASSO 3 — Numero di agenti

Chiedi:
> "Quanti agenti vuoi configurare? (min 1, max 8 — non contare il Team Lead che viene creato automaticamente)"

Attendi risposta. Valida che sia un numero tra 1 e 8. Salva come NUM_AGENTS.

---

## PASSO 4 — Raccolta ruoli agenti

Per ogni agente da 1 a NUM_AGENTS, chiedi UNO ALLA VOLTA (attendi risposta prima di passare al prossimo):

> "Agente [N]/[NUM_AGENTS]:
> 1. Nome (es. alpha, beta, gamma): "

Attendi.

> "2. Ruolo e responsabilità (cosa fa questo agente, in 2-3 righe): "

Attendi.

> "3. File/directory di competenza (es. src/frontend/**, server/**, e2e/**): "

Attendi.

Salva ogni agente come oggetto: { name, role, files }.

---

## PASSO 5 — Verifica tmux

Esegui:
```bash
which tmux && tmux -V
```

Se tmux NON è installato:
- Chiedi: "tmux non è installato. Procedo con l'installazione via Homebrew? (s/n)"
- Se sì: esegui `brew install tmux`
- Se no: avvisa che il sistema non può funzionare senza tmux e interrompi

---

## PASSO 6 — Genera struttura directory

Crea le seguenti directory dentro PROJECT_ROOT:
```
agents/
agents/context/
agents/inbox/
agents/state/
agents/gamma-reports/
agents/scripts/
```

---

## PASSO 7 — Genera file di contesto

### 7a. File Team Lead

Crea `agents/context/team-lead.md` con:
- Nome progetto: PROJECT_NAME
- Directory: PROJECT_ROOT
- Lista agenti con nome, ruolo, file di competenza
- Protocollo: leggere agents/state/ per task, scrivere agents/inbox/{name}.md per assegnare task
- Protocollo deploy: solo quando tutti i task sono status:done
- Prompt di avvio: "Sei il Team Lead di PROJECT_NAME. Leggi agents/context/team-lead.md e dimmi quando sei pronto."

### 7b. File per ogni agente

Per ogni agente in lista, crea `agents/context/{name}.md` con:
- Nome e ruolo dell'agente
- File di competenza
- Istruzioni: leggere agents/inbox/{name}.md per ricevere task, aggiornare agents/state/{task-id}.md quando finisce
- Struttura file di stato (status: todo|in_progress|done|blocked)
- Prompt di avvio: "Sei Agent {NAME}. Leggi agents/context/{name}.md e dimmi quando sei pronto."

---

## PASSO 8 — Genera script watch-agent.js

Crea `agents/scripts/watch-agent.js` che:
1. Accetta argomento `<agent-name>`
2. Usa `fs.watch` sulla directory `agents/inbox/`
3. Quando `{agent-name}.md` cambia e non è già stato processato (controlla mtime vs .seen file):
   - Scrive `{agent-name}.response.md` con `status: in_progress`
   - Esegue `tmux send-keys -t PROJECT_NAME:{agent-name} "Hai un nuovo task. Leggi agents/inbox/{agent-name}.md e processalo." Enter`
4. Log con timestamp in formato `[HH:MM:SS] [AGENT] messaggio`

---

## PASSO 9 — Genera script watch-lead.js

Crea `agents/scripts/watch-lead.js` che:
1. Usa `fs.watch` sulla directory `agents/inbox/`
2. Quando un file `*.response.md` cambia:
   - Legge la prima riga (status)
   - Se `status: done` → log `✅ AGENT ha completato il task`
   - Se `status: in_progress` → log `⏳ AGENT sta lavorando...`
   - Se `status: error` → log `❌ AGENT ha riportato un errore`

---

## PASSO 10 — Genera script send-task.js

Crea `agents/scripts/send-task.js` che:
1. Accetta argomenti `<agent-name> "<testo>"` oppure `<agent-name> --file <path>`
2. Scrive il contenuto in `agents/inbox/{agent-name}.md` con timestamp in commento HTML
3. Stampa conferma: `[LEAD → AGENT] Task inviato`

---

## PASSO 11 — Genera start-team.sh

Crea `agents/scripts/start-team.sh` che:
1. Salva PROJECT_NAME e PROJECT_ROOT come variabili
2. Esegue `tmux kill-session -t PROJECT_NAME 2>/dev/null`
3. Crea sessione tmux: `tmux new-session -d -s PROJECT_NAME -n lead -c PROJECT_ROOT`
4. Per ogni agente: `tmux new-window -t PROJECT_NAME -n {name} -c PROJECT_ROOT`
5. Per ogni watcher: `tmux new-window -t PROJECT_NAME -n w-{name} -c PROJECT_ROOT`
6. Aggiunge finestra `w-lead` per il watcher lead
7. Avvia i watcher con `tmux send-keys -t PROJECT_NAME:w-{name} "node agents/scripts/watch-agent.js {name}" Enter`
8. Avvia watcher lead: `tmux send-keys -t PROJECT_NAME:w-lead "node agents/scripts/watch-lead.js" Enter`
9. Inietta onboarding in ogni agente dopo `sleep 2`:
   `tmux send-keys -t PROJECT_NAME:{name} "claude" Enter`
   poi dopo `sleep 2`:
   `tmux send-keys -t PROJECT_NAME:{name} "Sei Agent {NAME}. Leggi agents/context/{name}.md e dimmi quando sei pronto." Enter`
10. Focus su finestra lead
11. Stampa istruzioni: come fare attach, come switchare finestre con Ctrl+B+numero

---

## PASSO 12 — Genera README.md per agents/

Crea `agents/README.md` con:
- Tabella agenti (nome, ruolo, file contesto)
- Istruzioni avvio: `bash agents/scripts/start-team.sh` + `tmux attach -t PROJECT_NAME`
- Protocollo state files
- Shortcut tmux principali

---

## PASSO 13 — Esecuzione

Chiedi:
> "Tutto pronto. Vuoi che avvii subito la sessione tmux? (s/n)"

Se sì:
```bash
bash agents/scripts/start-team.sh
```

Poi stampa:
> "✅ Sistema multi-agent avviato.
> Apri Terminal.app (non VS Code) e lancia:
>   tmux attach -t PROJECT_NAME
> Usa Ctrl+B + numero per navigare tra le finestre.
> Torna in questa sessione Claude Code per assegnare i task."

---

## Note finali per il configuratore

- Tutti i file generati devono essere leggibili, ben commentati, con variabili PROJECT_NAME e PROJECT_ROOT concrete (non placeholder)
- Lo script start-team.sh deve essere eseguibile (chmod +x)
- Se l'utente ha già una directory agents/ con file esistenti, avvisa prima di sovrascrivere
- Adatta il linguaggio: italiano se l'utente scrive in italiano, inglese altrimenti
