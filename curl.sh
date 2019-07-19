#!/bin/bash

cd /tmp
rm -rf tmpcurlsitemap.xml 2>/dev/null
curl -s -m 10 https://example.com/sitemap.xml > tmpcurlsitemap.xml && echo "[ INFO ] Sitemap downloaded"

if ! [ -s tmpcurlsitemap.xml ]; then
        echo "[ERROR] Sitemap not available"
        rm -rf tmpcurlsitemap.xml 2>/dev/null
        exit 1
fi

COUNTER=0
OK=0
ERROR=0
TOTAL=0

echo "[ INFO ] Processing..."

for URL in $(while read line; do echo $line | grep "example.com" | cut -f2 -d\> | cut -f1 -d\<; done < tmpcurlsitemap.xml); do
        COUNTER=$((COUNTER+1))
        URL=$( php -r "echo urlencode(\"$URL\");";)
        URL=$(echo $URL | sed 's/%3A/:/g' | sed 's/%2F/\//g')
        TOTAL=$((TOTAL+1))
        if [[ $(curl -s -o /dev/null -w "%{http_code}" -m 5 $URL) -eq 200 ]]; then
                echo "[  OK  ] $URL"
                OK=$((OK+1))
        else
                ERROR=$((ERROR+1))
                echo "[ ERROR ] $URL"
        fi
done

if [[ $COUNTER -eq 0 ]]; then
        echo "[ERROR] No files checked, please verify the domain" >&2
        exit 1
fi

echo "OK: $OK"
echo "ERROR: $ERROR"
echo "TOTAL: $TOTAL"

rm tmpcurlsitemap.xml && echo "[ INFO ] Sitemap removed"

cd $OLDPWD

exit 0
