#!/usr/bin/env bash

help() {
   echo "Usage: subsmasher.sh -d example.com -o subdomains.txt"
   echo -e "\t-d Domain Name"
   echo -e "\t-o Output File Name"
   exit 1
}

while getopts "d:o:" option
do
   case "$option" in
      d ) TARGET="$OPTARG" ;;
      o ) OUTPUT="$OPTARG" ;;
      ? ) help ;;
   esac
done

if [ -z "$TARGET" ] || [ -z "$OUTPUT" ]
then
   echo "Target Domain or Output filename is not provided."
   help
fi

OUT_DIR=$(pwd)
TOOLS_DIR=$(pwd)/tools

echo [*] Running Subsmasher : ${TARGET}

cd $TOOLS_DIR/subscraper
echo "[*] Launching SubScraper"
python3 subscraper.py $TARGET -o $OUT_DIR/subscraper.txt &> /dev/null &

cd $TOOLS_DIR/Sublist3r
echo "[*] Launching Sublist3r"
python3 sublist3r.py -d $TARGET -o $OUT_DIR/sublist3r.txt &> /dev/null &

cd $TOOLS_DIR/assetfinder
echo "[*] Launching Assetfinder"
./assetfinder --subs-only $TARGET > $OUT_DIR/assetfinder.txt &

cd $TOOLS_DIR/subfinder
echo "[*] Launching Subfinder"
./subfinder -d $TARGET -all --silent > $OUT_DIR/subfinder.txt & 

cd $TOOLS_DIR/findomain
echo "[*] Launching Findomain"
./findomain -t $TARGET -q > $OUT_DIR/findomain.txt &

echo "[*] Launching Amass"
amass enum -passive -d $TARGET > $OUT_DIR/amass.txt &

echo "[*] Launching Certspotter"
cd $TOOLS_DIR/jq
curl -s "https://api.certspotter.com/v1/issuances?domain=$TARGET&expand=dns_names" | ./jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | grep $TARGET > $OUT_DIR/certspotter.txt &


echo "[*] Launching Crt.sh"
curl -s "https://crt.sh/?q=%.$TARGET" | grep $TARGET | cut -d '>' -f2 | cut -d '<' -f1 | grep -v " " > $OUT_DIR/crtsh.txt &

echo "[*] Waiting until all scripts complete..."
wait

cd $OUT_DIR
ls -l
(cat subscraper.txt sublist3r.txt assetfinder.txt subfinder.txt findomain.txt amass.txt certspotter.txt crtsh.txt | sort -u) > $OUTPUT
rm subscraper.txt sublist3r.txt assetfinder.txt subfinder.txt findomain.txt amass.txt certspotter.txt crtsh.txt

RES=$(cat $OUTPUT | wc -l)
echo -e "\n[+] SubWalker complete with ${RES} results"
echo "[+] Output saved to: $OUT_DIR/$OUTPUT"
exit 0
