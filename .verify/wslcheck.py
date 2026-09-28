import subprocess
r = subprocess.run(['wsl', '-d', 'Ubuntu', '--', 'bash', '-c', "pgrep -a sshd; echo ---; ss -tln | grep -E ':2222|:5432|:6379' || true"], capture_output=True, text=True, timeout=30)
print(r.stdout)
print(r.stderr[:300])
