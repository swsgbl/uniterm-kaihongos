import os, re
# vmenv.js resolveQemu: find what env var replaces QEMU_DIR
p = r'C:/Users/hongfu/AppData/Roaming/npm/node_modules/@hmharness/cli/node_modules/@hmharness/domain-harmony/dist/vmenv.js'
data = open(p, encoding='utf-8', errors='replace').read()
i = data.find('export function resolveQemu')
print(data[i:i+900])
