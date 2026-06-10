# Architecture Overview

Cron-Mbt is designed with a compiler-like pipeline to ensure zero-allocation parsing and fast evaluation.

## 1. Lexical Scanner
The lexer (`lexer.mbt`) reads the raw string expression and converts it into a token stream. It handles numerical bounds checking and operator identification (e.g., `-`, `/`, `*`, `,`).

## 2. AST Parser
The parser (`parser.mbt`) constructs an Abstract Syntax Tree (AST) representing the semantic constraints of the cron field.

## 3. Evaluator
The matcher (`matcher.mbt`) and schedule engine (`schedule.mbt`) consume the AST structures to perform runtime checking against timestamps.
