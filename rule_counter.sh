printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nListing Access Policy Package Names\n"
mgmt_cli -r true -d $DOMAIN show access-layers limit 500 --format json | jq --raw-output '."access-layers"[] | (.name)'

printf "\nWhat is the Policy Package Name?\n"
read POL_NAME
POL2=$(echo $POL_NAME | tr -d ' ')

mgmt_cli -r true show access-rulebase name "$POL_NAME" details-level full limit 500 --format json use-object-dictionary true |jq '.total' >total.txt

mgmt_cli -r true show access-rulebase name "$POL_NAME" details-level full limit 500 --format json use-object-dictionary true |jq '.rulebase[]| select(."inline-layer" == null|not) | ."inline-layer"' >inlinelayers.txt

for line in $(cat inlinelayers.txt) ;
do
    mgmt_cli -r true show access-rulebase uid $line details-level full limit 500 --format json use-object-dictionary true |jq '.total' >>total.txt
done

printf "\nTotal Number of Rules includeing Layers\n"
awk '{ sum += $1 } END { print sum }' total.txt

rm total.txt
