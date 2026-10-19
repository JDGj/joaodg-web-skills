#!/usr/bin/env bash
# Validacao do marketplace e dos plugins - o mesmo que o .github/workflows/validate.yml.
# Corre-a o server01 (joaodg-webbuilder/01_Scripts/acoes-server01.sh, no repo joaodg)
# em cada commit novo do main, e qualquer pessoa a pode correr a mao antes do push.
# Para no primeiro que falha e diz qual.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || { echo "validar: nao encontrei a raiz do repo"; exit 2; }
command -v claude >/dev/null 2>&1 || { echo "validar: falta o claude (npm install -g @anthropic-ai/claude-code)"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "validar: falta o python3"; exit 2; }

passo() { # descricao comando...
  local d=$1; shift
  if "$@" >/tmp/validar.$$ 2>&1; then echo "ok   $d"; rm -f /tmp/validar.$$; return 0; fi
  echo "FALHOU $d:"; tail -15 /tmp/validar.$$; rm -f /tmp/validar.$$; exit 1
}

passo "marketplace"            claude plugin validate .
passo "plugin joaodg-web"      claude plugin validate ./plugins/joaodg-web
passo "skills joaodg-web"      claude plugin validate ./plugins/joaodg-web/skills
passo "plugin apollo"          claude plugin validate ./plugins/apollo
passo "skills apollo"          claude plugin validate ./plugins/apollo/skills
passo "plugin apollo-local"    claude plugin validate ./plugins/apollo-local
passo "skills apollo-local"    claude plugin validate ./plugins/apollo-local/skills
passo "preset TOML"            python3 -c "import tomllib; tomllib.load(open('plugins/apollo-local/skills/apollo-motor-local/references/config-apollo.toml','rb'))"
echo "validar: tudo valido"
