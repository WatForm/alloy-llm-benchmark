# alloy-llm-benchmark

Scripts for running an Alloy benchmark workflow:
1. generate Alloy models from English descriptions,
2. score generated models against reference models and known instances.

## 1) Setup

### Python environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install openai
```

### API key setup

This repository expects your OpenAI key in:

```text
./secret/key
```

Create the file and paste only the raw key value into it.

## 2) Java requirements (for scoring)

Scoring uses three Java tools:
1. `scoring/alloy-diff.jar` (Java 17)
2. `scoring/org.alloytools.alloy.dist-6.2.0.jar` (Java 17)
3. `scoring/CompoSAT.jar` (Java 8)

The scoring script requires explicit Java homes:
1. `JAVA_HOME_17`
2. `JAVA_HOME_8`

Set these in your shell before running scoring:

```bash
export JAVA_HOME_17="/path/to/jdk-17"
export JAVA_HOME_8="/path/to/jdk-8"
```

Verify both:

```bash
echo "$JAVA_HOME_17"
"$JAVA_HOME_17/bin/java" -version
"$JAVA_HOME_17/bin/javac" -version

echo "$JAVA_HOME_8"
"$JAVA_HOME_8/bin/java" -version
```

Expected major versions:
1. `JAVA_HOME_17/bin/java` reports 17
2. `JAVA_HOME_8/bin/java` reports 1.8 (or 8)

## 3) Benchmark layout

The default run in this repository uses:

```text
benchmark/descriptions/   # input English descriptions (.md)
benchmark/outputs/        # generated Alloy outputs (.als)
benchmark/models/         # reference Alloy models (.als)
benchmark/instances/      # XML instances grouped by model/scope
benchmark/generalInstances/ # exact-scope XML instances grouped by model/scope
```

Prompt scaffolding is read from:

```text
prompts/english-alloy-prefix.txt
prompts/english-alloy-suffix.txt
```

## 4) Generate Alloy outputs from descriptions

Run:

```bash
python3 scripts/main.py benchmark/descriptions benchmark/outputs
```

What this does:
1. reads each `.md` description file,
2. wraps it with the prompt prefix and suffix,
3. calls the LLM in parallel,
4. writes one `.als` output per description into `benchmark/outputs`.

## 5) Score outputs against models and instances

Run:

```bash
python3 scripts/score.py benchmark/outputs benchmark/models benchmark/instances benchmark/generalInstances
```

Optional explicit report path:

```bash
python3 scripts/score.py benchmark/outputs benchmark/models benchmark/instances benchmark/generalInstances benchmark/outputs/scores.txt
```

What this does for each model:
1. checks syntactic validity (`0/1`),
2. runs Ringert/SemDiff implications in both directions for scopes `1..max(composat_max_scope, general_max_scope)`,
3. checks CompoSAT instances from the original model against the output model (`original => output`),
4. checks general instances from the original model against the output model (`original => output`),
5. runs CompoSAT on the output model for scopes `1..composat_max_scope`, then checks those instances against the original model (`output => original`),
6. runs `InstanceGenerator` on the output model for scopes `1..general_max_scope`, then checks those instances against the original model (`output => original`).

Notes:
1. CompoSAT runs in scoring have a `300s` timeout per scope.
2. `InstanceGenerator` runs in scoring also have a `300s` timeout per scope.
3. If a timeout occurs, `scores.txt` includes a clear `TIMEOUT` line listing the timed-out scope(s).
4. Multiple models can be scored in parallel. Control it with `SCORE_MODEL_WORKERS` (default: up to `4`, capped by model count).
5. CompoSAT scopes and general-instance scopes for a single model are each processed sequentially.

Example:

```bash
SCORE_MODEL_WORKERS=3 python3 scripts/score.py benchmark/outputs benchmark/models benchmark/instances benchmark/generalInstances
```

The scoring report is written to:

```text
benchmark/outputs/scores.txt
```

## 6) Model configuration

The OpenAI model is currently set in:

```text
scripts/openAI.py
```

Look for the `model=` argument in `client.chat.completions.create(...)`.
