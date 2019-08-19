@echo off
Echo Please wait until this window closes (~10 seconds)...
>> network-test-results.txt (
echo ==START==IPCONFIG=======================================
ipconfig /all
echo ==PING GATEWAY==========================================
for /f "tokens=2 delims=:" %%g in ('netsh interface ip show address ^| findstr "Default Gateway"') do ping %%g -n 2 -w 800
echo ==NSLOOKUP==============================================
nslookup google.com
echo -----------------------------------------
ping 8.8.8.8 -n 2 -w 800
nslookup google.com 8.8.8.8
echo -----------------------------------------
ping 1.1.1.1 -n 2 -w 800
nslookup google.com 1.1.1.1
echo ========================================================
)
start "" "network-test-results.txt"