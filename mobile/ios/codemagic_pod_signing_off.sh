#!/usr/bin/env bash
# Codemagic imzasiz iOS build: Podfile post_install icine pod hedeflerinde imza kapatma ekler.
# Bu dosya codemagic.yaml icinden cagrilir; YAML icine Ruby/heredoc gommek parse hatasina yol aciyor.
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f Podfile ]]; then
  echo "Podfile yok; flutter build ios --config-only once once calistirilmali."
  exit 0
fi

if grep -q "CM_DISABLE_POD_SIGNING" Podfile; then
  echo "Podfile zaten Codemagic pod imzasi patch'i iceriyor."
  exit 0
fi

python3 <<'PY'
import pathlib

p = pathlib.Path("Podfile")
t = p.read_text(encoding="utf-8")
needle = "flutter_additional_ios_build_settings(target)"
inject = (
    "\n    # CM_DISABLE_POD_SIGNING — Codemagic imzasiz build\n"
    "    target.build_configurations.each do |config|\n"
    "      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'\n"
    "      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'\n"
    "      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''\n"
    "    end"
)

if needle in t and "CM_DISABLE_POD_SIGNING" not in t:
    p.write_text(t.replace(needle, needle + inject, 1), encoding="utf-8")
    print("OK: Podfile patch uygulandi.")
elif "CM_DISABLE_POD_SIGNING" in t:
    print("OK: Podfile zaten patch'li.")
else:
    print("UYARI: Podfile'da 'flutter_additional_ios_build_settings(target)' bulunamadi; patch atlandi.")
PY
