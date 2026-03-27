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

Scoring uses Java tools:
1. `scoring/alloy-diff.jar`
2. `scoring/org.alloytools.alloy.dist-6.2.0.jar`

Make sure `java` and `javac` are available in your shell.

Quick check:

```bash
java -version
javac -version
```

## 3) Benchmark layout

The default run in this repository uses:

```text
benchmark/descriptions/   # input English descriptions (.md)
benchmark/outputs/        # generated Alloy outputs (.als)
benchmark/models/         # reference Alloy models (.als)
benchmark/instances/      # XML instances grouped by model/scope
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
python3 scripts/score.py benchmark/outputs benchmark/models benchmark/instances
```

What this does for each model:
1. checks syntactic validity (`0/1`),
2. runs SemDiff in both directions for each available scope (`0/2` per scope),
3. validates each XML instance with `InstanceChecker.java` (`0/N` per scope).

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
